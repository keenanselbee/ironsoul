#include "pch.h"
#include "papyrus_healthmonitor.h"
#include "papyrus_common.h"
#include "config.h"

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
        bool slowmoActive{ false };
        double slowmoEndAtSec{ 0.0 };
        bool slowmoRecovering{ false };
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
    static constexpr float kDeathSlowmoSeconds = 2.0f;
    static constexpr float kDeathSlowmoRecoverSeconds = 2.0f;
    static constexpr float kRearArmRecoverySeconds = 0.5f;

    static bool IsGamePausedByMenu()
    {
        auto* ui = RE::UI::GetSingleton();
        return ui && ui->GameIsPaused();
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
            g_healthMonitor.slowmoActive = false;
            g_healthMonitor.slowmoEndAtSec = 0.0;
            g_healthMonitor.slowmoRecovering = false;
            g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
            g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
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

    static void StartHealthMonitorInternal()
    {
        constexpr float kPollSeconds = 0.1f;
        std::thread oldWorker;
        std::uint64_t myToken = 0;

        {
            std::scoped_lock lock(g_healthMonitor.lock);
            if (g_healthMonitor.worker.joinable()) {
                oldWorker = std::move(g_healthMonitor.worker);
            }
            myToken = g_healthMonitor.token.fetch_add(1) + 1;
            g_healthMonitor.hpDepletedLatched = false;
            g_healthMonitor.slowmoActive = false;
            g_healthMonitor.slowmoEndAtSec = 0.0;
            g_healthMonitor.slowmoRecovering = false;
            g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
            g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
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
                        const double nowWallSec = std::chrono::duration<double>(
                            std::chrono::steady_clock::now().time_since_epoch())
                            .count();
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
                        float recoverSlowmoMultiplier = 1.0f;
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

                            if (g_healthMonitor.slowmoActive && nowGameplaySec >= g_healthMonitor.slowmoEndAtSec) {
                                g_healthMonitor.slowmoActive = false;
                                g_healthMonitor.slowmoEndAtSec = 0.0;
                                g_healthMonitor.slowmoRecovering = true;
                                g_healthMonitor.slowmoRecoverStartAtSec = nowGameplaySec;
                                g_healthMonitor.slowmoRecoverEndAtSec = nowGameplaySec + kDeathSlowmoRecoverSeconds;
                                shouldStartSlowmoRecovery = true;
                            } else if (g_healthMonitor.slowmoActive) {
                                shouldMaintainSlowmo = true;
                            }

                            if (g_healthMonitor.slowmoRecovering) {
                                const double recoverDuration = g_healthMonitor.slowmoRecoverEndAtSec - g_healthMonitor.slowmoRecoverStartAtSec;
                                if (recoverDuration <= 0.0 || nowGameplaySec >= g_healthMonitor.slowmoRecoverEndAtSec) {
                                    g_healthMonitor.slowmoRecovering = false;
                                    g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
                                    g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
                                    shouldCompleteSlowmoRecovery = true;
                                } else {
                                    const double tRaw = (nowGameplaySec - g_healthMonitor.slowmoRecoverStartAtSec) / recoverDuration;
                                    const float t = std::clamp(static_cast<float>(tRaw), 0.0f, 1.0f);
                                    recoverSlowmoMultiplier = kDeathSlowmoMultiplier + ((1.0f - kDeathSlowmoMultiplier) * t);
                                    shouldRecoverSlowmo = true;
                                }
                            }

                            if (currentHealth <= 0.0f) {
                                if (!g_healthMonitor.hpDepletedLatched) {
                                    if (DeathSlowMoEnabled()) {
                                        shouldApplySlowmo = true;
                                        g_healthMonitor.slowmoActive = true;
                                        g_healthMonitor.slowmoEndAtSec = nowGameplaySec + kDeathSlowmoSeconds;
                                        g_healthMonitor.slowmoRecovering = false;
                                        g_healthMonitor.slowmoRecoverStartAtSec = 0.0;
                                        g_healthMonitor.slowmoRecoverEndAtSec = 0.0;
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
                                    }
                                } else {
                                    g_healthMonitor.recoveredSinceSec = 0.0;
                                }
                            }
                        }

                        if (shouldApplySlowmo) {
                            shouldStartSlowmoRecovery = false;
                            shouldRecoverSlowmo = false;
                            shouldCompleteSlowmoRecovery = false;
                        }

                        if (shouldStartSlowmoRecovery && InfoLoggingEnabled()) {
                            logger::info("DeathSlowMo: recovery start seconds={}", kDeathSlowmoRecoverSeconds);
                        }
                        if (shouldApplySlowmo) {
                            QueueSetGlobalTimeMultiplier(kDeathSlowmoMultiplier, "death-detected");
                            PlayRandomSlowMoSound();
                        }
                        if (shouldMaintainSlowmo) {
                            QueueSetGlobalTimeMultiplier(kDeathSlowmoMultiplier, "slowmo-maintain", false);
                        }
                        if (shouldRecoverSlowmo) {
                            QueueSetGlobalTimeMultiplier(recoverSlowmoMultiplier, "slowmo-recover", false);
                        }
                        if (shouldCompleteSlowmoRecovery) {
                            QueueSetGlobalTimeMultiplier(1.0f, "slowmo-recover-end");
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
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("StartHealthMonitor", kScriptName, StartHealthMonitor);
        a_vm->RegisterFunction("StopHealthMonitor", kScriptName, StopHealthMonitor);
    }
}
