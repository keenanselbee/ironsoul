#include "pch.h"
#include "papyrus_healthmonitor.h"
#include "papyrus_common.h"
#include "config.h"
#include "menu_blocker.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <random>
#include <thread>

namespace IronSoul::Papyrus::HealthMonitor
{
namespace
{
    struct HealthMonitorState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> token{ 0 };
        std::thread worker;
        bool hpDepletedLatched{ false };
        bool slowmoHeld{ false };
        bool slowmoReleasePending{ false };
        bool slowmoRecovering{ false };
        bool slowmoSfxPlayed{ false };
        double slowmoHoldStartedAtSec{ 0.0 };
        double slowmoReleaseStartAtSec{ 0.0 };
        double slowmoRecoverySeconds{ 0.0 };
        double slowmoRecoverStartAtSec{ 0.0 };
        double slowmoRecoverEndAtSec{ 0.0 };
        double recoveredSinceSec{ 0.0 };
        double lastWallClockSampleSec{ 0.0 };
        double activeGameplayClockSec{ 0.0 };

        ~HealthMonitorState()
        {
            token.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };

    HealthMonitorState g_healthMonitor;

    struct SlowMoSfxState
    {
        std::mutex lock;
        bool initialized{ false };
        bool enabled{ false };
        std::array<RE::BGSSoundDescriptorForm*, 4> descriptors{};
        std::mt19937 rng{ std::random_device{}() };
    };

    SlowMoSfxState g_slowMoSfx;

    static constexpr const char* kPluginName = "Iron Soul - Dead God's Dream.esp";
    static constexpr std::array<RE::FormID, 4> kSlowMoLocalFormIDs{
        0x000216,
        0x000217,
        0x000218,
        0x000219
    };

    static constexpr float kDeathSlowmoMultiplier = 0.3f;
    static constexpr float kDeathSlowmoWatchdogSeconds = 60.0f;
    static constexpr float kRearArmRecoverySeconds = 0.5f;
    static constexpr float kPollSeconds = 0.2f;

    static bool IsGamePausedByMenu()
    {
        auto* ui = RE::UI::GetSingleton();
        return ui && ui->GameIsPaused();
    }

    static double WallSeconds()
    {
        return std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
    }

    static bool SleepCancelable(std::atomic<std::uint64_t>& a_tokenSource, std::uint64_t a_token, std::chrono::duration<float> a_totalSleep)
    {
        constexpr auto kSlice = std::chrono::milliseconds(10);
        const auto endAt = std::chrono::steady_clock::now() + a_totalSleep;

        while (true) {
            if (a_tokenSource.load() != a_token) {
                return false;
            }

            const auto now = std::chrono::steady_clock::now();
            if (now >= endAt) {
                return true;
            }

            const auto remaining = endAt - now;
            const auto waitFor = remaining < kSlice ? remaining : kSlice;
            std::this_thread::sleep_for(waitFor);
        }
    }

    static void QueueSetGlobalTimeMultiplier(float a_multiplier, const char* a_reason, bool a_log = true);

    static void ResetSlowMoStateLocked(bool a_resetSfx = true)
    {
        g_healthMonitor.slowmoHeld = false;
        g_healthMonitor.slowmoReleasePending = false;
        g_healthMonitor.slowmoRecovering = false;
        g_healthMonitor.slowmoHoldStartedAtSec = 0.0;
        g_healthMonitor.slowmoReleaseStartAtSec = 0.0;
        g_healthMonitor.slowmoRecoverySeconds = 0.0;
        g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
        g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
        if (a_resetSfx) {
            g_healthMonitor.slowmoSfxPlayed = false;
        }
    }

    static bool HasSlowMoStateLocked()
    {
        return g_healthMonitor.slowmoHeld || g_healthMonitor.slowmoReleasePending || g_healthMonitor.slowmoRecovering;
    }

