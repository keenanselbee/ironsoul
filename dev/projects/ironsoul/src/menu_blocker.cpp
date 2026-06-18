#include "pch.h"
#include "menu_blocker.h"
#include "config.h"

#include <SKSE/InputMap.h>

#include <CommCtrl.h>

#include <algorithm>
#include <array>
#include <cctype>
#include <thread>
#include <unordered_map>

namespace IronSoul::MenuBlocker
{
    std::int32_t BeginInternal(std::string_view a_reason, bool a_releaseOnMainMenu, bool a_healthDepletedToken);
    void EndInternal(std::int32_t a_token, std::string_view a_reason);

namespace
{
    using UEFlag = RE::ControlMap::UEFlag;

    constexpr auto kPollInterval = std::chrono::milliseconds(50);
    constexpr auto kSleepSlice = std::chrono::milliseconds(10);
    constexpr auto kBlockedAttemptLogInterval = std::chrono::seconds(1);
    constexpr auto kLoadBoundaryWatchdog = std::chrono::seconds(5);

    constexpr std::array<std::string_view, 20> kForbiddenMenus{
        "MessageBoxMenu",
        "Journal Menu",
        "TweenMenu",
        "InventoryMenu",
        "MagicMenu",
        "MapMenu",
        "StatsMenu",
        "FavoritesMenu",
        "Console",
        "Console Native UI Menu",
        "Sleep/Wait Menu",
        "ContainerMenu",
        "BarterMenu",
        "GiftMenu",
        "Book Menu",
        "LevelUp Menu",
        "RaceSex Menu",
        "Crafting Menu",
        "Training Menu",
        "Mod Manager Menu"
    };

    constexpr std::array<std::string_view, 23> kBlockedUserEvents{
        "pause",
        "journal",
        "tweenmenu",
        "inventory",
        "stats",
        "map",
        "favorites",
        "quickload",
        "quicksave",
        "newsave",
        "console",
        "quickinventory",
        "quickitems",
        "quickmagic",
        "quickstats",
        "quickskills",
        "quickmap",
        "quickfavorites",
        "wait",
        "load",
        "save",
        "systemmenu",
        "start"
    };

    struct ControlSnapshot
    {
        bool captured{ false };
        bool menuEnabled{ true };
        bool consoleEnabled{ true };
    };

    struct TokenState
    {
        bool releaseOnMainMenu{ false };
        bool allowWindowClose{ false };
    };

    void RestoreWindowCloseSubclass();
    void QueueWindowCloseSubclassUpdate(bool a_warnMissing);
    LRESULT CALLBACK WindowCloseSubclassProc(
        HWND a_hwnd,
        UINT a_message,
        WPARAM a_wParam,
        LPARAM a_lParam,
        UINT_PTR a_subclassId,
        DWORD_PTR a_refData);

    struct BlockerState
    {
        std::mutex lock;
        std::atomic<std::uint64_t> workerToken{ 0 };
        std::thread worker;
        std::int32_t nextToken{ 0 };
        std::int32_t healthDepletedToken{ 0 };
        std::int32_t loadBoundaryToken{ 0 };
        std::uint64_t loadBoundarySerial{ 0 };
        std::atomic<std::uint64_t> loadBoundaryWatchdogToken{ 0 };
        std::thread loadBoundaryWatchdog;
        std::unordered_map<std::int32_t, TokenState> activeTokens;
        ControlSnapshot controls;
        bool releaseOnMainMenu{ false };
        bool allowWindowClose{ false };
        bool inputSinkRegistered{ false };
        bool menuSinkRegistered{ false };
        bool windowCloseSubclassInstalled{ false };
        HWND gameWindow{ nullptr };
        std::atomic_bool shouldBlockWindowClose{ false };
        std::atomic_bool debugWindowCloseLogEnabled{ false };
        std::atomic<std::int64_t> lastBlockedWindowLogMs{ 0 };
        bool warnedMissingTaskInterface{ false };
        bool warnedMissingControlMap{ false };
        bool warnedMissingInputManager{ false };
        bool warnedMissingWindow{ false };
        bool warnedWindowSubclassInstallFailed{ false };
        bool warnedWindowSubclassRemoveFailed{ false };
        double lastBlockedInputLogSec{ 0.0 };
        double lastBlockedMenuLogSec{ 0.0 };

        ~BlockerState()
        {
            shouldBlockWindowClose.store(false, std::memory_order_release);
            RestoreWindowCloseSubclass();
            loadBoundaryWatchdogToken.fetch_add(1);
            if (loadBoundaryWatchdog.joinable()) {
                loadBoundaryWatchdog.join();
            }
            workerToken.fetch_add(1);
            if (worker.joinable()) {
                worker.join();
            }
        }
    };

