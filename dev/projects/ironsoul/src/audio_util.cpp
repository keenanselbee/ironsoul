#include "pch.h"
#include "audio_util.h"

#include <algorithm>
#include <cmath>

namespace IronSoul::Audio
{
    namespace
    {
        std::string_view OwnerOrDefault(std::string_view a_owner)
        {
            return a_owner.empty() ? std::string_view{ "Audio" } : a_owner;
        }

        bool ShouldWarn(std::atomic<bool>* a_warned)
        {
            return !a_warned || !a_warned->exchange(true);
        }
    }

    float ClampVolume(float a_value)
    {
        return std::clamp(a_value, 0.0F, 1.0F);
    }

    std::string_view ReasonOrDefault(std::string_view a_reason, std::string_view a_fallback)
    {
        return a_reason.empty() ? a_fallback : a_reason;
    }

    FadePlan MakeFadePlan(float a_seconds, float a_stepSeconds)
    {
        const float seconds = (std::max)(a_seconds, 0.0F);
        const float stepSeconds = (std::max)(a_stepSeconds, 0.001F);
        int steps = static_cast<int>(std::ceil(seconds / stepSeconds));
        if (steps < 1) {
            steps = 1;
        }
        return FadePlan{ steps, std::chrono::duration<float>(seconds / static_cast<float>(steps)) };
    }

    float LinearFadeVolume(float a_from, float a_to, int a_step, int a_steps)
    {
        const int steps = (std::max)(a_steps, 1);
        const int step = std::clamp(a_step, 0, steps);
        const float progress = static_cast<float>(step) / static_cast<float>(steps);
        return ClampVolume(a_from + ((a_to - a_from) * progress));
    }

    bool BuildAndPlaySound(RE::BSSoundHandle& a_handle, RE::TESSound* a_sound, const SoundBuildOptions& a_options)
    {
        const auto owner = OwnerOrDefault(a_options.owner);
        const auto reason = ReasonOrDefault(a_options.reason, "native");
        if (!a_sound) {
            if (ShouldWarn(a_options.missingDescriptorWarned)) {
                logger::warn("{}: missing sound reason={}", owner, reason);
            }
            return false;
        }

        auto* descriptor = a_sound->descriptor;
        if (!descriptor) {
            if (ShouldWarn(a_options.missingDescriptorWarned)) {
                logger::warn(
                    "{}: sound descriptor lookup failed soundFormID={:08X} reason={}",
                    owner,
                    a_sound->GetFormID(),
                    reason);
            }
            return false;
        }

        return BuildAndPlayDescriptor(a_handle, descriptor, a_sound->GetFormID(), a_options);
    }

    bool BuildAndPlayDescriptor(
        RE::BSSoundHandle& a_handle,
        RE::BGSSoundDescriptorForm* a_descriptor,
        RE::FormID a_logFormID,
        const SoundBuildOptions& a_options)
    {
        const auto owner = OwnerOrDefault(a_options.owner);
        const auto reason = ReasonOrDefault(a_options.reason, "native");
        const RE::FormID logFormID = a_logFormID != 0 ? a_logFormID : (a_descriptor ? a_descriptor->GetFormID() : 0);

        if (!a_descriptor) {
            if (ShouldWarn(a_options.missingDescriptorWarned)) {
                logger::warn("{}: missing sound descriptor soundFormID={:08X} reason={}", owner, logFormID, reason);
            }
            return false;
        }

        auto* audioManager = RE::BSAudioManager::GetSingleton();
        if (!audioManager) {
            if (ShouldWarn(a_options.missingAudioWarned)) {
                logger::warn("{}: BSAudioManager unavailable soundFormID={:08X} reason={}", owner, logFormID, reason);
            }
            return false;
        }

        if (!audioManager->BuildSoundDataFromDescriptor(a_handle, a_descriptor, a_options.flags)) {
            logger::warn("{}: BuildSoundDataFromDescriptor failed soundFormID={:08X} reason={}", owner, logFormID, reason);
            return false;
        }
        if (!a_handle.IsValid()) {
            logger::warn("{}: invalid sound handle soundFormID={:08X} reason={}", owner, logFormID, reason);
            return false;
        }

        a_handle.SetVolume(ClampVolume(a_options.volume));
        if (!a_handle.Play()) {
            logger::warn("{}: Play failed soundFormID={:08X} reason={}", owner, logFormID, reason);
            return false;
        }
        return true;
    }
}