    static bool EnsureSlowMoDescriptorsLoaded()
    {
        std::scoped_lock lock(g_slowMoSfx.lock);
        if (g_slowMoSfx.initialized) {
            return g_slowMoSfx.enabled;
        }

        g_slowMoSfx.initialized = true;
        auto* dataHandler = RE::TESDataHandler::GetSingleton();
        if (!dataHandler) {
            logger::warn("DeathSlowMoSFX: TESDataHandler unavailable");
            return false;
        }

        for (std::size_t i = 0; i < kSlowMoLocalFormIDs.size(); ++i) {
            auto* form = dataHandler->LookupForm(kSlowMoLocalFormIDs[i], kPluginName);
            auto* sound = form ? form->As<RE::BGSSoundDescriptorForm>() : nullptr;
            if (!sound) {
                logger::warn("DeathSlowMoSFX: missing descriptor localID=0x{:06X} plugin='{}'", kSlowMoLocalFormIDs[i], kPluginName);
                return false;
            }
            g_slowMoSfx.descriptors[i] = sound;
        }

        g_slowMoSfx.enabled = true;
        if (InfoLoggingEnabled()) {
            logger::info("DeathSlowMoSFX: loaded {} descriptors", g_slowMoSfx.descriptors.size());
        }
        return true;
    }

    static void PlayRandomSlowMoSound()
    {
        if (IronSoul::Config::GetInt("SFX", 1) == 0) {
            return;
        }
        if (IronSoul::Config::GetInt("DeathSlowMoSFX", 1) == 0) {
            return;
        }
        if (!EnsureSlowMoDescriptorsLoaded()) {
            return;
        }

        auto* audioMgr = RE::BSAudioManager::GetSingleton();
        if (!audioMgr) {
            logger::warn("DeathSlowMoSFX: BSAudioManager unavailable");
            return;
        }

        RE::BGSSoundDescriptorForm* descriptor = nullptr;
        {
            std::scoped_lock lock(g_slowMoSfx.lock);
            std::uniform_int_distribution<std::size_t> dist(0, g_slowMoSfx.descriptors.size() - 1);
            descriptor = g_slowMoSfx.descriptors[dist(g_slowMoSfx.rng)];
        }

        if (!descriptor) {
            logger::warn("DeathSlowMoSFX: descriptor cache empty");
            return;
        }

        RE::BSSoundHandle handle{};
        if (!audioMgr->BuildSoundDataFromDescriptor(handle, descriptor, 0x1A)) {
            logger::warn("DeathSlowMoSFX: BuildSoundDataFromDescriptor failed");
            return;
        }
        if (!handle.IsValid()) {
            logger::warn("DeathSlowMoSFX: invalid sound handle");
            return;
        }
        if (!handle.Play()) {
            logger::warn("DeathSlowMoSFX: Play failed");
        }
    }

    // --- Health Monitor Runtime ---
    // ==============================

    static void StopHealthMonitorInternal()
    {
        std::thread oldWorker;
        {
            std::scoped_lock lock(g_healthMonitor.lock);
            g_healthMonitor.token.fetch_add(1);
            g_healthMonitor.hpDepletedLatched = false;
            ResetSlowMoStateLocked();
            g_healthMonitor.recoveredSinceSec = 0.0;
            g_healthMonitor.lastWallClockSampleSec = 0.0;
            g_healthMonitor.activeGameplayClockSec = 0.0;
            if (g_healthMonitor.worker.joinable()) {
                oldWorker = std::move(g_healthMonitor.worker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }
        IronSoul::MenuBlocker::EndHealthDepletedBlock("monitor-stop");
        QueueSetGlobalTimeMultiplier(1.0f, "monitor-stop");
    }

    static void QueueSetGlobalTimeMultiplier(float a_multiplier, const char* a_reason, bool a_log)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (InfoLoggingEnabled()) {
                logger::warn("DeathSlowMo: task interface unavailable (reason={})", a_reason ? a_reason : "unknown");
            }
            return;
        }

        const float mult = a_multiplier;
        const bool infoLog = InfoLoggingEnabled();
        const bool doLog = a_log;
        const std::string reason = a_reason ? a_reason : "unknown";

        task->AddTask([mult, infoLog, doLog, reason]() {
            auto* timer = RE::BSTimer::GetSingleton();
            if (!timer) {
                if (infoLog && doLog) {
                    logger::warn("DeathSlowMo: BSTimer unavailable (reason={})", reason);
                }
                return;
            }

            timer->SetGlobalTimeMultiplier(mult, false);
            if (infoLog && doLog) {
                logger::info("DeathSlowMo: BSTimer SetGlobalTimeMultiplier multiplier={} reason={}", mult, reason);
            }
        });
    }

