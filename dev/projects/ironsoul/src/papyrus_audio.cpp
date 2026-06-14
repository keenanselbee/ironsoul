#include "pch.h"
#include "audio_util.h"
#include "papyrus_audio.h"
#include "papyrus_common.h"

#include <algorithm>
#include <atomic>
#include <cmath>
#include <thread>

namespace IronSoul::Papyrus::Audio
{
    namespace
    {
        constexpr float kFadeStepSeconds = 0.03F;

        struct TrackedSound
        {
            RE::BSSoundHandle handle{};
            RE::FormID soundFormID{ 0 };
            float currentVolume{ 1.0F };
            std::uint64_t fadeToken{ 0 };
        };

        struct AudioState
        {
            std::mutex lock;
            std::unordered_map<std::int32_t, TrackedSound> tracked;
            std::int32_t nextToken{ 1 };
            std::atomic<bool> warnedMissingTask{ false };
        };

        AudioState g_audio;

        bool InfoLoggingEnabled()
        {
            return IronSoul::Papyrus::InfoLoggingEnabled();
        }

        IronSoul::Audio::SoundBuildOptions MakeBuildOptions(float a_volume, const std::string& a_reason)
        {
            IronSoul::Audio::SoundBuildOptions options;
            options.owner = "Audio";
            options.reason = IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus");
            options.volume = a_volume;
            return options;
        }

        std::int32_t AllocateTokenLocked()
        {
            std::int32_t token = g_audio.nextToken;
            if (token <= 0) {
                token = 1;
                g_audio.nextToken = 1;
            }

            while (g_audio.tracked.contains(token)) {
                ++token;
                if (token <= 0) {
                    token = 1;
                }
            }

            g_audio.nextToken = token + 1;
            if (g_audio.nextToken <= 0) {
                g_audio.nextToken = 1;
            }
            return token;
        }

