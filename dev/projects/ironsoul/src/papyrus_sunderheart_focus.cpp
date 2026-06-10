#include "pch.h"
#include "papyrus_sunderheart_focus.h"
#include "papyrus_common.h"
#include "config.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <string>
#include <thread>

namespace IronSoul::Papyrus::SunderheartFocus
{
namespace
{
    constexpr float kFadeInSeconds = 0.35F;
    constexpr float kFadeOutSeconds = 1.0F;
    constexpr float kHoverFadeOutSeconds = 0.20F;
    constexpr float kRetargetSeconds = 0.12F;
    constexpr float kHoverMatchDebounceSeconds = 0.04F;
    constexpr float kHoverClearDebounceSeconds = 0.25F;
    constexpr float kHoverLeaseCheckSeconds = 0.25F;
    constexpr float kFadeStepSeconds = 0.03F;
    constexpr float kVolumeEpsilon = 0.001F;
    constexpr std::uint32_t kFocusSoundFlags = 0x1A;
    constexpr const char* kInventoryMenuName = "InventoryMenu";

    struct FocusTarget
    {
        bool active{ false };
        float volume{ 0.0F };
    };

    struct FocusState
    {
        std::mutex lock;
        RE::FormID focusLoopFormID{ 0 };
        FocusTarget hover;
        FocusTarget pendingHover;
        FocusTarget action;
        FocusTarget use;
        RE::BSSoundHandle handle{};
        bool handleActive{ false };
        float currentVolume{ 0.0F };
        float targetVolume{ 0.0F };
        std::atomic<std::uint64_t> hoverToken{ 0 };
        std::atomic<std::uint64_t> hoverLeaseToken{ 0 };
        std::atomic<std::uint64_t> fadeToken{ 0 };
        std::atomic<bool> warnedMissingTask{ false };
        std::atomic<bool> warnedMissingAudio{ false };
        std::atomic<bool> warnedMissingSound{ false };
        bool menuSinkRegistered{ false };
    };

    class FocusMenuSink :
        public RE::BSTEventSink<RE::MenuOpenCloseEvent>
    {
    public:
        RE::BSEventNotifyControl ProcessEvent(
            const RE::MenuOpenCloseEvent* a_event,
            RE::BSTEventSource<RE::MenuOpenCloseEvent>*) override;
    };

    FocusState g_focus;
    FocusMenuSink g_menuSink;

    void ValidateHoverLease(std::uint64_t a_token);

    float Clamp01(float a_value)
    {
        return std::clamp(a_value, 0.0F, 1.0F);
    }

    bool NearlyEqual(float a_left, float a_right)
    {
        return std::fabs(a_left - a_right) <= kVolumeEpsilon;
    }

    bool InfoLoggingEnabled()
    {
        return IronSoul::Config::ShouldEmitInfoLog();
    }

    bool FocusSfxEnabled()
    {
        return IronSoul::Config::GetInt("SFX", 1) != 0 &&
            IronSoul::Config::GetInt("SunderheartFocusSFX", 1) != 0;
    }

    float ResolveDesiredVolumeLocked()
    {
        if (g_focus.use.active) {
            return Clamp01(g_focus.use.volume);
        }
        if (g_focus.action.active) {
            return Clamp01(g_focus.action.volume);
        }
        if (g_focus.hover.active) {
            return Clamp01(g_focus.hover.volume);
        }
        return 0.0F;
    }

    bool QueueTask(auto a_task, const char* a_operation)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (!g_focus.warnedMissingTask.exchange(true)) {
                logger::warn("SunderheartFocus: task interface unavailable operation={}", a_operation ? a_operation : "unknown");
            }
            return false;
        }