    static void HoldDeathSlowMoInternal(std::string a_reason)
    {
        if (!DeathSlowMoEnabled()) {
            return;
        }

        const double nowSec = WallSeconds();
        bool shouldApplySlowmo = false;
        bool shouldPlaySfx = false;
        {
            std::scoped_lock lock(g_healthMonitor.lock);
            const bool wasActive = HasSlowMoStateLocked();
            if (!wasActive || g_healthMonitor.slowmoReleasePending || g_healthMonitor.slowmoRecovering) {
                shouldApplySlowmo = true;
                g_healthMonitor.slowmoHoldStartedAtSec = nowSec;
            } else if (g_healthMonitor.slowmoHoldStartedAtSec <= 0.0) {
                g_healthMonitor.slowmoHoldStartedAtSec = nowSec;
            }

            g_healthMonitor.slowmoHeld = true;
            g_healthMonitor.slowmoReleasePending = false;
            g_healthMonitor.slowmoRecovering = false;
            g_healthMonitor.slowmoReleaseStartAtSec = 0.0;
            g_healthMonitor.slowmoRecoverySeconds = 0.0;
            g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
            g_healthMonitor.slowmoRecoverEndAtSec = 0.0;

            if (!g_healthMonitor.slowmoSfxPlayed) {
                g_healthMonitor.slowmoSfxPlayed = true;
                shouldPlaySfx = true;
            }
        }

        if (shouldApplySlowmo) {
            QueueSetGlobalTimeMultiplier(kDeathSlowmoMultiplier, a_reason.empty() ? "hold" : a_reason.c_str());
        }
        if (shouldPlaySfx) {
            PlayRandomSlowMoSound();
        }
    }

