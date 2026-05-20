#include "pch.h"
#include "datastore.h"
#include "papyrusbindings.h"
#include "config.h"
#include "journal.h"
#include "pathutil.h"

#include <random>
#include <format>
#include <cctype>
#include <filesystem>
#include <array>
#include <atomic>
#include <thread>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <string>
#include <limits>
#include <type_traits>
#include <utility>

namespace IronSoul::Papyrus
{
    // --- Native State ---
    // ====================

    // Script name that owns the global native functions.
    // In Papyrus you will call:
    //   IronSoulNative.LogJournalEntry(msg)  (plugin will prepend "Name [A+] | " when a preset label is active)
    //   int v = IronSoulNative.GetConfigInt("SomeKey", 0)
    static constexpr const char* kScriptName = "IronSoulNative";
    static constexpr const char* kMusicFadeSetVolumeEvent = "IronSoul_MusicFadeSetVolume";
    static bool InfoLoggingEnabled()
    {
        return IronSoul::Config::ShouldEmitInfoLog();
    }
    static bool DeathSlowMoEnabled()
    {
        return IronSoul::Config::GetInt("SlowMoOnDeath", 1) == 1;
    }

    // --- Runtime State ---
    // =====================
    namespace
    {
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
        struct CursorSuppressState
        {
            std::mutex lock;
            std::uint8_t suppressStep{ 0 };  // 0=idle, 1=moved-right, 2=hidden+offscreen-right
            bool savedPosValid{ false };
            bool savedVisibilityValid{ false };
            bool savedVisible{ true };
            float savedPosX{ 0.0f };
            float savedPosY{ 0.0f };
        };
        CursorSuppressState g_cursorSuppressState;

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

        static float Clamp01(float a_value)
        {
            return std::clamp(a_value, 0.0f, 1.0f);
        }

        static bool IsGamePausedByMenu()
        {
            auto* ui = RE::UI::GetSingleton();
            return ui && ui->GameIsPaused();
        }

        // --- Music Fade Runtime ---
        // ==========================

        static void RefreshMusicVolumeOverrideCache()
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
                logger::warn("SlowMoSFX: TESDataHandler unavailable");
                return false;
            }

            for (std::size_t i = 0; i < kSlowMoLocalFormIDs.size(); ++i) {
                auto* form = dataHandler->LookupForm(kSlowMoLocalFormIDs[i], kPluginName);
                auto* sound = form ? form->As<RE::BGSSoundDescriptorForm>() : nullptr;
                if (!sound) {
                    logger::warn("SlowMoSFX: missing descriptor localID=0x{:06X} plugin='{}'", kSlowMoLocalFormIDs[i], kPluginName);
                    return false;
                }
                g_slowMoSfx.descriptors[i] = sound;
            }

