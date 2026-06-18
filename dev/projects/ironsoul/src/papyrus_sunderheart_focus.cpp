#include "pch.h"
#include "audio_util.h"
#include "papyrus_sunderheart_focus.h"
#include "papyrus_itemselect.h"
#include "papyrus_common.h"
#include "config.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cctype>
#include <cmath>
#include <string>
#include <thread>

namespace IronSoul::Papyrus::SunderheartFocus
{
namespace
{
    constexpr float kFadeInSeconds = 0.35F;
    constexpr float kFadeOutSeconds = 1.0F;
    constexpr float kHoverFadeOutSeconds = 0.12F;
    constexpr float kRetargetSeconds = 0.12F;
    constexpr float kHoverMatchDebounceSeconds = 0.04F;
    constexpr float kHoverClearDebounceSeconds = 0.25F;
    constexpr float kHoverLeaseCheckSeconds = 0.25F;
    constexpr float kInventoryHoverPollSeconds = 0.03F;
    constexpr float kInventoryHoverStableSeconds = 0.07F;
    constexpr float kUseIntentPendingMaxAgeSeconds = 0.85F;
    constexpr float kFadeStepSeconds = 0.03F;
    constexpr float kVolumeEpsilon = 0.001F;
    constexpr const char* kInventoryMenuName = "InventoryMenu";
    constexpr std::array<float, 5> kInventoryHoverTierVolumes{
        0.2F,
        0.4F,
        0.6F,
        0.8F,
        1.0F
    };

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
        std::atomic<std::uint64_t> inventoryHoverPollToken{ 0 };
        std::atomic<bool> warnedMissingTask{ false };
        std::atomic<bool> warnedMissingAudio{ false };
        std::atomic<bool> warnedMissingSound{ false };
        std::array<RE::FormID, 5> inventoryHoverTierListFormIDs{};
        RE::FormID inventoryHoverSpentFormID{ 0 };
        RE::FormID inventoryHoverCandidateFormID{ 0 };
        RE::FormID inventoryHoverCurrentFormID{ 0 };
        RE::FormID inventoryHoverSuppressedFormID{ 0 };
        float inventoryHoverCandidateVolume{ 0.0F };
        double inventoryHoverCandidateSinceSeconds{ 0.0 };
        bool inventoryHoverConfigured{ false };
        bool inventoryHoverPolling{ false };
        bool menuSinkRegistered{ false };
        bool inputSinkRegistered{ false };
        bool useIntentCaptureActive{ false };
        double useIntentCaptureUntilSeconds{ 0.0 };
        bool useIntentPending{ false };
        RE::FormID useIntentPendingFormID{ 0 };
        std::int32_t useIntentPendingTier{ 0 };
        double useIntentPendingAtSeconds{ 0.0 };
        std::string useIntentPendingSource;
        bool useIntentClaimed{ false };
        RE::FormID useIntentClaimedFormID{ 0 };
        std::int32_t useIntentClaimedTier{ 0 };
        double useIntentClaimedAtSeconds{ 0.0 };
        std::string useIntentClaimedSource;
    };

    struct InventoryHoverConfigSnapshot
    {
        std::array<RE::FormID, 5> tierListFormIDs{};
        RE::FormID spentFormID{ 0 };
        bool configured{ false };
    };

    class FocusMenuSink :
        public RE::BSTEventSink<RE::MenuOpenCloseEvent>
    {
    public:
        RE::BSEventNotifyControl ProcessEvent(
            const RE::MenuOpenCloseEvent* a_event,
            RE::BSTEventSource<RE::MenuOpenCloseEvent>*) override;
    };

    class FocusInputSink :
        public RE::BSTEventSink<RE::InputEvent*>
    {
    public:
        RE::BSEventNotifyControl ProcessEvent(
            RE::InputEvent* const* a_eventList,
            RE::BSTEventSource<RE::InputEvent*>*) override;
    };

    FocusState g_focus;
    FocusMenuSink g_menuSink;
    FocusInputSink g_inputSink;

    void ValidateHoverLease(std::uint64_t a_token);
    void StopInventoryHoverPolling(std::string a_reason, bool a_clearHover);

    bool NearlyEqual(float a_left, float a_right)
    {
        return std::fabs(a_left - a_right) <= kVolumeEpsilon;
    }