    static void ReleaseDeathSlowMoInternal(float a_recoverySeconds, float a_delaySeconds, std::string a_reason)
    {
        const float recoverySeconds = a_recoverySeconds < 0.0f ? 0.0f : a_recoverySeconds;
        const float delaySeconds = a_delaySeconds < 0.0f ? 0.0f : a_delaySeconds;
        const double nowSec = WallSeconds();
        bool shouldClearNow = false;
        bool hadState = false;
        {
            std::scoped_lock lock(g_healthMonitor.lock);
            hadState = HasSlowMoStateLocked();
            if (!hadState) {
                return;
            }

            if (delaySeconds <= 0.0f && recoverySeconds <= 0.0f) {
                ResetSlowMoStateLocked();
                shouldClearNow = true;
            } else if (delaySeconds <= 0.0f) {
                g_healthMonitor.slowmoHeld = false;
                g_healthMonitor.slowmoReleasePending = false;
                g_healthMonitor.slowmoRecovering = true;
                g_healthMonitor.slowmoReleaseStartAtSec = 0.0;
                g_healthMonitor.slowmoRecoverySeconds = recoverySeconds;
                g_healthMonitor.slowmoRecoverStartAtSec = nowSec;
                g_healthMonitor.slowmoRecoverEndAtSec = nowSec + recoverySeconds;
            } else {
                g_healthMonitor.slowmoHeld = true;
                g_healthMonitor.slowmoReleasePending = true;
                g_healthMonitor.slowmoRecovering = false;
                g_healthMonitor.slowmoReleaseStartAtSec = nowSec + delaySeconds;
                g_healthMonitor.slowmoRecoverySeconds = recoverySeconds;
                g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
                g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info("DeathSlowMo: release scheduled recoverySeconds={} delaySeconds={} reason={}", recoverySeconds, delaySeconds, a_reason.empty() ? "release" : a_reason);
        }
        if (shouldClearNow) {
            QueueSetGlobalTimeMultiplier(1.0f, a_reason.empty() ? "release" : a_reason.c_str());
        }
    }

    static void ClearDeathSlowMoInternal(std::string a_reason)
    {
        bool hadState = false;
        {
            std::scoped_lock lock(g_healthMonitor.lock);
            hadState = HasSlowMoStateLocked() || g_healthMonitor.slowmoSfxPlayed;
            ResetSlowMoStateLocked();
        }

        if (hadState) {
            QueueSetGlobalTimeMultiplier(1.0f, a_reason.empty() ? "clear" : a_reason.c_str());
        }
    }

    static void StartHealthMonitorInternal()
    {
        std::thread oldWorker;
        std::uint64_t myToken = 0;

        {
            std::scoped_lock lock(g_healthMonitor.lock);
            if (g_healthMonitor.worker.joinable()) {
                oldWorker = std::move(g_healthMonitor.worker);
            }
            myToken = g_healthMonitor.token.fetch_add(1) + 1;
            g_healthMonitor.hpDepletedLatched = false;
            ResetSlowMoStateLocked();
            g_healthMonitor.recoveredSinceSec = 0.0;
            g_healthMonitor.lastWallClockSampleSec = 0.0;
            g_healthMonitor.activeGameplayClockSec = 0.0;

            g_healthMonitor.worker = std::thread([myToken]() {
                while (g_healthMonitor.token.load() == myToken) {
                    auto* task = SKSE::GetTaskInterface();
                    if (!task) {
                        if (!SleepCancelable(g_healthMonitor.token, myToken, std::chrono::duration<float>(kPollSeconds))) {
                            return;
                        }
                        continue;
                    }

                    task->AddTask([myToken]() {
                        if (g_healthMonitor.token.load() != myToken) {
                            return;
                        }
                        const double nowWallSec = WallSeconds();
                        const bool pausedByMenu = IsGamePausedByMenu();

                        auto* player = RE::PlayerCharacter::GetSingleton();
                        if (!player) {
                            return;
                        }
                        auto* actor = static_cast<RE::Actor*>(player);
                        if (!actor) {
                            return;
                        }
                        auto* avOwner = actor->AsActorValueOwner();
                        if (!avOwner) {
                            return;
                        }

                        const float currentHealth = avOwner->GetActorValue(RE::ActorValue::kHealth);

                        bool shouldApplySlowmo = false;
                        bool shouldMaintainSlowmo = false;
                        bool shouldStartSlowmoRecovery = false;
                        bool shouldRecoverSlowmo = false;
                        bool shouldCompleteSlowmoRecovery = false;
                        bool shouldPlaySfx = false;
                        bool shouldBeginMenuBlock = false;
                        bool shouldEndMenuBlock = false;
                        bool watchdogReleased = false;
                        float recoverSlowmoMultiplier = 1.0f;
                        double recoverySeconds = 0.0;
                        double nowGameplaySec = 0.0;
                        {
                            std::scoped_lock lock(g_healthMonitor.lock);
                            if (g_healthMonitor.lastWallClockSampleSec <= 0.0 || nowWallSec < g_healthMonitor.lastWallClockSampleSec) {
                                g_healthMonitor.lastWallClockSampleSec = nowWallSec;
                            } else {
                                const double wallDelta = nowWallSec - g_healthMonitor.lastWallClockSampleSec;
                                g_healthMonitor.lastWallClockSampleSec = nowWallSec;
                                if (!pausedByMenu && wallDelta > 0.0) {
                                    g_healthMonitor.activeGameplayClockSec += wallDelta;
                                }
                            }

                            nowGameplaySec = g_healthMonitor.activeGameplayClockSec;

                            if (currentHealth <= 0.0f) {
                                if (!g_healthMonitor.hpDepletedLatched) {
                                    shouldBeginMenuBlock = true;
                                    if (DeathSlowMoEnabled()) {
                                        if (!HasSlowMoStateLocked()) {
                                            shouldApplySlowmo = true;
                                            g_healthMonitor.slowmoHoldStartedAtSec = nowWallSec;
                                            g_healthMonitor.slowmoHeld = true;
                                            g_healthMonitor.slowmoReleasePending = false;
                                            g_healthMonitor.slowmoRecovering = false;
                                            g_healthMonitor.slowmoReleaseStartAtSec = 0.0;
                                            g_healthMonitor.slowmoRecoverySeconds = 0.0;
                                            g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
                                            g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
                                            if (!g_healthMonitor.slowmoSfxPlayed) {
                                                g_healthMonitor.slowmoSfxPlayed = true;
                                                shouldPlaySfx = true;
                                            }
                                        } else if (g_healthMonitor.slowmoHeld && g_healthMonitor.slowmoHoldStartedAtSec <= 0.0) {
                                            g_healthMonitor.slowmoHoldStartedAtSec = nowWallSec;
                                        }
                                    }
                                }
                                g_healthMonitor.hpDepletedLatched = true;
                                g_healthMonitor.recoveredSinceSec = 0.0;
                            } else {
                                if (g_healthMonitor.hpDepletedLatched) {
                                    if (g_healthMonitor.recoveredSinceSec <= 0.0) {
                                        g_healthMonitor.recoveredSinceSec = nowGameplaySec;
                                    } else if ((nowGameplaySec - g_healthMonitor.recoveredSinceSec) >= kRearArmRecoverySeconds) {
                                        g_healthMonitor.hpDepletedLatched = false;
                                        g_healthMonitor.recoveredSinceSec = 0.0;
                                        shouldEndMenuBlock = true;
                                    }
                                } else {
                                    g_healthMonitor.recoveredSinceSec = 0.0;
                                }
                            }

                            if (g_healthMonitor.slowmoHeld) {
                                if (g_healthMonitor.slowmoHoldStartedAtSec <= 0.0) {
                                    g_healthMonitor.slowmoHoldStartedAtSec = nowWallSec;
                                }
                                if ((nowWallSec - g_healthMonitor.slowmoHoldStartedAtSec) >= kDeathSlowmoWatchdogSeconds) {
                                    ResetSlowMoStateLocked();
                                    shouldCompleteSlowmoRecovery = true;
                                    watchdogReleased = true;
                                } else {
                                    shouldMaintainSlowmo = true;
                                }
                            }

                            if (g_healthMonitor.slowmoReleasePending && nowWallSec >= g_healthMonitor.slowmoReleaseStartAtSec) {
                                g_healthMonitor.slowmoReleasePending = false;
                                g_healthMonitor.slowmoHeld = false;
                                if (g_healthMonitor.slowmoRecoverySeconds <= 0.0) {
                                    ResetSlowMoStateLocked();
                                    shouldCompleteSlowmoRecovery = true;
                                } else {
                                    g_healthMonitor.slowmoRecovering = true;
                                    g_healthMonitor.slowmoRecoverStartAtSec = nowWallSec;
                                    g_healthMonitor.slowmoRecoverEndAtSec = nowWallSec + g_healthMonitor.slowmoRecoverySeconds;
                                    recoverySeconds = g_healthMonitor.slowmoRecoverySeconds;
                                    shouldStartSlowmoRecovery = true;
                                }
                            }

                            if (g_healthMonitor.slowmoRecovering) {
                                const double recoverDuration = g_healthMonitor.slowmoRecoverEndAtSec - g_healthMonitor.slowmoRecoverStartAtSec;
                                if (recoverDuration <= 0.0 || nowWallSec >= g_healthMonitor.slowmoRecoverEndAtSec) {
                                    ResetSlowMoStateLocked();
                                    shouldCompleteSlowmoRecovery = true;
                                } else {
                                    const double tRaw = (nowWallSec - g_healthMonitor.slowmoRecoverStartAtSec) / recoverDuration;
                                    const float t = std::clamp(static_cast<float>(tRaw), 0.0f, 1.0f);
                                    recoverSlowmoMultiplier = kDeathSlowmoMultiplier + ((1.0f - kDeathSlowmoMultiplier) * t);
                                    shouldRecoverSlowmo = true;
                                }
                            }
                        }

                        if (shouldApplySlowmo) {
                            shouldMaintainSlowmo = false;
                            shouldStartSlowmoRecovery = false;
                            shouldRecoverSlowmo = false;
                            shouldCompleteSlowmoRecovery = false;
                        }

                        if (shouldBeginMenuBlock) {
                            IronSoul::MenuBlocker::BeginHealthDepletedBlock();
                        }
                        if (shouldEndMenuBlock) {
                            IronSoul::MenuBlocker::EndHealthDepletedBlock("health-recovered");
                        }
                        if (shouldStartSlowmoRecovery && InfoLoggingEnabled()) {
                            logger::info("DeathSlowMo: recovery start seconds={}", recoverySeconds);
                        }
                        if (watchdogReleased) {
                            logger::warn("DeathSlowMo: watchdog restored time multiplier after {}s", kDeathSlowmoWatchdogSeconds);
                        }
                        if (shouldApplySlowmo) {
                            QueueSetGlobalTimeMultiplier(kDeathSlowmoMultiplier, "death-detected");
                        }
                        if (shouldPlaySfx) {
                            PlayRandomSlowMoSound();
                        }
                        if (shouldMaintainSlowmo) {
                            QueueSetGlobalTimeMultiplier(kDeathSlowmoMultiplier, "slowmo-maintain", false);
                        }
                        if (shouldRecoverSlowmo) {
                            QueueSetGlobalTimeMultiplier(recoverSlowmoMultiplier, "slowmo-recover", false);
                        }
                        if (shouldCompleteSlowmoRecovery) {
                            QueueSetGlobalTimeMultiplier(1.0f, watchdogReleased ? "slowmo-watchdog" : "slowmo-recover-end");
                        }
                    });

                    if (!SleepCancelable(g_healthMonitor.token, myToken, std::chrono::duration<float>(kPollSeconds))) {
                        return;
                    }
                }
            });
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }
    }

    static void StartHealthMonitor(RE::StaticFunctionTag*)
    {
        StartHealthMonitorInternal();
    }

    static void StopHealthMonitor(RE::StaticFunctionTag*)
    {
        StopHealthMonitorInternal();
    }

    static void HoldDeathSlowMo(RE::StaticFunctionTag*, std::string a_reason)
    {
        HoldDeathSlowMoInternal(a_reason);
    }

    static void ReleaseDeathSlowMo(RE::StaticFunctionTag*, float a_recoverySeconds, float a_delaySeconds, std::string a_reason)
    {
        ReleaseDeathSlowMoInternal(a_recoverySeconds, a_delaySeconds, a_reason);
    }

    static void ClearDeathSlowMo(RE::StaticFunctionTag*, std::string a_reason)
    {
        ClearDeathSlowMoInternal(a_reason);
    }

    static bool KillPlayerImmediate(RE::StaticFunctionTag*, bool a_ragdollInstant, std::string a_reason)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("KillPlayerImmediate: task interface unavailable reason={}", a_reason.empty() ? "unknown" : a_reason);
            return false;
        }

