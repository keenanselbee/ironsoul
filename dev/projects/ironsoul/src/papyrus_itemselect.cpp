#include "pch.h"
#include "papyrus_itemselect.h"
#include "papyrus_common.h"

#include <string>
#include <string_view>

namespace IronSoul::Papyrus::ItemSelect
{
namespace
{
    static bool OpenMenu(RE::StaticFunctionTag*, std::string a_menuName)
    {
        if (a_menuName.empty()) {
            return false;
        }

        auto* uiQueue = RE::UIMessageQueue::GetSingleton();
        if (!uiQueue) {
            logger::warn("OpenMenu: UI message queue unavailable for '{}'", a_menuName);
            return false;
        }

        uiQueue->AddMessage(RE::BSFixedString(a_menuName), RE::UI_MESSAGE_TYPE::kShow, nullptr);
        return true;
    }

    static bool CloseMenu(RE::StaticFunctionTag*, std::string a_menuName)
    {
        if (a_menuName.empty()) {
            return false;
        }

        auto* uiQueue = RE::UIMessageQueue::GetSingleton();
        if (!uiQueue) {
            logger::warn("CloseMenu: UI message queue unavailable for '{}'", a_menuName);
            return false;
        }

        uiQueue->AddMessage(RE::BSFixedString(a_menuName), RE::UI_MESSAGE_TYPE::kHide, nullptr);
        return true;
    }
}

    RE::ItemList* GetOpenInventoryItemList()
    {
        auto* ui = RE::UI::GetSingleton();
        auto menu = ui ? ui->GetMenu<RE::InventoryMenu>() : nullptr;
        return menu ? menu->GetRuntimeData().itemList : nullptr;
    }

    std::uint32_t GetInventoryRowCount(RE::ItemList* a_itemList)
    {
        return a_itemList ? static_cast<std::uint32_t>(a_itemList->items.size()) : 0;
    }

    RE::InventoryEntryData* GetInventoryRowEntry(RE::ItemList* a_itemList, std::uint32_t a_rowIndex)
    {
        if (!a_itemList || a_rowIndex >= GetInventoryRowCount(a_itemList)) {
            return nullptr;
        }

        auto* item = a_itemList->items[a_rowIndex];
        return item ? item->data.objDesc : nullptr;
    }

    RE::InventoryEntryData* GetInventorySelectedEntry()
    {
        auto* itemList = GetOpenInventoryItemList();
        auto* item = itemList ? itemList->GetSelectedItem() : nullptr;
        return item ? item->data.objDesc : nullptr;
    }

    static bool InventorySelectedItemHasEditorIDPrefix(RE::StaticFunctionTag*, std::string a_editorIDPrefix)
    {
        if (a_editorIDPrefix.empty()) {
            return false;
        }

        auto* entry = GetInventorySelectedEntry();
        auto* object = entry ? entry->object : nullptr;
        const char* editorID = object ? object->GetFormEditorID() : nullptr;
        if (!editorID || editorID[0] == '\0') {
            return false;
        }

        return std::string_view(editorID).starts_with(a_editorIDPrefix);
    }

    static bool InventorySelectedItemHasEditorID(RE::StaticFunctionTag*, std::string a_editorID)
    {
        if (a_editorID.empty()) {
            return false;
        }

        auto* entry = GetInventorySelectedEntry();
        auto* object = entry ? entry->object : nullptr;
        const char* editorID = object ? object->GetFormEditorID() : nullptr;
        if (!editorID || editorID[0] == '\0') {
            return false;
        }

        return a_editorID == editorID;
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("OpenMenu", kScriptName, OpenMenu);
        a_vm->RegisterFunction("CloseMenu", kScriptName, CloseMenu);
        a_vm->RegisterFunction("InventorySelectedItemHasEditorIDPrefix", kScriptName, InventorySelectedItemHasEditorIDPrefix);
        a_vm->RegisterFunction("InventorySelectedItemHasEditorID", kScriptName, InventorySelectedItemHasEditorID);
    }
}
