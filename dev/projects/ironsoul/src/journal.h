#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace IronSoul::Journal
{
	struct JournalEventText
	{
		std::string detail;
		std::string summary;
	};

	inline constexpr std::int32_t kDailyAnimaPriorityNone = 0;
	inline constexpr std::int32_t kDailyAnimaPriorityMinor = 1;
	inline constexpr std::int32_t kDailyAnimaPriorityStrong = 2;
	inline constexpr std::int32_t kDailyAnimaPriorityNamedUndead = 3;
	inline constexpr std::int32_t kDailyAnimaPriorityDragon = 4;
	inline constexpr std::int32_t kDailyAnimaPriorityMajor = 5;
	inline constexpr std::int32_t kDailyAnimaPriorityCapstone = 6;
	bool AppendEvent(std::string_view a_guid, JournalEventText a_event, std::int32_t a_startDay, std::int32_t a_nowDay);
	bool FlushDailyAnima(std::string_view a_guid);
	bool NoteDailyAnimaAward(
		std::string_view a_guid,
		std::string_view a_source,
		std::int32_t a_amount,
		std::int32_t a_priority);

	std::string BuildDayLine(std::string_view a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay);
	JournalEventText BuildExternalEvent(std::string_view a_source, std::string_view a_eventText);
	std::string AppendTotalDeaths(std::string_view a_baseText, std::int32_t a_totalDeaths);
	JournalEventText BuildDefeatOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives);
	JournalEventText BuildDefeatLuckOutcome(
		std::int32_t a_deathsPred,
		std::int32_t a_maxLives,
		std::int32_t a_roll,
		std::int32_t a_luck);
	JournalEventText BuildTrueDeathOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives);
	JournalEventText BuildDefiantFatigueOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives, bool a_terminal);
	JournalEventText BuildLuckOutcome(std::int32_t a_luck, std::int32_t a_roll, std::int32_t a_maxLuck);
	JournalEventText BuildAnimaAward(std::string_view a_source, std::int32_t a_amount);
	JournalEventText BuildSoulFeat(std::int32_t a_soulTier, std::int32_t a_totalDeaths);
	JournalEventText BuildDefiantSoulFeat(std::int32_t a_totalDeaths);
	JournalEventText BuildDefiantRestore(std::int32_t a_targetTier, std::int32_t a_totalDeaths);
	JournalEventText BuildDefiantAwakened();
	JournalEventText BuildCHIMRealized();
}