        const bool ragdollInstant = a_ragdollInstant;
        const bool infoLog = InfoLoggingEnabled();
        const std::string reason = a_reason.empty() ? "unknown" : a_reason;
        task->AddTask([ragdollInstant, infoLog, reason]() {
            auto* player = RE::PlayerCharacter::GetSingleton();
            if (!player) {
                logger::warn("KillPlayerImmediate: player unavailable reason={}", reason);
                return;
            }

            auto* actor = static_cast<RE::Actor*>(player);
            if (!actor) {
                logger::warn("KillPlayerImmediate: actor unavailable reason={}", reason);
                return;
            }

            if (auto* base = actor->GetActorBase()) {
                base->actorData.actorBaseFlags.reset(RE::ACTOR_BASE_DATA::Flag::kEssential);
            }
            if (auto* avOwner = actor->AsActorValueOwner()) {
                avOwner->SetActorValue(RE::ActorValue::kHealth, 0.0f);
            }

            actor->KillImpl(actor, 999999.0f, true, ragdollInstant);
            if (ragdollInstant) {
                actor->PotentiallyFixRagdollState();
            }

            if (infoLog) {
                logger::info("KillPlayerImmediate: KillImpl queued ragdollInstant={} reason={}", ragdollInstant, reason);
            }
        });

        return true;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("StartHealthMonitor", kScriptName, StartHealthMonitor);
        a_vm->RegisterFunction("StopHealthMonitor", kScriptName, StopHealthMonitor);
        a_vm->RegisterFunction("HoldDeathSlowMo", kScriptName, HoldDeathSlowMo);
        a_vm->RegisterFunction("ReleaseDeathSlowMo", kScriptName, ReleaseDeathSlowMo);
        a_vm->RegisterFunction("ClearDeathSlowMo", kScriptName, ClearDeathSlowMo);
        a_vm->RegisterFunction("KillPlayerImmediate", kScriptName, KillPlayerImmediate);
    }
}
