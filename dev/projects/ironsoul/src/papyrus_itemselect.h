#pragma once

#include <cstdint>

namespace RE
{
    class InventoryEntryData;
    struct ItemList;
}

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::ItemSelect
{
    RE::ItemList* GetOpenInventoryItemList();
    std::uint32_t GetInventoryRowCount(RE::ItemList* a_itemList);
    RE::InventoryEntryData* GetInventoryRowEntry(RE::ItemList* a_itemList, std::uint32_t a_rowIndex);
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}
