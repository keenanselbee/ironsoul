#include "pch.h"
#include "papyrus_healthmonitor.h"
#include "papyrus_slowmo.h"
#include "papyrus_common.h"
#include "menu_blocker.h"

#include <atomic>
#include <chrono>
#include <thread>

namespace IronSoul::Papyrus::HealthMonitor
{
namespace
{
    struct HealthMonitorState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> token{ 0 };
        std::thread worker;
        bool hpDepletedLatched{ false };
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

    static constexpr float kRearArmRecoverySeconds = 0.5f;
    static constexpr float kPollSeconds = 0.2f;

    static bool IsGamePausedByMenu()
    {
        auto* ui = RE::UI::GetSingleton();
        return ui && ui->GameIsPaused();
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

    static void StopHealthMonitorInternal()
    {
        std::thread oldWorker;
        {
            std::scoped_lock lock(g_healthMonitor.lock);
            g_healthMonitor.token.fetch_add(1);
            g_healthMonitor.hpDepletedLatched = false;
            SlowMo::ResetDeathSlowMoTracking();
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
        IronSoul::MenuBlocker::EndHealthDepletedBlock("monitor-stop");
        SlowMo::RestoreDeathSlowMo("monitor-stop");
    }

    static void StartHealthMonitorInternal()
    {
        std::thread oldWorker;
        std::uint64_t myToken = 0;

        {
            std::scoped_lock lock(g_healthMonitor.lock);
            if (g_healthMonitor.worker.joinable()) {
                oldWorker = std::move(g_healthMonitor.worker);
            }
            myToken = g_healthMonitor.token.fetch_add(1) + 1;
            g_healthMonitor.hpDepletedLatched = false;
            SlowMo::ResetDeathSlowMoTracking();
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
                        const double nowWallSec = WallSeconds();
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

                        bool shouldHandleDeathSlowMo = false;
                        bool shouldBeginMenuBlock = false;
                        bool shouldEndMenuBlock = false;
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

                            if (currentHealth <= 0.0f) {
                                if (!g_healthMonitor.hpDepletedLatched) {
                                    shouldBeginMenuBlock = true;
                                    shouldHandleDeathSlowMo = true;
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
                                        shouldEndMenuBlock = true;
                                    }
                                } else {
                                    g_healthMonitor.recoveredSinceSec = 0.0;
                                }
                            }
                        }

                        if (shouldBeginMenuBlock) {
                            IronSoul::MenuBlocker::BeginHealthDepletedBlock();
                        }
                        if (shouldEndMenuBlock) {
                            IronSoul::MenuBlocker::EndHealthDepletedBlock("health-recovered");
                        }
                        if (shouldHandleDeathSlowMo) {
                            SlowMo::OnHealthDepleted(nowWallSec);
                        } else {
                            SlowMo::TickDeathSlowMo(nowWallSec);
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

    static void StartHealthMonitor(RE::StaticFunctionTag*)
    {
        StartHealthMonitorInternal();
    }

    static void StopHealthMonitor(RE::StaticFunctionTag*)
    {
        StopHealthMonitorInternal();
    }

    static bool KillPlayerImmediate(RE::StaticFunctionTag*, bool a_ragdollInstant, std::string a_reason)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("KillPlayerImmediate: task interface unavailable reason={}", a_reason.empty() ? "unknown" : a_reason);
            return false;
        }

        const bool ragdollInstant = a_ragdollInstant;
        const bool infoLog = InfoLoggingEnabled();
        const std::string reason = a_reason.empty() ? "unknown" : a_reason;
        const auto requestedAt = std::chrono::steady_clock::now();

        if (infoLog) {
            logger::info("KillPlayerImmediate: request queued ragdollInstant={} reason={}", ragdollInstant, reason);
        }

        task->AddTask([ragdollInstant, infoLog, reason, requestedAt]() {
            const auto queueDelayMs = std::chrono::duration<double, std::milli>(
                std::chrono::steady_clock::now() - requestedAt).count();

            auto* player = RE::PlayerCharacter::GetSingleton();
            if (!player) {
                logger::warn("KillPlayerImmediate: player unavailable reason={}", reason);
                return;
            }

            auto* actor = static_cast<RE::Actor*>(player);
            if (!actor) {
                logger::warn("KillPlayerImmediate: actor unavailable reason={}", reason);
                return;
            }

            if (auto* base = actor->GetActorBase()) {
                base->actorData.actorBaseFlags.reset(RE::ACTOR_BASE_DATA::Flag::kEssential);
            }
            if (auto* avOwner = actor->AsActorValueOwner()) {
                avOwner->SetActorValue(RE::ActorValue::kHealth, 0.0f);
            }

            actor->KillImpl(actor, 999999.0f, true, ragdollInstant);
            if (ragdollInstant) {
                actor->PotentiallyFixRagdollState();
            }

            if (infoLog) {
                logger::info(
                    "KillPlayerImmediate: KillImpl executed ragdollInstant={} reason={} queueDelayMs={:.1f}",
                    ragdollInstant,
                    reason,
                    queueDelayMs);
            }
        });

        return true;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("StartHealthMonitor", kScriptName, StartHealthMonitor);
        a_vm->RegisterFunction("StopHealthMonitor", kScriptName, StopHealthMonitor);
        a_vm->RegisterFunction("KillPlayerImmediate", kScriptName, KillPlayerImmediate);
    }
}
