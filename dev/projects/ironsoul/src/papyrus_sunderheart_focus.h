#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::SunderheartFocus
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);
    void RegisterLifecycleHooks();
}
