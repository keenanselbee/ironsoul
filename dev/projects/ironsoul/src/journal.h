#pragma once

#include <string_view>

namespace IronSoul::Journal
{
	// Appends a single line to Data/SKSE/plugins/ironsoul-character-journal.log
	bool AppendLine(std::string_view line);

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
	std::string BuildDragonSoulAbsorbed(std::int32_t a_total);
	std::string BuildSoulFeat(
		std::int32_t a_soulTier,
		std::int32_t a_totalDeaths,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled);
	std::string BuildDefiantSoulFeat(std::int32_t a_totalDeaths);
	std::string BuildDefiantRestore(
		std::int32_t a_targetTier,
		std::int32_t a_totalDeaths,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled);
	std::string BuildDefiantAwakened();
	std::string BuildCHIMRealized();
}
