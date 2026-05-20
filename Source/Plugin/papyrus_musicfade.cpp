#include "pch.h"
#include "papyrus_musicfade.h"
#include "papyrus_common.h"
#include "config.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <thread>

namespace IronSoul::Papyrus::MusicFade
{
namespace
{
    static constexpr const char* kMusicFadeSetVolumeEvent = "IronSoul_MusicFadeSetVolume";

        struct MusicFadeState
        {
            std::mutex lock;
            std::atomic<std::uint64_t> token{ 0 };
            std::thread worker;
            std::atomic<bool> warnedMissingSink{ false };
            std::atomic<bool> warnedMissingCategory{ false };
            float currentVolume{ 1.0f };
            float cachedMenuVolume{ -1.0f };
            bool cachedMenuVolumeValid{ false };

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
            std::int32_t mode{ -1 };               // -1=disabled, 0=force mute restore, 1=force full restore
            bool enabled{ false };
            float effectiveMenuVolume{ 1.0f };     // valid only when enabled
        };
        MusicVolumeOverrideState g_musicVolumeOverride;

        static float Clamp01(float a_value)
        {
            return std::clamp(a_value, 0.0f, 1.0f);
        }

        static void QueueSetMusicVolume(RE::FormID a_categoryFormID, float a_volume, std::uint64_t a_token)
        {
            auto* task = SKSE::GetTaskInterface();
            if (!task || a_categoryFormID == 0) {
                logger::warn("Music fade: QueueSetMusicVolume skipped (task={} formID={})", task ? "ok" : "null", a_categoryFormID);
                return;
            }

            const float v = Clamp01(a_volume);
            task->AddTask([a_categoryFormID, v, a_token]() {
                if (g_musicFade.token.load() != a_token) {
                    return;
                }

                auto* modCallbacks = SKSE::GetModCallbackEventSource();
                if (!modCallbacks) {
                    if (!g_musicFade.warnedMissingSink.exchange(true)) {
                        logger::warn("Music fade: mod callback source unavailable");
                    }
                    return;
                }

                auto* category = RE::TESForm::LookupByID<RE::BGSSoundCategory>(a_categoryFormID);
                if (!category) {
                    if (!g_musicFade.warnedMissingCategory.exchange(true)) {
                        logger::warn("Music fade: SoundCategory lookup failed for formID={}", a_categoryFormID);
                    }
                    return;
                }

                const SKSE::ModCallbackEvent ev(kMusicFadeSetVolumeEvent, "", v, category);
                modCallbacks->SendEvent(&ev);
            });
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

        static void StartMusicFade(RE::FormID a_categoryFormID, float a_targetVolume, float a_seconds)
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
                logger::info("Music fade: start request token={} formID={} target={} seconds={}", myToken, a_categoryFormID, target, seconds);
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
                    logger::info("Music fade: worker begin token={} start={} target={} seconds={}", myToken, start, target, seconds);
                }
                g_musicFade.worker = std::thread([myToken, a_categoryFormID, start, target, seconds]() {
                if (seconds <= 0.0f) {
                    if (g_musicFade.token.load() != myToken) {
                        if (InfoLoggingEnabled()) {
                            logger::info("Music fade: immediate set canceled token={}", myToken);
                        }
                        return;
                    }
                    QueueSetMusicVolume(a_categoryFormID, target, myToken);
                    std::scoped_lock lock(g_musicFade.lock);
                    g_musicFade.currentVolume = target;
                    if (InfoLoggingEnabled()) {
                        logger::info("Music fade: immediate set complete token={} value={}", myToken, target);
                    }
                    return;
                }

                constexpr int kSteps = 20;
                const auto stepSleep = std::chrono::duration<float>(seconds / static_cast<float>(kSteps));

                for (int i = 1; i <= kSteps; ++i) {
                    if (g_musicFade.token.load() != myToken) {
                        if (InfoLoggingEnabled()) {
                            logger::info("Music fade: worker canceled token={} step={}/{}", myToken, i, kSteps);
                        }
                        return;
                    }

                    const float t = static_cast<float>(i) / static_cast<float>(kSteps);
                    const float v = start + (target - start) * t;
                    QueueSetMusicVolume(a_categoryFormID, v, myToken);

                    {
                        std::scoped_lock lock(g_musicFade.lock);
                        g_musicFade.currentVolume = Clamp01(v);
                    }

                    if (!SleepCancelable(myToken, stepSleep)) {
                        if (InfoLoggingEnabled()) {
                            logger::info("Music fade: sleep canceled token={} step={}/{}", myToken, i, kSteps);
                        }
                        return;
                    }
                }
                if (InfoLoggingEnabled()) {
                    logger::info("Music fade: worker complete token={} final={}", myToken, target);
                }
                });
            }
        }
}

    void RefreshMusicVolumeOverrideCache()
        {
            std::int32_t mode = IronSoul::Config::GetInt("MusicVolumeOverride", -1);
            if (mode != -1 && mode != 0 && mode != 1) {
                logger::warn("MusicFade: invalid MusicVolumeOverride={} (expected -1/0/1). Falling back to -1.", mode);
                mode = -1;
            }

            const bool enabled = (mode == 0 || mode == 1);
            const float effective = (mode == 0) ? 0.0f : 1.0f;
            {
                std::scoped_lock lock(g_musicVolumeOverride.lock);
                g_musicVolumeOverride.mode = mode;
                g_musicVolumeOverride.enabled = enabled;
                g_musicVolumeOverride.effectiveMenuVolume = effective;
            }

            if (InfoLoggingEnabled()) {
                logger::info(
                    "MusicFade: MusicVolumeOverride cached mode={} enabled={} effectiveMenuVolume={}",
                    mode,
                    enabled ? 1 : 0,
                    enabled ? effective : -1.0f);
            }
        }

