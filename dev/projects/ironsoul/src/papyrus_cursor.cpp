#include "pch.h"
#include "papyrus_cursor.h"
#include "papyrus_common.h"
#include "config.h"

#include <array>
#include <atomic>
#include <limits>
#include <thread>
#include <unordered_set>

namespace IronSoul::Papyrus::Cursor
{
namespace
{
    constexpr std::array<const char*, 14> kOverlayMenuNames{
        "HUD Menu",
        "MiniMapMenu",
        "TrueHUD",
        "lvlWidget",
        "goldWidget",
        "gametimeWidget",
        "shoutWidget",
        "resistWidget",
        "playtimeWidget",
        "weightWidget",
        "equipWidget_STB",
        "STBActiveEffects",
        "BTPS Menu",
        "BTPS Ovelay Menu"
    };

    struct OverlayAlphaState
    {
        bool captured{ false };
        double savedAlpha{ 100.0 };
    };

    struct CursorSuppressState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> workerToken{ 0 };
        std::thread worker;
        std::int32_t nextToken{ 0 };
        std::unordered_set<std::int32_t> activeTokens;
        bool suppressionApplied{ false };
        bool savedPosValid{ false };
        bool savedVisibilityValid{ false };
        bool savedVisible{ true };
        float savedPosX{ 0.0f };
        float savedPosY{ 0.0f };
        bool warnedMissingCursor{ false };
        std::uintptr_t customMenuAddr{ 0 };
        bool customMenuFlagsValid{ false };
        bool customMenuHadUsesCursor{ false };
        bool customMenuHadUpdateUsesCursor{ false };
        std::array<OverlayAlphaState, kOverlayMenuNames.size()> overlayAlphaStates{};

        ~CursorSuppressState()
        {
            workerToken.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };
    CursorSuppressState g_cursorSuppressState;

    static void ResetOverlayAlphaStatesLocked()
    {
        for (auto& overlayState : g_cursorSuppressState.overlayAlphaStates) {
            overlayState.captured = false;
            overlayState.savedAlpha = 100.0;
        }
    }

    static void ApplyOverlayAlphaSuppressionLocked(RE::UI* a_ui)
    {
        if (!a_ui) {
            return;
        }

        for (std::size_t i = 0; i < kOverlayMenuNames.size(); ++i) {
            auto movie = a_ui->GetMovieView(kOverlayMenuNames[i]);
            auto* movieView = movie.get();
            if (!movieView) {
                continue;
            }

            RE::GFxValue currentAlpha;
            if (!movieView->GetVariable(&currentAlpha, "_root._alpha") || !currentAlpha.IsNumber()) {
                continue;
            }

            auto& overlayState = g_cursorSuppressState.overlayAlphaStates[i];
            if (!overlayState.captured) {
                overlayState.savedAlpha = currentAlpha.GetNumber();
                overlayState.captured = true;
            }

            movieView->SetVariableDouble("_root._alpha", 0.0, RE::GFxMovie::SetVarType::kNormal);
        }
    }

    static void RestoreOverlayAlphaSuppressionLocked(RE::UI* a_ui)
    {
        if (a_ui) {
            for (std::size_t i = 0; i < kOverlayMenuNames.size(); ++i) {
                const auto& overlayState = g_cursorSuppressState.overlayAlphaStates[i];
                if (!overlayState.captured) {
                    continue;
                }

                auto movie = a_ui->GetMovieView(kOverlayMenuNames[i]);
                auto* movieView = movie.get();
                if (!movieView) {
                    continue;
                }

                movieView->SetVariableDouble("_root._alpha", overlayState.savedAlpha, RE::GFxMovie::SetVarType::kNormal);
            }
        }

        ResetOverlayAlphaStatesLocked();
    }

