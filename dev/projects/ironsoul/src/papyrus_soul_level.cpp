#include "pch.h"
#include "papyrus_soul_level.h"

#include "papyrus_common.h"
#include "soul_level.h"

namespace IronSoul::Papyrus::SoulLevel
{
namespace
{
    std::int32_t SoulLevelGetSlainWorld(RE::StaticFunctionTag*, std::int32_t a_level)
    {
        return IronSoul::SoulLevel::GetWorldSlain(a_level);
    }

    std::int32_t SoulLevelGetSlainCharacter(RE::StaticFunctionTag*, std::string a_guid, std::int32_t a_level)
    {
        return IronSoul::SoulLevel::GetCharacterSlain(a_guid, a_level);
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("SoulLevelGetSlainWorld", kScriptName, SoulLevelGetSlainWorld);
        a_vm->RegisterFunction("SoulLevelGetSlainCharacter", kScriptName, SoulLevelGetSlainCharacter);
    }
}
