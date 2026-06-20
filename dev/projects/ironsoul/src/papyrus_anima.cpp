#include "pch.h"
#include "papyrus_anima.h"

#include "anima.h"
#include "boss_latches.h"
#include "death_sink.h"
#include "papyrus_common.h"

namespace IronSoul::Papyrus::Anima
{
namespace
{
    static std::int32_t AnimaGetCharacter(RE::StaticFunctionTag*, std::string a_guid)
    {
        return IronSoul::Anima::GetCharacter(a_guid);
    }

    static std::int32_t AnimaGetWorld(RE::StaticFunctionTag*)
    {
        return IronSoul::Anima::GetWorld();
    }

    static std::int32_t SoulTierGetWorld(RE::StaticFunctionTag*)
    {
        return IronSoul::Anima::GetSaveHighestUnlockedTier();
    }

    static std::int32_t AnimaGetEligibleMilestone(
        RE::StaticFunctionTag*,
        std::string a_guid,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths)
    {
        return IronSoul::Anima::GetEligibleMilestone(a_guid, a_characterDragonSouls, a_currentDeaths);
    }

    static std::int32_t AnimaGetRequiredForMilestone(RE::StaticFunctionTag*, std::int32_t a_milestone)
    {
        return IronSoul::Anima::GetRequiredForMilestone(a_milestone);
    }

    static std::string AnimaAddCharacter(
        RE::StaticFunctionTag*,
        std::string a_guid,
        std::int32_t a_amount,
        std::string a_source,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld)
    {
        return IronSoul::Anima::AddCharacter(a_guid, a_amount, a_source, a_characterDragonSouls, a_currentDeaths, a_updateWorld);
    }

    static std::string AnimaSetCharacter(
        RE::StaticFunctionTag*,
        std::string a_guid,
        std::int32_t a_value,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths)
    {
        return IronSoul::Anima::SetCharacter(a_guid, a_value, a_characterDragonSouls, a_currentDeaths);
    }

    static std::string AnimaSetWorld(RE::StaticFunctionTag*, std::int32_t a_value)
    {
        return IronSoul::Anima::SetWorld(a_value);
    }

    static std::string SoulTierSetWorld(RE::StaticFunctionTag*, std::int32_t a_tier)
    {
        return IronSoul::Anima::SetSaveHighestUnlockedTier(a_tier);
    }

    static std::string AnimaPollBossLatches(
        RE::StaticFunctionTag*,
        std::string a_guid,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld)
    {
        return IronSoul::BossLatches::PollAnimaBossLatches(a_guid, a_characterDragonSouls, a_currentDeaths, a_updateWorld);
    }

    static std::string DeathSinkDrainAnimaAwards(RE::StaticFunctionTag*)
    {
        return IronSoul::DeathSink::DrainAnimaAwards();
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("AnimaGetCharacter", kScriptName, AnimaGetCharacter);
        a_vm->RegisterFunction("AnimaGetWorld", kScriptName, AnimaGetWorld);
        a_vm->RegisterFunction("SoulTierGetWorld", kScriptName, SoulTierGetWorld);
        a_vm->RegisterFunction("AnimaGetEligibleMilestone", kScriptName, AnimaGetEligibleMilestone);
        a_vm->RegisterFunction("AnimaGetRequiredForMilestone", kScriptName, AnimaGetRequiredForMilestone);
        a_vm->RegisterFunction("AnimaAddCharacter", kScriptName, AnimaAddCharacter);
        a_vm->RegisterFunction("AnimaSetCharacter", kScriptName, AnimaSetCharacter);
        a_vm->RegisterFunction("AnimaSetWorld", kScriptName, AnimaSetWorld);
        a_vm->RegisterFunction("SoulTierSetWorld", kScriptName, SoulTierSetWorld);
        a_vm->RegisterFunction("AnimaPollBossLatches", kScriptName, AnimaPollBossLatches);
        a_vm->RegisterFunction("DeathSinkDrainAnimaAwards", kScriptName, DeathSinkDrainAnimaAwards);
    }
}
