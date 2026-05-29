#include "pch.h"
#include "papyrus_config.h"
#include "papyrus_common.h"
#include "papyrus_runtime.h"
#include "config.h"

namespace IronSoul::Papyrus::Config
{
namespace
{
    static std::int32_t GetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_fallback)
    {
        return IronSoul::Config::GetAllowedInt(a_key, a_fallback);
    }

    static std::int32_t GetIronSoulPresetOrdinal(RE::StaticFunctionTag*)
    {
        return IronSoul::Config::GetIronSoulPresetOrdinal();
    }

    static bool SetEffectiveDisplayDifficulty(RE::StaticFunctionTag*, std::int32_t a_presetFamily, std::int32_t a_displayRank)
    {
        return IronSoul::Config::SetEffectiveDisplayDifficulty(a_presetFamily, a_displayRank);
    }

    static std::string GetConfigKeyCanonical(RE::StaticFunctionTag*, std::string a_key)
    {
        return IronSoul::Config::GetConfigKeyCanonical(a_key);
    }

    static std::string GetConfigKeyDisplayName(RE::StaticFunctionTag*, std::string a_key)
    {
        return IronSoul::Config::GetConfigKeyDisplayName(a_key);
    }

    static std::int32_t GetConfigKeyFlags(RE::StaticFunctionTag*, std::string a_key)
    {
        return IronSoul::Config::GetConfigKeyFlags(a_key);
    }

    static std::string GetConfigSetError(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        return IronSoul::Config::GetConfigSetError(a_key, a_value);
    }

    static std::string GetConfigSummary(RE::StaticFunctionTag*)
    {
        return IronSoul::Config::GetConfigSummary();
    }

    static bool SetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_value, bool a_persistToIni)
    {
        const bool ok = IronSoul::Config::SetInt(a_key, a_value, a_persistToIni);
        if (ok) {
            IronSoul::Papyrus::Runtime::RefreshRuntimeConfigCaches();
        }
        return ok;
    }

    static bool SetConfigString(RE::StaticFunctionTag*, std::string a_key, std::string a_value, bool a_persistToIni)
    {
        const bool ok = IronSoul::Config::SetString(a_key, a_value, a_persistToIni);
        if (ok) {
            IronSoul::Papyrus::Runtime::RefreshRuntimeConfigCaches();
        }
        return ok;
    }

    static bool ReloadConfig(RE::StaticFunctionTag*)
    {
        IronSoul::Config::Load();
        IronSoul::Papyrus::Runtime::RefreshRuntimeConfigCaches();
        return true;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("GetConfigInt", kScriptName, GetConfigInt);
        a_vm->RegisterFunction("GetIronSoulPresetOrdinal", kScriptName, GetIronSoulPresetOrdinal);
        a_vm->RegisterFunction("SetEffectiveDisplayDifficulty", kScriptName, SetEffectiveDisplayDifficulty);
        a_vm->RegisterFunction("GetConfigKeyCanonical", kScriptName, GetConfigKeyCanonical);
        a_vm->RegisterFunction("GetConfigKeyDisplayName", kScriptName, GetConfigKeyDisplayName);
        a_vm->RegisterFunction("GetConfigKeyFlags", kScriptName, GetConfigKeyFlags);
        a_vm->RegisterFunction("GetConfigSetError", kScriptName, GetConfigSetError);
        a_vm->RegisterFunction("GetConfigSummary", kScriptName, GetConfigSummary);
        a_vm->RegisterFunction("SetConfigInt", kScriptName, SetConfigInt);
        a_vm->RegisterFunction("SetConfigString", kScriptName, SetConfigString);
        a_vm->RegisterFunction("ReloadConfig", kScriptName, ReloadConfig);
    }
}
