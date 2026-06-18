#include "pch.h"

#include "journal.h"
#include "pathutil.h"
#include "text_catalog.h"

#include <algorithm>
#include <random>

namespace fs = std::filesystem;

namespace IronSoul::Journal
{
	static std::mutex g_mutex;
	static constexpr std::int32_t kUncappedMaxLivesSentinel = 2000000000;

	static fs::path GetLogPath()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"ironsoul-character-journal.log";
	}

	static std::string TrimCopy(std::string_view a_value)
	{
		const auto first = a_value.find_first_not_of(" \t\n\r");
		if (first == std::string_view::npos) {
			return {};
		}
		const auto last = a_value.find_last_not_of(" \t\n\r");
		return std::string(a_value.substr(first, last - first + 1));
	}

	static std::int32_t RandomIntInclusive(std::int32_t a_min, std::int32_t a_max)
	{
		thread_local std::mt19937 rng{ std::random_device{}() };
		std::uniform_int_distribution<std::int32_t> dist(a_min, a_max);
		return dist(rng);
	}

	static std::int32_t PercentThresholdCeil(std::int32_t a_maxLuck, std::int32_t a_pct)
	{
		if (a_maxLuck <= 0) {
			return 0;
		}
		if (a_pct <= 0) {
			return 0;
		}
		if (a_pct >= 100) {
			return a_maxLuck;
		}
		const std::int64_t scaled = static_cast<std::int64_t>(a_maxLuck) * a_pct;
		return static_cast<std::int32_t>((scaled + 99) / 100);
	}

	static std::int32_t LuckTier(std::int32_t a_luck, std::int32_t a_maxLuck)
	{
		if (a_maxLuck <= 0) {
			return 0;
		}
		a_luck = std::clamp(a_luck, 0, a_maxLuck);
		if (a_luck >= a_maxLuck) {
			return 4;
		}
		if (a_luck >= PercentThresholdCeil(a_maxLuck, 75)) {
			return 3;
		}
		if (a_luck >= PercentThresholdCeil(a_maxLuck, 50)) {
			return 2;
		}
		if (a_luck >= PercentThresholdCeil(a_maxLuck, 25)) {
			return 1;
		}
		return 0;
	}

	static std::string BuildDeathCount(std::int32_t a_deathsNow, std::int32_t a_maxLives)
	{
		const std::string deaths = std::to_string(a_deathsNow);
		if (a_maxLives <= 0 || a_maxLives >= kUncappedMaxLivesSentinel) {
			return IronSoul::Text::Format("Journal.DeathCount", { { "deaths", deaths } });
		}

		const std::string maxLives = std::to_string(a_maxLives);
		return IronSoul::Text::Format(
			"Journal.DeathCountCapped",
			{ { "deaths", deaths }, { "max", maxLives } });
	}

	static std::string PickNormalDefeatFlavor()
	{
		switch (RandomIntInclusive(1, 12)) {
		case 1:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal1");
		case 2:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal2");
		case 3:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal3");
		case 4:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal4");
		case 5:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal5");
		case 6:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal6");
		case 7:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal7");
		case 8:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal8");
		case 9:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal9");
		case 10:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal10");
		case 11:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal11");
		default:
			return IronSoul::Text::Get("Journal.DefeatFlavor.Normal12");
		}
	}

	static std::string PickNearCapDefeatFlavor()
	{
		switch (RandomIntInclusive(1, 4)) {
		case 1:
			return IronSoul::Text::Get("Journal.DefeatFlavor.NearCap1");
		case 2:
			return IronSoul::Text::Get("Journal.DefeatFlavor.NearCap2");
		case 3:
			return IronSoul::Text::Get("Journal.DefeatFlavor.NearCap3");
		default:
			return IronSoul::Text::Get("Journal.DefeatFlavor.NearCap4");
		}
	}

	static std::string PickDefeatFlavor(std::int32_t a_deathsNow, std::int32_t a_maxLives)
	{
		if (a_maxLives > 0 && a_maxLives < kUncappedMaxLivesSentinel && a_deathsNow >= (a_maxLives - 1)) {
			return PickNearCapDefeatFlavor();
		}
		return PickNormalDefeatFlavor();
	}

	static std::string BuildSoulFeatBase(
		std::int32_t a_soulTier,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled)
	{
		switch (a_soulTier) {
		case 6:
			return IronSoul::Text::Get("Journal.SoulFeat.Devour");
		case 5:
			if (a_molagKilled) {
				return IronSoul::Text::Get("Journal.SoulFeat.PlatinumMolagBal");
			}
			if (a_miraakKilled) {
				return IronSoul::Text::Get("Journal.SoulFeat.PlatinumMiraak");
			}
			return IronSoul::Text::Get("Journal.SoulFeat.Platinum");
		case 4:
			if (a_alduinKilled) {
				return IronSoul::Text::Get("Journal.SoulFeat.EbonAlduin");
			}
			if (a_harkonKilled) {
				return IronSoul::Text::Get("Journal.SoulFeat.EbonHarkon");
			}
			return IronSoul::Text::Get("Journal.SoulFeat.Ebon");
		case 3:
			return IronSoul::Text::Get("Journal.SoulFeat.Gold");
		case 2:
			return IronSoul::Text::Get("Journal.SoulFeat.Silver");
		default:
			return {};
		}
	}

	static std::string BuildDefiantRestoreBase(
		std::int32_t a_targetTier,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled)
	{
		switch (a_targetTier) {
		case 6:
			return IronSoul::Text::Get("Journal.DefiantRestore.Devour");
		case 5:
			if (a_molagKilled) {
				return IronSoul::Text::Get("Journal.DefiantRestore.PlatinumMolagBal");
			}
			if (a_miraakKilled) {
				return IronSoul::Text::Get("Journal.DefiantRestore.PlatinumMiraak");
			}
			return IronSoul::Text::Get("Journal.DefiantRestore.Platinum");
		case 4:
			if (a_alduinKilled) {
				return IronSoul::Text::Get("Journal.DefiantRestore.EbonAlduin");
			}
			if (a_harkonKilled) {
				return IronSoul::Text::Get("Journal.DefiantRestore.EbonHarkon");
			}
			return IronSoul::Text::Get("Journal.DefiantRestore.Ebon");
		case 3:
			return IronSoul::Text::Get("Journal.DefiantRestore.Gold");
		case 2:
			return IronSoul::Text::Get("Journal.DefiantRestore.Silver");
		case 1:
			return IronSoul::Text::Get("Journal.DefiantRestore.Iron");
		default:
			return {};
		}
	}

	bool AppendLine(std::string_view line)
	{
		std::lock_guard lock(g_mutex);

		const fs::path logPath = GetLogPath();
		std::error_code ec;
		fs::create_directories(logPath.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul: could not create log directory: {}", logPath.parent_path().string());
			return false;
		}

		std::ofstream out(logPath, std::ios::out | std::ios::app);
		if (!out.is_open()) {
			logger::warn("Iron Soul: could not open ironsoul-character-journal.log for append: {}", logPath.string());
			return false;
		}

		out.write(line.data(), static_cast<std::streamsize>(line.size()));
		out.put('\n');
		out.flush();
		return out.good();
	}

	std::string BuildDayLine(std::string_view a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay)
	{
		const std::string eventText = TrimCopy(a_eventText);
		if (eventText.empty()) {
			return {};
		}

		std::int32_t dayIndex = 1;
		if (a_startDay != -1) {
			dayIndex = (a_nowDay - a_startDay) + 1;
		}
		if (dayIndex < 1) {
			dayIndex = 1;
		}

		const std::string day = std::to_string(dayIndex);
		return IronSoul::Text::Format(
			"Journal.DayLine",
			{ { "day", day }, { "event", eventText } });
	}

	std::string BuildExternalEvent(std::string_view a_source, std::string_view a_eventText)
	{
		const std::string eventText = TrimCopy(a_eventText);
		if (eventText.empty()) {
			return {};
		}

		std::string source = TrimCopy(a_source);
		if (source.empty()) {
			source = IronSoul::Text::Get("Journal.ExternalSourceDefault");
		}
		return IronSoul::Text::Format(
			"Journal.ExternalEvent",
			{ { "source", source }, { "event", eventText } });
	}

	std::string AppendTotalDeaths(std::string_view a_baseText, std::int32_t a_totalDeaths)
	{
		const std::string baseText = TrimCopy(a_baseText);
		if (baseText.empty()) {
			return {};
		}

		const std::string totalDeaths = std::to_string(a_totalDeaths);
		return baseText + " " + IronSoul::Text::Format(
			"Journal.TotalDeathsSuffix",
			{ { "total", totalDeaths } });
	}

	std::string BuildDefeatOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives)
	{
		const std::string deathCount = BuildDeathCount(a_deathsNow, a_maxLives);
		const std::string flavor = PickDefeatFlavor(a_deathsNow, a_maxLives);
		return IronSoul::Text::Format(
			"Journal.DefeatOutcome",
			{ { "death_count", deathCount }, { "flavor", flavor } });
	}

	std::string BuildDefeatLuckOutcome(
		std::int32_t a_deathsPred,
		std::int32_t a_maxLives,
		std::int32_t a_roll,
		std::int32_t a_luck)
	{
		const std::string roll = std::to_string(a_roll);
		const std::string luck = std::to_string(a_luck);
		const std::string suffix = IronSoul::Text::Format(
			"Journal.DefeatLuckSuffix",
			{ { "roll", roll }, { "luck", luck } });
		return BuildDefeatOutcome(a_deathsPred, a_maxLives) + " " + suffix;
	}

	std::string BuildTrueDeathOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives)
	{
		const std::string deathCount = BuildDeathCount(a_deathsNow, a_maxLives);
		return IronSoul::Text::Format(
			"Journal.TrueDeathOutcome",
			{ { "death_count", deathCount } });
	}

	std::string BuildDefiantFatigueOutcome(std::int32_t a_deathsNow, std::int32_t a_maxLives, bool a_terminal)
	{
		const std::string deathCount = BuildDeathCount(a_deathsNow, a_maxLives);
		if (a_terminal) {
			return IronSoul::Text::Format(
				"Journal.DefiantFatigueTerminal",
				{ { "death_count", deathCount } });
		}
		return IronSoul::Text::Format(
			"Journal.DefiantFatigue",
			{ { "death_count", deathCount } });
	}

	std::string BuildLuckOutcome(std::int32_t a_luck, std::int32_t a_roll, std::int32_t a_maxLuck)
	{
		const std::string roll = std::to_string(a_roll);
		const std::string luck = std::to_string(a_luck);
		const auto replacements = { IronSoul::Text::Replacement{ "roll", roll }, IronSoul::Text::Replacement{ "luck", luck } };

		const auto tier = LuckTier(a_luck, a_maxLuck);
		if (tier >= 4) {
			return IronSoul::Text::Format("Journal.LuckOutcomeMax", replacements);
		}
		if (tier == 3) {
			return IronSoul::Text::Format("Journal.LuckOutcomeHigh", replacements);
		}
		if (tier == 2) {
			return IronSoul::Text::Format("Journal.LuckOutcomeMid", replacements);
		}
		if (tier == 1) {
			return IronSoul::Text::Format("Journal.LuckOutcomeLow", replacements);
		}
		return IronSoul::Text::Format("Journal.LuckOutcomeBase", replacements);
	}

	std::string BuildDragonSoulAbsorbed(std::int32_t a_total)
	{
		return IronSoul::Text::Format(
			"Journal.DragonSoulAbsorbed",
			{ { "total", std::to_string(a_total) } });
	}

	std::string BuildSoulFeat(
		std::int32_t a_soulTier,
		std::int32_t a_totalDeaths,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled)
	{
		const std::string baseText = BuildSoulFeatBase(a_soulTier, a_molagKilled, a_miraakKilled, a_alduinKilled, a_harkonKilled);
		return AppendTotalDeaths(baseText, a_totalDeaths);
	}

	std::string BuildDefiantSoulFeat(std::int32_t a_totalDeaths)
	{
		return AppendTotalDeaths(
			IronSoul::Text::Get("Journal.SoulFeat.Defiant"),
			a_totalDeaths);
	}

	std::string BuildDefiantRestore(
		std::int32_t a_targetTier,
		std::int32_t a_totalDeaths,
		bool a_molagKilled,
		bool a_miraakKilled,
		bool a_alduinKilled,
		bool a_harkonKilled)
	{
		const std::string baseText = BuildDefiantRestoreBase(a_targetTier, a_molagKilled, a_miraakKilled, a_alduinKilled, a_harkonKilled);
		return AppendTotalDeaths(baseText, a_totalDeaths);
	}

	std::string BuildDefiantAwakened()
	{
		return IronSoul::Text::Get(
			"Journal.DefiantAwakened");
	}

	std::string BuildCHIMRealized()
	{
		return IronSoul::Text::Get(
			"Journal.CHIMRealized");
	}
}