        void StopAllTrackedInternal(const std::string& a_reason)
        {
            std::size_t stopped = 0;
            {
                std::scoped_lock lock(g_audio.lock);
                for (auto& [token, tracked] : g_audio.tracked) {
                    (void)token;
                    tracked.fadeToken += 1;
                    if (tracked.handle.IsValid()) {
                        tracked.handle.Stop();
                        ++stopped;
                    }
                }
                g_audio.tracked.clear();
            }

            if (stopped > 0 && InfoLoggingEnabled()) {
                logger::info("Audio: stopped all tracked count={} reason={}", stopped, IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
            }
        }

        bool IsFadeCurrent(std::int32_t a_token, std::uint64_t a_fadeToken)
        {
            std::scoped_lock lock(g_audio.lock);
            auto it = g_audio.tracked.find(a_token);
            return it != g_audio.tracked.end() && it->second.fadeToken == a_fadeToken;
        }

        void QueueFadeStep(
            std::int32_t a_token,
            std::uint64_t a_fadeToken,
            float a_volume,
            bool a_finalStep,
            std::string a_reason)
        {
            IronSoul::Audio::QueueTask([a_token, a_fadeToken, volume = IronSoul::Audio::ClampVolume(a_volume), a_finalStep, reason = std::move(a_reason)]() {
                std::scoped_lock lock(g_audio.lock);
                auto it = g_audio.tracked.find(a_token);
                if (it == g_audio.tracked.end() || it->second.fadeToken != a_fadeToken) {
                    return;
                }

                auto& tracked = it->second;
                if (tracked.handle.IsValid()) {
                    tracked.handle.SetVolume(volume);
                }
                tracked.currentVolume = volume;

                if (a_finalStep) {
                    if (tracked.handle.IsValid()) {
                        tracked.handle.Stop();
                    }
                    if (InfoLoggingEnabled()) {
                        logger::info(
                            "Audio: faded tracked token={} soundFormID={:08X} reason={}",
                            a_token,
                            tracked.soundFormID,
                            IronSoul::Audio::ReasonOrDefault(reason, "papyrus"));
                    }
                    g_audio.tracked.erase(it);
                }
            }, "Audio", "fade step", &g_audio.warnedMissingTask);
        }

        bool StopTrackedInternal(std::int32_t a_token, const std::string& a_reason)
        {
            if (a_token <= 0) {
                return false;
            }

            RE::FormID soundFormID = 0;
            bool stopped = false;
            {
                std::scoped_lock lock(g_audio.lock);
                auto it = g_audio.tracked.find(a_token);
                if (it == g_audio.tracked.end()) {
                    return false;
                }

                it->second.fadeToken += 1;
                soundFormID = it->second.soundFormID;
                if (it->second.handle.IsValid()) {
                    stopped = it->second.handle.Stop();
                }
                g_audio.tracked.erase(it);
            }

            if (stopped && InfoLoggingEnabled()) {
                logger::info(
                    "Audio: stopped tracked token={} soundFormID={:08X} reason={}",
                    a_token,
                    soundFormID,
                    IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
            }
            return stopped;
        }

        static bool AudioPlay(
            RE::StaticFunctionTag*,
            RE::TESSound* a_sound,
            RE::TESObjectREFR* a_source,
            float a_volume,
            std::string a_reason)
        {
            (void)a_source;
            RE::BSSoundHandle handle{};
            const bool played = IronSoul::Audio::BuildAndPlaySound(handle, a_sound, MakeBuildOptions(a_volume, a_reason));
            if (played && InfoLoggingEnabled()) {
                logger::info(
                    "Audio: played soundFormID={:08X} reason={}",
                    a_sound ? a_sound->GetFormID() : 0,
                    IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
            }
            return played;
        }

        static std::int32_t AudioPlayTracked(
            RE::StaticFunctionTag*,
            RE::TESSound* a_sound,
            RE::TESObjectREFR* a_source,
            float a_volume,
            std::string a_reason)
        {
            (void)a_source;
            RE::BSSoundHandle handle{};
            if (!IronSoul::Audio::BuildAndPlaySound(handle, a_sound, MakeBuildOptions(a_volume, a_reason))) {
                return -1;
            }

            std::int32_t token = -1;
            {
                std::scoped_lock lock(g_audio.lock);
                token = AllocateTokenLocked();
                g_audio.tracked.emplace(
                    token,
                    TrackedSound{
                        handle,
                        a_sound ? a_sound->GetFormID() : 0,
                        IronSoul::Audio::ClampVolume(a_volume),
                        0
                    });
            }

            if (InfoLoggingEnabled()) {
                logger::info(
                    "Audio: played tracked token={} soundFormID={:08X} reason={}",
                    token,
                    a_sound ? a_sound->GetFormID() : 0,
                    IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
            }
            return token;
        }

        static bool AudioFadeOutTracked(RE::StaticFunctionTag*, std::int32_t a_token, float a_seconds, std::string a_reason)
        {
            if (a_token <= 0) {
                return false;
            }
            if (a_seconds <= 0.0F) {
                return StopTrackedInternal(a_token, a_reason);
            }
            if (!SKSE::GetTaskInterface()) {
                logger::warn("Audio: task interface unavailable operation=fade token={} reason={}", a_token, IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
                return false;
            }

            float startVolume = 0.0F;
            std::uint64_t fadeToken = 0;
            {
                std::scoped_lock lock(g_audio.lock);
                auto it = g_audio.tracked.find(a_token);
                if (it == g_audio.tracked.end()) {
                    return false;
                }

                fadeToken = ++it->second.fadeToken;
                startVolume = IronSoul::Audio::ClampVolume(it->second.currentVolume);
            }

            const auto fadePlan = IronSoul::Audio::MakeFadePlan(a_seconds, kFadeStepSeconds);

            if (InfoLoggingEnabled()) {
                logger::info(
                    "Audio: fade tracked token={} from={} seconds={} reason={}",
                    a_token,
                    startVolume,
                    a_seconds,
                    IronSoul::Audio::ReasonOrDefault(a_reason, "papyrus"));
            }

            std::thread([token = a_token, fadeToken, startVolume, steps = fadePlan.steps, sleepDuration = fadePlan.stepDuration, reason = std::move(a_reason)]() {
                for (int step = 1; step <= steps; ++step) {
                    std::this_thread::sleep_for(sleepDuration);
                    if (!IsFadeCurrent(token, fadeToken)) {
                        return;
                    }

                    const float volume = IronSoul::Audio::LinearFadeVolume(startVolume, 0.0F, step, steps);
                    QueueFadeStep(token, fadeToken, volume, step == steps, reason);
                }
            }).detach();

            return true;
        }

        static bool AudioStopTracked(RE::StaticFunctionTag*, std::int32_t a_token, std::string a_reason)
        {
            return StopTrackedInternal(a_token, a_reason);
        }

        static void AudioStopAllTracked(RE::StaticFunctionTag*, std::string a_reason)
        {
            StopAllTrackedInternal(a_reason);
        }

        void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
        {
            if (!a_message) {
                return;
            }
            if (a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
                StopAllTrackedInternal("pre-load");
            } else if (a_message->type == SKSE::MessagingInterface::kNewGame) {
                StopAllTrackedInternal("new-game");
            }
        }
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("AudioPlay", IronSoul::Papyrus::kScriptName, AudioPlay);
        a_vm->RegisterFunction("AudioPlayTracked", IronSoul::Papyrus::kScriptName, AudioPlayTracked);
        a_vm->RegisterFunction("AudioFadeOutTracked", IronSoul::Papyrus::kScriptName, AudioFadeOutTracked);
        a_vm->RegisterFunction("AudioStopTracked", IronSoul::Papyrus::kScriptName, AudioStopTracked);
        a_vm->RegisterFunction("AudioStopAllTracked", IronSoul::Papyrus::kScriptName, AudioStopAllTracked);
    }

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("Audio: messaging interface unavailable; tracked cleanup on load disabled");
        } else if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("Audio: failed to register lifecycle listener");
        } else {
            logger::info("Audio: lifecycle listener registered");
        }
    }
}
