#pragma once

#include <cstdint>
#include <string_view>

namespace IronSoul::Journal
{
	inline constexpr std::int32_t kDailyAnimaPriorityNone = 0;
	inline constexpr std::int32_t kDailyAnimaPriorityMinor = 1;
	inline constexpr std::int32_t kDailyAnimaPriorityStrong = 2;
	inline constexpr std::int32_t kDailyAnimaPriorityNamedUndead = 3;
	inline constexpr std::int32_t kDailyAnimaPriorityDragon = 4;
	inline constexpr std::int32_t kDailyAnimaPriorityMajor = 5;
	inline constexpr std::int32_t kDailyAnimaPriorityCapstone = 6;

	// Appends a single line to Data/SKSE/plugins/ironsoul-character-journal.log
	bool AppendLine(std::string_view line);
	bool AppendEvent(std::string_view a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay);
	bool FlushDailyAnima(std::string_view a_guid);
	bool NoteDailyAnimaAward(
		std::string_view a_guid,
		std::string_view a_source,
		std::int32_t a_amount,
		std::int32_t a_priority);

	std::string BuildDayLine(std::string_view a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay);
	std::string BuildExternalEvent(std::string_view a_source, std::string_view a_eventText);
	std::string AppendTotalDeaths(std::string_view a_baseText, std::int32_t a_totalDeaths);
	std::string BuildDefeatOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives);
	std::string BuildDefeatLuckOutcome(
		std::int32_t a_deathsPred,
		std::int32_t a_maxLives,
		std::int32_t a_roll,
		std::int32_t a_luck);
	std::string BuildTrueDeathOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives);
	std::string BuildDefiantFatigueOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives, bool a_terminal);
	std::string BuildLuckOutcome(std::int32_t a_luck, std::int32_t a_roll, std::int32_t a_maxLuck);
	std::string BuildAnimaAward(std::string_view a_source, std::int32_t a_amount);
	std::string BuildSoulFeat(std::int32_t a_soulTier, std::int32_t a_totalDeaths);
	std::string BuildDefiantSoulFeat(std::int32_t a_totalDeaths);
	std::string BuildDefiantRestore(std::int32_t a_targetTier, std::int32_t a_totalDeaths);
	std::string BuildDefiantAwakened();
	std::string BuildCHIMRealized();
}
