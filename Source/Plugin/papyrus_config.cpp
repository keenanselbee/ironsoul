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

    static std::int32_t GetIronSoulPresetPlus(RE::StaticFunctionTag*)
    {
        return IronSoul::Config::GetIronSoulPresetPlus();
    }

    static bool SetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_value, bool a_persistToIni)
    {
        return IronSoul::Config::SetInt(a_key, a_value, a_persistToIni);
    }

    static bool SetConfigString(RE::StaticFunctionTag*, std::string a_key, std::string a_value, bool a_persistToIni)
    {
        return IronSoul::Config::SetString(a_key, a_value, a_persistToIni);
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
        a_vm->RegisterFunction("GetIronSoulPresetPlus", kScriptName, GetIronSoulPresetPlus);
        a_vm->RegisterFunction("SetConfigInt", kScriptName, SetConfigInt);
        a_vm->RegisterFunction("SetConfigString", kScriptName, SetConfigString);
        a_vm->RegisterFunction("ReloadConfig", kScriptName, ReloadConfig);
    }
}
