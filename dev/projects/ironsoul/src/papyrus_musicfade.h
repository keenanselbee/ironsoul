#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::MusicFade
{
    void RegisterLifecycleHooks();
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}
