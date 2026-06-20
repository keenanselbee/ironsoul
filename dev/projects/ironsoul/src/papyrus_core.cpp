#include "pch.h"
#include "papyrus_core.h"
#include "papyrus_common.h"
#include "datastore.h"
#include "identity.h"

namespace IronSoul::Papyrus::Core
{
namespace
{
    static std::string GetPlayerName(RE::StaticFunctionTag*)
    {
        // Return empty if the name is not yet available (Papyrus uses this to gate GUID assignment).
        return ResolvePlayerName(false);
    }

    static std::string GenerateGuidUnique(RE::StaticFunctionTag*, std::string a_playerName)
    {
        return IronSoul::Identity::GenerateGuidUnique(a_playerName);
    }

    // --- Core Native Bindings ---
    // ============================

    static bool IsAvailable(RE::StaticFunctionTag*)
    {
        // Simple probe to confirm the Iron Soul SKSE plugin is loaded and Papyrus natives are registered.
        return true;
    }

    static bool DataStoreReady(RE::StaticFunctionTag*)
    {
        // True once the native datastore has been initialized.
        return IronSoul::DataStore::IsInitialized();
    }

}

    void RegisterAvailability(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("IsAvailable", kScriptName, IsAvailable);
        a_vm->RegisterFunction("DataStoreReady", kScriptName, DataStoreReady);
    }

    void RegisterIdentity(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("GetPlayerName", kScriptName, GetPlayerName);
        a_vm->RegisterFunction("GenerateGuidUnique", kScriptName, GenerateGuidUnique);
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        RegisterAvailability(a_vm);
        RegisterIdentity(a_vm);
    }
}