    static bool ClearCustomMenuCursorFlagsLocked()
    {
        auto* ui = RE::UI::GetSingleton();
        if (!ui) {
            return false;
        }

        auto menu = ui->GetMenu("CustomMenu");
        auto* customMenu = menu.get();
        if (!customMenu) {
            g_cursorSuppressState.customMenuAddr = 0;
            g_cursorSuppressState.customMenuFlagsValid = false;
            return false;
        }

        const auto customMenuAddr = reinterpret_cast<std::uintptr_t>(customMenu);
        const bool newMenu = g_cursorSuppressState.customMenuAddr != customMenuAddr;
        if (newMenu) {
            g_cursorSuppressState.customMenuAddr = customMenuAddr;
            g_cursorSuppressState.customMenuHadUsesCursor = customMenu->UsesCursor();
            g_cursorSuppressState.customMenuHadUpdateUsesCursor = customMenu->UpdateUsesCursor();
            g_cursorSuppressState.customMenuFlagsValid = true;
        }

        bool changedFlags = false;
        if (customMenu->UsesCursor()) {
            customMenu->menuFlags.reset(RE::UI_MENU_FLAGS::kUsesCursor);
            changedFlags = true;
        }
        if (customMenu->UpdateUsesCursor()) {
            customMenu->menuFlags.reset(RE::UI_MENU_FLAGS::kUpdateUsesCursor);
            changedFlags = true;
        }

        return newMenu || changedFlags;
    }

    static void RestoreCustomMenuCursorFlagsLocked()
    {
        auto* ui = RE::UI::GetSingleton();
        RE::GPtr<RE::IMenu> menu;
        if (ui) {
            menu = ui->GetMenu("CustomMenu");
        }
        auto* customMenu = menu.get();
        if (customMenu && g_cursorSuppressState.customMenuFlagsValid &&
            reinterpret_cast<std::uintptr_t>(customMenu) == g_cursorSuppressState.customMenuAddr) {
            if (g_cursorSuppressState.customMenuHadUsesCursor) {
                customMenu->menuFlags.set(RE::UI_MENU_FLAGS::kUsesCursor);
            } else {
                customMenu->menuFlags.reset(RE::UI_MENU_FLAGS::kUsesCursor);
            }

            if (g_cursorSuppressState.customMenuHadUpdateUsesCursor) {
                customMenu->menuFlags.set(RE::UI_MENU_FLAGS::kUpdateUsesCursor);
            } else {
                customMenu->menuFlags.reset(RE::UI_MENU_FLAGS::kUpdateUsesCursor);
            }
        }

        g_cursorSuppressState.customMenuAddr = 0;
        g_cursorSuppressState.customMenuFlagsValid = false;
        g_cursorSuppressState.customMenuHadUsesCursor = false;
        g_cursorSuppressState.customMenuHadUpdateUsesCursor = false;
    }

    static bool HasActiveSession(std::uint64_t a_workerToken)
    {
        if (g_cursorSuppressState.workerToken.load() != a_workerToken) {
            return false;
        }

        std::scoped_lock lock(g_cursorSuppressState.lock);
        return g_cursorSuppressState.workerToken.load() == a_workerToken && !g_cursorSuppressState.activeTokens.empty();
    }

