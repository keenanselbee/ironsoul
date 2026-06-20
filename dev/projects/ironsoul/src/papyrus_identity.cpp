#include "pch.h"
#include "papyrus_identity.h"

#include "identity.h"
#include "papyrus_common.h"

namespace IronSoul::Papyrus::Identity
{
namespace
{
    static std::string IdentityGetCurrentGuid(RE::StaticFunctionTag*)
    {
        return IronSoul::Identity::GetCurrentGuid();
    }

    static bool IdentitySetCurrentGuid(RE::StaticFunctionTag*, std::string a_guid)
    {
        return IronSoul::Identity::SetCurrentGuid(a_guid);
    }

    static std::string IdentityApplyLoadedSnapshot(RE::StaticFunctionTag*, std::string a_guid)
    {
        return IronSoul::Identity::ApplyLoadedSnapshot(a_guid);
    }

    static std::string IdentityGetLoadedSnapshot(RE::StaticFunctionTag*)
    {
        return IronSoul::Identity::GetLoadedSnapshotPayload();
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("IdentityGetCurrentGuid", kScriptName, IdentityGetCurrentGuid);
        a_vm->RegisterFunction("IdentitySetCurrentGuid", kScriptName, IdentitySetCurrentGuid);
        a_vm->RegisterFunction("IdentityApplyLoadedSnapshot", kScriptName, IdentityApplyLoadedSnapshot);
        a_vm->RegisterFunction("IdentityGetLoadedSnapshot", kScriptName, IdentityGetLoadedSnapshot);
    }
}
