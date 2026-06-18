#include "pch.h"
#include "audio_util.h"
#include "papyrus_slowmo.h"
#include "papyrus_common.h"
#include "config.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cmath>
#include <random>
#include <thread>

namespace IronSoul::Papyrus::SlowMo
{
namespace
{
    struct DeathSlowMoState
    {
        std::mutex lock;
        bool slowmoHeld{ false };
        bool slowmoReleasePending{ false };
        bool slowmoRecovering{ false };
        bool slowmoSfxPlayed{ false };
        double slowmoHoldStartedAtSec{ 0.0 };
        double slowmoReleaseStartAtSec{ 0.0 };
        double slowmoRecoverySeconds{ 0.0 };
        double slowmoRecoverStartAtSec{ 0.0 };
        double slowmoRecoverEndAtSec{ 0.0 };
        float slowmoHoldMultiplier{ 0.3f };
        float slowmoRecoverFromMultiplier{ 0.3f };
        float slowmoRecoverToMultiplier{ 1.0f };
        bool slowmoRecoverReleaseOnComplete{ true };
    };

    DeathSlowMoState g_deathSlowMo;

    struct TimeMultiplierRampState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> token{ 0 };
        std::thread worker;

        ~TimeMultiplierRampState()
        {
            token.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };

    TimeMultiplierRampState g_timeMultiplierRamp;

    struct FeatUnlockSlowMoState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> token{ 0 };
        std::thread worker;

        ~FeatUnlockSlowMoState()
        {
            token.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };

    FeatUnlockSlowMoState g_featUnlockSlowMo;

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
    static constexpr float kDeathEngineHandoffMultiplier = 0.8f;
    static constexpr float kDeathSlowmoWatchdogSeconds = 60.0f;
    static constexpr float kFeatUnlockSlowmoMultiplier = 0.5f;
    // Feat slowmo now releases after the 30s key-dismiss menu closes; keep a watchdog in case that close path never returns.
    static constexpr float kFeatUnlockSlowmoWatchdogSlackSeconds = 32.0f;
    static constexpr float kTimeMultiplierNormalEpsilon = 0.02f;
    static constexpr float kTimeMultiplierDriftEpsilon = 0.08f;

    enum class TimeMultiplierOwner
    {
        kNone,
        kDeathSlowMo,
        kTimeRamp,
        kFeatUnlock
    };

    enum class TimeMultiplierWriteMode
    {
        kNormal,
        kRestore
    };

    struct TimeMultiplierOwnershipState
    {
        std::mutex lock;
        TimeMultiplierOwner owner{ TimeMultiplierOwner::kNone };
        float expectedTargetMultiplier{ 1.0f };
    };

    TimeMultiplierOwnershipState g_timeMultiplierOwnership;

    static const char* TimeMultiplierOwnerName(TimeMultiplierOwner a_owner)
    {
        switch (a_owner) {
        case TimeMultiplierOwner::kDeathSlowMo:
            return "death-slowmo";
        case TimeMultiplierOwner::kTimeRamp:
            return "time-ramp";
        case TimeMultiplierOwner::kFeatUnlock:
            return "feat-unlock";
        default:
            return "none";
        }
    }

    static const char* TimeMultiplierWriteModeName(TimeMultiplierWriteMode a_mode)
    {
        switch (a_mode) {
        case TimeMultiplierWriteMode::kRestore:
            return "restore";
        default:
            return "normal";
        }
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

    static bool FloatNear(float a_value, float a_expected, float a_epsilon)
    {
        return std::fabs(a_value - a_expected) <= a_epsilon;
    }

    static bool PlayerHasSlowTimeEffect()
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        auto* actor = player ? static_cast<RE::Actor*>(player) : nullptr;
        auto* magicTarget = actor ? actor->GetMagicTarget() : nullptr;
        return magicTarget && magicTarget->HasEffectWithArchetype(RE::EffectArchetype::kSlowTime);
    }

    static bool GlobalTimeMultiplierNearNormal(float a_current, float a_target)
    {
        return FloatNear(a_current, 1.0f, kTimeMultiplierNormalEpsilon) &&
               FloatNear(a_target, 1.0f, kTimeMultiplierNormalEpsilon);
    }

    static bool DeathEngineHandoffActive(float a_current, float a_target)
    {
        return FloatNear(a_current, kDeathEngineHandoffMultiplier, kTimeMultiplierDriftEpsilon) ||
               FloatNear(a_target, kDeathEngineHandoffMultiplier, kTimeMultiplierDriftEpsilon);
    }

    static bool TimeMultiplierAvailableForOwner(TimeMultiplierOwner a_owner, float a_current, float a_target)
    {
        if (GlobalTimeMultiplierNearNormal(a_current, a_target)) {
            return true;
        }
        return a_owner == TimeMultiplierOwner::kDeathSlowMo && DeathEngineHandoffActive(a_current, a_target);
    }

    static bool TimeMultiplierOwnerActive(TimeMultiplierOwner a_owner)
    {
        std::scoped_lock lock(g_timeMultiplierOwnership.lock);
        return g_timeMultiplierOwnership.owner == a_owner;
    }