namespace
{
    static void MusicFadeOut(RE::StaticFunctionTag*, RE::BGSSoundCategory* a_musicCategory, float a_seconds, float a_menuVolume)
    {
        if (IronSoul::Config::GetInt("MusicFade", 1) == 0) {
            return;
        }

        if (!a_musicCategory) {
            logger::warn("MusicFadeOut: null SoundCategory");
            return;
        }

        const RE::FormID formID = a_musicCategory->GetFormID();
        float effectiveMenuVolume = a_menuVolume;
        std::int32_t overrideMode = -1;
        bool usingOverride = false;
        {
            std::scoped_lock lock(g_musicVolumeOverride.lock);
            overrideMode = g_musicVolumeOverride.mode;
            usingOverride = g_musicVolumeOverride.enabled;
            if (usingOverride) {
                effectiveMenuVolume = g_musicVolumeOverride.effectiveMenuVolume;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MusicFadeOut: formID={} seconds={} menuVolumeIn={} effectiveMenuVolume={} source={} overrideMode={}",
                formID,
                a_seconds,
                a_menuVolume,
                effectiveMenuVolume,
                usingOverride ? "override" : "papyrus",
                overrideMode);
        }
        {
            std::scoped_lock lock(g_musicFade.lock);

            if (effectiveMenuVolume >= 0.0f) {
                g_musicFade.cachedMenuVolume = Clamp01(effectiveMenuVolume);
                g_musicFade.cachedMenuVolumeValid = true;
            } else if (!g_musicFade.cachedMenuVolumeValid) {
                g_musicFade.cachedMenuVolume = 1.0f;
                g_musicFade.cachedMenuVolumeValid = true;
            }

            if (g_musicFade.currentVolume >= 0.999f) {
                g_musicFade.currentVolume = g_musicFade.cachedMenuVolume;
            }

            if (InfoLoggingEnabled()) {
                logger::info(
                    "MusicFadeOut: cache valid={} cachedMenu={} currentVolume={}",
                    g_musicFade.cachedMenuVolumeValid ? 1 : 0,
                    g_musicFade.cachedMenuVolume,
                    g_musicFade.currentVolume);
            }
        }

        StartMusicFade(formID, 0.0f, a_seconds);
    }

    static void MusicFadeIn(RE::StaticFunctionTag*, RE::BGSSoundCategory* a_musicCategory, float a_seconds)
    {
        if (IronSoul::Config::GetInt("MusicFade", 1) == 0) {
            return;
        }

        if (!a_musicCategory) {
            logger::warn("MusicFadeIn: null SoundCategory");
            return;
        }

        const RE::FormID formID = a_musicCategory->GetFormID();
        float target = 1.0f;
        if (InfoLoggingEnabled()) {
            logger::info("MusicFadeIn: formID={} seconds={}", formID, a_seconds);
        }

        {
            std::scoped_lock lock(g_musicFade.lock);
            if (!g_musicFade.cachedMenuVolumeValid) {
                if (InfoLoggingEnabled()) {
                    logger::info("MusicFadeIn: no cached menu volume; using 1.0");
                }
                target = 1.0f;
            } else {
                target = Clamp01(g_musicFade.cachedMenuVolume);
            }
            if (InfoLoggingEnabled()) {
                logger::info(
                    "MusicFadeIn: cache valid={} cachedMenu={} currentVolume={} target={}",
                    g_musicFade.cachedMenuVolumeValid ? 1 : 0,
                    g_musicFade.cachedMenuVolume,
                    g_musicFade.currentVolume,
                    target);
            }
            g_musicFade.cachedMenuVolumeValid = false;
            g_musicFade.cachedMenuVolume = -1.0f;
        }

        StartMusicFade(formID, target, a_seconds);
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("MusicFadeOut", kScriptName, MusicFadeOut);
        a_vm->RegisterFunction("MusicFadeIn", kScriptName, MusicFadeIn);
    }
}