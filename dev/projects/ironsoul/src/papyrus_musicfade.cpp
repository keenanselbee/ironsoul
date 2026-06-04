#include "pch.h"
#include "papyrus_musicfade.h"
#include "papyrus_common.h"
#include "config.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <string>
#include <thread>

namespace IronSoul::Papyrus::MusicFade
{
namespace
{
    static constexpr const char* kMusicFadeCompleteEvent = "IronSoul_MusicFadeComplete";

    struct MusicFadeState
    {
        std::mutex operationLock;
        std::mutex lock;
        std::atomic<std::uint64_t> token{ 0 };
        std::thread worker;
        std::atomic<bool> warnedMissingSink{ false };
        std::atomic<bool> warnedMissingCategory{ false };
        float currentVolume{ 1.0f };
        float cachedMenuVolume{ -1.0f };
        bool cachedMenuVolumeValid{ false };
        bool sessionActive{ false };
        bool loadRecoveryRequired{ false };

        ~MusicFadeState()
        {
            token.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };

    MusicFadeState g_musicFade;
    struct MusicVolumeOverrideState
    {
        std::mutex lock;
        std::int32_t percent{ -1 };            // -1=disabled, 0..100=forced restore percent
        bool enabled{ false };
        float effectiveMenuVolume{ 1.0f };     // valid only when enabled
    };
    MusicVolumeOverrideState g_musicVolumeOverride;

    static float Clamp01(float a_value)
    {
        return std::clamp(a_value, 0.0f, 1.0f);
    }

    static bool CanStartMusicFade(RE::FormID a_categoryFormID, const char* a_operation)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task || a_categoryFormID == 0) {
            logger::warn(
                "{}: cannot start fade (task={} formID={})",
                a_operation ? a_operation : "MusicFade",
                task ? "ok" : "null",
                a_categoryFormID);
            return false;
        }
        return true;
    }

    static void SendMusicFadeComplete(RE::BGSSoundCategory* a_category, const std::string& a_phase, float a_volume)
    {
        auto* modCallbacks = SKSE::GetModCallbackEventSource();
        if (!modCallbacks) {
            if (!g_musicFade.warnedMissingSink.exchange(true)) {
                logger::warn("Music fade: mod callback source unavailable");
            }
            return;
        }

        const SKSE::ModCallbackEvent ev(kMusicFadeCompleteEvent, a_phase.c_str(), Clamp01(a_volume), a_category);
        modCallbacks->SendEvent(&ev);
    }

