#include "pch.h"
#include "papyrus_runtimepulse.h"

#include "datastore.h"
#include "papyrus_common.h"

#include <algorithm>
#include <atomic>
#include <functional>
#include <unordered_map>
#include <thread>
#include <vector>

namespace IronSoul::Papyrus::RuntimePulse
{
namespace
{
    constexpr const char* kRuntimeUpdateEvent = "IronSoul_RuntimeUpdate";
    constexpr std::uint32_t kMaxPapyrusToken = 1000000;
    constexpr auto kRespawnMonitorPollSeconds = std::chrono::duration<float>(0.2F);
    constexpr auto kDataFlushHeartbeatSeconds = std::chrono::duration<float>(5.0F);
    constexpr auto kActiveClockPollSeconds = std::chrono::duration<float>(0.25F);
    constexpr double kActiveClockMaxSampleSeconds = 1.0;
    constexpr float kDragonSoulWatcherDefaultPollSeconds = 0.5F;
    constexpr float kDragonSoulWatcherMinPollSeconds = 0.10F;
    constexpr float kDragonSoulWatcherMaxPollSeconds = 5.0F;

    struct ActiveGameplayAlarm
    {
        int targetSecond{ 0 };
        std::string reason;
    };

    struct NewGameIntroAlarm
    {
        double targetSeconds{ 0.0 };
        std::string reason;
    };

    struct RuntimePulseState
    {
        std::atomic<std::uint32_t> updateToken{ 0 };
        std::atomic<std::uint32_t> respawnMonitorToken{ 0 };
        std::atomic<std::uint32_t> dataFlushToken{ 0 };
        std::atomic<std::uint32_t> activeClockToken{ 0 };
        std::atomic<std::uint32_t> activeAlarmToken{ 0 };
        std::atomic<std::uint32_t> newGameIntroAlarmToken{ 0 };
        std::atomic<std::uint32_t> featUnlockMenuAlarmToken{ 0 };
        std::atomic<std::uint32_t> dragonSoulWatcherToken{ 0 };
        std::atomic<int> dragonSoulWatcherBaseline{ -1 };
        std::atomic<bool> dataFlushStarted{ false };
        std::atomic<bool> activeClockStarted{ false };
        std::atomic<bool> warnedMissingTask{ false };
        std::atomic<bool> warnedMissingCallback{ false };
        std::mutex activeClockLock;
        double activeGameplaySeconds{ 0.0 };
        std::chrono::steady_clock::time_point activeClockLastSample{};
        bool newGameIntroClockActive{ false };
        bool newGameIntroLoadInProgress{ false };
        bool newGameIntroSawLoadBoundary{ false };
        double newGameIntroSeconds{ 0.0 };
        std::chrono::steady_clock::time_point newGameIntroLastSample{};
        std::unordered_map<std::uint32_t, ActiveGameplayAlarm> activeAlarms;
        std::unordered_map<std::uint32_t, NewGameIntroAlarm> newGameIntroAlarms;
    };

    RuntimePulseState g_runtimePulse;

    bool IsPlayerBleedingOut(RE::Actor* a_actor);
    void SendRuntimeUpdateEvent(const std::string& a_reason, std::uint32_t a_token);

    float WallClockSeconds()
    {
        static const auto startedAt = std::chrono::steady_clock::now();
        return std::chrono::duration<float>(std::chrono::steady_clock::now() - startedAt).count();
    }

    std::uint32_t ClaimNextToken(std::atomic<std::uint32_t>& a_token)
    {
        auto current = a_token.load();
        for (;;) {
            const auto next = current >= kMaxPapyrusToken ? 1U : current + 1U;
            if (a_token.compare_exchange_weak(current, next)) {
                return next;
            }
        }
    }

    void CancelToken(std::atomic<std::uint32_t>& a_token, std::uint32_t a_expectedToken)
    {
        if (a_expectedToken == 0) {
            ClaimNextToken(a_token);
            return;
        }

        auto current = a_token.load();
        while (current == a_expectedToken) {
            const auto next = current >= kMaxPapyrusToken ? 1U : current + 1U;
            if (a_token.compare_exchange_weak(current, next)) {
                return;
            }
        }
    }