    class BlockerSink :
        public RE::BSTEventSink<RE::InputEvent*>,
        public RE::BSTEventSink<RE::MenuOpenCloseEvent>
    {
    public:
        RE::BSEventNotifyControl ProcessEvent(
            RE::InputEvent* const* a_eventList,
            RE::BSTEventSource<RE::InputEvent*>*) override;

        RE::BSEventNotifyControl ProcessEvent(
            const RE::MenuOpenCloseEvent* a_event,
            RE::BSTEventSource<RE::MenuOpenCloseEvent>*) override;
    };

    BlockerState g_state;
    BlockerSink g_sink;
    constexpr UINT_PTR kWindowCloseSubclassId = 0x49726F6E536F756C;

    bool InfoLoggingEnabled()
    {
        return IronSoul::Config::ShouldEmitInfoLog();
    }

    bool DebugLoggingEnabled()
    {
        return InfoLoggingEnabled() && IronSoul::Config::GetInt("LogLevel", 2) >= 3;
    }

    double NowSeconds()
    {
        return std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
    }

    bool AllowsWindowCloseReason(std::string_view a_reason)
    {
        return a_reason == "quit-desktop";
    }

    std::string_view ResolveReason(std::string_view a_reason)
    {
        return a_reason.empty() ? std::string_view{ "unknown" } : a_reason;
    }

    bool IsActiveLocked()
    {
        return !g_state.activeTokens.empty();
    }

    bool IsActive()
    {
        std::scoped_lock lock(g_state.lock);
        return IsActiveLocked();
    }

    bool ShouldPrearmWindowCloseSubclass()
    {
        return IronSoul::Config::GetAllowedInt("Anticheat", 1) == 1;
    }

    void RecalculateTokenFlagsLocked()
    {
        g_state.releaseOnMainMenu = std::any_of(
            g_state.activeTokens.begin(),
            g_state.activeTokens.end(),
            [](const auto& entry) {
                return entry.second.releaseOnMainMenu;
            });
        g_state.allowWindowClose = std::any_of(
            g_state.activeTokens.begin(),
            g_state.activeTokens.end(),
            [](const auto& entry) {
                return entry.second.allowWindowClose;
            });

        const bool shouldBlockWindowClose =
            IsActiveLocked() &&
            !g_state.allowWindowClose &&
            ShouldPrearmWindowCloseSubclass();
        g_state.shouldBlockWindowClose.store(shouldBlockWindowClose, std::memory_order_release);
        g_state.debugWindowCloseLogEnabled.store(DebugLoggingEnabled(), std::memory_order_release);
        if (!shouldBlockWindowClose) {
            g_state.lastBlockedWindowLogMs.store(0, std::memory_order_release);
        }
    }

    bool ShouldReleaseOnMainMenu()
    {
        std::scoped_lock lock(g_state.lock);
        return IsActiveLocked() && g_state.releaseOnMainMenu;
    }

    void RefreshWindowCloseState()
    {
        std::scoped_lock lock(g_state.lock);
        RecalculateTokenFlagsLocked();
    }

    bool ShouldBlockWindowClose()
    {
        return g_state.shouldBlockWindowClose.load(std::memory_order_acquire);
    }

    std::string NormalizeEventName(std::string_view a_value)
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

    bool IsBlockedUserEvent(std::string_view a_userEvent)
    {
        if (a_userEvent.empty()) {
            return false;
        }

        const std::string normalized = NormalizeEventName(a_userEvent);
        return std::find(kBlockedUserEvents.begin(), kBlockedUserEvents.end(), normalized) != kBlockedUserEvents.end();
    }

    bool IsBlockedFallbackKey(const RE::ButtonEvent& a_event)
    {
        const auto device = a_event.GetDevice();
        const auto idCode = a_event.GetIDCode();

        if (device == RE::INPUT_DEVICE::kKeyboard) {
            return idCode == 1;
        }

        if (device == RE::INPUT_DEVICE::kGamepad) {
            return idCode == SKSE::InputMap::kGamepadButtonOffset_START ||
                idCode == SKSE::InputMap::kGamepadButtonOffset_BACK ||
                idCode == 0x10 ||
                idCode == 0x20;
        }

        return false;
    }

    bool ShouldBlockButton(const RE::ButtonEvent& a_event, std::string_view a_userEvent)
    {
        return IsBlockedUserEvent(a_userEvent) || IsBlockedFallbackKey(a_event);
    }