    static bool SleepCancelable(std::uint64_t a_workerToken, std::chrono::milliseconds a_totalSleep)
    {
        constexpr auto kSlice = std::chrono::milliseconds(10);
        const auto endAt = std::chrono::steady_clock::now() + a_totalSleep;

        while (true) {
            if (!HasActiveSession(a_workerToken)) {
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

    static void ApplyMenuCursorSuppressionLocked(RE::MenuCursor* a_menuCursor, const char* a_reason)
    {
        if (!a_menuCursor) {
            if (!g_cursorSuppressState.warnedMissingCursor) {
                g_cursorSuppressState.warnedMissingCursor = true;
                if (InfoLoggingEnabled()) {
                    logger::warn("CursorSuppress: MenuCursor singleton unavailable");
                }
            }
            return;
        }

        auto& rt = a_menuCursor->GetRuntimeData();
        const bool firstApply = !g_cursorSuppressState.suppressionApplied;
        if (firstApply) {
            g_cursorSuppressState.savedPosX = rt.cursorPosX;
            g_cursorSuppressState.savedPosY = rt.cursorPosY;
            g_cursorSuppressState.savedPosValid = true;
            g_cursorSuppressState.savedVisible = rt.showCursorCount >= 0;
            g_cursorSuppressState.savedVisibilityValid = true;
            g_cursorSuppressState.suppressionApplied = true;
        }

        const float baseW = rt.screenWidthX > 0.0f ? rt.screenWidthX : 1920.0f;
        rt.cursorPosX = baseW + 10000.0f;
        rt.cursorPosY = g_cursorSuppressState.savedPosValid ? g_cursorSuppressState.savedPosY : rt.cursorPosY;
        a_menuCursor->SetCursorVisibility(false);

        if (firstApply && InfoLoggingEnabled()) {
            logger::info("CursorSuppress: applied reason={}", a_reason ? a_reason : "unknown");
        }
    }

    static void QueuePrimeSuppression(std::uint64_t a_workerToken, const char* a_reason)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (InfoLoggingEnabled()) {
                logger::warn("CursorSuppress: task interface unavailable during prime");
            }
            return;
        }

        task->AddTask([a_workerToken, a_reason]() {
            auto* menuCursor = RE::MenuCursor::GetSingleton();
            auto* uiQueue = RE::UIMessageQueue::GetSingleton();
            auto* uiStr = RE::InterfaceStrings::GetSingleton();

            std::scoped_lock lock(g_cursorSuppressState.lock);
            if (g_cursorSuppressState.workerToken.load() != a_workerToken || g_cursorSuppressState.activeTokens.empty()) {
                return;
            }

            g_cursorSuppressState.customMenuAddr = 0;
            g_cursorSuppressState.customMenuFlagsValid = false;
            g_cursorSuppressState.customMenuHadUsesCursor = false;
            g_cursorSuppressState.customMenuHadUpdateUsesCursor = false;

            if (uiQueue && uiStr) {
                uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kHide, nullptr);
            }
            ApplyMenuCursorSuppressionLocked(menuCursor, a_reason);
        });
    }

    static void QueueApplySuppression(std::uint64_t a_workerToken, const char* a_reason)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            if (InfoLoggingEnabled()) {
                logger::warn("CursorSuppress: task interface unavailable during apply");
            }
            return;
        }

