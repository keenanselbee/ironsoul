#include "pch.h"
#include "papyrus_itemselect.h"
#include "papyrus_common.h"

#include <cstdint>
#include <optional>
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

    std::optional<RE::FormID> ParseFormIDText(std::string_view a_formIDText)
    {
        if (a_formIDText.empty()) {
            return std::nullopt;
        }

        std::uint32_t base = 10;
        std::size_t index = 0;
        if (a_formIDText.size() > 2 && a_formIDText[0] == '0' && (a_formIDText[1] == 'x' || a_formIDText[1] == 'X')) {
            base = 16;
            index = 2;
        }

        if (index >= a_formIDText.size()) {
            return std::nullopt;
        }

        std::uint64_t value = 0;
        for (; index < a_formIDText.size(); ++index) {
            const char ch = a_formIDText[index];
            std::uint32_t digit = 0;
            if (ch >= '0' && ch <= '9') {
                digit = static_cast<std::uint32_t>(ch - '0');
            } else if (base == 16 && ch >= 'a' && ch <= 'f') {
                digit = static_cast<std::uint32_t>(ch - 'a' + 10);
            } else if (base == 16 && ch >= 'A' && ch <= 'F') {
                digit = static_cast<std::uint32_t>(ch - 'A' + 10);
            } else {
                return std::nullopt;
            }

            if (digit >= base) {
                return std::nullopt;
            }

            value = (value * base) + digit;
            if (value > 0xFFFFFFFFULL) {
                return std::nullopt;
            }
        }

        return static_cast<RE::FormID>(value);
    }

    RE::TESForm* ResolveFormFromFormIDText(std::string_view a_formIDText)
    {
        const auto formID = ParseFormIDText(a_formIDText);
        if (!formID || *formID == 0) {
            return nullptr;
        }

        return RE::TESForm::LookupByID(*formID);
    }

    const char* ResolveEditorIDFromFormIDText(std::string_view a_formIDText)
    {
        auto* form = ResolveFormFromFormIDText(a_formIDText);
        const char* editorID = form ? form->GetFormEditorID() : nullptr;
        return editorID && editorID[0] ? editorID : nullptr;
    }

    static RE::TESForm* FormIDStringToForm(RE::StaticFunctionTag*, std::string a_formIDText)
    {
        if (a_formIDText.empty()) {
            return nullptr;
        }

        return ResolveFormFromFormIDText(a_formIDText);
    }

    static bool FormIDStringHasEditorIDPrefix(RE::StaticFunctionTag*, std::string a_formIDText, std::string a_editorIDPrefix)
    {
        if (a_formIDText.empty() || a_editorIDPrefix.empty()) {
            return false;
        }

        const char* editorID = ResolveEditorIDFromFormIDText(a_formIDText);
        return editorID && std::string_view(editorID).starts_with(a_editorIDPrefix);
    }

    static bool FormIDStringHasEditorID(RE::StaticFunctionTag*, std::string a_formIDText, std::string a_editorID)
    {
        if (a_formIDText.empty() || a_editorID.empty()) {
            return false;
        }

        const char* editorID = ResolveEditorIDFromFormIDText(a_formIDText);
        return editorID && a_editorID == editorID;
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("OpenMenu", kScriptName, OpenMenu);
        a_vm->RegisterFunction("CloseMenu", kScriptName, CloseMenu);
        a_vm->RegisterFunction("InventorySelectedItemHasEditorIDPrefix", kScriptName, InventorySelectedItemHasEditorIDPrefix);
        a_vm->RegisterFunction("InventorySelectedItemHasEditorID", kScriptName, InventorySelectedItemHasEditorID);
        a_vm->RegisterFunction("FormIDStringToForm", kScriptName, FormIDStringToForm);
        a_vm->RegisterFunction("FormIDStringHasEditorIDPrefix", kScriptName, FormIDStringHasEditorIDPrefix);
        a_vm->RegisterFunction("FormIDStringHasEditorID", kScriptName, FormIDStringHasEditorID);
    }
}
