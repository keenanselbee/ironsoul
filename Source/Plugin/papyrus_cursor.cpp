#include "pch.h"
#include "papyrus_cursor.h"
#include "papyrus_common.h"
#include "config.h"

namespace IronSoul::Papyrus::Cursor
{
namespace
{
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
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("SuppressCursor", kScriptName, SuppressCursor);
    }
}