    bool QueueGameTask(std::function<void()> a_task, std::string_view a_operation)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (!g_runtimePulse.warnedMissingTask.exchange(true)) {
                logger::warn("RuntimePulse: task interface unavailable operation={}", a_operation);
            }
            return false;
        }

        task->AddTask(std::move(a_task));
        return true;
    }

    bool RuntimeEventDispatchAvailable(std::string_view a_operation)
    {
        if (!SKSE::GetTaskInterface()) {
            if (!g_runtimePulse.warnedMissingTask.exchange(true)) {
                logger::warn("RuntimePulse: task interface unavailable operation={}", a_operation);
            }
            return false;
        }

        if (!SKSE::GetModCallbackEventSource()) {
            if (!g_runtimePulse.warnedMissingCallback.exchange(true)) {
                logger::warn("RuntimePulse: mod callback source unavailable operation={}", a_operation);
            }
            return false;
        }

        return true;
    }

    bool IsPlayerInActiveGameplay()
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        auto* actor = static_cast<RE::Actor*>(player);
        if (!actor || actor->IsDead() || IsPlayerBleedingOut(actor)) {
            return false;
        }

        auto* ui = RE::UI::GetSingleton();
        if (ui && ui->GameIsPaused()) {
            return false;
        }

        return true;
    }

    int GetPlayerDragonSouls()
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        auto* actor = static_cast<RE::Actor*>(player);
        if (!actor) {
            return -1;
        }

        auto* avOwner = actor->AsActorValueOwner();
        if (!avOwner) {
            return -1;
        }

        return static_cast<int>(avOwner->GetActorValue(RE::ActorValue::kDragonSouls));
    }

    int GetActiveGameplaySecondsSnapshot()
    {
        std::scoped_lock lock(g_runtimePulse.activeClockLock);
        if (g_runtimePulse.activeGameplaySeconds <= 0.0) {
            return 0;
        }
        return static_cast<int>(g_runtimePulse.activeGameplaySeconds);
    }

    void ProcessActiveClockSample()
    {
        const auto now = std::chrono::steady_clock::now();
        const bool activeGameplay = IsPlayerInActiveGameplay();
        std::vector<std::pair<std::string, std::uint32_t>> dueAlarms;

        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            if (g_runtimePulse.activeClockLastSample.time_since_epoch().count() == 0) {
                g_runtimePulse.activeClockLastSample = now;
            } else {
                double elapsed = std::chrono::duration<double>(now - g_runtimePulse.activeClockLastSample).count();
                g_runtimePulse.activeClockLastSample = now;
                if (activeGameplay && elapsed > 0.0) {
                    if (elapsed > kActiveClockMaxSampleSeconds) {
                        elapsed = kActiveClockMaxSampleSeconds;
                    }
                    g_runtimePulse.activeGameplaySeconds += elapsed;
                }
            }

            if (g_runtimePulse.newGameIntroClockActive) {
                if (g_runtimePulse.newGameIntroLastSample.time_since_epoch().count() == 0) {
                    g_runtimePulse.newGameIntroLastSample = now;
                } else {
                    double elapsed = std::chrono::duration<double>(now - g_runtimePulse.newGameIntroLastSample).count();
                    g_runtimePulse.newGameIntroLastSample = now;
                    if (activeGameplay && elapsed > 0.0) {
                        if (elapsed > kActiveClockMaxSampleSeconds) {
                            elapsed = kActiveClockMaxSampleSeconds;
                        }
                        g_runtimePulse.newGameIntroSeconds += elapsed;
                    }
                }

                for (auto it = g_runtimePulse.newGameIntroAlarms.begin(); it != g_runtimePulse.newGameIntroAlarms.end();) {
                    if (g_runtimePulse.newGameIntroSeconds >= it->second.targetSeconds) {
                        dueAlarms.emplace_back(it->second.reason, it->first);
                        it = g_runtimePulse.newGameIntroAlarms.erase(it);
                    } else {
                        ++it;
                    }
                }
            }

            const int activeSecond = g_runtimePulse.activeGameplaySeconds > 0.0 ?
                static_cast<int>(g_runtimePulse.activeGameplaySeconds) :
                0;

            for (auto it = g_runtimePulse.activeAlarms.begin(); it != g_runtimePulse.activeAlarms.end();) {
                if (activeSecond >= it->second.targetSecond) {
                    dueAlarms.emplace_back(it->second.reason, it->first);
                    it = g_runtimePulse.activeAlarms.erase(it);
                } else {
                    ++it;
                }
            }
        }

        for (const auto& [reason, token] : dueAlarms) {
            SendRuntimeUpdateEvent(reason, token);
        }
    }

    void StartActiveGameplayClockInternal()
    {
        if (g_runtimePulse.activeClockStarted.exchange(true)) {
            return;
        }

        const auto token = ClaimNextToken(g_runtimePulse.activeClockToken);
        try {
            std::thread([token]() {
                if (InfoLoggingEnabled()) {
                    logger::info("RuntimePulse: active gameplay clock started interval=0.25s");
                }
                while (g_runtimePulse.activeClockToken.load() == token) {
                    std::this_thread::sleep_for(kActiveClockPollSeconds);
                    if (g_runtimePulse.activeClockToken.load() != token) {
                        return;
                    }

                    QueueGameTask([token]() {
                        if (g_runtimePulse.activeClockToken.load() != token) {
                            return;
                        }
                        ProcessActiveClockSample();
                    }, "active-gameplay-clock");
                }
            }).detach();
        } catch (const std::exception& e) {
            g_runtimePulse.activeClockStarted = false;
            CancelToken(g_runtimePulse.activeClockToken, token);
            logger::error("RuntimePulse: failed to start active gameplay clock error={}", e.what());
        }
    }

    void StartNewGameIntroClockInternal(std::string_view a_source)
    {
        StartActiveGameplayClockInternal();

        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            g_runtimePulse.newGameIntroClockActive = true;
            g_runtimePulse.newGameIntroLoadInProgress = false;
            g_runtimePulse.newGameIntroSawLoadBoundary = false;
            g_runtimePulse.newGameIntroSeconds = 0.0;
            g_runtimePulse.newGameIntroLastSample = std::chrono::steady_clock::now();
            g_runtimePulse.newGameIntroAlarms.clear();
        }

        if (InfoLoggingEnabled()) {
            logger::info("RuntimePulse: new-game intro clock started source={}", a_source);
        }
    }

    bool EnsureNewGameIntroClockStartedInternal(std::string_view a_source)
    {
        StartActiveGameplayClockInternal();

        bool started = false;
        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            if (!g_runtimePulse.newGameIntroClockActive &&
                !g_runtimePulse.newGameIntroLoadInProgress &&
                !g_runtimePulse.newGameIntroSawLoadBoundary) {
                g_runtimePulse.newGameIntroClockActive = true;
                g_runtimePulse.newGameIntroSeconds = 0.0;
                g_runtimePulse.newGameIntroLastSample = std::chrono::steady_clock::now();
                g_runtimePulse.newGameIntroAlarms.clear();
                started = true;
            }
        }

        if (started && InfoLoggingEnabled()) {
            logger::info("RuntimePulse: new-game intro clock started source={}", a_source);
        }
        return started;
    }

    void ResetNewGameIntroClockInternal(std::string_view a_reason, bool a_markLoadBoundary)
    {
        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            g_runtimePulse.newGameIntroClockActive = false;
            if (a_markLoadBoundary) {
                g_runtimePulse.newGameIntroSawLoadBoundary = true;
            }
            g_runtimePulse.newGameIntroSeconds = 0.0;
            g_runtimePulse.newGameIntroLastSample = {};
            g_runtimePulse.newGameIntroAlarms.clear();
        }

        if (InfoLoggingEnabled()) {
            logger::info("RuntimePulse: new-game intro clock reset reason={}", a_reason);
        }
    }

    void SetNewGameIntroLoadInProgress(bool a_inProgress)
    {
        std::scoped_lock lock(g_runtimePulse.activeClockLock);
        g_runtimePulse.newGameIntroLoadInProgress = a_inProgress;
        if (a_inProgress) {
            g_runtimePulse.newGameIntroSawLoadBoundary = true;
        }
    }

    float GetNewGameIntroElapsedSecondsSnapshot()
    {
        std::scoped_lock lock(g_runtimePulse.activeClockLock);
        if (!g_runtimePulse.newGameIntroClockActive) {
            return -1.0F;
        }
        if (g_runtimePulse.newGameIntroSeconds <= 0.0) {
            return 0.0F;
        }
        return static_cast<float>(g_runtimePulse.newGameIntroSeconds);
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }

        if (a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
            SetNewGameIntroLoadInProgress(true);
            ResetNewGameIntroClockInternal("pre-load", true);
        } else if (a_message->type == SKSE::MessagingInterface::kPostLoadGame) {
            SetNewGameIntroLoadInProgress(false);
            ResetNewGameIntroClockInternal("post-load", true);
        }
    }

    static bool EnsureNewGameIntroClockStarted(RE::StaticFunctionTag*, std::string a_reason)
    {
        if (a_reason.empty()) {
            a_reason = "papyrus";
        }
        return EnsureNewGameIntroClockStartedInternal(a_reason);
    }

    void SendRuntimeUpdateEvent(const std::string& a_reason, std::uint32_t a_token)
    {
        auto* modCallbacks = SKSE::GetModCallbackEventSource();
        if (!modCallbacks) {
            if (!g_runtimePulse.warnedMissingCallback.exchange(true)) {
                logger::warn("RuntimePulse: mod callback source unavailable");
            }
            return;
        }

        const SKSE::ModCallbackEvent ev(
            kRuntimeUpdateEvent,
            a_reason.c_str(),
            static_cast<float>(a_token),
            nullptr);
        modCallbacks->SendEvent(&ev);
    }

    std::uint32_t QueueRuntimeUpdateInternal(float a_delaySeconds, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("runtime-update")) {
            return 0;
        }

        if (a_delaySeconds < 0.0F) {
            a_delaySeconds = 0.0F;
        }
        if (a_reason.empty()) {
            a_reason = "runtime-update";
        }

        const auto token = ClaimNextToken(g_runtimePulse.updateToken);
        const auto logReason = a_reason;
        try {
            std::thread([token, delaySeconds = a_delaySeconds, reason = std::move(a_reason)]() {
                if (delaySeconds > 0.0F) {
                    std::this_thread::sleep_for(std::chrono::duration<float>(delaySeconds));
                }
                if (g_runtimePulse.updateToken.load() != token) {
                    return;
                }

                QueueGameTask([token, reason]() {
                    if (g_runtimePulse.updateToken.load() != token) {
                        return;
                    }
                    SendRuntimeUpdateEvent(reason, token);
                }, "runtime-update");
            }).detach();
        } catch (const std::exception& e) {
            CancelToken(g_runtimePulse.updateToken, token);
            logger::error("RuntimePulse: failed to queue runtime update reason={} error={}", logReason, e.what());
            return 0;
        }

        return token;
    }

    void CancelRuntimeUpdateInternal(std::uint32_t a_token)
    {
        CancelToken(g_runtimePulse.updateToken, a_token);
    }

    std::uint32_t QueueFeatUnlockMenuAlarmInternal(float a_delaySeconds, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("feat-unlock-menu-alarm")) {
            return 0;
        }

        if (a_delaySeconds < 0.0F) {
            a_delaySeconds = 0.0F;
        }
        if (a_reason.empty()) {
            a_reason = "feat-unlock-menu";
        }

        const auto token = ClaimNextToken(g_runtimePulse.featUnlockMenuAlarmToken);
        const auto logReason = a_reason;
        try {
            std::thread([token, delaySeconds = a_delaySeconds, reason = std::move(a_reason)]() {
                if (delaySeconds > 0.0F) {
                    std::this_thread::sleep_for(std::chrono::duration<float>(delaySeconds));
                }
                if (g_runtimePulse.featUnlockMenuAlarmToken.load() != token) {
                    return;
                }

                QueueGameTask([token, reason]() {
                    if (g_runtimePulse.featUnlockMenuAlarmToken.load() != token) {
                        return;
                    }
                    SendRuntimeUpdateEvent(reason, token);
                }, "feat-unlock-menu-alarm");
            }).detach();
        } catch (const std::exception& e) {
            CancelToken(g_runtimePulse.featUnlockMenuAlarmToken, token);
            logger::error("RuntimePulse: failed to queue feat unlock menu alarm reason={} error={}", logReason, e.what());
            return 0;
        }

        return token;
    }

    void CancelFeatUnlockMenuAlarmInternal(std::uint32_t a_token)
    {
        CancelToken(g_runtimePulse.featUnlockMenuAlarmToken, a_token);
    }

    bool IsPlayerBleedingOut(RE::Actor* a_actor)
    {
        if (!a_actor) {
            return false;
        }

        const auto* actorState = a_actor->AsActorState();
        return actorState && actorState->IsBleedingOut();
    }

    void SendRespawnMonitorEvent(std::uint32_t a_token, const std::string& a_reason)
    {
        SendRuntimeUpdateEvent(a_reason, a_token);
    }

    std::uint32_t BeginRespawnStateMonitorInternal(float a_watchdogSeconds, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("respawn-monitor")) {
            return 0;
        }

        if (a_watchdogSeconds < 0.0F) {
            a_watchdogSeconds = 0.0F;
        }
        if (a_reason.empty()) {
            a_reason = "respawn-monitor";
        }

        const auto token = ClaimNextToken(g_runtimePulse.respawnMonitorToken);
        const auto logReason = a_reason;
        try {
            std::thread([token, watchdogSeconds = a_watchdogSeconds, reason = std::move(a_reason)]() {
                const auto startedAt = std::chrono::steady_clock::now();
                if (InfoLoggingEnabled()) {
                    logger::info(
                        "RuntimePulse: respawn monitor started token={} watchdog={} reason={}",
                        token,
                        watchdogSeconds,
                        reason);
                }

                while (g_runtimePulse.respawnMonitorToken.load() == token) {
                    std::this_thread::sleep_for(kRespawnMonitorPollSeconds);
                    if (g_runtimePulse.respawnMonitorToken.load() != token) {
                        return;
                    }

                    QueueGameTask([token, startedAt, watchdogSeconds]() {
                        if (g_runtimePulse.respawnMonitorToken.load() != token) {
                            return;
                        }

                        const auto now = std::chrono::steady_clock::now();
                        const auto elapsed = std::chrono::duration<float>(now - startedAt).count();
                        if (watchdogSeconds > 0.0F && elapsed > watchdogSeconds) {
                            SendRespawnMonitorEvent(token, "respawn-watchdog");
                            return;
                        }

                        auto* player = RE::PlayerCharacter::GetSingleton();
                        auto* actor = static_cast<RE::Actor*>(player);
                        if (!actor) {
                            return;
                        }

                        const bool dead = actor->IsDead();
                        const bool bleedingOut = IsPlayerBleedingOut(actor);
                        if (dead && !bleedingOut) {
                            SendRespawnMonitorEvent(token, "respawn-dead");
                        } else if (!dead && !bleedingOut) {
                            SendRespawnMonitorEvent(token, "respawn-recovered");
                        }
                    }, "respawn-monitor");
                }
            }).detach();
        } catch (const std::exception& e) {
            CancelToken(g_runtimePulse.respawnMonitorToken, token);
            logger::error("RuntimePulse: failed to start respawn monitor reason={} error={}", logReason, e.what());
            return 0;
        }

        return token;
    }

    void EndRespawnStateMonitorInternal(std::uint32_t a_token)
    {
        CancelToken(g_runtimePulse.respawnMonitorToken, a_token);
    }

    std::uint32_t QueueActiveGameplayAlarmInternal(int a_targetSecond, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("active-gameplay-alarm")) {
            return 0;
        }

        StartActiveGameplayClockInternal();

        if (a_targetSecond < 0) {
            a_targetSecond = 0;
        }
        if (a_reason.empty()) {
            a_reason = "active-gameplay-alarm";
        }

        const auto token = ClaimNextToken(g_runtimePulse.activeAlarmToken);
        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            g_runtimePulse.activeAlarms[token] = ActiveGameplayAlarm{ a_targetSecond, std::move(a_reason) };
        }
        return token;
    }

    void CancelActiveGameplayAlarmInternal(std::uint32_t a_token)
    {
        std::scoped_lock lock(g_runtimePulse.activeClockLock);
        if (a_token == 0) {
            g_runtimePulse.activeAlarms.clear();
            return;
        }

        g_runtimePulse.activeAlarms.erase(a_token);
    }

    std::uint32_t QueueNewGameIntroAlarmInternal(float a_targetSeconds, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("new-game-intro-alarm")) {
            return 0;
        }

        StartActiveGameplayClockInternal();

        if (a_targetSeconds < 0.0F) {
            a_targetSeconds = 0.0F;
        }
        if (a_reason.empty()) {
            a_reason = "intro-target-alarm";
        }

        const auto token = ClaimNextToken(g_runtimePulse.newGameIntroAlarmToken);
        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            if (!g_runtimePulse.newGameIntroClockActive) {
                return 0;
            }

            g_runtimePulse.newGameIntroAlarms[token] = NewGameIntroAlarm{
                static_cast<double>(a_targetSeconds),
                a_reason
            };
        }

        return token;
    }

    void CancelNewGameIntroAlarmInternal(std::uint32_t a_token)
    {
        std::scoped_lock lock(g_runtimePulse.activeClockLock);
        if (a_token == 0) {
            g_runtimePulse.newGameIntroAlarms.clear();
            return;
        }

        g_runtimePulse.newGameIntroAlarms.erase(a_token);
    }

    std::uint32_t BeginDragonSoulWatcherInternal(int a_baselineDragonSouls, float a_pollSeconds, std::string a_reason)
    {
        if (!RuntimeEventDispatchAvailable("dragon-soul-watcher")) {
            return 0;
        }

        if (a_pollSeconds <= 0.0F) {
            a_pollSeconds = kDragonSoulWatcherDefaultPollSeconds;
        }
        a_pollSeconds = std::clamp(a_pollSeconds, kDragonSoulWatcherMinPollSeconds, kDragonSoulWatcherMaxPollSeconds);
        if (a_reason.empty()) {
            a_reason = "dragon-souls-changed";
        }

        const auto token = ClaimNextToken(g_runtimePulse.dragonSoulWatcherToken);
        g_runtimePulse.dragonSoulWatcherBaseline.store(a_baselineDragonSouls);
        const auto logReason = a_reason;
        try {
            std::thread([token, pollSeconds = a_pollSeconds, reason = std::move(a_reason)]() {
                if (InfoLoggingEnabled()) {
                    logger::info(
                        "RuntimePulse: dragon soul watcher started token={} poll={} reason={}",
                        token,
                        pollSeconds,
                        reason);
                }

                while (g_runtimePulse.dragonSoulWatcherToken.load() == token) {
                    std::this_thread::sleep_for(std::chrono::duration<float>(pollSeconds));
                    if (g_runtimePulse.dragonSoulWatcherToken.load() != token) {
                        return;
                    }

                    QueueGameTask([token, reason]() {
                        if (g_runtimePulse.dragonSoulWatcherToken.load() != token) {
                            return;
                        }
                        if (!IsPlayerInActiveGameplay()) {
                            return;
                        }

                        const int currentSouls = GetPlayerDragonSouls();
                        if (currentSouls < 0) {
                            return;
                        }

                        const int baseline = g_runtimePulse.dragonSoulWatcherBaseline.load();
                        if (baseline < 0) {
                            g_runtimePulse.dragonSoulWatcherBaseline.store(currentSouls);
                            return;
                        }
                        if (currentSouls != baseline) {
                            g_runtimePulse.dragonSoulWatcherBaseline.store(currentSouls);
                            SendRuntimeUpdateEvent(reason, token);
                        }
                    }, "dragon-soul-watcher");
                }
            }).detach();
        } catch (const std::exception& e) {
            CancelToken(g_runtimePulse.dragonSoulWatcherToken, token);
            logger::error("RuntimePulse: failed to start dragon soul watcher reason={} error={}", logReason, e.what());
            return 0;
        }

        return token;
    }

    void EndDragonSoulWatcherInternal(std::uint32_t a_token)
    {
        CancelToken(g_runtimePulse.dragonSoulWatcherToken, a_token);
    }

    static std::int32_t QueueRuntimeUpdate(RE::StaticFunctionTag*, float a_delaySeconds, std::string a_reason)
    {
        return static_cast<std::int32_t>(QueueRuntimeUpdateInternal(a_delaySeconds, std::move(a_reason)));
    }

    static void CancelRuntimeUpdate(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        CancelRuntimeUpdateInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }

    static std::int32_t QueueFeatUnlockMenuAlarm(RE::StaticFunctionTag*, float a_delaySeconds, std::string a_reason)
    {
        return static_cast<std::int32_t>(QueueFeatUnlockMenuAlarmInternal(a_delaySeconds, std::move(a_reason)));
    }

    static void CancelFeatUnlockMenuAlarm(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        CancelFeatUnlockMenuAlarmInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }

    static std::int32_t BeginRespawnStateMonitor(RE::StaticFunctionTag*, float a_watchdogSeconds, std::string a_reason)
    {
        return static_cast<std::int32_t>(BeginRespawnStateMonitorInternal(a_watchdogSeconds, std::move(a_reason)));
    }

    static void EndRespawnStateMonitor(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        EndRespawnStateMonitorInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }

    static std::int32_t GetActiveGameplaySeconds(RE::StaticFunctionTag*)
    {
        StartActiveGameplayClockInternal();
        return static_cast<std::int32_t>(GetActiveGameplaySecondsSnapshot());
    }

    static float GetWallClockSeconds(RE::StaticFunctionTag*)
    {
        return WallClockSeconds();
    }

    static float GetNewGameIntroElapsedSeconds(RE::StaticFunctionTag*)
    {
        StartActiveGameplayClockInternal();
        return GetNewGameIntroElapsedSecondsSnapshot();
    }

    static std::int32_t QueueActiveGameplayAlarm(RE::StaticFunctionTag*, std::int32_t a_targetSecond, std::string a_reason)
    {
        return static_cast<std::int32_t>(QueueActiveGameplayAlarmInternal(a_targetSecond, std::move(a_reason)));
    }

    static void CancelActiveGameplayAlarm(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        CancelActiveGameplayAlarmInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }

    static std::int32_t QueueNewGameIntroAlarm(RE::StaticFunctionTag*, float a_targetSeconds, std::string a_reason)
    {
        return static_cast<std::int32_t>(QueueNewGameIntroAlarmInternal(a_targetSeconds, std::move(a_reason)));
    }

    static void CancelNewGameIntroAlarm(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        CancelNewGameIntroAlarmInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }

    static std::int32_t BeginDragonSoulWatcher(RE::StaticFunctionTag*, std::int32_t a_baselineDragonSouls, float a_pollSeconds, std::string a_reason)
    {
        return static_cast<std::int32_t>(BeginDragonSoulWatcherInternal(a_baselineDragonSouls, a_pollSeconds, std::move(a_reason)));
    }

    static void EndDragonSoulWatcher(RE::StaticFunctionTag*, std::int32_t a_token, std::string)
    {
        EndDragonSoulWatcherInternal(a_token > 0 ? static_cast<std::uint32_t>(a_token) : 0U);
    }
}

    void StartDataFlushHeartbeat()
    {
        StartActiveGameplayClockInternal();

        if (g_runtimePulse.dataFlushStarted.exchange(true)) {
            return;
        }

        const auto token = ClaimNextToken(g_runtimePulse.dataFlushToken);
        try {
            std::thread([token]() {
                if (InfoLoggingEnabled()) {
                    logger::info("RuntimePulse: datastore dirty flush heartbeat started interval=5s");
                }
                while (g_runtimePulse.dataFlushToken.load() == token) {
                    std::this_thread::sleep_for(kDataFlushHeartbeatSeconds);
                    if (g_runtimePulse.dataFlushToken.load() != token) {
                        return;
                    }
                    IronSoul::DataStore::FlushIfDirty();
                }
            }).detach();
        } catch (const std::exception& e) {
            g_runtimePulse.dataFlushStarted = false;
            CancelToken(g_runtimePulse.dataFlushToken, token);
            logger::error("RuntimePulse: failed to start datastore flush heartbeat error={}", e.what());
        }
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("QueueRuntimeUpdate", kScriptName, QueueRuntimeUpdate);
        a_vm->RegisterFunction("CancelRuntimeUpdate", kScriptName, CancelRuntimeUpdate);
        a_vm->RegisterFunction("QueueFeatUnlockMenuAlarm", kScriptName, QueueFeatUnlockMenuAlarm);
        a_vm->RegisterFunction("CancelFeatUnlockMenuAlarm", kScriptName, CancelFeatUnlockMenuAlarm);
        a_vm->RegisterFunction("BeginRespawnStateMonitor", kScriptName, BeginRespawnStateMonitor);
        a_vm->RegisterFunction("EndRespawnStateMonitor", kScriptName, EndRespawnStateMonitor);
        a_vm->RegisterFunction("GetActiveGameplaySeconds", kScriptName, GetActiveGameplaySeconds);
        a_vm->RegisterFunction("GetWallClockSeconds", kScriptName, GetWallClockSeconds);
        a_vm->RegisterFunction("EnsureNewGameIntroClockStarted", kScriptName, EnsureNewGameIntroClockStarted);
        a_vm->RegisterFunction("GetNewGameIntroElapsedSeconds", kScriptName, GetNewGameIntroElapsedSeconds);
        a_vm->RegisterFunction("QueueNewGameIntroAlarm", kScriptName, QueueNewGameIntroAlarm);
        a_vm->RegisterFunction("CancelNewGameIntroAlarm", kScriptName, CancelNewGameIntroAlarm);
        a_vm->RegisterFunction("QueueActiveGameplayAlarm", kScriptName, QueueActiveGameplayAlarm);
        a_vm->RegisterFunction("CancelActiveGameplayAlarm", kScriptName, CancelActiveGameplayAlarm);
        a_vm->RegisterFunction("BeginDragonSoulWatcher", kScriptName, BeginDragonSoulWatcher);
        a_vm->RegisterFunction("EndDragonSoulWatcher", kScriptName, EndDragonSoulWatcher);
    }

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("RuntimePulse: messaging interface unavailable; new-game intro clock disabled");
            return;
        }

        if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("RuntimePulse: failed to register lifecycle listener");
            return;
        }

        logger::info("RuntimePulse: lifecycle listener registered");
    }

    void HandleSerializationRevert()
    {
        bool loadInProgress = false;
        {
            std::scoped_lock lock(g_runtimePulse.activeClockLock);
            loadInProgress = g_runtimePulse.newGameIntroLoadInProgress;
        }

        if (loadInProgress) {
            ResetNewGameIntroClockInternal("load-revert", true);
            return;
        }

        StartNewGameIntroClockInternal("vm-revert");
    }
}