    bool ClaimBlockedInputLog()
    {
        if (!DebugLoggingEnabled()) {
            return false;
        }

        const double nowSec = NowSeconds();
        std::scoped_lock lock(g_state.lock);
        if ((nowSec - g_state.lastBlockedInputLogSec) < kBlockedAttemptLogInterval.count()) {
            return false;
        }

        g_state.lastBlockedInputLogSec = nowSec;
        return true;
    }

    bool ClaimBlockedMenuLog()
    {
        if (!DebugLoggingEnabled()) {
            return false;
        }

        const double nowSec = NowSeconds();
        std::scoped_lock lock(g_state.lock);
        if ((nowSec - g_state.lastBlockedMenuLogSec) < kBlockedAttemptLogInterval.count()) {
            return false;
        }

        g_state.lastBlockedMenuLogSec = nowSec;
        return true;
    }

    bool ClaimBlockedWindowLog()
    {
        if (!g_state.debugWindowCloseLogEnabled.load(std::memory_order_acquire)) {
            return false;
        }

        const auto nowMs = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch()).count();
        auto lastMs = g_state.lastBlockedWindowLogMs.load(std::memory_order_acquire);
        if ((nowMs - lastMs) < std::chrono::duration_cast<std::chrono::milliseconds>(kBlockedAttemptLogInterval).count()) {
            return false;
        }

        while (!g_state.lastBlockedWindowLogMs.compare_exchange_weak(
            lastMs,
            nowMs,
            std::memory_order_acq_rel,
            std::memory_order_acquire)) {
            if ((nowMs - lastMs) < std::chrono::duration_cast<std::chrono::milliseconds>(kBlockedAttemptLogInterval).count()) {
                return false;
            }
        }

        return true;
    }

    void LogBlockedInputAttempt(const RE::ButtonEvent& a_event, std::string_view a_userEvent)
    {
        if (!ClaimBlockedInputLog()) {
            return;
        }

        logger::info(
            "MenuBlocker: blocked input event='{}' device={} idCode={}",
            a_userEvent.empty() ? "unmapped" : a_userEvent,
            static_cast<std::uint32_t>(a_event.GetDevice()),
            a_event.GetIDCode());
    }

    void LogBlockedMenuAttempt(std::string_view a_menuName)
    {
        if (!ClaimBlockedMenuLog()) {
            return;
        }

        logger::info("MenuBlocker: blocked menu open '{}'", a_menuName.empty() ? "unknown" : a_menuName);
    }

    void LogBlockedWindowClose(UINT a_message, WPARAM a_wParam)
    {
        if (!ClaimBlockedWindowLog()) {
            return;
        }

        logger::info(
            "MenuBlocker: blocked window close message=0x{:X} wParam=0x{:X}",
            static_cast<std::uint32_t>(a_message),
            static_cast<std::uintptr_t>(a_wParam));
    }

    void NeutralizeButton(RE::ButtonEvent& a_event)
    {
        a_event.userEvent = RE::BSFixedString("");
        a_event.idCode = RE::ControlMap::kInvalid;
        auto& runtime = a_event.GetRuntimeData();
        runtime.value = 0.0f;
        runtime.heldDownSecs = 0.0f;
    }

    bool IsForbiddenMenu(std::string_view a_menuName)
    {
        return std::find(kForbiddenMenus.begin(), kForbiddenMenus.end(), a_menuName) != kForbiddenMenus.end();
    }

    bool IsMainMenu(std::string_view a_menuName)
    {
        return a_menuName == "Main Menu";
    }

    struct WindowSearch
    {
        DWORD processId{ 0 };
        HWND window{ nullptr };
    };

    BOOL CALLBACK FindProcessWindowCallback(HWND a_hwnd, LPARAM a_lParam)
    {
        auto* search = reinterpret_cast<WindowSearch*>(a_lParam);
        if (!search || search->window) {
            return FALSE;
        }

        if (!IsWindowVisible(a_hwnd) || GetWindow(a_hwnd, GW_OWNER) != nullptr) {
            return TRUE;
        }

        const auto exStyle = static_cast<LONG_PTR>(GetWindowLongPtrW(a_hwnd, GWL_EXSTYLE));
        if ((exStyle & WS_EX_TOOLWINDOW) != 0) {
            return TRUE;
        }

        DWORD windowProcessId = 0;
        GetWindowThreadProcessId(a_hwnd, &windowProcessId);
        if (windowProcessId != search->processId) {
            return TRUE;
        }

        search->window = a_hwnd;
        return FALSE;
    }

    HWND FindGameWindow()
    {
        WindowSearch search{ GetCurrentProcessId(), nullptr };
        EnumWindows(FindProcessWindowCallback, reinterpret_cast<LPARAM>(&search));
        return search.window;
    }