            g_slowMoSfx.enabled = true;
            if (InfoLoggingEnabled()) {
                logger::info("SlowMoSFX: loaded {} descriptors", g_slowMoSfx.descriptors.size());
            }
            return true;
        }

        static void PlayRandomSlowMoSound()
        {
            if (IronSoul::Config::GetInt("SFX", 1) == 0) {
                return;
            }
            if (IronSoul::Config::GetInt("SlowMoSFX", 1) == 0) {
                return;
            }
            if (!EnsureSlowMoDescriptorsLoaded()) {
                return;
            }

            auto* audioMgr = RE::BSAudioManager::GetSingleton();
            if (!audioMgr) {
                logger::warn("SlowMoSFX: BSAudioManager unavailable");
                return;
            }

            RE::BGSSoundDescriptorForm* descriptor = nullptr;
            {
                std::scoped_lock lock(g_slowMoSfx.lock);
                std::uniform_int_distribution<std::size_t> dist(0, g_slowMoSfx.descriptors.size() - 1);
                descriptor = g_slowMoSfx.descriptors[dist(g_slowMoSfx.rng)];
            }

            if (!descriptor) {
                logger::warn("SlowMoSFX: descriptor cache empty");
                return;
            }

            RE::BSSoundHandle handle{};
            if (!audioMgr->BuildSoundDataFromDescriptor(handle, descriptor, 0x1A)) {
                logger::warn("SlowMoSFX: BuildSoundDataFromDescriptor failed");
                return;
            }
            if (!handle.IsValid()) {
                logger::warn("SlowMoSFX: invalid sound handle");
                return;
            }
            if (!handle.Play()) {
                logger::warn("SlowMoSFX: Play failed");
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

    static std::string Trim(std::string s)
    {
        const auto first = s.find_first_not_of(" \t\n\r");
        if (first == std::string::npos) {
            return {};
        }
        const auto last = s.find_last_not_of(" \t\n\r");
        return s.substr(first, last - first + 1);
    }

    static std::string ResolvePlayerName(bool a_fallbackToPrisoner)
    {
        // Player name can be unavailable very early (pre-RaceMenu / early load).
        // For journal logging we may want a stable fallback; for Papyrus callers we often
        // want an empty string so the controller can decide when identity is "ready".
        constexpr const char* kFallback = "Prisoner";
        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player) {
            return a_fallbackToPrisoner ? kFallback : std::string{};
        }

        std::string name = player->GetName();
        name = Trim(name);
        if (name.empty()) {
            return a_fallbackToPrisoner ? kFallback : std::string{};
        }
        return name;
    }

    static std::string GetPlayerName(RE::StaticFunctionTag*)
    {
        // Return empty if the name is not yet available (Papyrus uses this to gate GUID assignment).
        return ResolvePlayerName(false);
    }

    static char FirstGuidLetterFromName(const std::string& a_playerName)
    {
        // GUID prefix letter is derived from the character name (uppercase).
        // We skip leading whitespace and prefer the first ASCII alphabetic character.
        // If unavailable, fall back to 'P' (Prisoner).
        std::string name = Trim(a_playerName);
        for (unsigned char c : name) {
            if (std::isalpha(c)) {
                return static_cast<char>(std::toupper(c));
            }
        }
        return 'P';
    }

    static std::string GenerateGuidUnique(RE::StaticFunctionTag*, std::string a_playerName)
    {
        // GUID format (v2): "<LETTER><####>" where:
        //   - LETTER is the first letter of the player name (uppercase), fallback 'P'
        //   - #### is 1000-9999
        // Collision handling:
        //   - We maintain a dedicated collision index in MainData:
        //       "G.U.<GUID>" = 1
        //   - Generation checks for key existence and CLAIMS the GUID by writing the marker
        //     before returning it.
        // This avoids scanning the entire datastore.
        thread_local std::mt19937 rng{ std::random_device{}() };
        std::uniform_int_distribution<std::int32_t> dist(1000, 9999);

        const char prefix = FirstGuidLetterFromName(a_playerName);

        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = dist(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);

            // Atomically claim the GUID marker. If it already exists, it's a collision.
            if (IronSoul::DataStore::SetIntIfAbsent(usedKey, 1)) {
                if (attempt > 1) {
                    logger::warn("IronSoul GUID: collision(s) avoided; claimed '{}' on attempt {}", guid, attempt);
                }
                return guid;
            }
        }

        // Extremely unlikely fallback: widen the space slightly.
        std::uniform_int_distribution<std::int32_t> distWide(100000, 999999);
        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = distWide(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);
            if (IronSoul::DataStore::SetIntIfAbsent(usedKey, 1)) {
                logger::error("IronSoul GUID: exhausted 4-digit space; claimed widened GUID '{}'", guid);
                return guid;
            }
        }

        logger::critical("IronSoul GUID: failed to claim a unique GUID (unexpected)");
        return {};
    }

    // --- Core Native Bindings ---
    // ============================

    static bool IsAvailable(RE::StaticFunctionTag*)
    {
        // Simple probe to confirm the Iron Soul SKSE plugin is loaded and Papyrus natives are registered.
        return true;
    }

    static bool DataStoreReady(RE::StaticFunctionTag*)
    {
        // True once the native datastore has been initialized.
        return IronSoul::DataStore::IsInitialized();
    }

    // --- Journal Bindings ---
    // ========================

    static void LogJournalEntry(RE::StaticFunctionTag*, std::string a_message)
    {
        // Papyrus supplies the full event text (including punctuation).
        // The plugin prepends the current player name and separator.
        const std::string name = ResolvePlayerName(true);
        std::string msg = Trim(a_message);
        if (msg.empty()) {
            return;  // nothing to log
        }

        std::string difficultyLabel;
        const auto preset = IronSoul::Config::GetAllowedInt("IronSoulPreset", 0);
        if (preset >= 1 && preset <= 3) {
            if (preset == 1) {
                difficultyLabel = "[D]";
            } else if (preset == 2) {
                difficultyLabel = "[H]";
            } else {
                difficultyLabel = "[A]";
            }

            auto plusCount = IronSoul::Config::GetIronSoulPresetPlus();
            if (plusCount < 0) {
                plusCount = 0;
            } else if (plusCount > 2) {
                plusCount = 2;
            }
            if (plusCount > 0) {
                difficultyLabel.insert(difficultyLabel.size() - 1, static_cast<std::size_t>(plusCount), '+');
            }
        }

        std::string prefix = name;
        if (!difficultyLabel.empty()) {
            prefix += " " + difficultyLabel;
        }
        IronSoul::Journal::AppendLine(prefix + " | " + msg);
    }

    // --- Config Bindings ---
    // =======================

    static std::int32_t GetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_fallback)
    {
        return IronSoul::Config::GetAllowedInt(a_key, a_fallback);
    }

    static std::int32_t GetIronSoulPresetPlus(RE::StaticFunctionTag*)
    {
        return IronSoul::Config::GetIronSoulPresetPlus();
    }

    static bool SetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_value, bool a_persistToIni)
    {
        return IronSoul::Config::SetInt(a_key, a_value, a_persistToIni);
    }

    static bool SetConfigString(RE::StaticFunctionTag*, std::string a_key, std::string a_value, bool a_persistToIni)
    {
        return IronSoul::Config::SetString(a_key, a_value, a_persistToIni);
    }

    static bool ReloadConfig(RE::StaticFunctionTag*)
    {
        IronSoul::Config::Load();
        RefreshMusicVolumeOverrideCache();
        return true;
    }

    // --- DataStore Bindings ---
    // ==========================

    static int32_t DataGetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_fallback)
    {
        return IronSoul::DataStore::GetInt(a_key, a_fallback);
    }

    static void DataSetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        if (!IronSoul::DataStore::SetInt(a_key, a_value)) {
            logger::warn("DataSetInt rejected (invalid key): key='{}' keyLen={}", a_key, a_key.size());
        }
    }

    static bool DataSetIntIfChanged(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        return IronSoul::DataStore::SetIntIfChanged(a_key, a_value);
    }

    static bool DataSetIntChecked(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        return IronSoul::DataStore::SetIntChecked(a_key, a_value);
    }

    static std::string DataGetString(RE::StaticFunctionTag*, std::string a_key, std::string a_fallback)
    {
        return IronSoul::DataStore::GetString(a_key, a_fallback);
    }

    static std::string DataGetCharacterData(RE::StaticFunctionTag*, std::string a_guid, std::string a_section)
    {
        return IronSoul::DataStore::GetCharacterData(a_guid, a_section);
    }

    static void DataSetString(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        if (!IronSoul::DataStore::SetString(a_key, a_value)) {
            logger::warn(
                "DataSetString rejected (invalid key or value too long): key='{}' keyLen={} valueLen={}",
                a_key,
                a_key.size(),
                a_value.size());
        }
    }

    static bool DataSetStringIfChanged(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        return IronSoul::DataStore::SetStringIfChanged(a_key, a_value);
    }

    static bool DataSetStringChecked(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        return IronSoul::DataStore::SetStringChecked(a_key, a_value);
    }

    static bool DataHasKey(RE::StaticFunctionTag*, std::string a_key)
    {
        return IronSoul::DataStore::HasKey(a_key);
    }

    static void DataDeleteKey(RE::StaticFunctionTag*, std::string a_key)
    {
        IronSoul::DataStore::DeleteKey(a_key);
    }

    static void DataFlushIfDirty(RE::StaticFunctionTag*)
    {
        IronSoul::DataStore::FlushIfDirty();
    }

    // --- Dynamic Asset Helpers ---
    // =============================


    static std::optional<const wchar_t*> ResolveDynamicSplashTierToken(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"0defiant";
        case 1:
            return L"1iron";
        case 2:
            return L"2silver";
        case 3:
            return L"3gold";
        case 4:
            return L"4ebon";
        case 5:
            return L"5platinum";
        case 6:
            return L"6devour";
        case 9:
            return L"9chim";
        default:
            return std::nullopt;
        }
    }

    static std::int32_t NormalizeDynamicSplashPreset(std::int32_t a_presetId)
    {
        if (a_presetId == 1 || a_presetId == 2 || a_presetId == 3) {
            return a_presetId;
        }

        return 0;
    }

    static std::optional<std::wstring> ResolveDynamicSplashFile(std::int32_t a_tierId, std::int32_t a_presetId)
    {
        const auto token = ResolveDynamicSplashTierToken(a_tierId);
        if (!token) {
            return std::nullopt;
        }

        std::wstring file = L"splash";
        auto preset = NormalizeDynamicSplashPreset(a_presetId);
        if (a_tierId == 9 && preset > 1) {
            preset = 0;
        }
        if (preset != 0) {
            file += std::to_wstring(preset);
        }
        file += *token;
        file += L".png";

        return file;
    }

    static std::optional<const wchar_t*> ResolveDynamicLevelWidgetFile(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"lvlWidget0defiant.swf";
        case 1:
            return L"lvlWidget1iron.swf";
        case 2:
            return L"lvlWidget2silver.swf";
        case 3:
            return L"lvlWidget3gold.swf";
        case 4:
            return L"lvlWidget4ebon.swf";
        case 5:
            return L"lvlWidget5platinum.swf";
        case 6:
            return L"lvlWidget6devour.swf";
        case 9:
            return L"lvlWidget9chim.swf";
        default:
            return std::nullopt;
        }
    }

    static std::int32_t NormalizeDynamicDraugrEyePreset(std::int32_t a_presetId)
    {
        if (a_presetId == 1 || a_presetId == 2 || a_presetId == 3) {
            return a_presetId;
        }

        return 0;
    }

    static const wchar_t* ResolveDynamicDraugrEyeSuffix(std::int32_t a_presetId)
    {
        switch (NormalizeDynamicDraugrEyePreset(a_presetId)) {
        case 1:
            return L"BLUE";
        case 2:
            return L"PURPLE";
        case 3:
            return L"RED";
        default:
            return L"ORIGINAL";
        }
    }

    static std::int32_t NormalizeDynamicAssetMode(std::int32_t a_mode)
    {
        if (a_mode == 0 || a_mode == 2) {
            return a_mode;
        }

        return 1;
    }

    static std::filesystem::path GetBackupPath(const std::filesystem::path& a_dst)
    {
        return a_dst.parent_path() / std::filesystem::path(a_dst.stem().wstring() + L"BACKUP" + a_dst.extension().wstring());
    }

    static bool EnsureBackupBeforeReplace(const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        const fs::path backup = GetBackupPath(a_dst);
        if (fs::exists(backup)) {
            return true;
        }

        if (!fs::exists(a_dst)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: live file missing, skipped backup/replacement: {}", a_context, a_dst.string());
            }
            return false;
        }

        std::error_code ec;
        fs::create_directories(backup.parent_path(), ec);
        if (ec) {
            logger::error("{}: backup directory creation failed '{}' (ec={})", a_context, backup.parent_path().string(), ec.value());
            return false;
        }

        fs::copy_file(a_dst, backup, fs::copy_options::none, ec);
        if (ec) {
            logger::error("{}: backup failed '{}' -> '{}' (ec={})", a_context, a_dst.string(), backup.string(), ec.value());
            return false;
        }

        if (InfoLoggingEnabled()) {
            logger::info("{}: backed up '{}' -> '{}'", a_context, a_dst.string(), backup.string());
        }
        return true;
    }

    static bool CopyFileReplacing(const std::filesystem::path& a_src, const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        std::error_code ec;
        fs::create_directories(a_dst.parent_path(), ec);
        if (ec) {
            logger::warn("{}: create_directories failed: {} (ec={})", a_context, a_dst.parent_path().string(), ec.value());
            ec.clear();
        }

        fs::path tmp = a_dst;
        tmp += L".tmp";

        fs::copy_file(a_src, tmp, fs::copy_options::overwrite_existing, ec);
        if (ec) {
            logger::error("{}: copy failed '{}' -> '{}' (ec={})", a_context, a_src.string(), tmp.string(), ec.value());
            return false;
        }

        ec.clear();
        fs::rename(tmp, a_dst, ec);
        if (ec) {
            ec.clear();
            fs::copy_file(a_src, a_dst, fs::copy_options::overwrite_existing, ec);
            if (ec) {
                logger::error("{}: overwrite failed '{}' -> '{}' (ec={})", a_context, a_src.string(), a_dst.string(), ec.value());
                ec.clear();
                fs::remove(tmp, ec);
                return false;
            }
            ec.clear();
            fs::remove(tmp, ec);
        }

        return true;
    }

    static bool CopyVariantWithBackup(const std::filesystem::path& a_src, const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        if (!fs::exists(a_src)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: source missing, skipped: {}", a_context, a_src.string());
            }
            return false;
        }

        if (!EnsureBackupBeforeReplace(a_dst, a_context)) {
            return false;
        }

        return CopyFileReplacing(a_src, a_dst, a_context);
    }

    static bool RestoreBackupIfPresent(const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        const fs::path backup = GetBackupPath(a_dst);
        if (!fs::exists(backup)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: backup missing, skipped restore: {}", a_context, backup.string());
            }
            return false;
        }

        return CopyFileReplacing(backup, a_dst, a_context);
    }

    // --- Dynamic Asset Bindings ---
    // ==============================

    static void ApplyDynamicDraugrEyes(RE::StaticFunctionTag*, std::int32_t a_presetId)
    {
        static constexpr const wchar_t* kTargets[] = {
            L"meshes\\actors\\draugr\\character assets\\fxdraugrmaleeyes.nif",
            L"meshes\\actors\\draugr\\character assets\\fxdraugrfemaleeyes.nif"
        };

        const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicDraugrEyes", 1));
        const std::int32_t preset = NormalizeDynamicDraugrEyePreset(a_presetId);

        try {
            namespace fs = std::filesystem;

            const wchar_t* suffix = L"BACKUP";
            if (mode != 0) {
                suffix = (mode == 2 || preset == 0) ? L"ORIGINAL" : ResolveDynamicDraugrEyeSuffix(preset);
            }
            bool copiedAny = false;

            for (auto* target : kTargets) {
                const fs::path dst = IronSoul::PathUtil::GetDataRoot() / fs::path(target);
                if (mode == 0) {
                    if (RestoreBackupIfPresent(dst, "ApplyDynamicDraugrEyes")) {
                        copiedAny = true;
                    }
                    continue;
                }

                const fs::path src = dst.parent_path() / fs::path(dst.stem().wstring() + suffix + dst.extension().wstring());

                if (CopyVariantWithBackup(src, dst, "ApplyDynamicDraugrEyes")) {
                    copiedAny = true;
                    if (InfoLoggingEnabled()) {
                        logger::info("ApplyDynamicDraugrEyes: applied '{}' -> '{}'", src.string(), dst.string());
                    }
                }
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicDraugrEyes: mode={} presetId={} suffix={} copiedAny={}", mode, a_presetId, fs::path(suffix).string(), copiedAny ? 1 : 0);
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicDraugrEyes: exception: {}", e.what());
        }
    }

    static void ApplyDynamicSplash(RE::StaticFunctionTag*, std::int32_t a_tierId, std::int32_t a_presetId)
    {
        // Plugin performs the file copy.
        try {
            namespace fs = std::filesystem;

            std::wstring file = L"splash1iron.png";
            const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicSplash", 1));
            if (mode == 1) {
                const auto resolved = ResolveDynamicSplashFile(a_tierId, a_presetId);
                if (!resolved) {
                    logger::warn("ApplyDynamicSplash: invalid tierId={}", a_tierId);
                    return;
                }
                file = *resolved;
            }

            const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";
            const fs::path src = ifaceDir / fs::path(file);
            const fs::path dst = ifaceDir / L"splash.png";

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicSplash");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, "ApplyDynamicSplash")) {
                return;
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicSplash: applied tierId={} presetId={} mode={} ('{}' -> '{}')", a_tierId, a_presetId, mode, src.string(), dst.string());
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicSplash: exception: {}", e.what());
        }
    }

    static bool DynamicLevelWidgetAssetsPresent()
    {
        namespace fs = std::filesystem;
        const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";

        // Require the base destination to exist to confirm the user has the widget mod installed.
        // We still overwrite it, but its presence is used as the install signal.
        if (!fs::exists(ifaceDir / L"lvlWidget.swf")) {
            return false;
        }
        static constexpr const wchar_t* kVariants[] = {
            L"lvlWidget0defiant.swf",
            L"lvlWidget1iron.swf",
            L"lvlWidget2silver.swf",
            L"lvlWidget3gold.swf",
            L"lvlWidget4ebon.swf",
            L"lvlWidget5platinum.swf",
            L"lvlWidget6devour.swf",
            L"lvlWidget9chim.swf"
        };

        for (auto* f : kVariants) {
            if (!fs::exists(ifaceDir / f)) {
                return false;
            }
        }
        return true;
    }

    static void ApplyDynamicLevelWidget(RE::StaticFunctionTag*, std::int32_t a_tierId)
    {
        try {
            namespace fs = std::filesystem;
            const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";

            const wchar_t* file = L"lvlWidget1iron.swf";
            const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicLevelWidget", 1));
            if (mode == 1) {
                if (!DynamicLevelWidgetAssetsPresent()) {
                    return;
                }

                const auto resolved = ResolveDynamicLevelWidgetFile(a_tierId);
                if (!resolved) {
                    logger::warn("ApplyDynamicLevelWidget: invalid tierId={}", a_tierId);
                    return;
                }
                file = *resolved;
            }

            const fs::path src = ifaceDir / file;
            const fs::path dst = ifaceDir / L"lvlWidget.swf";

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicLevelWidget");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, "ApplyDynamicLevelWidget")) {
                return;
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicLevelWidget: applied tierId={} mode={} ('{}' -> '{}')", a_tierId, mode, src.string(), dst.string());
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicLevelWidget: exception: {}", e.what());
        }
    }

    // --- Music Fade Bindings ---
    // ===========================

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

    // --- Health Monitor Bindings ---
    // ===============================

    static void StartHealthMonitor(RE::StaticFunctionTag*)
    {
        StartHealthMonitorInternal();
    }

    static void StopHealthMonitor(RE::StaticFunctionTag*)
    {
        StopHealthMonitorInternal();
    }

    // --- Cursor Suppression Binding ---
    // ==================================

    static void SuppressCursor(RE::StaticFunctionTag*, bool a_suppress)
    {
        // Gate cursor suppression behind INI:
        // CursorHide=0 blocks both suppress and restore calls.
        if (IronSoul::Config::GetInt("CursorHide", 1) == 0) {
            if (InfoLoggingEnabled()) {
                logger::info("SuppressCursor: blocked by CursorHide=0");
            }
            return;
        }

        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("SuppressCursor: task interface unavailable");
            return;
        }

        task->AddTask([a_suppress]() {
            auto* menuCursor = RE::MenuCursor::GetSingleton();
            auto* uiQueue = RE::UIMessageQueue::GetSingleton();
            auto* uiStr = RE::InterfaceStrings::GetSingleton();

            if (!menuCursor && InfoLoggingEnabled()) {
                logger::warn("SuppressCursor: MenuCursor singleton unavailable");
            }

            {
                std::scoped_lock lock(g_cursorSuppressState.lock);
                if (a_suppress) {
                    if (g_cursorSuppressState.suppressStep == 0) {
                        g_cursorSuppressState.savedPosValid = false;
                        g_cursorSuppressState.savedVisibilityValid = false;
                        if (menuCursor) {
                            auto& rt = menuCursor->GetRuntimeData();
                            g_cursorSuppressState.savedPosX = rt.cursorPosX;
                            g_cursorSuppressState.savedPosY = rt.cursorPosY;
                            g_cursorSuppressState.savedPosValid = true;
                            g_cursorSuppressState.savedVisible = rt.showCursorCount >= 0;
                            g_cursorSuppressState.savedVisibilityValid = true;

                            const float baseW = rt.screenWidthX > 0.0f ? rt.screenWidthX : 1920.0f;
                            const float rightEdgeX = baseW - 1.0f;
                            rt.cursorPosX = rightEdgeX > 0.0f ? rightEdgeX : 0.0f;
                            rt.cursorPosY = g_cursorSuppressState.savedPosY;
                        }
                        g_cursorSuppressState.suppressStep = 1;
                        if (InfoLoggingEnabled()) {
                            logger::info("SuppressCursor: step1 move-right");
                        }
                        return;
                    }

                    if (g_cursorSuppressState.suppressStep == 1) {
                        if (uiQueue && uiStr) {
                            uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kHide, nullptr);
                        }
                        if (menuCursor) {
                            auto& rt = menuCursor->GetRuntimeData();
                            const float baseW = rt.screenWidthX > 0.0f ? rt.screenWidthX : 1920.0f;
                            rt.cursorPosX = baseW + 10000.0f;
                            rt.cursorPosY = g_cursorSuppressState.savedPosY;
                            menuCursor->SetCursorVisibility(false);
                        }
                        g_cursorSuppressState.suppressStep = 2;
                        if (InfoLoggingEnabled()) {
                            logger::info("SuppressCursor: step2 hide+offscreen-right");
                        }
                        return;
                    }

                    // step >= 2: keep hidden + offscreen-right
                    if (menuCursor) {
                        auto& rt = menuCursor->GetRuntimeData();
                        const float baseW = rt.screenWidthX > 0.0f ? rt.screenWidthX : 1920.0f;
                        rt.cursorPosX = baseW + 10000.0f;
                        rt.cursorPosY = g_cursorSuppressState.savedPosY;
                        menuCursor->SetCursorVisibility(false);
                    }
                    if (InfoLoggingEnabled()) {
                        logger::info("SuppressCursor: step2 reapply");
                    }
                } else {
                    if (g_cursorSuppressState.suppressStep == 0) {
                        if (InfoLoggingEnabled()) {
                            logger::warn("SuppressCursor: disable requested while not suppressed (ignored)");
                        }
                        return;
                    }

                    bool hasSavedVisibility = false;
                    bool restoreVisible = true;

                    if (menuCursor) {
                        auto& rt = menuCursor->GetRuntimeData();
                        if (g_cursorSuppressState.savedPosValid) {
                            rt.cursorPosX = g_cursorSuppressState.savedPosX;
                            rt.cursorPosY = g_cursorSuppressState.savedPosY;
                            g_cursorSuppressState.savedPosValid = false;
                        }
                        if (g_cursorSuppressState.savedVisibilityValid) {
                            hasSavedVisibility = true;
                            restoreVisible = g_cursorSuppressState.savedVisible;
                            menuCursor->SetCursorVisibility(restoreVisible);
                            g_cursorSuppressState.savedVisibilityValid = false;
                        } else {
                            menuCursor->SetCursorVisibility(true);
                        }
                    }

                    if (uiQueue && uiStr) {
                        if (hasSavedVisibility && !restoreVisible) {
                            uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kHide, nullptr);
                        } else {
                            uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kUpdate, nullptr);
                        }
                    }

                    g_cursorSuppressState.savedPosValid = false;
                    g_cursorSuppressState.savedVisibilityValid = false;
                    g_cursorSuppressState.suppressStep = 0;

                    if (InfoLoggingEnabled()) {
                        logger::info("SuppressCursor: disabled");
                    }
                }
            }
        });
    }

    // --- Native Registration ---
    // ===========================

    bool Register()
    {
        auto* papyrus = SKSE::GetPapyrusInterface();
        if (!papyrus) {
            logger::error("Iron Soul: Papyrus interface unavailable");
            return false;
        }

        RefreshMusicVolumeOverrideCache();

        const bool ok = papyrus->Register([](RE::BSScript::IVirtualMachine* a_vm) {
            a_vm->RegisterFunction("IsAvailable", kScriptName, IsAvailable);
            a_vm->RegisterFunction("DataStoreReady", kScriptName, DataStoreReady);
            a_vm->RegisterFunction("LogJournalEntry", kScriptName, LogJournalEntry);
            a_vm->RegisterFunction("GetPlayerName", kScriptName, GetPlayerName);
            a_vm->RegisterFunction("GenerateGuidUnique", kScriptName, GenerateGuidUnique);
            a_vm->RegisterFunction("GetConfigInt", kScriptName, GetConfigInt);
            a_vm->RegisterFunction("GetIronSoulPresetPlus", kScriptName, GetIronSoulPresetPlus);
            a_vm->RegisterFunction("SetConfigInt", kScriptName, SetConfigInt);
            a_vm->RegisterFunction("SetConfigString", kScriptName, SetConfigString);
            a_vm->RegisterFunction("ReloadConfig", kScriptName, ReloadConfig);
            a_vm->RegisterFunction("ApplyDynamicDraugrEyes", kScriptName, ApplyDynamicDraugrEyes);
            a_vm->RegisterFunction("ApplyDynamicSplash", kScriptName, ApplyDynamicSplash);
            a_vm->RegisterFunction("ApplyDynamicLevelWidget", kScriptName, ApplyDynamicLevelWidget);
            a_vm->RegisterFunction("MusicFadeOut", kScriptName, MusicFadeOut);
            a_vm->RegisterFunction("MusicFadeIn", kScriptName, MusicFadeIn);
            a_vm->RegisterFunction("StartHealthMonitor", kScriptName, StartHealthMonitor);
            a_vm->RegisterFunction("StopHealthMonitor", kScriptName, StopHealthMonitor);
            a_vm->RegisterFunction("SuppressCursor", kScriptName, SuppressCursor);
            a_vm->RegisterFunction("DataGetInt", kScriptName, DataGetInt);
            a_vm->RegisterFunction("DataSetInt", kScriptName, DataSetInt);
            a_vm->RegisterFunction("DataSetIntIfChanged", kScriptName, DataSetIntIfChanged);
            a_vm->RegisterFunction("DataSetIntChecked", kScriptName, DataSetIntChecked);
            a_vm->RegisterFunction("DataGetString", kScriptName, DataGetString);
            a_vm->RegisterFunction("DataGetCharacterData", kScriptName, DataGetCharacterData);
            a_vm->RegisterFunction("DataSetString", kScriptName, DataSetString);
            a_vm->RegisterFunction("DataSetStringIfChanged", kScriptName, DataSetStringIfChanged);
            a_vm->RegisterFunction("DataSetStringChecked", kScriptName, DataSetStringChecked);
            a_vm->RegisterFunction("DataHasKey", kScriptName, DataHasKey);
            a_vm->RegisterFunction("DataDeleteKey", kScriptName, DataDeleteKey);
            a_vm->RegisterFunction("DataFlushIfDirty", kScriptName, DataFlushIfDirty);
            return true;
        });

        if (ok) {
            logger::info("Iron Soul: Registered papyrus natives on script '{}'", kScriptName);
        } else {
            logger::critical("Iron Soul: Failed to register papyrus natives");
        }

        return ok;
    }
}