    static bool QueueSetMusicVolume(RE::FormID a_categoryFormID, float a_volume, std::uint64_t a_token)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task || a_categoryFormID == 0) {
            logger::warn("Music fade: QueueSetMusicVolume skipped (task={} formID={})", task ? "ok" : "null", a_categoryFormID);
            return false;
        }

        const float v = Clamp01(a_volume);
        task->AddTask([a_categoryFormID, v, a_token]() {
            std::scoped_lock operationGuard(g_musicFade.operationLock);
            if (g_musicFade.token.load() != a_token) {
                return;
            }

            auto* category = RE::TESForm::LookupByID<RE::BGSSoundCategory>(a_categoryFormID);
            if (!category) {
                if (!g_musicFade.warnedMissingCategory.exchange(true)) {
                    logger::warn("Music fade: SoundCategory lookup failed for formID={}", a_categoryFormID);
                }
                return;
            }

            if (g_musicFade.token.load() != a_token) {
                return;
            }

            category->SetCategoryVolume(v);

            std::scoped_lock lock(g_musicFade.lock);
            if (g_musicFade.token.load() != a_token) {
                return;
            }
            g_musicFade.currentVolume = v;
        });
        return true;
    }

    static bool QueueMusicFadeFinalize(
        RE::FormID a_categoryFormID,
        const std::string& a_phase,
        float a_volume,
        std::uint64_t a_token)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task || a_categoryFormID == 0) {
            logger::error(
                "Music fade: finalization could not queue phase={} token={} task={} formID={}; session retained",
                a_phase,
                a_token,
                task ? "ok" : "null",
                a_categoryFormID);
            return false;
        }

        const float v = Clamp01(a_volume);
        task->AddTask([a_categoryFormID, phase = a_phase, v, a_token]() {
            RE::BGSSoundCategory* category = nullptr;
            {
                std::scoped_lock operationGuard(g_musicFade.operationLock);
                if (g_musicFade.token.load() != a_token) {
                    return;
                }

                category = RE::TESForm::LookupByID<RE::BGSSoundCategory>(a_categoryFormID);
                if (!category) {
                    logger::error(
                        "Music fade: finalization category lookup failed phase={} token={} formID={}; session retained",
                        phase,
                        a_token,
                        a_categoryFormID);
                    return;
                }

                if (g_musicFade.token.load() != a_token) {
                    return;
                }

                category->SetCategoryVolume(v);

                std::scoped_lock lock(g_musicFade.lock);
                if (g_musicFade.token.load() != a_token) {
                    return;
                }
                g_musicFade.currentVolume = v;
                if (phase == "in") {
                    g_musicFade.sessionActive = false;
                }
            }

            if (InfoLoggingEnabled()) {
                logger::info("Music fade: finalization completed token={} phase={} final={}", a_token, phase, v);
            }
            SendMusicFadeComplete(category, phase, v);
        });
        return true;
    }

    static bool QueueMusicFadeRecovery(RE::FormID a_categoryFormID, float a_volume, std::uint64_t a_token)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task || a_categoryFormID == 0) {
            logger::warn("Music fade: QueueMusicFadeRecovery skipped (task={} formID={})", task ? "ok" : "null", a_categoryFormID);
            return false;
        }

        const float v = Clamp01(a_volume);
        task->AddTask([a_categoryFormID, v, a_token]() {
            RE::BGSSoundCategory* category = nullptr;
            {
                std::scoped_lock operationGuard(g_musicFade.operationLock);
                if (g_musicFade.token.load() != a_token) {
                    return;
                }

                category = RE::TESForm::LookupByID<RE::BGSSoundCategory>(a_categoryFormID);
                if (!category) {
                    logger::error(
                        "Music fade: load recovery category lookup failed token={} formID={}; recovery retained",
                        a_token,
                        a_categoryFormID);
                    return;
                }

                if (g_musicFade.token.load() != a_token) {
                    return;
                }

                category->SetCategoryVolume(v);

                std::scoped_lock lock(g_musicFade.lock);
                if (g_musicFade.token.load() != a_token) {
                    return;
                }
                g_musicFade.currentVolume = v;
                g_musicFade.sessionActive = false;
                g_musicFade.loadRecoveryRequired = false;
            }

            if (InfoLoggingEnabled()) {
                logger::info("Music fade: load recovery completed token={} final={}", a_token, v);
            }
            SendMusicFadeComplete(category, "in", v);
        });
        return true;
    }

    static bool SleepCancelable(std::uint64_t a_token, std::chrono::duration<float> a_totalSleep)
    {
        constexpr auto kSlice = std::chrono::milliseconds(10);
        const auto endAt = std::chrono::steady_clock::now() + a_totalSleep;

        while (true) {
            if (g_musicFade.token.load() != a_token) {
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

    static bool CancelMusicFadeForLoadBoundaryLocked(const char* a_reason, bool a_markRecovery)
    {
        const auto newToken = g_musicFade.token.fetch_add(1) + 1;
        std::thread oldWorker;
        bool sessionWasActive = false;
        bool recoveryRequired = false;

        {
            std::scoped_lock lock(g_musicFade.lock);
            sessionWasActive = g_musicFade.sessionActive;
            if (a_markRecovery && sessionWasActive) {
                g_musicFade.loadRecoveryRequired = true;
            }

            g_musicFade.sessionActive = false;
            g_musicFade.cachedMenuVolume = -1.0f;
            g_musicFade.cachedMenuVolumeValid = false;
            recoveryRequired = g_musicFade.loadRecoveryRequired;

            if (g_musicFade.worker.joinable()) {
                oldWorker = std::move(g_musicFade.worker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "Music fade: load boundary canceled token={} reason={} sessionWasActive={} recoveryRequired={}",
                newToken,
                a_reason ? a_reason : "unknown",
                sessionWasActive ? 1 : 0,
                recoveryRequired ? 1 : 0);
        }
        return recoveryRequired;
    }

    static bool CancelMusicFadeForLoadBoundary(const char* a_reason, bool a_markRecovery)
    {
        std::scoped_lock operationGuard(g_musicFade.operationLock);
        return CancelMusicFadeForLoadBoundaryLocked(a_reason, a_markRecovery);
    }

    static void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (a_message && a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
            CancelMusicFadeForLoadBoundary("pre-load", true);
        }
    }

    static void StartMusicFadeLocked(RE::FormID a_categoryFormID, float a_targetVolume, float a_seconds, std::string a_phase)
    {
        if (a_categoryFormID == 0) {
            logger::warn("Music fade: StartMusicFade skipped (invalid formID)");
            return;
        }

        const float target = Clamp01(a_targetVolume);
        const float seconds = (std::max)(0.0f, a_seconds);
        float start = 1.0f;
        std::thread oldWorker;

        {
            std::scoped_lock lock(g_musicFade.lock);
            if (g_musicFade.worker.joinable()) {
                oldWorker = std::move(g_musicFade.worker);
            }
        }

        const std::uint64_t myToken = g_musicFade.token.fetch_add(1) + 1;
        if (InfoLoggingEnabled()) {
            logger::info("Music fade: start request token={} phase={} formID={} target={} seconds={}", myToken, a_phase, a_categoryFormID, target, seconds);
        }

        if (oldWorker.joinable()) {
            if (InfoLoggingEnabled()) {
                logger::info("Music fade: waiting for previous worker");
            }
            oldWorker.join();
            if (InfoLoggingEnabled()) {
                logger::info("Music fade: previous worker joined");
            }
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            start = Clamp01(g_musicFade.currentVolume);
            if (InfoLoggingEnabled()) {
                logger::info("Music fade: worker begin token={} phase={} start={} target={} seconds={}", myToken, a_phase, start, target, seconds);
            }
            g_musicFade.worker = std::thread([myToken, a_categoryFormID, start, target, seconds, phase = std::move(a_phase)]() {
            if (seconds <= 0.0f) {
                if (g_musicFade.token.load() != myToken) {
                    if (InfoLoggingEnabled()) {
                        logger::info("Music fade: immediate set canceled token={} phase={}", myToken, phase);
                    }
                    return;
                }
                if (QueueMusicFadeFinalize(a_categoryFormID, phase, target, myToken) && InfoLoggingEnabled()) {
                    logger::info("Music fade: immediate finalization queued token={} phase={} value={}", myToken, phase, target);
                }
                return;
            }

            constexpr int kSteps = 20;
            const auto stepSleep = std::chrono::duration<float>(seconds / static_cast<float>(kSteps));

            for (int i = 1; i <= kSteps; ++i) {
                if (g_musicFade.token.load() != myToken) {
                    if (InfoLoggingEnabled()) {
                        logger::info("Music fade: worker canceled token={} phase={} step={}/{}", myToken, phase, i, kSteps);
                    }
                    return;
                }

                const float t = static_cast<float>(i) / static_cast<float>(kSteps + 1);
                const float v = start + (target - start) * t;
                QueueSetMusicVolume(a_categoryFormID, v, myToken);

                if (!SleepCancelable(myToken, stepSleep)) {
                    if (InfoLoggingEnabled()) {
                        logger::info("Music fade: sleep canceled token={} phase={} step={}/{}", myToken, phase, i, kSteps);
                    }
                    return;
                }
            }

            if (QueueMusicFadeFinalize(a_categoryFormID, phase, target, myToken) && InfoLoggingEnabled()) {
                logger::info("Music fade: finalization queued token={} phase={} final={}", myToken, phase, target);
            }
            });
        }
    }
}

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("Music fade: messaging interface unavailable; pre-load cancellation disabled");
            return;
        }

        if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("Music fade: failed to register pre-load cancellation listener");
            return;
        }

        logger::info("Music fade: pre-load cancellation listener registered");
    }

    void RefreshMusicVolumeOverrideCache()
    {
        std::int32_t percent = IronSoul::Config::GetInt("MusicVolumeOverride", -1);
        if (percent != -1 && (percent < 0 || percent > 100)) {
            logger::warn("MusicFade: invalid MusicVolumeOverride={} (expected -1/0..100). Falling back to -1.", percent);
            percent = -1;
        }

        const bool enabled = (percent >= 0);
        const float effective = enabled ? (static_cast<float>(percent) / 100.0f) : 1.0f;
        {
            std::scoped_lock lock(g_musicVolumeOverride.lock);
            g_musicVolumeOverride.percent = percent;
            g_musicVolumeOverride.enabled = enabled;
            g_musicVolumeOverride.effectiveMenuVolume = effective;
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MusicFade: MusicVolumeOverride cached percent={} enabled={} effectiveMenuVolume={}",
                percent,
                enabled ? 1 : 0,
                enabled ? effective : -1.0f);
        }
    }

