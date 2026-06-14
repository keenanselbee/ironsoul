#pragma once

#include <atomic>
#include <chrono>
#include <string>
#include <string_view>
#include <utility>

namespace IronSoul::Audio
{
    inline constexpr std::uint32_t kDefaultSoundFlags = 0x1A;

    struct SoundBuildOptions
    {
        std::string_view owner{ "Audio" };
        std::string reason;
        std::uint32_t flags{ kDefaultSoundFlags };
        float volume{ 1.0F };
        std::atomic<bool>* missingDescriptorWarned{ nullptr };
        std::atomic<bool>* missingAudioWarned{ nullptr };
    };

    struct FadePlan
    {
        int steps{ 1 };
        std::chrono::duration<float> stepDuration{ 0.0F };
    };

    float ClampVolume(float a_value);
    std::string_view ReasonOrDefault(std::string_view a_reason, std::string_view a_fallback);
    FadePlan MakeFadePlan(float a_seconds, float a_stepSeconds);
    float LinearFadeVolume(float a_from, float a_to, int a_step, int a_steps);
    bool BuildAndPlaySound(RE::BSSoundHandle& a_handle, RE::TESSound* a_sound, const SoundBuildOptions& a_options);
    bool BuildAndPlayDescriptor(
        RE::BSSoundHandle& a_handle,
        RE::BGSSoundDescriptorForm* a_descriptor,
        RE::FormID a_logFormID,
        const SoundBuildOptions& a_options);

    template <class Task>
    bool QueueTask(Task&& a_task, std::string_view a_owner, std::string_view a_operation, std::atomic<bool>* a_warnedMissingTask = nullptr)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (!a_warnedMissingTask || !a_warnedMissingTask->exchange(true)) {
                const auto owner = a_owner.empty() ? std::string_view{ "Audio" } : a_owner;
                const auto operation = a_operation.empty() ? std::string_view{ "unknown" } : a_operation;
                logger::warn("{}: task interface unavailable operation={}", owner, operation);
            }
            return false;
        }

        task->AddTask(std::forward<Task>(a_task));
        return true;
    }
}
