#include "pch.h"

#include "journal.h"
#include "config.h"
#include "datastore.h"
#include "pathutil.h"
#include "text_catalog.h"

#include "RE/C/Calendar.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <limits>
#include <random>

namespace fs = std::filesystem;

namespace IronSoul::Journal
{
	static std::mutex g_mutex;
	static std::mutex g_dailyMutex;
	static constexpr std::int32_t kUncappedMaxLivesSentinel = 2000000000;
	static constexpr const char* kJournalStartDayKey = "IS_5341";
	static constexpr const char* kJournalOpenerLoggedKey = "IS_2270";
	static constexpr const char* kDailyAnimaDayKey = "J.AD";
	static constexpr const char* kDailyAnimaTotalKey = "AN.D";
	static constexpr const char* kDailyAnimaPriorityKey = "J.AP";
	static constexpr const char* kDailyAnimaDateDayKey = "J.DD";
	static constexpr const char* kDailyAnimaDateMonthKey = "J.DM";
	static constexpr const char* kDailyAnimaDateYearKey = "J.DY";

	struct DailyAnimaDate
	{
		std::int32_t day = 17;
		std::int32_t month = 7;
		std::int32_t year = 201;
	};

	struct DailyAnimaState
	{
		std::int32_t trackedDay = -1;
		std::int32_t total = 0;
		std::int32_t priority = kDailyAnimaPriorityNone;
		DailyAnimaDate date;
	};

	static constexpr std::array<std::string_view, 12> kMonthNames = {
		"Morning Star",
		"Sun's Dawn",
		"First Seed",
		"Rain's Hand",
		"Second Seed",
		"Midyear",
		"Sun's Height",
		"Last Seed",
		"Hearthfire",
		"Frostfall",
		"Sun's Dusk",
		"Evening Star"
	};

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

	static std::string MakeGuidKey(std::string_view a_key, std::string_view a_guid)
	{
		return std::string(a_key) + ":" + std::string(a_guid);
	}

	static std::uint32_t HashDailySeed(std::string_view a_guid, std::int32_t a_day, std::int32_t a_priority)
	{
		std::uint32_t hash = 2166136261u;
		for (const unsigned char c : a_guid) {
			hash ^= c;
			hash *= 16777619u;
		}

		const std::uint32_t day = static_cast<std::uint32_t>(a_day);
		const std::uint32_t priority = static_cast<std::uint32_t>(a_priority);
		hash ^= day;
		hash *= 16777619u;
		hash ^= priority;
		hash *= 16777619u;
		return hash;
	}

	static std::int32_t ClampDailyAnimaPriority(std::int32_t a_priority)
	{
		return std::clamp(a_priority, kDailyAnimaPriorityNone, kDailyAnimaPriorityCapstone);
	}

	static bool IsCharacterJournalEnabled()
	{
		return IronSoul::Config::GetAllowedInt("CharacterJournal", 1) == 1;
	}

	static std::int32_t GetCurrentGameDay()
	{
		const auto* calendar = RE::Calendar::GetSingleton();
		if (!calendar) {
			return 0;
		}
		return static_cast<std::int32_t>(calendar->GetCurrentGameTime());
	}

	static DailyAnimaDate GetCurrentDailyAnimaDate()
	{
		const auto* calendar = RE::Calendar::GetSingleton();
		if (!calendar) {
			return {};
		}

		DailyAnimaDate date;
		date.day = std::clamp(static_cast<std::int32_t>(calendar->GetDay()), 1, 31);
		date.month = std::clamp(static_cast<std::int32_t>(calendar->GetMonth()), 0, 11);
		date.year = (std::max)(static_cast<std::int32_t>(calendar->GetYear()), 1);
		return date;
	}

	static std::string BuildDailyDate(const DailyAnimaDate& a_date)
	{
		const std::int32_t month = std::clamp(a_date.month, 0, 11);
		return std::to_string((std::max)(a_date.day, 1)) + " " +
			std::string(kMonthNames[static_cast<std::size_t>(month)]) +
			", 4E " + std::to_string((std::max)(a_date.year, 1));
	}

