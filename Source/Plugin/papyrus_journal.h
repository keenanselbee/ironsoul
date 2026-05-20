#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::Journal
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}