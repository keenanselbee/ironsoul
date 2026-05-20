#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::DynamicAssets
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}