        task->AddTask([a_workerToken, a_reason]() {
            auto* menuCursor = RE::MenuCursor::GetSingleton();
            auto* ui = RE::UI::GetSingleton();
            auto* uiQueue = RE::UIMessageQueue::GetSingleton();
            auto* uiStr = RE::InterfaceStrings::GetSingleton();

            std::scoped_lock lock(g_cursorSuppressState.lock);
            if (g_cursorSuppressState.workerToken.load() != a_workerToken || g_cursorSuppressState.activeTokens.empty()) {
                return;
            }

            ClearCustomMenuCursorFlagsLocked();

            if (uiQueue && uiStr) {
                uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kHide, nullptr);
            }
            ApplyOverlayAlphaSuppressionLocked(ui);
            ApplyMenuCursorSuppressionLocked(menuCursor, a_reason);
        });
    }

    static void QueueRestore(std::uint64_t a_restoreToken)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("CursorSuppress: task interface unavailable during restore");
            return;
        }

        task->AddTask([a_restoreToken]() {
            auto* menuCursor = RE::MenuCursor::GetSingleton();
            auto* ui = RE::UI::GetSingleton();
            auto* uiQueue = RE::UIMessageQueue::GetSingleton();
            auto* uiStr = RE::InterfaceStrings::GetSingleton();

            bool hasSavedVisibility = false;
            bool restoreVisible = true;
            {
                std::scoped_lock lock(g_cursorSuppressState.lock);
                if (g_cursorSuppressState.workerToken.load() != a_restoreToken || !g_cursorSuppressState.activeTokens.empty()) {
                    if (InfoLoggingEnabled()) {
                        logger::info("CursorSuppress: restore skipped because suppression restarted");
                    }
                    return;
                }

                if (menuCursor) {
                    auto& rt = menuCursor->GetRuntimeData();
                    if (g_cursorSuppressState.savedPosValid) {
                        rt.cursorPosX = g_cursorSuppressState.savedPosX;
                        rt.cursorPosY = g_cursorSuppressState.savedPosY;
                    }
                    if (g_cursorSuppressState.savedVisibilityValid) {
                        hasSavedVisibility = true;
                        restoreVisible = g_cursorSuppressState.savedVisible;
                        menuCursor->SetCursorVisibility(restoreVisible);
                    }
                } else {
                    if (InfoLoggingEnabled()) {
                        logger::warn("CursorSuppress: MenuCursor singleton unavailable during restore");
                    }
                }
                RestoreCustomMenuCursorFlagsLocked();
                RestoreOverlayAlphaSuppressionLocked(ui);

                if (uiQueue && uiStr) {
                    if (hasSavedVisibility && !restoreVisible) {
                        uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kHide, nullptr);
                    } else {
                        uiQueue->AddMessage(uiStr->cursorMenu, RE::UI_MESSAGE_TYPE::kUpdate, nullptr);
                    }
                }

                g_cursorSuppressState.suppressionApplied = false;
                g_cursorSuppressState.savedPosValid = false;
                g_cursorSuppressState.savedVisibilityValid = false;
                g_cursorSuppressState.warnedMissingCursor = false;
            }

            if (InfoLoggingEnabled()) {
                logger::info("CursorSuppress: restored");
            }
        });
    }

    static void CursorWorker(std::uint64_t a_workerToken)
    {
        constexpr auto kReapplyInterval = std::chrono::milliseconds(16);

        while (HasActiveSession(a_workerToken)) {
            QueueApplySuppression(a_workerToken, "worker");
            if (!SleepCancelable(a_workerToken, kReapplyInterval)) {
                return;
            }
        }
    }

    static void JoinWorkerIfIdle()
    {
        std::thread oldWorker;
        {
            std::scoped_lock lock(g_cursorSuppressState.lock);
            if (g_cursorSuppressState.activeTokens.empty() && g_cursorSuppressState.worker.joinable()) {
                oldWorker = std::move(g_cursorSuppressState.worker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }
    }

    static std::int32_t NextTokenLocked()
    {
        constexpr auto kMaxToken = (std::numeric_limits<std::int32_t>::max)();

        do {
            if (g_cursorSuppressState.nextToken >= kMaxToken) {
                g_cursorSuppressState.nextToken = 0;
            }
            ++g_cursorSuppressState.nextToken;
        } while (g_cursorSuppressState.activeTokens.contains(g_cursorSuppressState.nextToken));

        return g_cursorSuppressState.nextToken;
    }

    static std::int32_t BeginCursorSuppress(RE::StaticFunctionTag*)
    {
        if (IronSoul::Config::GetInt("CursorHide", 1) == 0) {
            if (InfoLoggingEnabled()) {
                logger::info("CursorSuppress: begin blocked by CursorHide=0");
            }
            return 0;
        }

        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("CursorSuppress: task interface unavailable");
            return 0;
        }

        JoinWorkerIfIdle();

        std::int32_t token = 0;
        std::uint64_t workerToken = 0;
        bool startWorker = false;
        std::size_t activeCount = 0;
        {
            std::scoped_lock lock(g_cursorSuppressState.lock);
            const bool wasIdle = g_cursorSuppressState.activeTokens.empty();
            if (wasIdle) {
                g_cursorSuppressState.suppressionApplied = false;
                g_cursorSuppressState.savedPosValid = false;
                g_cursorSuppressState.savedVisibilityValid = false;
                g_cursorSuppressState.warnedMissingCursor = false;
                g_cursorSuppressState.customMenuAddr = 0;
                g_cursorSuppressState.customMenuFlagsValid = false;
                g_cursorSuppressState.customMenuHadUsesCursor = false;
                g_cursorSuppressState.customMenuHadUpdateUsesCursor = false;
                ResetOverlayAlphaStatesLocked();
                workerToken = g_cursorSuppressState.workerToken.fetch_add(1) + 1;
                startWorker = true;
            } else {
                workerToken = g_cursorSuppressState.workerToken.load();
            }

            token = NextTokenLocked();
            g_cursorSuppressState.activeTokens.insert(token);
            activeCount = g_cursorSuppressState.activeTokens.size();

            if (startWorker) {
                g_cursorSuppressState.worker = std::thread([workerToken]() {
                    CursorWorker(workerToken);
                });
            }
        }

        QueueApplySuppression(workerToken, "begin");
        if (InfoLoggingEnabled()) {
            logger::info("CursorSuppress: begin token={} active={}", token, activeCount);
        }
        return token;
    }

    static void EndCursorSuppress(RE::StaticFunctionTag*, std::int32_t a_token)
    {
        if (a_token <= 0) {
            if (InfoLoggingEnabled()) {
                logger::info("CursorSuppress: end ignored for token={}", a_token);
            }
            return;
        }

        bool shouldRestore = false;
        std::uint64_t restoreToken = 0;
        std::size_t activeCount = 0;
        {
            std::scoped_lock lock(g_cursorSuppressState.lock);
            const auto erased = g_cursorSuppressState.activeTokens.erase(a_token);
            if (erased == 0) {
                if (InfoLoggingEnabled()) {
                    logger::warn("CursorSuppress: end ignored for inactive token={}", a_token);
                }
                return;
            }

            activeCount = g_cursorSuppressState.activeTokens.size();
            if (g_cursorSuppressState.activeTokens.empty()) {
                restoreToken = g_cursorSuppressState.workerToken.fetch_add(1) + 1;
                shouldRestore = true;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info("CursorSuppress: end token={} active={}", a_token, activeCount);
        }

        if (shouldRestore) {
            QueueRestore(restoreToken);
        }
    }

    static void RefreshCursorSuppress(RE::StaticFunctionTag*)
    {
        if (IronSoul::Config::GetInt("CursorHide", 1) == 0) {
            return;
        }

        std::uint64_t workerToken = 0;
        {
            std::scoped_lock lock(g_cursorSuppressState.lock);
            if (g_cursorSuppressState.activeTokens.empty()) {
                return;
            }

            workerToken = g_cursorSuppressState.workerToken.load();
        }

        QueueApplySuppression(workerToken, "refresh");
    }

    static void PrimeCursorSuppress(RE::StaticFunctionTag*)
    {
        if (IronSoul::Config::GetInt("CursorHide", 1) == 0) {
            return;
        }

        std::uint64_t workerToken = 0;
        {
            std::scoped_lock lock(g_cursorSuppressState.lock);
            if (g_cursorSuppressState.activeTokens.empty()) {
                return;
            }

            workerToken = g_cursorSuppressState.workerToken.load();
        }

        QueuePrimeSuppression(workerToken, "prime");
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("BeginCursorSuppress", kScriptName, BeginCursorSuppress);
        a_vm->RegisterFunction("EndCursorSuppress", kScriptName, EndCursorSuppress);
        a_vm->RegisterFunction("PrimeCursorSuppress", kScriptName, PrimeCursorSuppress);
        a_vm->RegisterFunction("RefreshCursorSuppress", kScriptName, RefreshCursorSuppress);
    }
}