    static bool TryAcquireTimeMultiplierOwner(TimeMultiplierOwner a_owner, const std::string& a_reason)
    {
        std::scoped_lock lock(g_timeMultiplierOwnership.lock);
        if (g_timeMultiplierOwnership.owner == a_owner) {
            return true;
        }
        if (g_timeMultiplierOwnership.owner != TimeMultiplierOwner::kNone) {
            if (InfoLoggingEnabled()) {
                logger::info(
                    "TimeMultiplier: skipped owner={} reason={} activeOwner={}",
                    TimeMultiplierOwnerName(a_owner),
                    a_reason.empty() ? "unknown" : a_reason,
                    TimeMultiplierOwnerName(g_timeMultiplierOwnership.owner));
            }
            return false;
        }
        if (!RE::BSTimer::GetSingleton()) {
            if (InfoLoggingEnabled()) {
                logger::warn("TimeMultiplier: BSTimer unavailable owner={} reason={}", TimeMultiplierOwnerName(a_owner), a_reason.empty() ? "unknown" : a_reason);
            }
            return false;
        }
        if (!SKSE::GetTaskInterface()) {
            if (InfoLoggingEnabled()) {
                logger::warn("TimeMultiplier: task interface unavailable owner={} reason={}", TimeMultiplierOwnerName(a_owner), a_reason.empty() ? "unknown" : a_reason);
            }
            return false;
        }
        const float current = RE::BSTimer::QGlobalTimeMultiplier();
        const float target = RE::BSTimer::QGlobalTimeMultiplierTarget();
        if (!TimeMultiplierAvailableForOwner(a_owner, current, target)) {
            if (InfoLoggingEnabled()) {
                logger::info(
                    "TimeMultiplier: skipped owner={} reason={} current={} target={}",
                    TimeMultiplierOwnerName(a_owner),
                    a_reason.empty() ? "unknown" : a_reason,
                    current,
                    target);
            }
            return false;
        }
        if (PlayerHasSlowTimeEffect()) {
            if (InfoLoggingEnabled()) {
                logger::info("TimeMultiplier: skipped owner={} reason={} activeSlowTimeEffect=true", TimeMultiplierOwnerName(a_owner), a_reason.empty() ? "unknown" : a_reason);
            }
            return false;
        }

        g_timeMultiplierOwnership.owner = a_owner;
        g_timeMultiplierOwnership.expectedTargetMultiplier = 1.0f;
        if (InfoLoggingEnabled()) {
            logger::info("TimeMultiplier: acquired owner={} reason={}", TimeMultiplierOwnerName(a_owner), a_reason.empty() ? "unknown" : a_reason);
        }
        return true;
    }

    static void RelinquishTimeMultiplierOwnerLocked(TimeMultiplierOwner a_owner, const std::string& a_reason, const char* a_detail)
    {
        if (g_timeMultiplierOwnership.owner != a_owner) {
            return;
        }
        g_timeMultiplierOwnership.owner = TimeMultiplierOwner::kNone;
        g_timeMultiplierOwnership.expectedTargetMultiplier = 1.0f;
        if (InfoLoggingEnabled()) {
            logger::info(
                "TimeMultiplier: relinquished owner={} reason={} detail={}",
                TimeMultiplierOwnerName(a_owner),
                a_reason.empty() ? "unknown" : a_reason,
                a_detail ? a_detail : "unknown");
        }
    }

    static void QueueSetOwnedTimeMultiplier(
        TimeMultiplierOwner a_owner,
        float a_multiplier,
        const char* a_reason,
        bool a_log = true,
        bool a_releaseAfterWrite = false,
        TimeMultiplierWriteMode a_mode = TimeMultiplierWriteMode::kNormal)
    {
        const std::string reason = a_reason ? a_reason : "unknown";
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (InfoLoggingEnabled()) {
                logger::warn("TimeMultiplier: task interface unavailable owner={} reason={}", TimeMultiplierOwnerName(a_owner), reason);
            }
            std::scoped_lock lock(g_timeMultiplierOwnership.lock);
            RelinquishTimeMultiplierOwnerLocked(a_owner, reason, "task-interface-unavailable");
            return;
        }

        const float mult = a_multiplier;
        const bool infoLog = InfoLoggingEnabled();
        const bool doLog = a_log;
        const bool releaseAfterWrite = a_releaseAfterWrite;
        const TimeMultiplierWriteMode mode = a_mode;

        task->AddTask([owner = a_owner, mult, infoLog, doLog, releaseAfterWrite, mode, reason]() {
            auto* timer = RE::BSTimer::GetSingleton();
            if (!timer) {
                if (infoLog && doLog) {
                    logger::warn("TimeMultiplier: BSTimer unavailable owner={} reason={}", TimeMultiplierOwnerName(owner), reason);
                }
                return;
            }

            std::scoped_lock lock(g_timeMultiplierOwnership.lock);
            if (g_timeMultiplierOwnership.owner != owner) {
                return;
            }
            if (mode != TimeMultiplierWriteMode::kRestore && PlayerHasSlowTimeEffect()) {
                RelinquishTimeMultiplierOwnerLocked(owner, reason, "active-slow-time-effect");
                return;
            }

            const float current = RE::BSTimer::QGlobalTimeMultiplier();
            const float target = RE::BSTimer::QGlobalTimeMultiplierTarget();
            const float expectedTarget = g_timeMultiplierOwnership.expectedTargetMultiplier;
            const bool deathEngineHandoff =
                owner == TimeMultiplierOwner::kDeathSlowMo &&
                DeathEngineHandoffActive(current, target);
            if (mode != TimeMultiplierWriteMode::kRestore &&
                !FloatNear(target, expectedTarget, kTimeMultiplierDriftEpsilon) &&
                !FloatNear(target, mult, kTimeMultiplierDriftEpsilon) &&
                !deathEngineHandoff) {
                if (infoLog) {
                    logger::info(
                        "TimeMultiplier: target drift owner={} mode={} current={} target={} expectedTarget={} requested={} reason={} detail={}",
                        TimeMultiplierOwnerName(owner),
                        TimeMultiplierWriteModeName(mode),
                        current,
                        target,
                        expectedTarget,
                        mult,
                        reason,
                        "external-drift");
                }
                RelinquishTimeMultiplierOwnerLocked(owner, reason, "external-drift");
                return;
            }

            timer->SetGlobalTimeMultiplier(mult, false);
            if (releaseAfterWrite) {
                g_timeMultiplierOwnership.owner = TimeMultiplierOwner::kNone;
                g_timeMultiplierOwnership.expectedTargetMultiplier = 1.0f;
            } else {
                g_timeMultiplierOwnership.expectedTargetMultiplier = mult;
            }

            if (infoLog && doLog) {
                logger::info(
                    "TimeMultiplier: set owner={} multiplier={} release={} mode={} current={} target={} expectedTarget={} reason={}",
                    TimeMultiplierOwnerName(owner),
                    mult,
                    releaseAfterWrite,
                    TimeMultiplierWriteModeName(mode),
                    current,
                    target,
                    expectedTarget,
                    reason);
            }
        });
    }

