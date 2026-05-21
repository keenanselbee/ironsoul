#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::Core
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);
    void RegisterAvailability(RE::BSScript::IVirtualMachine* a_vm);
    void RegisterIdentity(RE::BSScript::IVirtualMachine* a_vm);
}