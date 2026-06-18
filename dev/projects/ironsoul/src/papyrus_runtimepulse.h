#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::RuntimePulse
{
    void HandleSerializationRevert();
    void Register(RE::BSScript::IVirtualMachine* a_vm);
    void RegisterLifecycleHooks();
    void StartDataFlushHeartbeat();
}