    static void ResetDeathSlowMoStateLocked(bool a_resetSfx = true)
    {
        g_deathSlowMo.slowmoHeld = false;
        g_deathSlowMo.slowmoReleasePending = false;
        g_deathSlowMo.slowmoRecovering = false;
        g_deathSlowMo.slowmoHoldStartedAtSec = 0.0;
        g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
        g_deathSlowMo.slowmoRecoverySeconds = 0.0;
        g_deathSlowMo.slowmoRecoverStartAtSec = 0.0;
        g_deathSlowMo.slowmoRecoverEndAtSec = 0.0;
        g_deathSlowMo.slowmoHoldMultiplier = kDeathSlowmoMultiplier;
        g_deathSlowMo.slowmoRecoverFromMultiplier = kDeathSlowmoMultiplier;
        g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
        g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
        if (a_resetSfx) {
            g_deathSlowMo.slowmoSfxPlayed = false;
        }
    }

    static bool HasDeathSlowMoStateLocked()
    {
        return g_deathSlowMo.slowmoHeld || g_deathSlowMo.slowmoReleasePending || g_deathSlowMo.slowmoRecovering;
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
        IronSoul::Audio::SoundBuildOptions options;
        options.owner = "DeathSlowMoSFX";
        options.reason = "death-slowmo";
        (void)IronSoul::Audio::BuildAndPlayDescriptor(handle, descriptor, descriptor->GetFormID(), options);
    }

    static void StartTimeMultiplierRampInternal(float a_fromMultiplier, float a_toMultiplier, float a_seconds, std::string a_reason)
    {
        const float fromMultiplier = std::clamp(a_fromMultiplier, 0.05f, 4.0f);
        const float toMultiplier = std::clamp(a_toMultiplier, 0.05f, 4.0f);
        const float seconds = a_seconds < 0.0f ? 0.0f : a_seconds;
        const std::string reason = a_reason.empty() ? "time-ramp" : a_reason;
        const bool releaseAfterFinalWrite = FloatNear(toMultiplier, 1.0f, kTimeMultiplierNormalEpsilon);
        const TimeMultiplierWriteMode finalWriteMode = releaseAfterFinalWrite ? TimeMultiplierWriteMode::kRestore : TimeMultiplierWriteMode::kNormal;

        std::thread oldWorker;
        std::uint64_t myToken = 0;
        {
            std::scoped_lock lock(g_timeMultiplierRamp.lock);
            if (g_timeMultiplierRamp.worker.joinable()) {
                oldWorker = std::move(g_timeMultiplierRamp.worker);
            }
            myToken = g_timeMultiplierRamp.token.fetch_add(1) + 1;

            if (!TryAcquireTimeMultiplierOwner(TimeMultiplierOwner::kTimeRamp, reason)) {
                myToken = 0;
            } else if (seconds > 0.0f) {
                g_timeMultiplierRamp.worker = std::thread([myToken, fromMultiplier, toMultiplier, seconds, reason, releaseAfterFinalWrite, finalWriteMode]() {
                    const auto startedAt = std::chrono::steady_clock::now();
                    const auto duration = std::chrono::duration<float>(seconds);

                    while (g_timeMultiplierRamp.token.load() == myToken) {
                        const auto now = std::chrono::steady_clock::now();
                        const auto elapsed = now - startedAt;
                        const float rawT = std::chrono::duration<float>(elapsed).count() / seconds;
                        const float t = std::clamp(rawT, 0.0f, 1.0f);
                        const float multiplier = fromMultiplier + ((toMultiplier - fromMultiplier) * t);

                        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kTimeRamp, multiplier, reason.c_str(), false);
                        if (elapsed >= duration) {
                            break;
                        }

                        if (!SleepCancelable(g_timeMultiplierRamp.token, myToken, std::chrono::milliseconds(50))) {
                            return;
                        }
                    }

                    if (g_timeMultiplierRamp.token.load() == myToken) {
                        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kTimeRamp, toMultiplier, reason.c_str(), true, releaseAfterFinalWrite, finalWriteMode);
                    }
                });
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }

        if (myToken == 0) {
            return;
        }
        if (seconds <= 0.0f) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kTimeRamp, toMultiplier, reason.c_str(), true, releaseAfterFinalWrite, finalWriteMode);
        } else {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kTimeRamp, fromMultiplier, reason.c_str());
            if (InfoLoggingEnabled()) {
                logger::info("TimeMultiplierRamp: started from={} to={} seconds={} reason={}", fromMultiplier, toMultiplier, seconds, reason);
            }
        }
    }

    static void ClearTimeMultiplierRampInternal(std::string a_reason)
    {
        const std::string reason = a_reason.empty() ? "time-ramp-clear" : a_reason;
        std::thread oldWorker;
        {
            std::scoped_lock lock(g_timeMultiplierRamp.lock);
            g_timeMultiplierRamp.token.fetch_add(1);
            if (g_timeMultiplierRamp.worker.joinable()) {
                oldWorker = std::move(g_timeMultiplierRamp.worker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }

        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kTimeRamp, 1.0f, reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
        if (InfoLoggingEnabled()) {
            logger::info("TimeMultiplierRamp: cleared reason={}", reason);
        }
    }

    static void ReleaseDeathSlowMoInternal(float a_recoverySeconds, float a_delaySeconds, std::string a_reason)
    {
        const float recoverySeconds = a_recoverySeconds < 0.0f ? 0.0f : a_recoverySeconds;
        const float delaySeconds = a_delaySeconds < 0.0f ? 0.0f : a_delaySeconds;
        const double nowSec = WallSeconds();
        bool shouldClearNow = false;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);
            if (!HasDeathSlowMoStateLocked()) {
                return;
            }

            if (delaySeconds <= 0.0f && recoverySeconds <= 0.0f) {
                ResetDeathSlowMoStateLocked();
                shouldClearNow = true;
            } else if (delaySeconds <= 0.0f) {
                g_deathSlowMo.slowmoHeld = false;
                g_deathSlowMo.slowmoReleasePending = false;
                g_deathSlowMo.slowmoRecovering = true;
                g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
                g_deathSlowMo.slowmoRecoverySeconds = recoverySeconds;
                g_deathSlowMo.slowmoRecoverStartAtSec = nowSec;
                g_deathSlowMo.slowmoRecoverEndAtSec = nowSec + recoverySeconds;
                g_deathSlowMo.slowmoHoldMultiplier = kDeathSlowmoMultiplier;
                g_deathSlowMo.slowmoRecoverFromMultiplier = kDeathSlowmoMultiplier;
                g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
            } else {
                g_deathSlowMo.slowmoHeld = true;
                g_deathSlowMo.slowmoReleasePending = true;
                g_deathSlowMo.slowmoRecovering = false;
                g_deathSlowMo.slowmoReleaseStartAtSec = nowSec + delaySeconds;
                g_deathSlowMo.slowmoRecoverySeconds = recoverySeconds;
                g_deathSlowMo.slowmoRecoverStartAtSec = 0.0;
                g_deathSlowMo.slowmoRecoverEndAtSec = 0.0;
                g_deathSlowMo.slowmoHoldMultiplier = kDeathSlowmoMultiplier;
                g_deathSlowMo.slowmoRecoverFromMultiplier = kDeathSlowmoMultiplier;
                g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info("DeathSlowMo: release scheduled recoverySeconds={} delaySeconds={} reason={}", recoverySeconds, delaySeconds, a_reason.empty() ? "release" : a_reason);
        }
        if (shouldClearNow) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, 1.0f, a_reason.empty() ? "release" : a_reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
        }
    }

    static void ReleaseDeathSlowMoWithHoldInternal(float a_holdMultiplier, float a_holdSeconds, float a_recoverySeconds, std::string a_reason)
    {
        const float holdMultiplier = std::clamp(a_holdMultiplier, 0.05f, 4.0f);
        const float holdSeconds = a_holdSeconds < 0.0f ? 0.0f : a_holdSeconds;
        const float recoverySeconds = a_recoverySeconds < 0.0f ? 0.0f : a_recoverySeconds;
        const double nowSec = WallSeconds();
        bool shouldApplyHold = false;
        bool shouldClearNow = false;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);
            if (!HasDeathSlowMoStateLocked()) {
                return;
            }

            if (holdSeconds <= 0.0f && recoverySeconds <= 0.0f) {
                ResetDeathSlowMoStateLocked();
                shouldClearNow = true;
            } else if (holdSeconds <= 0.0f) {
                g_deathSlowMo.slowmoHeld = false;
                g_deathSlowMo.slowmoReleasePending = false;
                g_deathSlowMo.slowmoRecovering = true;
                g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
                g_deathSlowMo.slowmoRecoverySeconds = recoverySeconds;
                g_deathSlowMo.slowmoRecoverStartAtSec = nowSec;
                g_deathSlowMo.slowmoRecoverEndAtSec = nowSec + recoverySeconds;
                g_deathSlowMo.slowmoHoldMultiplier = holdMultiplier;
                g_deathSlowMo.slowmoRecoverFromMultiplier = holdMultiplier;
                g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
                shouldApplyHold = true;
            } else {
                g_deathSlowMo.slowmoHeld = true;
                g_deathSlowMo.slowmoReleasePending = true;
                g_deathSlowMo.slowmoRecovering = false;
                g_deathSlowMo.slowmoReleaseStartAtSec = nowSec + holdSeconds;
                g_deathSlowMo.slowmoRecoverySeconds = recoverySeconds;
                g_deathSlowMo.slowmoRecoverStartAtSec = 0.0;
                g_deathSlowMo.slowmoRecoverEndAtSec = 0.0;
                g_deathSlowMo.slowmoHoldMultiplier = holdMultiplier;
                g_deathSlowMo.slowmoRecoverFromMultiplier = holdMultiplier;
                g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
                shouldApplyHold = true;
            }
        }

        const std::string reason = a_reason.empty() ? "release-hold" : a_reason;
        if (InfoLoggingEnabled()) {
            logger::info(
                "DeathSlowMo: release hold scheduled holdMultiplier={} holdSeconds={} recoverySeconds={} reason={}",
                holdMultiplier,
                holdSeconds,
                recoverySeconds,
                reason);
        }
        if (shouldApplyHold) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, holdMultiplier, reason.c_str());
        }
        if (shouldClearNow) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, 1.0f, reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
        }
    }

    static void TransitionDeathSlowMoToHoldInternal(float a_holdMultiplier, float a_transitionSeconds, std::string a_reason)
    {
        const float holdMultiplier = std::clamp(a_holdMultiplier, 0.05f, 4.0f);
        const float transitionSeconds = a_transitionSeconds < 0.0f ? 0.0f : a_transitionSeconds;
        const double nowSec = WallSeconds();
        float fromMultiplier = kDeathSlowmoMultiplier;
        bool shouldApplyHold = false;
        bool shouldStartTransition = false;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);
            if (!HasDeathSlowMoStateLocked()) {
                return;
            }

            fromMultiplier = g_deathSlowMo.slowmoHoldMultiplier;
            g_deathSlowMo.slowmoHeld = transitionSeconds <= 0.0f;
            g_deathSlowMo.slowmoReleasePending = false;
            g_deathSlowMo.slowmoRecovering = transitionSeconds > 0.0f;
            g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
            g_deathSlowMo.slowmoRecoverySeconds = transitionSeconds;
            g_deathSlowMo.slowmoRecoverStartAtSec = transitionSeconds > 0.0f ? nowSec : 0.0;
            g_deathSlowMo.slowmoRecoverEndAtSec = transitionSeconds > 0.0f ? nowSec + transitionSeconds : 0.0;
            g_deathSlowMo.slowmoHoldMultiplier = holdMultiplier;
            g_deathSlowMo.slowmoRecoverFromMultiplier = fromMultiplier;
            g_deathSlowMo.slowmoRecoverToMultiplier = holdMultiplier;
            g_deathSlowMo.slowmoRecoverReleaseOnComplete = false;
            if (transitionSeconds <= 0.0f) {
                g_deathSlowMo.slowmoHoldStartedAtSec = nowSec;
                shouldApplyHold = true;
            } else {
                shouldStartTransition = true;
            }
        }

        const std::string reason = a_reason.empty() ? "transition-hold" : a_reason;
        if (InfoLoggingEnabled()) {
            logger::info(
                "DeathSlowMo: transition hold scheduled fromMultiplier={} holdMultiplier={} transitionSeconds={} reason={}",
                fromMultiplier,
                holdMultiplier,
                transitionSeconds,
                reason);
        }
        if (shouldApplyHold) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, holdMultiplier, reason.c_str());
        } else if (shouldStartTransition) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, fromMultiplier, reason.c_str(), false);
        }
    }

    static void ClearDeathSlowMoInternal(std::string a_reason)
    {
        bool hadState = false;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);
            hadState = HasDeathSlowMoStateLocked() || g_deathSlowMo.slowmoSfxPlayed;
            ResetDeathSlowMoStateLocked();
        }

        if (hadState) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, 1.0f, a_reason.empty() ? "clear" : a_reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
        }
    }

    static bool TryStartFeatUnlockSlowMoInternal(float a_seconds, std::string a_reason)
    {
        if (!FeatSlowMoEnabled()) {
            return false;
        }

        const float seconds = a_seconds <= 0.0f ? 0.1f : a_seconds;
        const std::string reason = a_reason.empty() ? "feat-unlock" : a_reason;

        std::thread oldWorker;
        std::uint64_t myToken = 0;
        {
            std::scoped_lock lock(g_featUnlockSlowMo.lock);
            if (g_featUnlockSlowMo.worker.joinable()) {
                oldWorker = std::move(g_featUnlockSlowMo.worker);
            }
            myToken = g_featUnlockSlowMo.token.fetch_add(1) + 1;

            if (!TryAcquireTimeMultiplierOwner(TimeMultiplierOwner::kFeatUnlock, reason)) {
                myToken = 0;
            } else {
                g_featUnlockSlowMo.worker = std::thread([myToken, seconds, reason]() {
                    const auto startedAt = std::chrono::steady_clock::now();
                    const auto duration = std::chrono::duration<float>(seconds);

                    while (g_featUnlockSlowMo.token.load() == myToken) {
                        const auto now = std::chrono::steady_clock::now();
                        const auto elapsed = now - startedAt;
                        const float rawT = std::chrono::duration<float>(elapsed).count() / seconds;
                        const float t = std::clamp(rawT, 0.0f, 1.0f);
                        const float multiplier = 1.0f + ((kFeatUnlockSlowmoMultiplier - 1.0f) * t);

                        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, multiplier, reason.c_str(), false);
                        if (elapsed >= duration) {
                            break;
                        }

                        if (!SleepCancelable(g_featUnlockSlowMo.token, myToken, std::chrono::milliseconds(50))) {
                            return;
                        }
                    }

                    if (g_featUnlockSlowMo.token.load() != myToken) {
                        return;
                    }

                    QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, kFeatUnlockSlowmoMultiplier, reason.c_str());
                    if (!SleepCancelable(g_featUnlockSlowMo.token, myToken, std::chrono::duration<float>(kFeatUnlockSlowmoWatchdogSlackSeconds))) {
                        return;
                    }

                    if (g_featUnlockSlowMo.token.load() == myToken) {
                        logger::warn("FeatUnlockSlowMo: watchdog restored time multiplier after {}s", seconds + kFeatUnlockSlowmoWatchdogSlackSeconds);
                        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, 1.0f, "feat-unlock-watchdog", true, true, TimeMultiplierWriteMode::kRestore);
                    }
                });
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }
        if (myToken == 0) {
            return false;
        }

        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, 1.0f, reason.c_str());
        if (InfoLoggingEnabled()) {
            logger::info("FeatUnlockSlowMo: started seconds={} reason={}", seconds, reason);
        }
        return true;
    }

    static void ReleaseFeatUnlockSlowMoInternal(float a_seconds, std::string a_reason)
    {
        const float seconds = a_seconds < 0.0f ? 0.0f : a_seconds;
        const std::string reason = a_reason.empty() ? "feat-unlock-release" : a_reason;

        std::thread oldWorker;
        std::uint64_t myToken = 0;
        float fromMultiplier = kFeatUnlockSlowmoMultiplier;
        {
            std::scoped_lock lock(g_featUnlockSlowMo.lock);
            if (g_featUnlockSlowMo.worker.joinable()) {
                oldWorker = std::move(g_featUnlockSlowMo.worker);
            }
            myToken = g_featUnlockSlowMo.token.fetch_add(1) + 1;

            if (!TimeMultiplierOwnerActive(TimeMultiplierOwner::kFeatUnlock)) {
                myToken = 0;
            } else {
                fromMultiplier = std::clamp(RE::BSTimer::QGlobalTimeMultiplier(), kFeatUnlockSlowmoMultiplier, 4.0f);
                if (seconds > 0.0f) {
                    g_featUnlockSlowMo.worker = std::thread([myToken, fromMultiplier, seconds, reason]() {
                        const auto startedAt = std::chrono::steady_clock::now();
                        const auto duration = std::chrono::duration<float>(seconds);

                        while (g_featUnlockSlowMo.token.load() == myToken) {
                            const auto now = std::chrono::steady_clock::now();
                            const auto elapsed = now - startedAt;
                            const float rawT = std::chrono::duration<float>(elapsed).count() / seconds;
                            const float t = std::clamp(rawT, 0.0f, 1.0f);
                            const float multiplier = fromMultiplier + ((1.0f - fromMultiplier) * t);

                            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, multiplier, reason.c_str(), false, false, TimeMultiplierWriteMode::kRestore);
                            if (elapsed >= duration) {
                                break;
                            }

                            if (!SleepCancelable(g_featUnlockSlowMo.token, myToken, std::chrono::milliseconds(25))) {
                                return;
                            }
                        }

                        if (g_featUnlockSlowMo.token.load() == myToken) {
                            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, 1.0f, reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
                        }
                    });
                }
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }
        if (myToken == 0) {
            return;
        }
        if (seconds <= 0.0f) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, 1.0f, reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
        } else if (InfoLoggingEnabled()) {
            logger::info("FeatUnlockSlowMo: release started from={} seconds={} reason={}", fromMultiplier, seconds, reason);
        }
    }

    static void ClearFeatUnlockSlowMoInternal(std::string a_reason)
    {
        const std::string reason = a_reason.empty() ? "feat-unlock-clear" : a_reason;
        std::thread oldWorker;
        {
            std::scoped_lock lock(g_featUnlockSlowMo.lock);
            g_featUnlockSlowMo.token.fetch_add(1);
            if (g_featUnlockSlowMo.worker.joinable()) {
                oldWorker = std::move(g_featUnlockSlowMo.worker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }

        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kFeatUnlock, 1.0f, reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
    }

    static void StartDeathSlowMo(double a_nowWallSec, const std::string& a_reason)
    {
        if (!DeathSlowMoEnabled()) {
            return;
        }

        bool shouldApplySlowmo = false;
        bool shouldPlaySfx = false;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);
            const bool wasActive = HasDeathSlowMoStateLocked();
            const bool ownsDeathSlowmo = TimeMultiplierOwnerActive(TimeMultiplierOwner::kDeathSlowMo);
            if (!wasActive || !ownsDeathSlowmo || g_deathSlowMo.slowmoReleasePending || g_deathSlowMo.slowmoRecovering) {
                if (!TryAcquireTimeMultiplierOwner(TimeMultiplierOwner::kDeathSlowMo, a_reason)) {
                    if (wasActive && !ownsDeathSlowmo) {
                        ResetDeathSlowMoStateLocked();
                    }
                    return;
                }
                shouldApplySlowmo = true;
                g_deathSlowMo.slowmoHoldStartedAtSec = a_nowWallSec;
            } else if (g_deathSlowMo.slowmoHeld && g_deathSlowMo.slowmoHoldStartedAtSec <= 0.0) {
                g_deathSlowMo.slowmoHoldStartedAtSec = a_nowWallSec;
            }

            g_deathSlowMo.slowmoHeld = true;
            g_deathSlowMo.slowmoReleasePending = false;
            g_deathSlowMo.slowmoRecovering = false;
            g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
            g_deathSlowMo.slowmoRecoverySeconds = 0.0;
            g_deathSlowMo.slowmoRecoverStartAtSec = 0.0;
            g_deathSlowMo.slowmoRecoverEndAtSec = 0.0;
            g_deathSlowMo.slowmoHoldMultiplier = kDeathSlowmoMultiplier;
            g_deathSlowMo.slowmoRecoverFromMultiplier = kDeathSlowmoMultiplier;

            if (!g_deathSlowMo.slowmoSfxPlayed) {
                g_deathSlowMo.slowmoSfxPlayed = true;
                shouldPlaySfx = true;
            }
        }

        if (shouldApplySlowmo) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, kDeathSlowmoMultiplier, a_reason.c_str());
        }
        if (shouldPlaySfx) {
            PlayRandomSlowMoSound();
        }
    }

    static void HoldDeathSlowMo(RE::StaticFunctionTag*, std::string a_reason)
    {
        StartDeathSlowMo(WallSeconds(), a_reason.empty() ? "hold" : a_reason);
    }

    static void ReleaseDeathSlowMo(RE::StaticFunctionTag*, float a_recoverySeconds, float a_delaySeconds, std::string a_reason)
    {
        ReleaseDeathSlowMoInternal(a_recoverySeconds, a_delaySeconds, a_reason);
    }

    static void ReleaseDeathSlowMoWithHold(RE::StaticFunctionTag*, float a_holdMultiplier, float a_holdSeconds, float a_recoverySeconds, std::string a_reason)
    {
        ReleaseDeathSlowMoWithHoldInternal(a_holdMultiplier, a_holdSeconds, a_recoverySeconds, a_reason);
    }

    static void TransitionDeathSlowMoToHold(RE::StaticFunctionTag*, float a_holdMultiplier, float a_transitionSeconds, std::string a_reason)
    {
        TransitionDeathSlowMoToHoldInternal(a_holdMultiplier, a_transitionSeconds, a_reason);
    }

    static void ClearDeathSlowMo(RE::StaticFunctionTag*, std::string a_reason)
    {
        ClearDeathSlowMoInternal(a_reason);
    }

    static void StartTimeMultiplierRamp(RE::StaticFunctionTag*, float a_fromMultiplier, float a_toMultiplier, float a_seconds, std::string a_reason)
    {
        StartTimeMultiplierRampInternal(a_fromMultiplier, a_toMultiplier, a_seconds, a_reason);
    }

    static void ClearTimeMultiplierRamp(RE::StaticFunctionTag*, std::string a_reason)
    {
        ClearTimeMultiplierRampInternal(a_reason);
    }

    static bool TryStartFeatUnlockSlowMo(RE::StaticFunctionTag*, float a_seconds, std::string a_reason)
    {
        return TryStartFeatUnlockSlowMoInternal(a_seconds, a_reason);
    }

    static void ReleaseFeatUnlockSlowMo(RE::StaticFunctionTag*, float a_seconds, std::string a_reason)
    {
        ReleaseFeatUnlockSlowMoInternal(a_seconds, a_reason);
    }

    static void ClearFeatUnlockSlowMo(RE::StaticFunctionTag*, std::string a_reason)
    {
        ClearFeatUnlockSlowMoInternal(a_reason);
    }
}

    void ResetDeathSlowMoTracking()
    {
        std::scoped_lock lock(g_deathSlowMo.lock);
        ResetDeathSlowMoStateLocked();
    }

    void RestoreDeathSlowMo(std::string a_reason)
    {
        QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, 1.0f, a_reason.empty() ? "restore" : a_reason.c_str(), true, true, TimeMultiplierWriteMode::kRestore);
    }

    void OnHealthDepleted(double a_nowWallSec)
    {
        StartDeathSlowMo(a_nowWallSec, "death-detected");
    }

    void TickDeathSlowMo(double a_nowWallSec)
    {
        bool shouldMaintainSlowmo = false;
        bool shouldStartSlowmoRecovery = false;
        bool shouldRecoverSlowmo = false;
        bool shouldCompleteSlowmoRecovery = false;
        bool shouldCompleteHoldTransition = false;
        bool watchdogReleased = false;
        float maintainSlowmoMultiplier = kDeathSlowmoMultiplier;
        float recoverSlowmoMultiplier = 1.0f;
        float completeHoldMultiplier = 1.0f;
        double recoverySeconds = 0.0;
        {
            std::scoped_lock lock(g_deathSlowMo.lock);

            if (g_deathSlowMo.slowmoHeld) {
                if (g_deathSlowMo.slowmoHoldStartedAtSec <= 0.0) {
                    g_deathSlowMo.slowmoHoldStartedAtSec = a_nowWallSec;
                }
                maintainSlowmoMultiplier = g_deathSlowMo.slowmoHoldMultiplier;
                if ((a_nowWallSec - g_deathSlowMo.slowmoHoldStartedAtSec) >= kDeathSlowmoWatchdogSeconds) {
                    ResetDeathSlowMoStateLocked();
                    shouldCompleteSlowmoRecovery = true;
                    watchdogReleased = true;
                } else {
                    shouldMaintainSlowmo = true;
                }
            }

            if (g_deathSlowMo.slowmoReleasePending && a_nowWallSec >= g_deathSlowMo.slowmoReleaseStartAtSec) {
                g_deathSlowMo.slowmoReleasePending = false;
                g_deathSlowMo.slowmoHeld = false;
                if (g_deathSlowMo.slowmoRecoverySeconds <= 0.0) {
                    ResetDeathSlowMoStateLocked();
                    shouldCompleteSlowmoRecovery = true;
                } else {
                    g_deathSlowMo.slowmoRecovering = true;
                    g_deathSlowMo.slowmoRecoverStartAtSec = a_nowWallSec;
                    g_deathSlowMo.slowmoRecoverEndAtSec = a_nowWallSec + g_deathSlowMo.slowmoRecoverySeconds;
                    g_deathSlowMo.slowmoRecoverFromMultiplier = g_deathSlowMo.slowmoHoldMultiplier;
                    g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                    g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
                    recoverySeconds = g_deathSlowMo.slowmoRecoverySeconds;
                    shouldStartSlowmoRecovery = true;
                }
            }

            if (g_deathSlowMo.slowmoRecovering) {
                const double recoverDuration = g_deathSlowMo.slowmoRecoverEndAtSec - g_deathSlowMo.slowmoRecoverStartAtSec;
                if (recoverDuration <= 0.0 || a_nowWallSec >= g_deathSlowMo.slowmoRecoverEndAtSec) {
                    if (g_deathSlowMo.slowmoRecoverReleaseOnComplete) {
                        ResetDeathSlowMoStateLocked();
                        shouldCompleteSlowmoRecovery = true;
                    } else {
                        g_deathSlowMo.slowmoHeld = true;
                        g_deathSlowMo.slowmoReleasePending = false;
                        g_deathSlowMo.slowmoRecovering = false;
                        g_deathSlowMo.slowmoHoldStartedAtSec = a_nowWallSec;
                        g_deathSlowMo.slowmoReleaseStartAtSec = 0.0;
                        g_deathSlowMo.slowmoRecoverySeconds = 0.0;
                        g_deathSlowMo.slowmoRecoverStartAtSec = 0.0;
                        g_deathSlowMo.slowmoRecoverEndAtSec = 0.0;
                        g_deathSlowMo.slowmoRecoverFromMultiplier = g_deathSlowMo.slowmoHoldMultiplier;
                        g_deathSlowMo.slowmoRecoverToMultiplier = 1.0f;
                        g_deathSlowMo.slowmoRecoverReleaseOnComplete = true;
                        completeHoldMultiplier = g_deathSlowMo.slowmoHoldMultiplier;
                        shouldCompleteHoldTransition = true;
                    }
                } else {
                    const double tRaw = (a_nowWallSec - g_deathSlowMo.slowmoRecoverStartAtSec) / recoverDuration;
                    const float t = std::clamp(static_cast<float>(tRaw), 0.0f, 1.0f);
                    const float recoverFromMultiplier = g_deathSlowMo.slowmoRecoverFromMultiplier;
                    const float recoverToMultiplier = g_deathSlowMo.slowmoRecoverToMultiplier;
                    recoverSlowmoMultiplier = recoverFromMultiplier + ((recoverToMultiplier - recoverFromMultiplier) * t);
                    shouldRecoverSlowmo = true;
                }
            }
        }

        if (shouldStartSlowmoRecovery && InfoLoggingEnabled()) {
            logger::info("DeathSlowMo: recovery start seconds={}", recoverySeconds);
        }
        if (watchdogReleased) {
            logger::warn("DeathSlowMo: watchdog restored time multiplier after {}s", kDeathSlowmoWatchdogSeconds);
        }
        if (shouldMaintainSlowmo) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, maintainSlowmoMultiplier, "slowmo-maintain", false);
        }
        if (shouldRecoverSlowmo) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, recoverSlowmoMultiplier, "slowmo-recover", false, false, TimeMultiplierWriteMode::kRestore);
        }
        if (shouldCompleteHoldTransition) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, completeHoldMultiplier, "slowmo-transition-hold-end", true);
        }
        if (shouldCompleteSlowmoRecovery) {
            QueueSetOwnedTimeMultiplier(TimeMultiplierOwner::kDeathSlowMo, 1.0f, watchdogReleased ? "slowmo-watchdog" : "slowmo-recover-end", true, true, TimeMultiplierWriteMode::kRestore);
        }
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("HoldDeathSlowMo", kScriptName, HoldDeathSlowMo);
        a_vm->RegisterFunction("ReleaseDeathSlowMo", kScriptName, ReleaseDeathSlowMo);
        a_vm->RegisterFunction("ReleaseDeathSlowMoWithHold", kScriptName, ReleaseDeathSlowMoWithHold);
        a_vm->RegisterFunction("TransitionDeathSlowMoToHold", kScriptName, TransitionDeathSlowMoToHold);
        a_vm->RegisterFunction("ClearDeathSlowMo", kScriptName, ClearDeathSlowMo);
        a_vm->RegisterFunction("StartTimeMultiplierRamp", kScriptName, StartTimeMultiplierRamp);
        a_vm->RegisterFunction("ClearTimeMultiplierRamp", kScriptName, ClearTimeMultiplierRamp);
        a_vm->RegisterFunction("TryStartFeatUnlockSlowMo", kScriptName, TryStartFeatUnlockSlowMo);
        a_vm->RegisterFunction("ReleaseFeatUnlockSlowMo", kScriptName, ReleaseFeatUnlockSlowMo);
        a_vm->RegisterFunction("ClearFeatUnlockSlowMo", kScriptName, ClearFeatUnlockSlowMo);
    }
}