    double NowSeconds()
    {
        using clock = std::chrono::steady_clock;
        return std::chrono::duration<double>(clock::now().time_since_epoch()).count();
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
            return IronSoul::Audio::ClampVolume(g_focus.use.volume);
        }
        if (g_focus.action.active) {
            return IronSoul::Audio::ClampVolume(g_focus.action.volume);
        }
        if (g_focus.hover.active) {
            return IronSoul::Audio::ClampVolume(g_focus.hover.volume);
        }
        return 0.0F;
    }

    bool QueueTask(auto a_task, const char* a_operation)
    {
        return IronSoul::Audio::QueueTask(std::move(a_task), "SunderheartFocus", a_operation ? a_operation : "", &g_focus.warnedMissingTask);
    }

    bool IsInventoryMenuOpen()
    {
        auto* ui = RE::UI::GetSingleton();
        return ui && ui->IsMenuOpen(kInventoryMenuName);
    }

    void EnsureInputSinkRegisteredLocked(std::string_view a_reason, bool a_warnMissing)
    {
        if (g_focus.inputSinkRegistered) {
            return;
        }

        if (auto* inputManager = RE::BSInputDeviceManager::GetSingleton()) {
            inputManager->AddEventSink(static_cast<RE::BSTEventSink<RE::InputEvent*>*>(&g_inputSink));
            g_focus.inputSinkRegistered = true;
            logger::info("SunderheartFocus: input sink registered reason={}", a_reason.empty() ? "unknown" : a_reason);
        } else if (a_warnMissing) {
            logger::warn("SunderheartFocus: BSInputDeviceManager unavailable; use intent capture will retry reason={}", a_reason.empty() ? "unknown" : a_reason);
        }
    }

    void EnsureInputSinkRegistered(std::string_view a_reason, bool a_warnMissing)
    {
        std::scoped_lock lock(g_focus.lock);
        EnsureInputSinkRegisteredLocked(a_reason, a_warnMissing);
    }

    InventoryHoverConfigSnapshot GetInventoryHoverConfigSnapshot()
    {
        std::scoped_lock lock(g_focus.lock);
        return {
            g_focus.inventoryHoverTierListFormIDs,
            g_focus.inventoryHoverSpentFormID,
            g_focus.inventoryHoverConfigured
        };
    }

    std::int32_t ResolveInventorySunderheartTier(RE::TESForm* a_form, const InventoryHoverConfigSnapshot& a_config)
    {
        if (!a_form || !a_config.configured) {
            return 0;
        }

        const RE::FormID formID = a_form->GetFormID();
        if (formID == 0 || (a_config.spentFormID != 0 && formID == a_config.spentFormID)) {
            return 0;
        }

        for (std::size_t index = a_config.tierListFormIDs.size(); index > 0; --index) {
            const RE::FormID listFormID = a_config.tierListFormIDs[index - 1];
            auto* list = listFormID != 0 ? RE::TESForm::LookupByID<RE::BGSListForm>(listFormID) : nullptr;
            if (list && list->HasForm(a_form)) {
                return static_cast<std::int32_t>(index);
            }
        }

        return 0;
    }

    float ResolveInventoryHoverVolume(RE::TESForm* a_form, const InventoryHoverConfigSnapshot& a_config)
    {
        const std::int32_t tier = ResolveInventorySunderheartTier(a_form, a_config);
        if (tier <= 0 || static_cast<std::size_t>(tier) > kInventoryHoverTierVolumes.size()) {
            return 0.0F;
        }
        return kInventoryHoverTierVolumes[static_cast<std::size_t>(tier - 1)];
    }

    std::string NormalizeInputEventName(std::string_view a_value)
    {
        std::string out;
        out.reserve(a_value.size());
        for (unsigned char c : a_value) {
            if (c == ' ' || c == '_' || c == '-' || c == '\t') {
                continue;
            }
            out.push_back(static_cast<char>(std::tolower(c)));
        }
        return out;
    }

    bool IsUseIntentButton(const RE::ButtonEvent& a_event, std::string_view a_userEvent)
    {
        if (!a_event.IsDown()) {
            return false;
        }

        const std::string normalized = NormalizeInputEventName(a_userEvent);
        if (normalized == "activate" ||
            normalized == "accept" ||
            normalized == "equip" ||
            normalized == "use") {
            return true;
        }

        return a_event.GetDevice() == RE::INPUT_DEVICE::kMouse && a_event.GetIDCode() == 0;
    }

    void ClearUseIntentLocked()
    {
        g_focus.useIntentCaptureActive = false;
        g_focus.useIntentCaptureUntilSeconds = 0.0;
        g_focus.useIntentPending = false;
        g_focus.useIntentPendingFormID = 0;
        g_focus.useIntentPendingTier = 0;
        g_focus.useIntentPendingAtSeconds = 0.0;
        g_focus.useIntentPendingSource.clear();
        g_focus.useIntentClaimed = false;
        g_focus.useIntentClaimedFormID = 0;
        g_focus.useIntentClaimedTier = 0;
        g_focus.useIntentClaimedAtSeconds = 0.0;
        g_focus.useIntentClaimedSource.clear();
    }

    void ExpireUseIntentCaptureLocked(double a_now)
    {
        if (g_focus.useIntentCaptureActive && a_now > g_focus.useIntentCaptureUntilSeconds) {
            g_focus.useIntentCaptureActive = false;
            g_focus.useIntentCaptureUntilSeconds = 0.0;
        }
        if (g_focus.useIntentPending &&
            a_now > (g_focus.useIntentPendingAtSeconds + kUseIntentPendingMaxAgeSeconds)) {
            if (InfoLoggingEnabled()) {
                logger::info(
                    "SunderheartUseIntent: native pending expired formID={:08X} tier={} source={}",
                    g_focus.useIntentPendingFormID,
                    g_focus.useIntentPendingTier,
                    g_focus.useIntentPendingSource);
            }
            g_focus.useIntentPending = false;
            g_focus.useIntentPendingFormID = 0;
            g_focus.useIntentPendingTier = 0;
            g_focus.useIntentPendingAtSeconds = 0.0;
            g_focus.useIntentPendingSource.clear();
        }
    }

    void RecordSelectedSunderheartUseIntent(std::string a_source)
    {
        const double now = NowSeconds();
        InventoryHoverConfigSnapshot config;
        {
            std::scoped_lock lock(g_focus.lock);
            ExpireUseIntentCaptureLocked(now);
            if (!g_focus.useIntentCaptureActive) {
                return;
            }
            config = {
                g_focus.inventoryHoverTierListFormIDs,
                g_focus.inventoryHoverSpentFormID,
                g_focus.inventoryHoverConfigured
            };
        }

        if (!IsInventoryMenuOpen()) {
            return;
        }

        auto* entry = ItemSelect::GetInventorySelectedEntry();
        auto* selectedForm = entry ? entry->object : nullptr;
        const std::int32_t tier = ResolveInventorySunderheartTier(selectedForm, config);
        if (tier <= 0 || !selectedForm) {
            return;
        }

        const RE::FormID formID = selectedForm->GetFormID();
        if (formID == 0) {
            return;
        }

        {
            std::scoped_lock lock(g_focus.lock);
            ExpireUseIntentCaptureLocked(now);
            if (!g_focus.useIntentCaptureActive) {
                return;
            }
            g_focus.useIntentPending = true;
            g_focus.useIntentPendingFormID = formID;
            g_focus.useIntentPendingTier = tier;
            g_focus.useIntentPendingAtSeconds = now;
            g_focus.useIntentPendingSource = std::move(a_source);
            if (InfoLoggingEnabled()) {
                logger::info(
                    "SunderheartUseIntent: native captured formID={:08X} tier={} source={}",
                    g_focus.useIntentPendingFormID,
                    g_focus.useIntentPendingTier,
                    g_focus.useIntentPendingSource);
            }
        }
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
        if (!sound) {
            if (!g_focus.warnedMissingSound.exchange(true)) {
                logger::warn("SunderheartFocus: sound descriptor lookup failed soundFormID={:08X}", g_focus.focusLoopFormID);
            }
            return false;
        }

        IronSoul::Audio::SoundBuildOptions options;
        options.owner = "SunderheartFocus";
        options.reason = "focus-loop";
        options.volume = 0.0F;
        options.missingDescriptorWarned = &g_focus.warnedMissingSound;
        options.missingAudioWarned = &g_focus.warnedMissingAudio;
        if (!IronSoul::Audio::BuildAndPlaySound(g_focus.handle, sound, options)) {
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
        const float volume = IronSoul::Audio::ClampVolume(a_volume);
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
        float target = IronSoul::Audio::ClampVolume(a_targetVolume);
        if (!FocusSfxEnabled() && target > 0.0F) {
            target = 0.0F;
            a_stopAfterFade = true;
            a_reason += ":disabled";
        }

        if (NearlyEqual(g_focus.targetVolume, target) && !a_stopAfterFade) {
            return;
        }

        const std::uint64_t token = g_focus.fadeToken.fetch_add(1) + 1;
        const float startVolume = IronSoul::Audio::ClampVolume(g_focus.currentVolume);
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

        const auto fadePlan = IronSoul::Audio::MakeFadePlan(a_seconds, kFadeStepSeconds);
        QueueApplyVolume(token, startVolume, target > kVolumeEpsilon, false, a_reason);

        std::thread([token, startVolume, target, steps = fadePlan.steps, sleepDuration = fadePlan.stepDuration, stopAfterFade = a_stopAfterFade, reason = std::move(a_reason)]() {
            for (int step = 1; step <= steps; ++step) {
                std::this_thread::sleep_for(sleepDuration);
                if (g_focus.fadeToken.load() != token) {
                    return;
                }

                const float volume = IronSoul::Audio::LinearFadeVolume(startVolume, target, step, steps);
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
                a_reason == "hover-lease-menu-closed" ||
                a_reason == "native-hover-clear" ||
                a_reason == "native-hover-disabled" ||
                a_reason == "native-hover-suppressed";
            const float fadeSeconds = hoverOnlyFade ? kHoverFadeOutSeconds : kFadeOutSeconds;
            StartFadeLocked(0.0F, fadeSeconds, true, std::move(a_reason));
        }
    }

    void SetImmediateTarget(FocusTarget& a_target, float a_volume, std::string a_reason)
    {
        const float volume = IronSoul::Audio::ClampVolume(a_volume);
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
        const float volume = a_active ? IronSoul::Audio::ClampVolume(a_volume) : 0.0F;
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

    void ResetInventoryHoverSelectionLocked()
    {
        g_focus.inventoryHoverCandidateFormID = 0;
        g_focus.inventoryHoverCurrentFormID = 0;
        g_focus.inventoryHoverCandidateVolume = 0.0F;
        g_focus.inventoryHoverCandidateSinceSeconds = 0.0;
    }

    void CommitInventoryHoverLocked(RE::FormID a_formID, float a_volume)
    {
        const float volume = IronSoul::Audio::ClampVolume(a_volume);
        if (volume <= kVolumeEpsilon) {
            ResetInventoryHoverSelectionLocked();
            ClearHoverLocked("native-hover-clear");
            return;
        }

        g_focus.pendingHover = {};
        const bool changed =
            !g_focus.hover.active ||
            g_focus.inventoryHoverCurrentFormID != a_formID ||
            !NearlyEqual(g_focus.hover.volume, volume);

        g_focus.inventoryHoverCurrentFormID = a_formID;
        if (!changed) {
            ArmHoverLeaseLocked();
            return;
        }

        g_focus.hover.active = true;
        g_focus.hover.volume = volume;
        if (InfoLoggingEnabled()) {
            logger::info("SunderheartFocus: native hover commit formID={:08X} volume={}", a_formID, volume);
        }
        RecomputeFadeLocked("hover");
        ArmHoverLeaseLocked();
    }

    void ClearInventoryHoverLocked(std::string a_reason)
    {
        ResetInventoryHoverSelectionLocked();
        ClearHoverLocked(std::move(a_reason));
    }

    void PollInventoryHover(std::uint64_t a_token)
    {
        if (g_focus.inventoryHoverPollToken.load() != a_token) {
            return;
        }
        if (!IsInventoryMenuOpen()) {
            StopInventoryHoverPolling("inventory-menu-close", true);
            return;
        }

        const InventoryHoverConfigSnapshot config = GetInventoryHoverConfigSnapshot();
        auto* entry = ItemSelect::GetInventorySelectedEntry();
        auto* selectedForm = entry ? entry->object : nullptr;
        const RE::FormID selectedFormID = selectedForm ? selectedForm->GetFormID() : 0;
        const float focusVolume = ResolveInventoryHoverVolume(selectedForm, config);
        const bool matched = focusVolume > kVolumeEpsilon;
        const double now = NowSeconds();

        std::scoped_lock lock(g_focus.lock);
        if (g_focus.inventoryHoverPollToken.load() != a_token || !g_focus.inventoryHoverPolling) {
            return;
        }
        if (!g_focus.inventoryHoverConfigured || !FocusSfxEnabled() || g_focus.focusLoopFormID == 0) {
            g_focus.inventoryHoverPolling = false;
            g_focus.inventoryHoverPollToken.fetch_add(1);
            g_focus.inventoryHoverSuppressedFormID = 0;
            ClearInventoryHoverLocked("native-hover-disabled");
            return;
        }

        if (!matched) {
            if (g_focus.inventoryHoverSuppressedFormID != 0 && selectedFormID != g_focus.inventoryHoverSuppressedFormID) {
                g_focus.inventoryHoverSuppressedFormID = 0;
            }
            ClearInventoryHoverLocked("native-hover-clear");
            return;
        }

        if (g_focus.inventoryHoverSuppressedFormID != 0) {
            if (selectedFormID == g_focus.inventoryHoverSuppressedFormID) {
                ResetInventoryHoverSelectionLocked();
                ClearHoverLocked("native-hover-suppressed");
                return;
            }
            g_focus.inventoryHoverSuppressedFormID = 0;
        }

        if (g_focus.inventoryHoverCandidateFormID != selectedFormID ||
            !NearlyEqual(g_focus.inventoryHoverCandidateVolume, focusVolume)) {
            g_focus.inventoryHoverCandidateFormID = selectedFormID;
            g_focus.inventoryHoverCandidateVolume = focusVolume;
            g_focus.inventoryHoverCandidateSinceSeconds = now;
            return;
        }

        if ((now - g_focus.inventoryHoverCandidateSinceSeconds) < kInventoryHoverStableSeconds) {
            return;
        }

        CommitInventoryHoverLocked(selectedFormID, focusVolume);
    }

    void StartInventoryHoverPolling(std::string a_reason)
    {
        std::uint64_t token = 0;
        {
            std::scoped_lock lock(g_focus.lock);
            if (!g_focus.inventoryHoverConfigured || g_focus.inventoryHoverPolling || g_focus.focusLoopFormID == 0) {
                return;
            }
            if (!FocusSfxEnabled()) {
                return;
            }
            g_focus.inventoryHoverPolling = true;
            token = g_focus.inventoryHoverPollToken.fetch_add(1) + 1;
            if (InfoLoggingEnabled()) {
                logger::info("SunderheartFocus: inventory hover polling started reason={}", a_reason);
            }
        }

        std::thread([token]() {
            const auto pollDelay = std::chrono::duration<float>(kInventoryHoverPollSeconds);
            while (g_focus.inventoryHoverPollToken.load() == token) {
                std::this_thread::sleep_for(pollDelay);
                if (g_focus.inventoryHoverPollToken.load() != token) {
                    return;
                }
                if (!QueueTask([token]() {
                    PollInventoryHover(token);
                }, "SunderheartFocus inventory hover poll")) {
                    StopInventoryHoverPolling("inventory-hover-task-unavailable", true);
                    return;
                }
            }
        }).detach();
    }

    void StopInventoryHoverPolling(std::string a_reason, bool a_clearHover)
    {
        std::scoped_lock lock(g_focus.lock);
        if (g_focus.inventoryHoverPolling) {
            g_focus.inventoryHoverPolling = false;
            if (InfoLoggingEnabled()) {
                logger::info("SunderheartFocus: inventory hover polling stopped reason={}", a_reason);
            }
        }
        g_focus.inventoryHoverPollToken.fetch_add(1);
        g_focus.inventoryHoverSuppressedFormID = 0;
        if (a_clearHover) {
            ClearInventoryHoverLocked(std::move(a_reason));
        } else {
            ResetInventoryHoverSelectionLocked();
        }
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
                ResetInventoryHoverSelectionLocked();
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
        ResetInventoryHoverSelectionLocked();
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
            StopInventoryHoverPolling("configure-null", true);
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
        if (IsInventoryMenuOpen()) {
            StartInventoryHoverPolling("configure-change");
        }
        return true;
    }

    static bool SunderheartFocusConfigureInventoryHover(
        RE::StaticFunctionTag*,
        RE::BGSListForm* a_tier1,
        RE::BGSListForm* a_tier2,
        RE::BGSListForm* a_tier3,
        RE::BGSListForm* a_tier4,
        RE::BGSListForm* a_tier5,
        RE::TESForm* a_spent)
    {
        bool configured = false;
        {
            std::scoped_lock lock(g_focus.lock);
            g_focus.inventoryHoverTierListFormIDs = {
                a_tier1 ? a_tier1->GetFormID() : 0,
                a_tier2 ? a_tier2->GetFormID() : 0,
                a_tier3 ? a_tier3->GetFormID() : 0,
                a_tier4 ? a_tier4->GetFormID() : 0,
                a_tier5 ? a_tier5->GetFormID() : 0
            };
            g_focus.inventoryHoverSpentFormID = a_spent ? a_spent->GetFormID() : 0;
            g_focus.inventoryHoverConfigured =
                g_focus.inventoryHoverTierListFormIDs[0] != 0 ||
                g_focus.inventoryHoverTierListFormIDs[1] != 0 ||
                g_focus.inventoryHoverTierListFormIDs[2] != 0 ||
                g_focus.inventoryHoverTierListFormIDs[3] != 0 ||
                g_focus.inventoryHoverTierListFormIDs[4] != 0;
            configured = g_focus.inventoryHoverConfigured;
            ResetInventoryHoverSelectionLocked();
            if (InfoLoggingEnabled()) {
                logger::info(
                    "SunderheartFocus: inventory hover configured enabled={} spentFormID={:08X}",
                    g_focus.inventoryHoverConfigured,
                    g_focus.inventoryHoverSpentFormID);
            }
        }

        if (IsInventoryMenuOpen()) {
            StartInventoryHoverPolling("configure-inventory-hover");
        }
        return configured;
    }

    static bool SunderheartUseIntentConfigureInventoryForms(
        RE::StaticFunctionTag* a_tag,
        RE::BGSListForm* a_tier1,
        RE::BGSListForm* a_tier2,
        RE::BGSListForm* a_tier3,
        RE::BGSListForm* a_tier4,
        RE::BGSListForm* a_tier5,
        RE::TESForm* a_spent)
    {
        return SunderheartFocusConfigureInventoryHover(a_tag, a_tier1, a_tier2, a_tier3, a_tier4, a_tier5, a_spent);
    }

    static void SunderheartUseIntentBeginCapture(RE::StaticFunctionTag*, float a_seconds, std::string a_reason)
    {
        if (a_seconds <= 0.0F) {
            return;
        }

        EnsureInputSinkRegistered("use-intent-capture", false);

        const double now = NowSeconds();
        const double until = now + static_cast<double>((std::min)(a_seconds, 2.0F));
        {
            std::scoped_lock lock(g_focus.lock);
            g_focus.useIntentCaptureActive = true;
            g_focus.useIntentCaptureUntilSeconds = until;
            if (InfoLoggingEnabled()) {
                logger::info(
                    "SunderheartUseIntent: native capture begin reason={} seconds={}",
                    a_reason.empty() ? "unknown" : a_reason,
                    a_seconds);
            }
        }
    }

    static void SunderheartUseIntentClearCapture(RE::StaticFunctionTag*, std::string a_reason)
    {
        bool hadState = false;
        {
            std::scoped_lock lock(g_focus.lock);
            hadState =
                g_focus.useIntentCaptureActive ||
                g_focus.useIntentPending ||
                g_focus.useIntentClaimed;
            ClearUseIntentLocked();
        }
        if (hadState && InfoLoggingEnabled()) {
            logger::info("SunderheartUseIntent: native cleared reason={}", a_reason.empty() ? "unknown" : a_reason);
        }
    }

    static bool SunderheartUseIntentClaim(RE::StaticFunctionTag*)
    {
        const double now = NowSeconds();
        std::scoped_lock lock(g_focus.lock);
        ExpireUseIntentCaptureLocked(now);
        if (!g_focus.useIntentPending) {
            return false;
        }

        g_focus.useIntentClaimed = true;
        g_focus.useIntentClaimedFormID = g_focus.useIntentPendingFormID;
        g_focus.useIntentClaimedTier = g_focus.useIntentPendingTier;
        g_focus.useIntentClaimedAtSeconds = g_focus.useIntentPendingAtSeconds;
        g_focus.useIntentClaimedSource = g_focus.useIntentPendingSource;
        g_focus.useIntentPending = false;
        g_focus.useIntentPendingFormID = 0;
        g_focus.useIntentPendingTier = 0;
        g_focus.useIntentPendingAtSeconds = 0.0;
        g_focus.useIntentPendingSource.clear();
        g_focus.useIntentCaptureActive = false;
        g_focus.useIntentCaptureUntilSeconds = 0.0;
        if (InfoLoggingEnabled()) {
            logger::info(
                "SunderheartUseIntent: native claimed formID={:08X} tier={} source={}",
                g_focus.useIntentClaimedFormID,
                g_focus.useIntentClaimedTier,
                g_focus.useIntentClaimedSource);
        }
        return true;
    }

    static RE::TESForm* SunderheartUseIntentClaimedBaseForm(RE::StaticFunctionTag*)
    {
        std::scoped_lock lock(g_focus.lock);
        return g_focus.useIntentClaimedFormID != 0 ? RE::TESForm::LookupByID(g_focus.useIntentClaimedFormID) : nullptr;
    }

    static std::int32_t SunderheartUseIntentClaimedTier(RE::StaticFunctionTag*)
    {
        std::scoped_lock lock(g_focus.lock);
        return g_focus.useIntentClaimed ? g_focus.useIntentClaimedTier : 0;
    }

    static float SunderheartUseIntentClaimedAgeSeconds(RE::StaticFunctionTag*)
    {
        const double now = NowSeconds();
        std::scoped_lock lock(g_focus.lock);
        if (!g_focus.useIntentClaimed || g_focus.useIntentClaimedAtSeconds <= 0.0) {
            return -1.0F;
        }
        return static_cast<float>((std::max)(0.0, now - g_focus.useIntentClaimedAtSeconds));
    }

    static std::string SunderheartUseIntentClaimedSource(RE::StaticFunctionTag*)
    {
        std::scoped_lock lock(g_focus.lock);
        return g_focus.useIntentClaimed ? g_focus.useIntentClaimedSource : "";
    }

    static void SunderheartFocusSetHoverTarget(RE::StaticFunctionTag*, float a_volume)
    {
        const float volume = IronSoul::Audio::ClampVolume(a_volume);
        if (volume <= kVolumeEpsilon) {
            ClearHoverImmediate("hover-clear");
            return;
        }
        QueueHoverCommit(volume, volume > kVolumeEpsilon);
    }

    static void SunderheartFocusClearHoverTarget(RE::StaticFunctionTag*)
    {
        ClearHoverImmediate("hover-clear");
    }

    static void SunderheartFocusSuppressInventoryHover(RE::StaticFunctionTag*, std::string a_reason)
    {
        auto* entry = ItemSelect::GetInventorySelectedEntry();
        auto* selectedForm = entry ? entry->object : nullptr;
        const RE::FormID selectedFormID = selectedForm ? selectedForm->GetFormID() : 0;
        std::scoped_lock lock(g_focus.lock);
        g_focus.inventoryHoverSuppressedFormID = selectedFormID;
        ResetInventoryHoverSelectionLocked();
        if (InfoLoggingEnabled()) {
            logger::info(
                "SunderheartFocus: inventory hover suppressed reason={} formID={:08X}",
                a_reason.empty() ? "papyrus" : a_reason,
                selectedFormID);
        }
        ClearHoverLocked("native-hover-suppressed");
    }

    static void SunderheartFocusClearInventoryHoverSuppression(RE::StaticFunctionTag*, std::string a_reason)
    {
        bool shouldStartPolling = false;
        {
            std::scoped_lock lock(g_focus.lock);
            if (g_focus.inventoryHoverSuppressedFormID != 0 && InfoLoggingEnabled()) {
                logger::info(
                    "SunderheartFocus: inventory hover suppression cleared reason={} formID={:08X}",
                    a_reason.empty() ? "papyrus" : a_reason,
                    g_focus.inventoryHoverSuppressedFormID);
            }
            g_focus.inventoryHoverSuppressedFormID = 0;
            shouldStartPolling = g_focus.inventoryHoverConfigured && !g_focus.inventoryHoverPolling;
        }

        if (shouldStartPolling && IsInventoryMenuOpen()) {
            StartInventoryHoverPolling(a_reason.empty() ? "clear-suppression" : a_reason);
        }
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
        StopInventoryHoverPolling("papyrus-stop", true);
        StopImmediate(true, "papyrus-stop");
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }
        if (a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
            StopInventoryHoverPolling("pre-load", true);
            {
                std::scoped_lock lock(g_focus.lock);
                ClearUseIntentLocked();
            }
            StopImmediate(true, "pre-load");
        }
    }

    RE::BSEventNotifyControl FocusMenuSink::ProcessEvent(
        const RE::MenuOpenCloseEvent* a_event,
        RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
    {
        if (!a_event) {
            return RE::BSEventNotifyControl::kContinue;
        }

        const std::string_view menuName{ a_event->menuName.c_str() ? a_event->menuName.c_str() : "" };
        if (menuName == kInventoryMenuName) {
            if (a_event->opening) {
                EnsureInputSinkRegistered("inventory-menu-open", false);
                StartInventoryHoverPolling("inventory-menu-open");
            } else {
                StopInventoryHoverPolling("inventory-menu-close", true);
                {
                    std::scoped_lock lock(g_focus.lock);
                    ClearUseIntentLocked();
                }
            }
        }

        return RE::BSEventNotifyControl::kContinue;
    }

    RE::BSEventNotifyControl FocusInputSink::ProcessEvent(
        RE::InputEvent* const* a_eventList,
        RE::BSTEventSource<RE::InputEvent*>*)
    {
        if (!a_eventList) {
            return RE::BSEventNotifyControl::kContinue;
        }

        {
            std::scoped_lock lock(g_focus.lock);
            ExpireUseIntentCaptureLocked(NowSeconds());
            if (!g_focus.useIntentCaptureActive) {
                return RE::BSEventNotifyControl::kContinue;
            }
        }

        for (auto* event = *a_eventList; event; event = event->next) {
            if (event->GetEventType() != RE::INPUT_EVENT_TYPE::kButton) {
                continue;
            }

            auto* buttonEvent = event->AsButtonEvent();
            if (!buttonEvent) {
                continue;
            }

            const auto userEventName = buttonEvent->QUserEvent();
            const std::string_view userEvent{ userEventName.c_str() ? userEventName.c_str() : "" };
            if (!IsUseIntentButton(*buttonEvent, userEvent)) {
                continue;
            }

            RecordSelectedSunderheartUseIntent(userEvent.empty() ? "native-input" : std::string(userEvent));
        }

        return RE::BSEventNotifyControl::kContinue;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("SunderheartFocusConfigure", IronSoul::Papyrus::kScriptName, SunderheartFocusConfigure);
        a_vm->RegisterFunction("SunderheartFocusConfigureInventoryHover", IronSoul::Papyrus::kScriptName, SunderheartFocusConfigureInventoryHover);
        a_vm->RegisterFunction("SunderheartUseIntentConfigureInventoryForms", IronSoul::Papyrus::kScriptName, SunderheartUseIntentConfigureInventoryForms);
        a_vm->RegisterFunction("SunderheartUseIntentBeginCapture", IronSoul::Papyrus::kScriptName, SunderheartUseIntentBeginCapture);
        a_vm->RegisterFunction("SunderheartUseIntentClearCapture", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClearCapture);
        a_vm->RegisterFunction("SunderheartUseIntentClaim", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClaim);
        a_vm->RegisterFunction("SunderheartUseIntentClaimedBaseForm", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClaimedBaseForm);
        a_vm->RegisterFunction("SunderheartUseIntentClaimedTier", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClaimedTier);
        a_vm->RegisterFunction("SunderheartUseIntentClaimedAgeSeconds", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClaimedAgeSeconds);
        a_vm->RegisterFunction("SunderheartUseIntentClaimedSource", IronSoul::Papyrus::kScriptName, SunderheartUseIntentClaimedSource);
        a_vm->RegisterFunction("SunderheartFocusSetHoverTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusSetHoverTarget);
        a_vm->RegisterFunction("SunderheartFocusClearHoverTarget", IronSoul::Papyrus::kScriptName, SunderheartFocusClearHoverTarget);
        a_vm->RegisterFunction("SunderheartFocusSuppressInventoryHover", IronSoul::Papyrus::kScriptName, SunderheartFocusSuppressInventoryHover);
        a_vm->RegisterFunction("SunderheartFocusClearInventoryHoverSuppression", IronSoul::Papyrus::kScriptName, SunderheartFocusClearInventoryHoverSuppression);
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

        {
            std::scoped_lock lock(g_focus.lock);
            if (!g_focus.menuSinkRegistered) {
                auto* ui = RE::UI::GetSingleton();
                if (!ui) {
                    logger::warn("SunderheartFocus: UI singleton unavailable; inventory close cleanup disabled");
                } else {
                    ui->AddEventSink<RE::MenuOpenCloseEvent>(
                        static_cast<RE::BSTEventSink<RE::MenuOpenCloseEvent>*>(&g_menuSink));
                    g_focus.menuSinkRegistered = true;
                    logger::info("SunderheartFocus: menu sink registered");
                }
            }

            // BSInputDeviceManager is not reliably available this early. The
            // input sink is registered on InventoryMenu open or use-intent begin.
        }
    }
}