	static DailyAnimaState LoadDailyAnimaState(std::string_view a_guid)
	{
		DailyAnimaState state;
		state.trackedDay = IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaDayKey, a_guid), -1);
		state.total = (std::max)(IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaTotalKey, a_guid), 0), 0);
		state.priority = ClampDailyAnimaPriority(IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaPriorityKey, a_guid), 0));
		state.date.day = std::clamp(IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaDateDayKey, a_guid), 17), 1, 31);
		state.date.month = std::clamp(IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaDateMonthKey, a_guid), 7), 0, 11);
		state.date.year = (std::max)(IronSoul::DataStore::GetInt(MakeGuidKey(kDailyAnimaDateYearKey, a_guid), 201), 1);
		return state;
	}

	static void StoreDailyAnimaState(std::string_view a_guid, const DailyAnimaState& a_state)
	{
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaDayKey, a_guid), a_state.trackedDay);
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaTotalKey, a_guid), (std::max)(a_state.total, 0));
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaPriorityKey, a_guid), ClampDailyAnimaPriority(a_state.priority));
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaDateDayKey, a_guid), std::clamp(a_state.date.day, 1, 31));
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaDateMonthKey, a_guid), std::clamp(a_state.date.month, 0, 11));
		IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kDailyAnimaDateYearKey, a_guid), (std::max)(a_state.date.year, 1));
	}

	static void ResetDailyAnimaState(std::string_view a_guid, std::int32_t a_nowDay)
	{
		DailyAnimaState state;
		state.trackedDay = a_nowDay;
		state.date = GetCurrentDailyAnimaDate();
		StoreDailyAnimaState(a_guid, state);
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

	static std::string BuildSoulFeatBase(std::int32_t a_soulTier)
	{
		switch (a_soulTier) {
		case 6:
			return IronSoul::Text::Get("Journal.SoulFeat.Devour");
		case 5:
			return IronSoul::Text::Get("Journal.SoulFeat.Platinum");
		case 4:
			return IronSoul::Text::Get("Journal.SoulFeat.Ebon");
		case 3:
			return IronSoul::Text::Get("Journal.SoulFeat.Gold");
		case 2:
			return IronSoul::Text::Get("Journal.SoulFeat.Silver");
		default:
			return {};
		}
	}

	static std::string BuildDefiantRestoreBase(std::int32_t a_targetTier)
	{
		switch (a_targetTier) {
		case 6:
			return IronSoul::Text::Get("Journal.DefiantRestore.Devour");
		case 5:
			return IronSoul::Text::Get("Journal.DefiantRestore.Platinum");
		case 4:
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

	static std::string BuildJournalPrefix()
	{
		std::string name;
		if (auto* player = RE::PlayerCharacter::GetSingleton(); player) {
			name = TrimCopy(player->GetName());
		}
		if (name.empty()) {
			name = "Prisoner";
		}

		const std::string difficultyLabel = IronSoul::Config::GetEffectiveDisplayDifficultyJournalPrefix();
		if (!difficultyLabel.empty()) {
			name += " " + difficultyLabel;
		}
		return name;
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

	bool AppendEvent(std::string_view a_eventText, std::int32_t a_startDay, std::int32_t a_nowDay)
	{
		const std::string dayLine = BuildDayLine(a_eventText, a_startDay, a_nowDay);
		if (dayLine.empty()) {
			return false;
		}
		return AppendLine(BuildJournalPrefix() + " | " + dayLine);
	}

	static std::int32_t EnsureJournalStartDay(std::string_view a_guid, std::int32_t a_nowDay)
	{
		const std::string key = MakeGuidKey(kJournalStartDayKey, a_guid);
		std::int32_t startDay = IronSoul::DataStore::GetInt(key, -1);
		if (startDay == -1) {
			startDay = a_nowDay;
			IronSoul::DataStore::SetIntIfChanged(key, startDay);
		}
		return startDay;
	}

	static void EnsureJournalOpenerLogged(std::string_view a_guid)
	{
		if (IronSoul::DataStore::GetInt(MakeGuidKey(kJournalOpenerLoggedKey, a_guid), 0) == 1) {
			return;
		}

		if (AppendEvent(IronSoul::Text::Get("Journal.Opener"), 0, 0)) {
			IronSoul::DataStore::SetIntIfChanged(MakeGuidKey(kJournalOpenerLoggedKey, a_guid), 1);
		}
	}

	static std::string DailyAnimaTextKey(std::int32_t a_priority, std::int32_t a_index)
	{
		std::string bucket = "Minor";
		if (a_priority <= kDailyAnimaPriorityNone) {
			bucket = "None";
		} else if (a_priority >= kDailyAnimaPriorityCapstone) {
			bucket = "Capstone";
		} else if (a_priority == kDailyAnimaPriorityMajor) {
			bucket = "Major";
		} else if (a_priority == kDailyAnimaPriorityDragon) {
			bucket = "Dragon";
		} else if (a_priority == kDailyAnimaPriorityNamedUndead) {
			bucket = "NamedUndead";
		} else if (a_priority == kDailyAnimaPriorityStrong) {
			bucket = "Strong";
		}

		return "Journal.DailyAnima." + bucket + std::to_string(std::clamp(a_index, 1, 2));
	}

	static std::string BuildDailyAnimaEvent(std::string_view a_guid, const DailyAnimaState& a_state)
	{
		std::int32_t priority = ClampDailyAnimaPriority(a_state.priority);
		if (a_state.total <= 0) {
			priority = kDailyAnimaPriorityNone;
		} else if (priority <= kDailyAnimaPriorityNone) {
			priority = kDailyAnimaPriorityMinor;
		}

		const std::int32_t index = static_cast<std::int32_t>(HashDailySeed(a_guid, a_state.trackedDay, priority) % 2u) + 1;
		const std::string amount = std::to_string((std::max)(a_state.total, 0));
		const std::string text = IronSoul::Text::Format(
			DailyAnimaTextKey(priority, index),
			{ { "amount", amount } });
		return BuildDailyDate(a_state.date) + ". " + text;
	}

	static bool FlushDailyAnimaUnlocked(std::string_view a_guid)
	{
		if (a_guid.empty() || !IronSoul::DataStore::IsInitialized()) {
			return false;
		}

		const std::int32_t nowDay = GetCurrentGameDay();
		if (!IsCharacterJournalEnabled()) {
			ResetDailyAnimaState(a_guid, nowDay);
			return true;
		}

		const DailyAnimaState state = LoadDailyAnimaState(a_guid);
		if (state.trackedDay < 0) {
			ResetDailyAnimaState(a_guid, nowDay);
			return true;
		}

		if (nowDay < state.trackedDay) {
			ResetDailyAnimaState(a_guid, nowDay);
			return true;
		}
		if (nowDay == state.trackedDay) {
			return true;
		}

		EnsureJournalOpenerLogged(a_guid);
		const std::int32_t startDay = EnsureJournalStartDay(a_guid, state.trackedDay);
		const bool logged = AppendEvent(BuildDailyAnimaEvent(a_guid, state), startDay, state.trackedDay);
		if (!logged) {
			logger::warn("Iron Soul: failed to write daily Anima journal summary for guid={} day={}", a_guid, state.trackedDay);
		}

		ResetDailyAnimaState(a_guid, nowDay);
		return logged;
	}

	bool FlushDailyAnima(std::string_view a_guid)
	{
		std::lock_guard lock(g_dailyMutex);
		return FlushDailyAnimaUnlocked(TrimCopy(a_guid));
	}

	bool NoteDailyAnimaAward(
		std::string_view a_guid,
		std::string_view a_source,
		std::int32_t a_amount,
		std::int32_t a_priority)
	{
		(void)a_source;

		std::lock_guard lock(g_dailyMutex);

		const std::string guid = TrimCopy(a_guid);
		if (guid.empty() || !IronSoul::DataStore::IsInitialized()) {
			return false;
		}

		const bool flushed = FlushDailyAnimaUnlocked(guid);
		if (!IsCharacterJournalEnabled()) {
			return false;
		}

		const std::int32_t amount = (std::max)(a_amount, 0);
		if (amount <= 0) {
			return flushed;
		}

		DailyAnimaState state = LoadDailyAnimaState(guid);
		const std::int32_t nowDay = GetCurrentGameDay();
		if (state.trackedDay != nowDay) {
			ResetDailyAnimaState(guid, nowDay);
			state = LoadDailyAnimaState(guid);
		}

		const std::int64_t total = static_cast<std::int64_t>(state.total) + amount;
		const std::int64_t cappedTotal = total > (std::numeric_limits<std::int32_t>::max)() ?
			(std::numeric_limits<std::int32_t>::max)() :
			total;
		state.total = static_cast<std::int32_t>(cappedTotal);
		state.priority = (std::max)(state.priority, ClampDailyAnimaPriority(a_priority));
		StoreDailyAnimaState(guid, state);
		return flushed;
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

	std::string BuildAnimaAward(std::string_view a_source, std::int32_t a_amount)
	{
		std::string source = TrimCopy(a_source);
		if (source.empty()) {
			source = IronSoul::Text::Get("Journal.ExternalSourceDefault");
		}
		const std::int32_t clampedAmount = a_amount < 0 ? 0 : a_amount;
		return IronSoul::Text::Format(
			"Journal.AnimaAward",
			{ { "amount", std::to_string(clampedAmount) }, { "source", source } });
	}

	std::string BuildSoulFeat(std::int32_t a_soulTier, std::int32_t a_totalDeaths)
	{
		const std::string baseText = BuildSoulFeatBase(a_soulTier);
		return AppendTotalDeaths(baseText, a_totalDeaths);
	}

	std::string BuildDefiantSoulFeat(std::int32_t a_totalDeaths)
	{
		return AppendTotalDeaths(
			IronSoul::Text::Get("Journal.SoulFeat.Defiant"),
			a_totalDeaths);
	}

	std::string BuildDefiantRestore(std::int32_t a_targetTier, std::int32_t a_totalDeaths)
	{
		const std::string baseText = BuildDefiantRestoreBase(a_targetTier);
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