namespace
{
    static bool MusicFadeIsActive(RE::StaticFunctionTag*)
    {
        std::scoped_lock lock(g_musicFade.lock);
        return g_musicFade.sessionActive || g_musicFade.loadRecoveryRequired;
    }

    static bool MusicFadeRecoverAfterLoad(RE::StaticFunctionTag*, RE::BGSSoundCategory* a_musicCategory, float a_fallbackMenuVolume, bool a_savedFadeActive)
    {
        std::scoped_lock operationGuard(g_musicFade.operationLock);
        const bool nativeRecoveryRequired = CancelMusicFadeForLoadBoundaryLocked("post-load-recovery", true);
        const bool recoveryRequired = nativeRecoveryRequired || a_savedFadeActive;
        if (!recoveryRequired) {
            if (InfoLoggingEnabled()) {
                logger::info("MusicFadeRecoverAfterLoad: no recovery required");
            }
            return false;
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            g_musicFade.loadRecoveryRequired = true;
        }

        if (!a_musicCategory) {
            logger::error(
                "MusicFadeRecoverAfterLoad: recovery required but SoundCategory is null savedFadeActive={} nativeRecoveryRequired={}",
                a_savedFadeActive ? 1 : 0,
                nativeRecoveryRequired ? 1 : 0);
            return true;
        }

        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::error(
                "MusicFadeRecoverAfterLoad: recovery required but task interface is unavailable savedFadeActive={} nativeRecoveryRequired={}",
                a_savedFadeActive ? 1 : 0,
                nativeRecoveryRequired ? 1 : 0);
            return true;
        }