        task->AddTask(std::move(a_task));
        return true;
    }

    bool IsInventoryMenuOpen()
    {
        auto* ui = RE::UI::GetSingleton();
        return ui && ui->IsMenuOpen(kInventoryMenuName);
    }

    void QueueHoverLeaseCheck(std::uint64_t a_token)
    {
        std::thread([a_token]() {
            std::this_thread::sleep_for(std::chrono::duration<float>(kHoverLeaseCheckSeconds));
            if (g_focus.hoverLeaseToken.load() != a_token) {
                return;
            }

            QueueTask([a_token]() {
                ValidateHoverLease(a_token);
            }, "SunderheartFocus hover lease");
        }).detach();
    }

    void ArmHoverLeaseLocked()
    {
        const std::uint64_t token = g_focus.hoverLeaseToken.fetch_add(1) + 1;
        QueueHoverLeaseCheck(token);
    }

    void CancelHoverLease()
    {
        g_focus.hoverLeaseToken.fetch_add(1);
    }

    void ResetHandleLocked()
    {
        g_focus.handle = RE::BSSoundHandle{};
        g_focus.handleActive = false;
    }

    bool StopOwnedHandleLocked()
    {
        if (g_focus.handleActive && g_focus.handle.IsValid()) {
            g_focus.handle.Stop();
            return true;
        }
        return false;
    }

    bool EnsureHandleLocked()
    {
        if (g_focus.handleActive) {
            if (g_focus.handle.IsValid()) {
                return true;
            }
            ResetHandleLocked();
        }

        if (g_focus.focusLoopFormID == 0 || !FocusSfxEnabled()) {
            return false;
        }

        auto* sound = RE::TESForm::LookupByID<RE::TESSound>(g_focus.focusLoopFormID);
        auto* descriptor = sound ? sound->descriptor : nullptr;
        if (!descriptor) {
            if (!g_focus.warnedMissingSound.exchange(true)) {
                logger::warn("SunderheartFocus: sound descriptor lookup failed soundFormID={:08X}", g_focus.focusLoopFormID);
            }
            return false;
        }

        auto* audioManager = RE::BSAudioManager::GetSingleton();
        if (!audioManager) {
            if (!g_focus.warnedMissingAudio.exchange(true)) {
                logger::warn("SunderheartFocus: BSAudioManager unavailable");
            }
            return false;
        }

        if (!audioManager->BuildSoundDataFromDescriptor(g_focus.handle, descriptor, kFocusSoundFlags)) {
            logger::warn("SunderheartFocus: BuildSoundDataFromDescriptor failed soundFormID={:08X}", g_focus.focusLoopFormID);
            ResetHandleLocked();
            return false;
        }
        if (!g_focus.handle.IsValid()) {
            logger::warn("SunderheartFocus: invalid sound handle soundFormID={:08X}", g_focus.focusLoopFormID);
            ResetHandleLocked();
            return false;
        }

        g_focus.handle.SetVolume(0.0F);
        if (!g_focus.handle.Play()) {
            logger::warn("SunderheartFocus: Play failed soundFormID={:08X}", g_focus.focusLoopFormID);
            ResetHandleLocked();
            return false;
        }

        g_focus.handleActive = true;
        g_focus.currentVolume = 0.0F;
        if (InfoLoggingEnabled()) {
            logger::info("SunderheartFocus: started focus loop soundFormID={:08X}", g_focus.focusLoopFormID);
        }
        return true;
    }

    void QueueStopHandle(std::uint64_t a_token, std::string a_reason)
    {
        QueueTask([a_token, reason = std::move(a_reason)]() {
            std::scoped_lock lock(g_focus.lock);
            if (g_focus.fadeToken.load() != a_token) {
                return;
            }
            if (StopOwnedHandleLocked()) {
                if (InfoLoggingEnabled()) {
                    logger::info("SunderheartFocus: stopped focus loop reason={}", reason);
                }
            }
            ResetHandleLocked();
            g_focus.currentVolume = 0.0F;
            g_focus.targetVolume = 0.0F;
        }, "SunderheartFocus stop");
    }

    void QueueApplyVolume(std::uint64_t a_token, float a_volume, bool a_ensurePlaying, bool a_stopAfterFade, std::string a_reason)
    {
        const float volume = Clamp01(a_volume);
        QueueTask([a_token, volume, a_ensurePlaying, a_stopAfterFade, reason = std::move(a_reason)]() {
            std::scoped_lock lock(g_focus.lock);
            if (g_focus.fadeToken.load() != a_token) {
                return;
            }

            if ((a_ensurePlaying || volume > kVolumeEpsilon) && !EnsureHandleLocked()) {
                return;
            }

            if (g_focus.handleActive && g_focus.handle.IsValid()) {
                g_focus.handle.SetVolume(volume);
            }
            g_focus.currentVolume = volume;

            if (a_stopAfterFade && volume <= kVolumeEpsilon) {
                if (StopOwnedHandleLocked()) {
                    if (InfoLoggingEnabled()) {
                        logger::info("SunderheartFocus: fade stopped focus loop reason={}", reason);
                    }
                }
                ResetHandleLocked();
                g_focus.currentVolume = 0.0F;
                g_focus.targetVolume = 0.0F;
            }
        }, "SunderheartFocus apply volume");
    }

    void StartFadeLocked(float a_targetVolume, float a_seconds, bool a_stopAfterFade, std::string a_reason)
    {
        float target = Clamp01(a_targetVolume);
        if (!FocusSfxEnabled() && target > 0.0F) {
            target = 0.0F;
            a_stopAfterFade = true;
            a_reason += ":disabled";
        }

        if (NearlyEqual(g_focus.targetVolume, target) && !a_stopAfterFade) {
            return;
        }

        const std::uint64_t token = g_focus.fadeToken.fetch_add(1) + 1;
        const float startVolume = Clamp01(g_focus.currentVolume);
        g_focus.targetVolume = target;

        if (InfoLoggingEnabled()) {
            logger::info(
                "SunderheartFocus: fade start reason={} from={} to={} seconds={} stopAfter={}",
                a_reason,
                startVolume,
                target,
                a_seconds,
                a_stopAfterFade);
        }

        if (a_seconds <= 0.0F || NearlyEqual(startVolume, target)) {
            QueueApplyVolume(token, target, target > kVolumeEpsilon, a_stopAfterFade && target <= kVolumeEpsilon, a_reason);
            return;
        }

        int steps = static_cast<int>(std::ceil(a_seconds / kFadeStepSeconds));
        if (steps < 1) {
            steps = 1;
        }
        const auto sleepDuration = std::chrono::duration<float>(a_seconds / static_cast<float>(steps));
        QueueApplyVolume(token, startVolume, target > kVolumeEpsilon, false, a_reason);

        std::thread([token, startVolume, target, steps, sleepDuration, stopAfterFade = a_stopAfterFade, reason = std::move(a_reason)]() {
            for (int step = 1; step <= steps; ++step) {
                std::this_thread::sleep_for(sleepDuration);
                if (g_focus.fadeToken.load() != token) {
                    return;
                }

                const float progress = static_cast<float>(step) / static_cast<float>(steps);
                const float volume = startVolume + ((target - startVolume) * progress);
                QueueApplyVolume(token, volume, target > kVolumeEpsilon, stopAfterFade && step == steps && target <= kVolumeEpsilon, reason);
            }
        }).detach();
    }

    void RecomputeFadeLocked(std::string a_reason)
    {
        const float desired = ResolveDesiredVolumeLocked();
        if (desired > kVolumeEpsilon) {
            const bool starting = !g_focus.handleActive || g_focus.currentVolume <= kVolumeEpsilon;
            StartFadeLocked(desired, starting ? kFadeInSeconds : kRetargetSeconds, false, std::move(a_reason));
        } else {
            const bool hoverOnlyFade =
                a_reason == "hover" ||
                a_reason == "hover-clear" ||
                a_reason == "cancel-clear" ||
                a_reason == "inventory-menu-close" ||
                a_reason == "hover-lease-menu-closed";
            const float fadeSeconds = hoverOnlyFade ? kHoverFadeOutSeconds : kFadeOutSeconds;
            StartFadeLocked(0.0F, fadeSeconds, true, std::move(a_reason));
        }
    }

    void SetImmediateTarget(FocusTarget& a_target, float a_volume, std::string a_reason)
    {
        const float volume = Clamp01(a_volume);
        const bool active = volume > kVolumeEpsilon;
        {
            std::scoped_lock lock(g_focus.lock);
            if (a_target.active == active && NearlyEqual(a_target.volume, volume)) {
                return;
            }
            a_target.active = active;
            a_target.volume = active ? volume : 0.0F;
            if (InfoLoggingEnabled()) {
                logger::info("SunderheartFocus: target reason={} active={} volume={}", a_reason, active, volume);
            }
            RecomputeFadeLocked(std::move(a_reason));
        }
    }

    void CommitHoverTarget(std::uint64_t a_token)
    {
        std::scoped_lock lock(g_focus.lock);
        if (g_focus.hoverToken.load() != a_token) {
            return;
        }
        if (g_focus.hover.active == g_focus.pendingHover.active && NearlyEqual(g_focus.hover.volume, g_focus.pendingHover.volume)) {
            if (g_focus.hover.active) {
                ArmHoverLeaseLocked();
            } else {
                CancelHoverLease();
            }
            return;
        }

        g_focus.hover = g_focus.pendingHover;
        if (InfoLoggingEnabled()) {
            logger::info("SunderheartFocus: hover commit active={} volume={}", g_focus.hover.active, g_focus.hover.volume);
        }
        RecomputeFadeLocked("hover");
        if (g_focus.hover.active) {
            ArmHoverLeaseLocked();
        } else {
            CancelHoverLease();
        }
    }

    void QueueHoverCommit(float a_volume, bool a_active)
    {
        const std::uint64_t token = g_focus.hoverToken.fetch_add(1) + 1;
        CancelHoverLease();
        const float volume = a_active ? Clamp01(a_volume) : 0.0F;
        const float delaySeconds = a_active ? kHoverMatchDebounceSeconds : kHoverClearDebounceSeconds;
        {
            std::scoped_lock lock(g_focus.lock);
            g_focus.pendingHover.active = a_active;
            g_focus.pendingHover.volume = volume;
        }

        std::thread([token, delaySeconds]() {
            std::this_thread::sleep_for(std::chrono::duration<float>(delaySeconds));
            CommitHoverTarget(token);
        }).detach();
    }

    void ClearHoverLocked(std::string a_reason)
    {
        g_focus.pendingHover = {};
        if (!g_focus.hover.active && NearlyEqual(g_focus.hover.volume, 0.0F)) {
            return;
        }
        g_focus.hover = {};
        if (InfoLoggingEnabled()) {
            logger::info("SunderheartFocus: hover clear reason={}", a_reason);
        }
        RecomputeFadeLocked(std::move(a_reason));
    }

    void ClearHoverImmediate(std::string a_reason)
    {
        g_focus.hoverToken.fetch_add(1);
        CancelHoverLease();
        std::scoped_lock lock(g_focus.lock);
        ClearHoverLocked(std::move(a_reason));
    }

    void ValidateHoverLease(std::uint64_t a_token)
    {
        {
            std::scoped_lock lock(g_focus.lock);
            if (g_focus.hoverLeaseToken.load() != a_token || !g_focus.hover.active || g_focus.action.active || g_focus.use.active) {
                return;
            }
        }

        const bool inventoryOpen = IsInventoryMenuOpen();
        std::scoped_lock lock(g_focus.lock);
        if (g_focus.hoverLeaseToken.load() != a_token || !g_focus.hover.active || g_focus.action.active || g_focus.use.active) {
            return;
        }

        if (inventoryOpen) {
            QueueHoverLeaseCheck(a_token);
            return;
        }

        g_focus.hoverToken.fetch_add(1);
        CancelHoverLease();
        ClearHoverLocked("hover-lease-menu-closed");
    }

    void StopImmediate(bool a_clearTargets, std::string a_reason)
    {
        std::uint64_t token = 0;
        {
            std::scoped_lock lock(g_focus.lock);
            CancelHoverLease();
            if (a_clearTargets) {
                g_focus.hoverToken.fetch_add(1);
                g_focus.hover = {};
                g_focus.pendingHover = {};
                g_focus.action = {};
                g_focus.use = {};
            }
            token = g_focus.fadeToken.fetch_add(1) + 1;
            g_focus.currentVolume = 0.0F;
            g_focus.targetVolume = 0.0F;
        }
        QueueStopHandle(token, std::move(a_reason));
    }

    void ClearAllAndFade(std::string a_reason)
    {
        std::scoped_lock lock(g_focus.lock);
        g_focus.hoverToken.fetch_add(1);
        CancelHoverLease();
        g_focus.hover = {};
        g_focus.pendingHover = {};
        g_focus.action = {};
        g_focus.use = {};
        StartFadeLocked(0.0F, kFadeOutSeconds, true, std::move(a_reason));
    }

    void ClearCancelTargets()
    {
        std::scoped_lock lock(g_focus.lock);
        const bool hadAction = g_focus.action.active || !NearlyEqual(g_focus.action.volume, 0.0F);
        const bool hadUse = g_focus.use.active || !NearlyEqual(g_focus.use.volume, 0.0F);
        if (!hadAction && !hadUse) {
            return;
        }

        g_focus.action = {};
        g_focus.use = {};
        if (InfoLoggingEnabled()) {
            logger::info("SunderheartFocus: cancel clear action={} use={}", hadAction, hadUse);
        }
        RecomputeFadeLocked("cancel-clear");
    }

    static bool SunderheartFocusConfigure(RE::StaticFunctionTag*, RE::TESSound* a_focusLoop)
    {
        if (!a_focusLoop) {
            StopImmediate(true, "configure-null");
            std::scoped_lock lock(g_focus.lock);
            g_focus.focusLoopFormID = 0;
            return false;
        }

        const RE::FormID newFormID = a_focusLoop->GetFormID();
        {
            std::scoped_lock lock(g_focus.lock);
            if (g_focus.focusLoopFormID == newFormID) {
                return true;
            }

            g_focus.focusLoopFormID = newFormID;
            g_focus.warnedMissingSound = false;
            if (InfoLoggingEnabled()) {
                logger::info("SunderheartFocus: configured sound formID={:08X}", newFormID);
            }
        }
        StopImmediate(false, "configure-change");
        return true;
    }

    static void SunderheartFocusSetHoverTarget(RE::StaticFunctionTag*, float a_volume)
    {
        const float volume = Clamp01(a_volume);
        QueueHoverCommit(volume, volume > kVolumeEpsilon);
    }

    static void SunderheartFocusClearHoverTarget(RE::StaticFunctionTag*)
    {
        ClearHoverImmediate("hover-clear");
    }

    static void SunderheartFocusSetActionTarget(RE::StaticFunctionTag*, float a_volume)
    {
        SetImmediateTarget(g_focus.action, a_volume, "action");
    }

    static void SunderheartFocusClearActionTarget(RE::StaticFunctionTag*)
    {
        SetImmediateTarget(g_focus.action, 0.0F, "action-clear");
    }

    static void SunderheartFocusSetUseTarget(RE::StaticFunctionTag*, float a_volume)
    {
        SetImmediateTarget(g_focus.use, a_volume, "use");
    }

    static void SunderheartFocusClearUseTarget(RE::StaticFunctionTag*, bool a_immediate)
    {
        if (a_immediate) {
            StopImmediate(true, "use-clear-immediate");
            return;
        }

        SetImmediateTarget(g_focus.use, 0.0F, "use-clear");
    }

    static void SunderheartFocusPresentationHandoff(RE::StaticFunctionTag*)
    {
        ClearAllAndFade("presentation-handoff");
    }

    static void SunderheartFocusClearCancelTargets(RE::StaticFunctionTag*)
    {
        ClearCancelTargets();
    }

    static void SunderheartFocusStopImmediate(RE::StaticFunctionTag*)
    {
        StopImmediate(true, "papyrus-stop");
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }
        if (a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
            StopImmediate(true, "pre-load");
        }
    }

    RE::BSEventNotifyControl FocusMenuSink::ProcessEvent(
        const RE::MenuOpenCloseEvent* a_event,
        RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
    {
        if (!a_event || a_event->opening) {
            return RE::BSEventNotifyControl::kContinue;
        }

        const std::string_view menuName{ a_event->menuName.c_str() ? a_event->menuName.c_str() : "" };
        if (menuName == kInventoryMenuName) {
            ClearHoverImmediate("inventory-menu-close");
        }

        return RE::BSEventNotifyControl::kContinue;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("SunderheartFocusConfigure", IronSoul::Papyrus::kScriptName, SunderheartFocusConfigure);
        a_vm->RegisterFunction("SunderheartFocusSetHoverTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusSetHoverTarget);
        a_vm->RegisterFunction("SunderheartFocusClearHoverTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusClearHoverTarget);
        a_vm->RegisterFunction("SunderheartFocusSetActionTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusSetActionTarget);
        a_vm->RegisterFunction("SunderheartFocusClearActionTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusClearActionTarget);
        a_vm->RegisterFunction("SunderheartFocusSetUseTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusSetUseTarget);
        a_vm->RegisterFunction("SunderheartFocusClearUseTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusClearUseTarget);
        a_vm->RegisterFunction("SunderheartFocusPresentationHandoff", IronSoul::Papyrus::kScriptName, SunderheartFocusPresentationHandoff);
        a_vm->RegisterFunction("SunderheartFocusClearCancelTargets", IronSoul::Papyrus::kScriptName, SunderheartFocusClearCancelTargets);
        a_vm->RegisterFunction("SunderheartFocusStopImmediate", IronSoul::Papyrus::kScriptName, SunderheartFocusStopImmediate);
    }

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("SunderheartFocus: messaging interface unavailable; pre-load stop disabled");
        } else if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("SunderheartFocus: failed to register lifecycle listener");
        } else {
            logger::info("SunderheartFocus: lifecycle listener registered");
        }

        std::scoped_lock lock(g_focus.lock);
        if (g_focus.menuSinkRegistered) {
            return;
        }

        auto* ui = RE::UI::GetSingleton();
        if (!ui) {
            logger::warn("SunderheartFocus: UI singleton unavailable; inventory close cleanup disabled");
            return;
        }

        ui->AddEventSink<RE::MenuOpenCloseEvent>(
            static_cast<RE::BSTEventSink<RE::MenuOpenCloseEvent>*>(&g_menuSink));
        g_focus.menuSinkRegistered = true;
        logger::info("SunderheartFocus: menu sink registered");
    }
}