    void RestoreWindowCloseSubclass()
    {
        g_state.shouldBlockWindowClose.store(false, std::memory_order_release);
        g_state.debugWindowCloseLogEnabled.store(false, std::memory_order_release);

        HWND window = nullptr;
        {
            std::scoped_lock lock(g_state.lock);
            if (!g_state.windowCloseSubclassInstalled) {
                return;
            }
            window = g_state.gameWindow;
        }

        bool removed = true;
        if (window && IsWindow(window)) {
            SetLastError(ERROR_SUCCESS);
            removed = RemoveWindowSubclass(window, WindowCloseSubclassProc, kWindowCloseSubclassId) != FALSE;
            const auto error = GetLastError();
            if (!removed) {
                std::scoped_lock lock(g_state.lock);
                if (!g_state.warnedWindowSubclassRemoveFailed) {
                    g_state.warnedWindowSubclassRemoveFailed = true;
                    logger::warn(
                        "MenuBlocker: failed to remove window close subclass error={}",
                        static_cast<unsigned long>(error));
                }
                return;
            }
        }

        {
            std::scoped_lock lock(g_state.lock);
            if (g_state.gameWindow == window) {
                g_state.windowCloseSubclassInstalled = false;
                g_state.gameWindow = nullptr;
                g_state.warnedWindowSubclassRemoveFailed = false;
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info("MenuBlocker: window close subclass removed");
        }
    }

    void UpdateWindowCloseSubclassOnUiThread(bool a_warnMissing)
    {
        if (!ShouldPrearmWindowCloseSubclass()) {
            RestoreWindowCloseSubclass();
            return;
        }

        {
            std::scoped_lock lock(g_state.lock);
            if (g_state.windowCloseSubclassInstalled && g_state.gameWindow && IsWindow(g_state.gameWindow)) {
                return;
            }

            g_state.windowCloseSubclassInstalled = false;
            g_state.gameWindow = nullptr;
        }

        HWND window = FindGameWindow();
        if (!window) {
            if (a_warnMissing) {
                std::scoped_lock lock(g_state.lock);
                if (!g_state.warnedMissingWindow) {
                    g_state.warnedMissingWindow = true;
                    logger::warn("MenuBlocker: Skyrim window unavailable; Alt+F4/window-close blocking will retry");
                }
            }
            return;
        }

        SetLastError(ERROR_SUCCESS);
        const bool installed = SetWindowSubclass(window, WindowCloseSubclassProc, kWindowCloseSubclassId, 0) != FALSE;
        const auto error = GetLastError();
        if (!installed) {
            std::scoped_lock lock(g_state.lock);
            if (!g_state.warnedWindowSubclassInstallFailed) {
                g_state.warnedWindowSubclassInstallFailed = true;
                logger::warn(
                    "MenuBlocker: failed to install window close subclass error={}",
                    static_cast<unsigned long>(error));
            }
            return;
        }

        {
            std::scoped_lock lock(g_state.lock);
            g_state.windowCloseSubclassInstalled = true;
            g_state.gameWindow = window;
            g_state.warnedMissingWindow = false;
            g_state.warnedWindowSubclassInstallFailed = false;
            g_state.warnedWindowSubclassRemoveFailed = false;
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MenuBlocker: passive window close subclass installed hwnd=0x{:X}",
                reinterpret_cast<std::uintptr_t>(window));
        }
    }

    bool IsWindowCloseMessage(UINT a_message, WPARAM a_wParam)
    {
        if (a_message == WM_CLOSE) {
            return true;
        }

        if (a_message == WM_SYSCOMMAND && (a_wParam & 0xFFF0) == SC_CLOSE) {
            return true;
        }

        return false;
    }

    LRESULT CALLBACK WindowCloseSubclassProc(
        HWND a_hwnd,
        UINT a_message,
        WPARAM a_wParam,
        LPARAM a_lParam,
        UINT_PTR,
        DWORD_PTR)
    {
        if (IsWindowCloseMessage(a_message, a_wParam) && ShouldBlockWindowClose()) {
            LogBlockedWindowClose(a_message, a_wParam);
            return 0;
        }

        return DefSubclassProc(a_hwnd, a_message, a_wParam, a_lParam);
    }