        float target = 1.0f;
        const char* source = "default";
        if (a_fallbackMenuVolume >= 0.0f && a_fallbackMenuVolume <= 1.0f) {
            target = Clamp01(a_fallbackMenuVolume);
            source = "papyrus-cache";
        }

        std::int32_t overridePercent = -1;
        {
            std::scoped_lock lock(g_musicVolumeOverride.lock);
            overridePercent = g_musicVolumeOverride.percent;
            if (g_musicVolumeOverride.enabled) {
                target = g_musicVolumeOverride.effectiveMenuVolume;
                source = "override";
            }
        }

        const auto formID = a_musicCategory->GetFormID();
        if (formID == 0) {
            logger::error(
                "MusicFadeRecoverAfterLoad: recovery required but SoundCategory formID is invalid savedFadeActive={} nativeRecoveryRequired={}",
                a_savedFadeActive ? 1 : 0,
                nativeRecoveryRequired ? 1 : 0);
            return true;
        }

        const auto recoveryToken = g_musicFade.token.fetch_add(1) + 1;
        {
            std::scoped_lock lock(g_musicFade.lock);
            g_musicFade.cachedMenuVolume = -1.0f;
            g_musicFade.cachedMenuVolumeValid = false;
            g_musicFade.sessionActive = true;
            g_musicFade.loadRecoveryRequired = true;
        }

