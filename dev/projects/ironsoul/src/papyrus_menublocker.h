#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::MenuBlocker
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}