    void ApplyControlsOnGameThread()
    {
        auto* controlMap = RE::ControlMap::GetSingleton();
        if (!controlMap) {
            std::scoped_lock lock(g_state.lock);
            if (!g_state.warnedMissingControlMap) {
                g_state.warnedMissingControlMap = true;
                logger::warn("MenuBlocker: ControlMap singleton unavailable");
            }
            return;
        }

        bool disableMenu = false;
        bool disableConsole = false;
        {
            std::scoped_lock lock(g_state.lock);
            if (!IsActiveLocked()) {
                return;
            }

            if (!g_state.controls.captured) {
                g_state.controls.menuEnabled = controlMap->IsMenuControlsEnabled();
                g_state.controls.consoleEnabled = controlMap->IsConsoleControlsEnabled();
                g_state.controls.captured = true;
            }

            disableMenu = controlMap->IsMenuControlsEnabled();
            disableConsole = controlMap->IsConsoleControlsEnabled();
        }

        if (disableMenu) {
            controlMap->ToggleControls(UEFlag::kMenu, false);
        }
        if (disableConsole) {
            controlMap->ToggleControls(UEFlag::kConsole, false);
        }
    }

    void CloseForbiddenMenusOnGameThread()
    {
        auto* ui = RE::UI::GetSingleton();
        auto* uiQueue = RE::UIMessageQueue::GetSingleton();
        if (!ui || !uiQueue) {
            return;
        }

        for (const auto menuName : kForbiddenMenus) {
            if (ui->IsMenuOpen(menuName)) {
                uiQueue->AddMessage(RE::BSFixedString(menuName), RE::UI_MESSAGE_TYPE::kHide, nullptr);
            }
        }
    }

    void EnforceOnGameThread()
    {
        RefreshWindowCloseState();
        QueueWindowCloseSubclassUpdate(true);

        if (!IsActive()) {
            return;
        }

        ApplyControlsOnGameThread();
        CloseForbiddenMenusOnGameThread();
    }

