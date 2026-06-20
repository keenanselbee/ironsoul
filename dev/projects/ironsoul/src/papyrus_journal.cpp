#include "pch.h"
#include "papyrus_journal.h"
#include "papyrus_common.h"
#include "config.h"
#include "journal.h"

namespace IronSoul::Papyrus::Journal
{
namespace
{
    static bool AppendBuiltJournalEvent(std::string a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay)
    {
        return IronSoul::Journal::AppendEvent(a_eventText, a_startDay, a_nowDay);
    }

    static bool JournalLogEvent(RE::StaticFunctionTag*, std::string a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(a_eventText, a_startDay, a_nowDay);
    }

    static bool JournalLogDefeatOutcome(
        RE::StaticFunctionTag*,
        std::int32_t a_deathsNow,
        std::int32_t a_maxLives,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildDefeatOutcome(a_deathsNow, a_maxLives), a_startDay, a_nowDay);
    }

    static bool JournalLogDefeatLuckOutcome(
        RE::StaticFunctionTag*,
        std::int32_t a_deathsNow,
        std::int32_t a_maxLives,
        std::int32_t a_roll,
        std::int32_t a_luck,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildDefeatLuckOutcome(a_deathsNow, a_maxLives, a_roll, a_luck), a_startDay, a_nowDay);
    }

    static bool JournalLogTrueDeathOutcome(
        RE::StaticFunctionTag*,
        std::int32_t a_deathsNow,
        std::int32_t a_maxLives,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildTrueDeathOutcome(a_deathsNow, a_maxLives), a_startDay, a_nowDay);
    }

    static bool JournalLogDefiantFatigueOutcome(
        RE::StaticFunctionTag*,
        std::int32_t a_deathsNow,
        std::int32_t a_maxLives,
        bool a_terminal,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildDefiantFatigueOutcome(a_deathsNow, a_maxLives, a_terminal), a_startDay, a_nowDay);
    }

    static bool JournalLogLuckOutcome(
        RE::StaticFunctionTag*,
        std::int32_t a_luck,
        std::int32_t a_roll,
        std::int32_t a_maxLuck,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildLuckOutcome(a_luck, a_roll, a_maxLuck), a_startDay, a_nowDay);
    }

    static bool JournalLogAnimaAward(
        RE::StaticFunctionTag*,
        std::string a_source,
        std::int32_t a_amount,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildAnimaAward(a_source, a_amount), a_startDay, a_nowDay);
    }

    static bool JournalFlushDailyAnima(RE::StaticFunctionTag*, std::string a_guid)
    {
        return IronSoul::Journal::FlushDailyAnima(a_guid);
    }

    static bool JournalNoteDailyAnimaAward(
        RE::StaticFunctionTag*,
        std::string a_guid,
        std::string a_source,
        std::int32_t a_amount,
        std::int32_t a_priority)
    {
        return IronSoul::Journal::NoteDailyAnimaAward(a_guid, a_source, a_amount, a_priority);
    }

    static bool JournalLogSoulFeat(
        RE::StaticFunctionTag*,
        std::int32_t a_soulTier,
        std::int32_t a_totalDeaths,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(
            IronSoul::Journal::BuildSoulFeat(a_soulTier, a_totalDeaths),
            a_startDay,
            a_nowDay);
    }

    static bool JournalLogDefiantSoulFeat(
        RE::StaticFunctionTag*,
        std::int32_t a_totalDeaths,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildDefiantSoulFeat(a_totalDeaths), a_startDay, a_nowDay);
    }

    static bool JournalLogDefiantRestore(
        RE::StaticFunctionTag*,
        std::int32_t a_targetTier,
        std::int32_t a_totalDeaths,
        std::int32_t a_startDay,
        std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(
            IronSoul::Journal::BuildDefiantRestore(a_targetTier, a_totalDeaths),
            a_startDay,
            a_nowDay);
    }

    static bool JournalLogDefiantAwakened(RE::StaticFunctionTag*, std::int32_t a_startDay, std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildDefiantAwakened(), a_startDay, a_nowDay);
    }

    static bool JournalLogCHIMRealized(RE::StaticFunctionTag*, std::int32_t a_startDay, std::int32_t a_nowDay)
    {
        return AppendBuiltJournalEvent(IronSoul::Journal::BuildCHIMRealized(), a_startDay, a_nowDay);
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("JournalLogEvent", kScriptName, JournalLogEvent);
        a_vm->RegisterFunction("JournalLogDefeatOutcome", kScriptName, JournalLogDefeatOutcome);
        a_vm->RegisterFunction("JournalLogDefeatLuckOutcome", kScriptName, JournalLogDefeatLuckOutcome);
        a_vm->RegisterFunction("JournalLogTrueDeathOutcome", kScriptName, JournalLogTrueDeathOutcome);
        a_vm->RegisterFunction("JournalLogDefiantFatigueOutcome", kScriptName, JournalLogDefiantFatigueOutcome);
        a_vm->RegisterFunction("JournalLogLuckOutcome", kScriptName, JournalLogLuckOutcome);
        a_vm->RegisterFunction("JournalLogAnimaAward", kScriptName, JournalLogAnimaAward);
        a_vm->RegisterFunction("JournalFlushDailyAnima", kScriptName, JournalFlushDailyAnima);
        a_vm->RegisterFunction("JournalNoteDailyAnimaAward", kScriptName, JournalNoteDailyAnimaAward);
        a_vm->RegisterFunction("JournalLogSoulFeat", kScriptName, JournalLogSoulFeat);
        a_vm->RegisterFunction("JournalLogDefiantSoulFeat", kScriptName, JournalLogDefiantSoulFeat);
        a_vm->RegisterFunction("JournalLogDefiantRestore", kScriptName, JournalLogDefiantRestore);
        a_vm->RegisterFunction("JournalLogDefiantAwakened", kScriptName, JournalLogDefiantAwakened);
        a_vm->RegisterFunction("JournalLogCHIMRealized", kScriptName, JournalLogCHIMRealized);
    }
}