        if (!QueueMusicFadeRecovery(formID, target, recoveryToken)) {
            logger::error(
                "MusicFadeRecoverAfterLoad: failed to queue atomic recovery token={} formID={}; recovery retained",
                recoveryToken,
                formID);
            return true;
        }

        logger::info(
            "MusicFadeRecoverAfterLoad: restoring token={} formID={} target={} source={} overridePercent={} savedFadeActive={} nativeRecoveryRequired={}",
            recoveryToken,
            formID,
            target,
            source,
            overridePercent,
            a_savedFadeActive ? 1 : 0,
            nativeRecoveryRequired ? 1 : 0);

        return true;
    }

    static void MusicFadeOut(RE::StaticFunctionTag*, RE::BGSSoundCategory* a_musicCategory, float a_seconds, float a_menuVolume)
    {
        std::scoped_lock operationGuard(g_musicFade.operationLock);
        if (IronSoul::Config::GetInt("MusicFade", 1) == 0) {
            return;
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            if (g_musicFade.loadRecoveryRequired) {
                if (InfoLoggingEnabled()) {
                    logger::info("MusicFadeOut: skipped while load recovery is pending");
                }
                return;
            }
        }

        if (!a_musicCategory) {
            logger::warn("MusicFadeOut: null SoundCategory");
            return;
        }

        const RE::FormID formID = a_musicCategory->GetFormID();
        if (!CanStartMusicFade(formID, "MusicFadeOut")) {
            return;
        }

        float effectiveMenuVolume = a_menuVolume;
        std::int32_t overridePercent = -1;
        bool usingOverride = false;
        {
            std::scoped_lock lock(g_musicVolumeOverride.lock);
            overridePercent = g_musicVolumeOverride.percent;
            usingOverride = g_musicVolumeOverride.enabled;
            if (usingOverride) {
                effectiveMenuVolume = g_musicVolumeOverride.effectiveMenuVolume;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MusicFadeOut: formID={} seconds={} menuVolumeIn={} effectiveMenuVolume={} source={} overridePercent={}",
                formID,
                a_seconds,
                a_menuVolume,
                effectiveMenuVolume,
                usingOverride ? "override" : "papyrus",
                overridePercent);
        }
        {
            std::scoped_lock lock(g_musicFade.lock);
            const bool continuingSession = g_musicFade.sessionActive;

            if (effectiveMenuVolume >= 0.0f) {
                g_musicFade.cachedMenuVolume = Clamp01(effectiveMenuVolume);
                g_musicFade.cachedMenuVolumeValid = true;
            } else if (!g_musicFade.cachedMenuVolumeValid) {
                g_musicFade.cachedMenuVolume = 1.0f;
                g_musicFade.cachedMenuVolumeValid = true;
            }

            if (!continuingSession) {
                g_musicFade.currentVolume = g_musicFade.cachedMenuVolume;
            }
            g_musicFade.sessionActive = true;

            if (InfoLoggingEnabled()) {
                logger::info(
                    "MusicFadeOut: cache valid={} cachedMenu={} currentVolume={} continuingSession={}",
                    g_musicFade.cachedMenuVolumeValid ? 1 : 0,
                    g_musicFade.cachedMenuVolume,
                    g_musicFade.currentVolume,
                    continuingSession ? 1 : 0);
            }
        }

        StartMusicFadeLocked(formID, 0.0f, a_seconds, "out");
    }

    static void MusicFadeIn(RE::StaticFunctionTag*, RE::BGSSoundCategory* a_musicCategory, float a_seconds, float a_fallbackMenuVolume)
    {
        std::scoped_lock operationGuard(g_musicFade.operationLock);
        const bool musicFadeEnabled = IronSoul::Config::GetInt("MusicFade", 1) != 0;
        bool activeSession = false;
        bool recoveryPending = false;
        {
            std::scoped_lock lock(g_musicFade.lock);
            activeSession = g_musicFade.sessionActive || g_musicFade.loadRecoveryRequired;
            recoveryPending = g_musicFade.loadRecoveryRequired;
        }

        if (recoveryPending) {
            if (InfoLoggingEnabled()) {
                logger::info("MusicFadeIn: skipped while atomic load recovery is pending");
            }
            return;
        }

        if (!musicFadeEnabled && !activeSession) {
            return;
        }

        if (!a_musicCategory) {
            logger::warn("MusicFadeIn: null SoundCategory");
            return;
        }

        if (!musicFadeEnabled && InfoLoggingEnabled()) {
            logger::info("MusicFadeIn: restoring active session despite MusicFade=0");
        }

        const RE::FormID formID = a_musicCategory->GetFormID();
        if (!CanStartMusicFade(formID, "MusicFadeIn")) {
            return;
        }

        float target = 1.0f;
        bool usingCachedTarget = false;
        if (InfoLoggingEnabled()) {
            logger::info("MusicFadeIn: formID={} seconds={} fallbackMenuVolume={}", formID, a_seconds, a_fallbackMenuVolume);
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            if (g_musicFade.cachedMenuVolumeValid) {
                target = Clamp01(g_musicFade.cachedMenuVolume);
                usingCachedTarget = true;
            }
            if (InfoLoggingEnabled()) {
                logger::info(
                    "MusicFadeIn: cache valid={} cachedMenu={} currentVolume={}",
                    g_musicFade.cachedMenuVolumeValid ? 1 : 0,
                    g_musicFade.cachedMenuVolume,
                    g_musicFade.currentVolume);
            }
            g_musicFade.cachedMenuVolumeValid = false;
            g_musicFade.cachedMenuVolume = -1.0f;
        }

        std::int32_t overridePercent = -1;
        bool usingOverride = false;
        if (!usingCachedTarget) {
            {
                std::scoped_lock lock(g_musicVolumeOverride.lock);
                overridePercent = g_musicVolumeOverride.percent;
                usingOverride = g_musicVolumeOverride.enabled;
                if (usingOverride) {
                    target = g_musicVolumeOverride.effectiveMenuVolume;
                }
            }

            if (!usingOverride) {
                if (a_fallbackMenuVolume >= 0.0f && a_fallbackMenuVolume <= 1.0f) {
                    target = a_fallbackMenuVolume;
                } else {
                    target = 1.0f;
                }
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MusicFadeIn: target={} source={} overridePercent={}",
                target,
                usingCachedTarget ? "cache" : (usingOverride ? "override" : "fallback"),
                overridePercent);
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            g_musicFade.sessionActive = true;
        }
        StartMusicFadeLocked(formID, target, a_seconds, "in");
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("MusicFadeIsActive", kScriptName, MusicFadeIsActive);
        a_vm->RegisterFunction("MusicFadeRecoverAfterLoad", kScriptName, MusicFadeRecoverAfterLoad);
        a_vm->RegisterFunction("MusicFadeOut", kScriptName, MusicFadeOut);
        a_vm->RegisterFunction("MusicFadeIn", kScriptName, MusicFadeIn);
    }
}