    void QueueEnforce()
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            std::scoped_lock lock(g_state.lock);
            if (!g_state.warnedMissingTaskInterface) {
                g_state.warnedMissingTaskInterface = true;
                logger::warn("MenuBlocker: task interface unavailable");
            }
            return;
        }

        task->AddTask([]() {
            EnforceOnGameThread();
        });
    }

    void QueueWindowCloseSubclassUpdate(bool a_warnMissing)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            std::scoped_lock lock(g_state.lock);
            if (!g_state.warnedMissingTaskInterface) {
                g_state.warnedMissingTaskInterface = true;
                logger::warn("MenuBlocker: task interface unavailable");
            }
            return;
        }

        task->AddUITask([a_warnMissing]() {
            RefreshWindowCloseState();
            UpdateWindowCloseSubclassOnUiThread(a_warnMissing);
        });
    }

    void RestoreControlsOnGameThread(std::uint64_t a_restoreToken)
    {
        bool captured = false;
        bool restoreMenu = true;
        bool restoreConsole = true;
        {
            std::scoped_lock lock(g_state.lock);
            if (g_state.workerToken.load() != a_restoreToken || IsActiveLocked()) {
                return;
            }

            captured = g_state.controls.captured;
            restoreMenu = g_state.controls.menuEnabled;
            restoreConsole = g_state.controls.consoleEnabled;
            g_state.controls = {};
        }

        if (!captured) {
            return;
        }

        auto* controlMap = RE::ControlMap::GetSingleton();
        if (!controlMap) {
            logger::warn("MenuBlocker: ControlMap unavailable during restore");
            return;
        }

        if (controlMap->IsMenuControlsEnabled() != restoreMenu) {
            controlMap->ToggleControls(UEFlag::kMenu, restoreMenu);
        }
        if (controlMap->IsConsoleControlsEnabled() != restoreConsole) {
            controlMap->ToggleControls(UEFlag::kConsole, restoreConsole);
        }
    }

    void QueueRestoreControls(std::uint64_t a_restoreToken)
    {
        auto* task = SKSE::GetTaskInterface();
        if (!task) {
            logger::warn("MenuBlocker: task interface unavailable during restore");
            return;
        }

        task->AddTask([a_restoreToken]() {
            RestoreControlsOnGameThread(a_restoreToken);
        });
    }

    bool HasActiveSession(std::uint64_t a_workerToken)
    {
        if (g_state.workerToken.load() != a_workerToken) {
            return false;
        }

        std::scoped_lock lock(g_state.lock);
        return g_state.workerToken.load() == a_workerToken && IsActiveLocked();
    }

    bool SleepCancelable(std::uint64_t a_workerToken, std::chrono::milliseconds a_totalSleep)
    {
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
            std::this_thread::sleep_for(remaining < kSleepSlice ? remaining : kSleepSlice);
        }
    }

    void StartWorkerLocked(std::thread& a_oldWorker)
    {
        const auto newWorkerToken = g_state.workerToken.fetch_add(1) + 1;

        if (g_state.worker.joinable()) {
            a_oldWorker = std::move(g_state.worker);
        }

        g_state.worker = std::thread([newWorkerToken]() {
            QueueEnforce();
            while (SleepCancelable(newWorkerToken, kPollInterval)) {
                QueueEnforce();
            }
        });
    }

    void StopWorkerAndRestore(std::thread& a_oldWorker, std::uint64_t& a_restoreToken)
    {
        a_restoreToken = g_state.workerToken.fetch_add(1) + 1;
        if (g_state.worker.joinable()) {
            a_oldWorker = std::move(g_state.worker);
        }
    }

    void FinishStoppedWorker(std::thread& a_oldWorker, std::uint64_t a_restoreToken)
    {
        if (a_oldWorker.joinable()) {
            a_oldWorker.join();
        }
        QueueRestoreControls(a_restoreToken);
    }

    void ClearInternal(bool a_preserveLoadBoundary)
    {
        std::thread oldWorker;
        std::uint64_t restoreToken = 0;
        bool shouldRestore = false;
        bool preservedLoadBoundary = false;

        {
            std::scoped_lock lock(g_state.lock);
            shouldRestore = IsActiveLocked() || g_state.controls.captured;
            const auto loadToken = g_state.loadBoundaryToken;
            preservedLoadBoundary = a_preserveLoadBoundary &&
                loadToken > 0 &&
                g_state.activeTokens.contains(loadToken);

            g_state.activeTokens.clear();
            if (preservedLoadBoundary) {
                g_state.activeTokens[loadToken] = {};
            } else {
                g_state.loadBoundaryToken = 0;
                ++g_state.loadBoundarySerial;
                g_state.loadBoundaryWatchdogToken.fetch_add(1);
            }
            g_state.healthDepletedToken = 0;
            RecalculateTokenFlagsLocked();
            g_state.lastBlockedInputLogSec = 0.0;
            g_state.lastBlockedMenuLogSec = 0.0;
            g_state.lastBlockedWindowLogMs.store(0, std::memory_order_release);
            if (preservedLoadBoundary) {
                shouldRestore = false;
            } else if (shouldRestore) {
                StopWorkerAndRestore(oldWorker, restoreToken);
            }
        }

        if (!preservedLoadBoundary) {
            QueueWindowCloseSubclassUpdate(false);
        }

        if (shouldRestore) {
            FinishStoppedWorker(oldWorker, restoreToken);
            if (InfoLoggingEnabled()) {
                logger::info("MenuBlocker: cleared");
            }
        } else if (preservedLoadBoundary) {
            QueueEnforce();
            if (InfoLoggingEnabled()) {
                logger::info("MenuBlocker: cleared preserving load boundary");
            }
        }
    }

    bool SleepLoadBoundaryWatchdog(std::uint64_t a_watchdogToken)
    {
        const auto deadline = std::chrono::steady_clock::now() + kLoadBoundaryWatchdog;
        while (std::chrono::steady_clock::now() < deadline) {
            if (g_state.loadBoundaryWatchdogToken.load() != a_watchdogToken) {
                return false;
            }
            std::this_thread::sleep_for(kSleepSlice);
        }

        return g_state.loadBoundaryWatchdogToken.load() == a_watchdogToken;
    }

    void WatchLoadBoundary(std::int32_t a_token, std::uint64_t a_serial, std::uint64_t a_watchdogToken)
    {
        if (!SleepLoadBoundaryWatchdog(a_watchdogToken)) {
            return;
        }

        bool shouldEnd = false;
        {
            std::scoped_lock lock(g_state.lock);
            shouldEnd = g_state.loadBoundaryToken == a_token &&
                g_state.loadBoundarySerial == a_serial &&
                g_state.activeTokens.contains(a_token);
            if (shouldEnd) {
                g_state.loadBoundaryToken = 0;
                ++g_state.loadBoundarySerial;
            }
        }

        if (shouldEnd) {
            EndInternal(a_token, "load-boundary-watchdog");
        }
    }

    void StartLoadBoundaryWatchdog(std::int32_t a_token, std::uint64_t a_serial)
    {
        std::thread oldWatchdog;
        const auto watchdogToken = g_state.loadBoundaryWatchdogToken.fetch_add(1) + 1;

        {
            std::scoped_lock lock(g_state.lock);
            if (g_state.loadBoundaryWatchdog.joinable()) {
                oldWatchdog = std::move(g_state.loadBoundaryWatchdog);
            }
            g_state.loadBoundaryWatchdog = std::thread(WatchLoadBoundary, a_token, a_serial, watchdogToken);
        }

        if (oldWatchdog.joinable()) {
            oldWatchdog.join();
        }
    }

    void BeginLoadBoundaryBlock()
    {
        EndLoadBoundaryBlock("load-boundary-restart");

        if (IronSoul::Config::GetAllowedInt("Anticheat", 1) != 1) {
            return;
        }

        const auto token = BeginInternal("load-boundary", false, false);
        if (token <= 0) {
            return;
        }

        std::uint64_t serial = 0;
        {
            std::scoped_lock lock(g_state.lock);
            g_state.loadBoundaryToken = token;
            serial = ++g_state.loadBoundarySerial;
        }

        StartLoadBoundaryWatchdog(token, serial);

        if (InfoLoggingEnabled()) {
            logger::info("MenuBlocker: load boundary token={} watchdog={}s", token, kLoadBoundaryWatchdog.count());
        }
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }

        if (a_message->type == SKSE::MessagingInterface::kPostLoadGame) {
            BeginLoadBoundaryBlock();
        } else if (a_message->type == SKSE::MessagingInterface::kPreLoadGame) {
            EndLoadBoundaryBlock("pre-load");
        }
    }
}

    RE::BSEventNotifyControl BlockerSink::ProcessEvent(
        RE::InputEvent* const* a_eventList,
        RE::BSTEventSource<RE::InputEvent*>*)
    {
        if (!a_eventList || !IsActive()) {
            return RE::BSEventNotifyControl::kContinue;
        }

        bool blockedAny = false;
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
            if (!ShouldBlockButton(*buttonEvent, userEvent)) {
                continue;
            }

            LogBlockedInputAttempt(*buttonEvent, userEvent);
            NeutralizeButton(*buttonEvent);
            blockedAny = true;
        }

        if (blockedAny) {
            QueueEnforce();
            return RE::BSEventNotifyControl::kStop;
        }

        return RE::BSEventNotifyControl::kContinue;
    }

    RE::BSEventNotifyControl BlockerSink::ProcessEvent(
        const RE::MenuOpenCloseEvent* a_event,
        RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
    {
        if (!a_event || !a_event->opening || !IsActive()) {
            return RE::BSEventNotifyControl::kContinue;
        }

        const std::string_view menuName{ a_event->menuName.c_str() ? a_event->menuName.c_str() : "" };
        if (IsMainMenu(menuName) && ShouldReleaseOnMainMenu()) {
            ClearInternal(false);
            return RE::BSEventNotifyControl::kContinue;
        }

        if (IsForbiddenMenu(menuName)) {
            LogBlockedMenuAttempt(menuName);
            QueueEnforce();
            return RE::BSEventNotifyControl::kStop;
        }

        return RE::BSEventNotifyControl::kContinue;
    }

    void RegisterSinksInternal(bool a_warnMissingInputManager)
    {
        std::scoped_lock lock(g_state.lock);

        if (!g_state.inputSinkRegistered) {
            if (auto* inputManager = RE::BSInputDeviceManager::GetSingleton()) {
                inputManager->AddEventSink(static_cast<RE::BSTEventSink<RE::InputEvent*>*>(&g_sink));
                g_state.inputSinkRegistered = true;
                g_state.warnedMissingInputManager = false;
                logger::info("MenuBlocker: input sink registered");
            } else if (a_warnMissingInputManager && !g_state.warnedMissingInputManager) {
                g_state.warnedMissingInputManager = true;
                logger::warn("MenuBlocker: BSInputDeviceManager unavailable while blocker active");
            }
        }

        if (!g_state.menuSinkRegistered) {
            if (auto* ui = RE::UI::GetSingleton()) {
                ui->AddEventSink<RE::MenuOpenCloseEvent>(
                    static_cast<RE::BSTEventSink<RE::MenuOpenCloseEvent>*>(&g_sink));
                g_state.menuSinkRegistered = true;
                logger::info("MenuBlocker: menu sink registered");
            } else {
                logger::warn("MenuBlocker: UI singleton unavailable");
            }
        }
    }

    void RegisterSinks()
    {
        RegisterSinksInternal(false);
        QueueWindowCloseSubclassUpdate(false);
    }

    void RefreshWindowCloseSubclass()
    {
        RefreshWindowCloseState();
        QueueWindowCloseSubclassUpdate(false);
    }

    std::int32_t BeginInternal(std::string_view a_reason, bool a_releaseOnMainMenu, bool a_healthDepletedToken)
    {
        if (IronSoul::Config::GetAllowedInt("Anticheat", 1) != 1) {
            return 0;
        }

        RegisterSinksInternal(true);

        std::thread oldWorker;
        std::int32_t token = 0;
        bool shouldStart = false;
        std::size_t activeCount = 0;
        const bool allowWindowClose = AllowsWindowCloseReason(a_reason);
        {
            std::scoped_lock lock(g_state.lock);
            if (a_healthDepletedToken && g_state.healthDepletedToken > 0 &&
                g_state.activeTokens.contains(g_state.healthDepletedToken)) {
                return g_state.healthDepletedToken;
            }

            shouldStart = !IsActiveLocked();

            ++g_state.nextToken;
            if (g_state.nextToken <= 0) {
                g_state.nextToken = 1;
            }
            token = g_state.nextToken;

            g_state.activeTokens[token] = { a_releaseOnMainMenu, allowWindowClose };
            if (a_healthDepletedToken) {
                g_state.healthDepletedToken = token;
            }
            RecalculateTokenFlagsLocked();
            activeCount = g_state.activeTokens.size();

            if (shouldStart) {
                g_state.warnedMissingControlMap = false;
                g_state.lastBlockedInputLogSec = 0.0;
                g_state.lastBlockedMenuLogSec = 0.0;
                g_state.lastBlockedWindowLogMs.store(0, std::memory_order_release);
                StartWorkerLocked(oldWorker);
            }
        }

        if (oldWorker.joinable()) {
            oldWorker.join();
        }

        QueueWindowCloseSubclassUpdate(true);
        QueueEnforce();

        if (InfoLoggingEnabled()) {
            logger::info(
                "MenuBlocker: begin token={} reason={} releaseOnMainMenu={} allowWindowClose={} active={}",
                token,
                ResolveReason(a_reason),
                a_releaseOnMainMenu,
                allowWindowClose,
                activeCount);
        }
        return token;
    }

    void EndInternal(std::int32_t a_token, std::string_view a_reason)
    {
        if (a_token <= 0) {
            return;
        }

        std::thread oldWorker;
        std::uint64_t restoreToken = 0;
        bool shouldRestore = false;
        std::size_t activeCount = 0;
        {
            std::scoped_lock lock(g_state.lock);
            const auto erased = g_state.activeTokens.erase(a_token);
            if (erased == 0) {
                return;
            }

            if (g_state.healthDepletedToken == a_token) {
                g_state.healthDepletedToken = 0;
            }
            if (g_state.loadBoundaryToken == a_token) {
                g_state.loadBoundaryToken = 0;
                ++g_state.loadBoundarySerial;
            }

            RecalculateTokenFlagsLocked();
            activeCount = g_state.activeTokens.size();

            if (!IsActiveLocked()) {
                shouldRestore = true;
                StopWorkerAndRestore(oldWorker, restoreToken);
            }
        }

        if (InfoLoggingEnabled()) {
            logger::info(
                "MenuBlocker: end token={} reason={} active={}",
                a_token,
                ResolveReason(a_reason),
                activeCount);
        }

        QueueWindowCloseSubclassUpdate(false);

        if (shouldRestore) {
            FinishStoppedWorker(oldWorker, restoreToken);
        }
    }

    std::int32_t GetHealthDepletedToken()
    {
        std::scoped_lock lock(g_state.lock);
        if (g_state.healthDepletedToken <= 0 ||
            !g_state.activeTokens.contains(g_state.healthDepletedToken)) {
            return 0;
        }

        return g_state.healthDepletedToken;
    }

    void BeginHealthDepletedBlock()
    {
        BeginInternal("health-depleted", false, true);
    }

    void EndHealthDepletedBlock(std::string_view a_reason)
    {
        EndInternal(GetHealthDepletedToken(), a_reason);
    }

    void EndLoadBoundaryBlock(std::string_view a_reason)
    {
        std::int32_t token = 0;
        {
            std::scoped_lock lock(g_state.lock);
            token = g_state.loadBoundaryToken;
            g_state.loadBoundaryToken = 0;
            ++g_state.loadBoundarySerial;
            g_state.loadBoundaryWatchdogToken.fetch_add(1);
        }

        EndInternal(token, a_reason);
    }

    std::int32_t Begin(std::string_view a_reason, bool a_releaseOnMainMenu)
    {
        return BeginInternal(a_reason, a_releaseOnMainMenu, false);
    }

    void End(std::int32_t a_token)
    {
        EndInternal(a_token, "");
    }

    void Clear()
    {
        ClearInternal(false);
    }

    void ClearPreservingLoadBoundary()
    {
        ClearInternal(true);
    }

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("MenuBlocker: messaging interface unavailable; load boundary block disabled");
            return;
        }

        if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("MenuBlocker: failed to register load boundary listener");
            return;
        }

        logger::info("MenuBlocker: load boundary listener registered");
    }
}
