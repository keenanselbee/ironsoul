#include "pch.h"

#include "journal_book.h"

#include "anima.h"
#include "config.h"
#include "datastore.h"
#include "dynamic_book.h"
#include "pathutil.h"
#include "soul_level.h"
#include "storage_paths.h"

#include <algorithm>
#include <array>
#include <charconv>
#include <cctype>
#include <cstdint>
#include <limits>
#include <map>
#include <sstream>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul::JournalBook
{
namespace
{
	constexpr const char* kJournalSequenceWorldKey = "J.SEQ.W";
	constexpr const char* kIdentityNameKey = "I.N";
	constexpr const char* kIdentityTestCharacterKey = "I.T";
	constexpr const char* kCurrentDeathsKey = "IS_8155";
	constexpr const char* kLifetimeDeathsKey = "IS_9132";
	constexpr const char* kSoulTierKey = "IS_2204";
	constexpr const char* kDragonSoulsStoredTotalKey = "IS_9646";
	constexpr const char* kSunderheartsUnlockedCharacterKey = "SH.C";
	constexpr const char* kWorldDeathCountKey = "DC.W";
	constexpr const char* kWorldDragonSoulsTotalKey = "DS.W";
	constexpr const char* kSunderheartsUnlockedWorldKey = "SH.U.W";
	constexpr const char* kOghmaImageFirst =
		"<img src='img://Textures/Interface/Books/Daedric Artifact book/Daedric Artifac00.png' height='471' width='296'>";
	constexpr const char* kOghmaImageSecond =
		"<img src='img://Textures/Interface/Books/Daedric Artifact book/Daedric Artifact01.png' height='471' width='296'>";
	constexpr const char* kOghmaTextStyleDirective = "[IronSoulTextStyle:font=$SkyrimBooks,size=16]";
	constexpr const char* kOghmaCorruptionDirective = "[IronSoulCorruption:countMin=1,countMax=1,tickMin=5,tickMax=10,hold=1,revealOpen=1,revealTurn=0.75,revealRefresh=0.75]";
	constexpr const char* kOghmaTitleStyleDirective = "[IronSoulLineStyle:font=$SkyrimBooks,size=24,bold=true,align=center]";
	constexpr const char* kOghmaTitleCorruptionDirective = "[IronSoulLineCorruption:countMin=0,countMax=2,tickMin=0.6,tickMax=1.2,bold=true]";
	constexpr const char* kOghmaSubtitleStyleDirective = "[IronSoulLineStyle:font=$SkyrimBooks,size=22,bold=true,align=center]";
	constexpr const char* kOghmaSubtitleCorruptionDirective = "[IronSoulLineCorruption:countMin=0,countMax=2,tickMin=1.2,tickMax=2.4,bold=true]";
	constexpr const char* kOghmaSectionStyleDirective = "[IronSoulLineStyle:font=$SkyrimBooks,size=20,bold=true,align=center]";
	constexpr const char* kOghmaPageBreakDirective = "[pagebreak]";
	constexpr const char* kOghmaRightPageDirective = "[IronSoulRightPage]";
	constexpr const char* kOghmaDynamicBookId = "ironsoul-oghma-infinium";

	constexpr std::int32_t kTierDefiant = 0;
	constexpr std::int32_t kTierIron = 1;
	constexpr std::int32_t kTierSilver = 2;
	constexpr std::int32_t kTierGold = 3;
	constexpr std::int32_t kTierEbon = 4;
	constexpr std::int32_t kTierPlatinum = 5;
	constexpr std::int32_t kTierDevour = 6;
	constexpr std::int32_t kTierCHIM = 9;

	struct DifficultyBucket
	{
		std::int32_t family;
		std::int32_t rank;
		const char* key;
		const char* label;
	};

	constexpr std::array<DifficultyBucket, 15> kDifficultyBuckets{ {
		{ 1, -2, "1M2", "Dreamer--" },
		{ 1, -1, "1M1", "Dreamer-" },
		{ 1, 0, "1", "Dreamer" },
		{ 1, 1, "1P1", "Dreamer+" },
		{ 1, 2, "1P2", "Dreamer++" },
		{ 2, -2, "2M2", "Harbinger--" },
		{ 2, -1, "2M1", "Harbinger-" },
		{ 2, 0, "2", "Harbinger" },
		{ 2, 1, "2P1", "Harbinger+" },
		{ 2, 2, "2P2", "Harbinger++" },
		{ 3, -2, "3M2", "Apocalypse--" },
		{ 3, -1, "3M1", "Apocalypse-" },
		{ 3, 0, "3", "Apocalypse" },
		{ 3, 1, "3P1", "Apocalypse+" },
		{ 3, 2, "3P2", "Apocalypse++" },
	} };

	struct JournalEntry
	{
		std::int64_t sequence = 0;
		std::string text;
	};

	struct CharacterRecord
	{
		bool valid = false;
		bool exists = false;
		bool testCharacter = false;
		std::string guid;
		std::string name;
		std::string overallDifficulty;
		std::string soulStatus;
		std::string soulTier;
		std::string lastRecord;
		std::string lastRecordShort;
		std::int64_t lastSequence = 0;
		std::int32_t currentDeaths = 0;
		std::int32_t lifetimeDeaths = 0;
		std::int32_t animaCharacter = 0;
		std::int32_t dragonSoulsStoredTotal = 0;
		std::int32_t sunderheartsUnlockedCharacter = 0;
		std::array<std::int32_t, 5> soulLevelSlain{ 0, 0, 0, 0, 0 };
		std::vector<JournalEntry> entries;
	};

	std::mutex g_mutex;

	std::string TrimCopy(std::string_view a_value)
	{
		const auto first = a_value.find_first_not_of(" \t\r\n");
		if (first == std::string_view::npos) {
			return {};
		}
		const auto last = a_value.find_last_not_of(" \t\r\n");
		return std::string(a_value.substr(first, last - first + 1));
	}

	std::string MakeGuidKey(std::string_view a_key, std::string_view a_guid)
	{
		return std::string(a_key) + ":" + std::string(a_guid);
	}

	std::int32_t ClampNonNegative(std::int32_t a_value)
	{
		return a_value > 0 ? a_value : 0;
	}

	std::int32_t ClampRank(std::int32_t a_rank)
	{
		return std::clamp(a_rank, -2, 2);
	}

	bool IsSafeGuid(std::string_view a_guid)
	{
		if (a_guid.empty()) {
			return false;
		}
		for (const unsigned char c : a_guid) {
			if (!std::isalnum(c)) {
				return false;
			}
		}
		return true;
	}

	bool EqualsIgnoreCase(std::string_view a_lhs, std::string_view a_rhs)
	{
		if (a_lhs.size() != a_rhs.size()) {
			return false;
		}
		for (std::size_t i = 0; i < a_lhs.size(); ++i) {
			const auto lhs = static_cast<unsigned char>(a_lhs[i]);
			const auto rhs = static_cast<unsigned char>(a_rhs[i]);
			if (std::tolower(lhs) != std::tolower(rhs)) {
				return false;
			}
		}
		return true;
	}

	bool ContainsPrisoner(std::string_view a_name)
	{
		constexpr std::string_view needle = "prisoner";
		if (a_name.size() < needle.size()) {
			return false;
		}
		for (std::size_t i = 0; i <= a_name.size() - needle.size(); ++i) {
			if (EqualsIgnoreCase(a_name.substr(i, needle.size()), needle)) {
				return true;
			}
		}
		return false;
	}

	std::string MakeSummaryNameKey(std::string_view a_name)
	{
		std::string key = TrimCopy(a_name);
		std::transform(
			key.begin(),
			key.end(),
			key.begin(),
			[](const unsigned char c) { return static_cast<char>(std::tolower(c)); });
		return key;
	}

	std::string CurrentPlayerName()
	{
		if (auto* player = RE::PlayerCharacter::GetSingleton(); player) {
			return TrimCopy(player->GetName());
		}
		return {};
	}

	bool IsTestCharacter(std::string_view a_guid)
	{
		if (a_guid.empty()) {
			return true;
		}
		if (IronSoul::DataStore::GetInt(MakeGuidKey(kIdentityTestCharacterKey, a_guid), 0) == 1) {
			return true;
		}
		if (IronSoul::Config::GetAllowedInt("PrisonerTestCharacters", 1) != 1) {
			return false;
		}
		return ContainsPrisoner(CurrentPlayerName());
	}

	bool IsCharacterJournalEnabled()
	{
		return IronSoul::Config::GetAllowedInt("CharacterJournal", 1) == 1;
	}

	fs::path CharactersDir()
	{
		return IronSoul::StoragePaths::GetCharacterDataRoot() / L"characters";
	}

	fs::path BookPath()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"ironsoul" / L"ironsoul-oghma-infinium.txt";
	}

	fs::path CharacterPath(std::string_view a_guid)
	{
		return CharactersDir() / (std::string(a_guid) + ".txt");
	}

	bool WriteTextAtomically(const fs::path& a_path, const std::string& a_text)
	{
		std::error_code ec;
		fs::create_directories(a_path.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul Oghma: failed to create directory {}: {}", a_path.parent_path().string(), ec.message());
			return false;
		}

		fs::path tempPath = a_path;
		tempPath += L".tmp";

		{
			std::ofstream out(tempPath, std::ios::out | std::ios::binary | std::ios::trunc);
			if (!out.is_open()) {
				logger::warn("Iron Soul Oghma: failed to open temp file {}", tempPath.string());
				return false;
			}
			out.write(a_text.data(), static_cast<std::streamsize>(a_text.size()));
			out.flush();
			if (!out.good()) {
				logger::warn("Iron Soul Oghma: failed to write temp file {}", tempPath.string());
				fs::remove(tempPath, ec);
				return false;
			}
		}

		if (!MoveFileExW(
				tempPath.c_str(),
				a_path.c_str(),
				MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
			const auto error = GetLastError();
			if (error == ERROR_NOT_SAME_DEVICE) {
				if (CopyFileW(tempPath.c_str(), a_path.c_str(), FALSE)) {
					std::error_code removeEc;
					fs::remove(tempPath, removeEc);
					if (removeEc) {
						logger::debug(
							"Iron Soul Oghma: copied {} to {} after cross-device replace, but failed to remove temp file: {}",
							tempPath.string(),
							a_path.string(),
							removeEc.message());
					} else {
						logger::debug(
							"Iron Soul Oghma: copied {} to {} after cross-device replace",
							tempPath.string(),
							a_path.string());
					}
					return true;
				}

				const auto copyError = GetLastError();
				logger::warn(
					"Iron Soul Oghma: failed to copy {} to {} after cross-device replace error={}",
					tempPath.string(),
					a_path.string(),
					copyError);
				fs::remove(tempPath, ec);
				return false;
			}

			logger::warn(
				"Iron Soul Oghma: failed to replace {} with {} error={}",
				a_path.string(),
				tempPath.string(),
				error);
			fs::remove(tempPath, ec);
			return false;
		}
		return true;
	}

	std::optional<std::int64_t> ParseInt64(std::string_view a_value)
	{
		const std::string text = TrimCopy(a_value);
		if (text.empty()) {
			return std::nullopt;
		}

		std::int64_t value = 0;
		const auto* begin = text.data();
		const auto* end = begin + text.size();
		const auto [ptr, ec] = std::from_chars(begin, end, value);
		if (ec != std::errc{} || ptr != end) {
			return std::nullopt;
		}
		return value;
	}

	std::int32_t ParseMetaInt(const std::map<std::string, std::string>& a_meta, const std::string& a_key, std::int32_t a_fallback = 0)
	{
		const auto it = a_meta.find(a_key);
		if (it == a_meta.end()) {
			return a_fallback;
		}
		const auto parsed = ParseInt64(it->second);
		if (!parsed) {
			return a_fallback;
		}
		if (*parsed < (std::numeric_limits<std::int32_t>::min)()) {
			return (std::numeric_limits<std::int32_t>::min)();
		}
		if (*parsed > (std::numeric_limits<std::int32_t>::max)()) {
			return (std::numeric_limits<std::int32_t>::max)();
		}
		return static_cast<std::int32_t>(*parsed);
	}

	std::string SanitizeLine(std::string_view a_value)
	{
		std::string text = TrimCopy(a_value);
		for (char& c : text) {
			if (c == '\r' || c == '\n') {
				c = ' ';
			}
		}
		return TrimCopy(text);
	}

	std::string EscapeHtml(std::string_view a_value)
	{
		std::string escaped;
		escaped.reserve(a_value.size());
		for (const char c : a_value) {
			switch (c) {
			case '&':
				escaped += "&amp;";
				break;
			case '<':
				escaped += "&lt;";
				break;
			case '>':
				escaped += "&gt;";
				break;
			case '"':
				escaped += "&quot;";
				break;
			case '\'':
				escaped += "&#39;";
				break;
			default:
				escaped += c;
				break;
			}
		}
		return escaped;
	}

	bool IsBookDirectiveLine(std::string_view a_line)
	{
		return a_line == kOghmaPageBreakDirective || a_line == kOghmaRightPageDirective || a_line == kOghmaSectionStyleDirective;
	}

	CharacterRecord ParseCharacterFile(const fs::path& a_path, bool a_loadEntries)
	{
		CharacterRecord record;
		record.exists = fs::exists(a_path);
		if (!record.exists) {
			record.valid = true;
			return record;
		}

		std::ifstream in(a_path, std::ios::in | std::ios::binary);
		if (!in.is_open()) {
			logger::warn("Iron Soul Oghma: failed to open character journal {}", a_path.string());
			return record;
		}

		std::map<std::string, std::string> meta;
		std::vector<JournalEntry> entries;
		std::string section;
		std::string line;
		while (std::getline(in, line)) {
			line = TrimCopy(line);
			if (line.empty()) {
				continue;
			}
			if (line.front() == '[' && line.back() == ']') {
				section = line.substr(1, line.size() - 2);
				continue;
			}

			if (section == "Meta") {
				const auto eq = line.find('=');
				if (eq == std::string::npos) {
					continue;
				}
				meta[TrimCopy(std::string_view(line).substr(0, eq))] = TrimCopy(std::string_view(line).substr(eq + 1));
				continue;
			}

			if (a_loadEntries && section == "Entries") {
				const auto pipe = line.find('|');
				if (pipe == std::string::npos) {
					continue;
				}
				const auto sequence = ParseInt64(std::string_view(line).substr(0, pipe));
				std::string text = SanitizeLine(std::string_view(line).substr(pipe + 1));
				if (!sequence || text.empty()) {
					continue;
				}
				entries.push_back({ *sequence, std::move(text) });
			}
		}

		if (meta["Version"] != "3") {
			logger::warn("Iron Soul Oghma: skipped malformed character journal {}", a_path.string());
			return record;
		}

		record.guid = meta["Guid"];
		if (!IsSafeGuid(record.guid)) {
			record.guid = a_path.stem().string();
		}
		if (!IsSafeGuid(record.guid)) {
			logger::warn("Iron Soul Oghma: skipped character journal with invalid GUID {}", a_path.string());
			return record;
		}

		record.valid = true;
		record.name = meta["Name"].empty() ? record.guid : meta["Name"];
		record.overallDifficulty = meta["OverallDifficulty"].empty() ? "Harbinger" : meta["OverallDifficulty"];
		record.soulStatus = meta["SoulStatus"].empty() ? "Unbroken" : meta["SoulStatus"];
		record.soulTier = meta["SoulTier"].empty() ? "Iron Soul" : meta["SoulTier"];
		record.lastSequence = ParseMetaInt(meta, "LastSequence");
		record.lastRecord = meta["LastRecord"];
		record.lastRecordShort = SanitizeLine(meta["LastRecordShort"]);
		record.testCharacter = ParseMetaInt(meta, "TestCharacter") == 1;
		record.currentDeaths = ClampNonNegative(ParseMetaInt(meta, "CurrentDeaths"));
		record.lifetimeDeaths = ClampNonNegative(ParseMetaInt(meta, "LifetimeDeaths"));
		record.animaCharacter = ClampNonNegative(ParseMetaInt(meta, "AnimaCharacter"));
		record.dragonSoulsStoredTotal = ClampNonNegative(ParseMetaInt(meta, "DragonSoulsStoredTotal"));
		record.sunderheartsUnlockedCharacter = ClampNonNegative(ParseMetaInt(meta, "SunderheartsUnlockedCharacter"));
		for (std::int32_t level = 1; level <= 5; ++level) {
			record.soulLevelSlain[static_cast<std::size_t>(level - 1)] =
				ClampNonNegative(ParseMetaInt(meta, "SoulLevel" + std::to_string(level) + "SlainCharacter"));
		}
		record.entries = std::move(entries);
		return record;
	}
	const DifficultyBucket& BucketFor(std::int32_t a_family, std::int32_t a_rank)
	{
		a_family = std::clamp(a_family, 1, 3);
		a_rank = ClampRank(a_rank);
		for (const auto& bucket : kDifficultyBuckets) {
			if (bucket.family == a_family && bucket.rank == a_rank) {
				return bucket;
			}
		}
		return kDifficultyBuckets[7];
	}

	std::optional<DifficultyBucket> BucketFromJournalPrefix()
	{
		const std::string prefix = IronSoul::Config::GetEffectiveDisplayDifficultyJournalPrefix();
		if (prefix.size() < 3 || prefix.front() != '[' || prefix.back() != ']') {
			return std::nullopt;
		}

		std::int32_t family = 0;
		if (prefix[1] == 'D') {
			family = 1;
		} else if (prefix[1] == 'H') {
			family = 2;
		} else if (prefix[1] == 'A') {
			family = 3;
		}
		if (family == 0) {
			return std::nullopt;
		}

		const std::string rankText = prefix.substr(2, prefix.size() - 3);
		std::int32_t rank = 0;
		if (rankText == "--") {
			rank = -2;
		} else if (rankText == "-") {
			rank = -1;
		} else if (rankText == "+") {
			rank = 1;
		} else if (rankText == "++") {
			rank = 2;
		}
		return BucketFor(family, rank);
	}

	DifficultyBucket CurrentDifficultyBucket()
	{
		if (const auto fromPrefix = BucketFromJournalPrefix()) {
			return *fromPrefix;
		}

		const bool permadeath = IronSoul::Config::GetAllowedInt("Permadeath", 1) != 0;
		const bool defiantSoul = IronSoul::Config::GetAllowedInt("DefiantSoul", 1) != 0;
		std::int32_t family = 2;
		if (!permadeath) {
			family = 1;
		} else if (!defiantSoul) {
			family = 3;
		}

		const std::int32_t baselineLuck = family == 1 ? 4 : (family == 2 ? 3 : 2);
		const std::int32_t baselineThreat = family == 1 ? 2 : (family == 2 ? 3 : 4);
		const std::int32_t actualLuck = std::clamp(IronSoul::Config::GetAllowedInt("LuckLevel", baselineLuck), 1, 5);
		const std::int32_t actualThreat = std::clamp(IronSoul::Config::GetAllowedInt("DraugrThreatLevel", baselineThreat), 1, 5);
		std::int32_t rank = (baselineLuck - actualLuck) + (actualThreat - baselineThreat);
		if (IronSoul::Config::GetAllowedInt("Respawn", 1) == 0) {
			++rank;
		}
		if (IronSoul::Config::GetAllowedInt("DraugnarokSystem", 1) == 0) {
			--rank;
		}
		if (family < 1 || family > 3) {
			return BucketFor(2, 0);
		}
		return BucketFor(family, rank);
	}

	std::string DifficultyCountKey(std::string_view a_bucket, std::string_view a_guid)
	{
		return "DF.C." + std::string(a_bucket) + ":" + std::string(a_guid);
	}

	std::string DifficultySequenceKey(std::string_view a_bucket, std::string_view a_guid)
	{
		return "DF.S." + std::string(a_bucket) + ":" + std::string(a_guid);
	}

	void NoteDifficulty(std::string_view a_guid, const DifficultyBucket& a_bucket, std::int32_t a_sequence)
	{
		const std::string countKey = DifficultyCountKey(a_bucket.key, a_guid);
		const std::int32_t oldCount = ClampNonNegative(IronSoul::DataStore::GetInt(countKey, 0));
		const std::int32_t newCount = oldCount == (std::numeric_limits<std::int32_t>::max)() ? oldCount : oldCount + 1;
		IronSoul::DataStore::SetIntIfChanged(countKey, newCount);
		IronSoul::DataStore::SetIntIfChanged(DifficultySequenceKey(a_bucket.key, a_guid), a_sequence);
	}

	std::string OverallDifficulty(std::string_view a_guid, const DifficultyBucket& a_fallback)
	{
		std::int32_t bestCount = 0;
		std::int32_t bestSequence = 0;
		const DifficultyBucket* best = nullptr;
		for (const auto& bucket : kDifficultyBuckets) {
			const std::int32_t count = ClampNonNegative(IronSoul::DataStore::GetInt(DifficultyCountKey(bucket.key, a_guid), 0));
			const std::int32_t sequence = ClampNonNegative(IronSoul::DataStore::GetInt(DifficultySequenceKey(bucket.key, a_guid), 0));
			if (count > bestCount || (count == bestCount && count > 0 && sequence > bestSequence)) {
				bestCount = count;
				bestSequence = sequence;
				best = &bucket;
			}
		}
		return best ? best->label : a_fallback.label;
	}

	std::int32_t NextSequence()
	{
		const std::int32_t oldSequence = ClampNonNegative(IronSoul::DataStore::GetInt(kJournalSequenceWorldKey, 0));
		const std::int32_t newSequence = oldSequence == (std::numeric_limits<std::int32_t>::max)() ? oldSequence : oldSequence + 1;
		IronSoul::DataStore::SetIntIfChanged(kJournalSequenceWorldKey, newSequence);
		return newSequence;
	}

	std::string SoulTierLabel(std::int32_t a_tier)
	{
		switch (a_tier) {
		case kTierDefiant:
			return "Defiant Soul";
		case kTierSilver:
			return "Silver Soul";
		case kTierGold:
			return "Gilded Soul";
		case kTierEbon:
			return "Ebon Soul";
		case kTierPlatinum:
			return "Platinum Soul";
		case kTierDevour:
			return "Devour Soul";
		case kTierCHIM:
			return "CHIM";
		case kTierIron:
		default:
			return "Iron Soul";
		}
	}

	std::string SoulStatus(std::int32_t a_currentDeaths, std::int32_t a_tier)
	{
		const std::int32_t deaths = ClampNonNegative(a_currentDeaths);
		if (deaths <= 0) {
			return "Unbroken";
		}
		if (deaths == 1) {
			return "Scarred";
		}
		if (deaths <= 3) {
			return "Wounded";
		}
		if (deaths <= 5) {
			return "Fractured";
		}
		if (deaths <= 7) {
			return "Fading";
		}
		if (deaths == 8) {
			return "Unraveling";
		}
		if (deaths == 9) {
			return "Death's Door";
		}
		if (deaths == 10) {
			if (a_tier == kTierDefiant) {
				return "Defiant";
			}
			if (IronSoul::Config::GetAllowedInt("Permadeath", 1) != 0) {
				return "Sovngarde";
			}
			return "Death's Door";
		}
		if (deaths <= 12) {
			return "Rekindled";
		}
		if (deaths <= 14) {
			return "Burdened";
		}
		if (deaths <= 16) {
			return "Hollowing";
		}
		if (deaths <= 18) {
			return "Threadbare";
		}
		if (deaths == 19) {
			return "Death's Door";
		}
		return "Sovngarde";
	}

	CharacterRecord BuildCurrentRecord(
		std::string_view a_guid,
		const std::vector<JournalEntry>& a_entries,
		std::string_view a_lastRecordShort = {})
	{
		const DifficultyBucket currentDifficulty = CurrentDifficultyBucket();

		CharacterRecord record;
		record.valid = true;
		record.exists = true;
		record.guid = std::string(a_guid);
		record.name = IronSoul::DataStore::GetString(MakeGuidKey(kIdentityNameKey, a_guid), "");
		if (record.name.empty()) {
			record.name = CurrentPlayerName();
		}
		if (record.name.empty()) {
			record.name = record.guid;
		}
		record.testCharacter = IsTestCharacter(a_guid);
		record.currentDeaths = ClampNonNegative(IronSoul::DataStore::GetInt(MakeGuidKey(kCurrentDeathsKey, a_guid), 0));
		record.lifetimeDeaths = ClampNonNegative(IronSoul::DataStore::GetInt(MakeGuidKey(kLifetimeDeathsKey, a_guid), 0));
		const std::int32_t tier = IronSoul::DataStore::GetInt(MakeGuidKey(kSoulTierKey, a_guid), kTierIron);
		record.soulStatus = SoulStatus(record.currentDeaths, tier);
		record.soulTier = SoulTierLabel(tier);
		record.overallDifficulty = OverallDifficulty(a_guid, currentDifficulty);
		record.animaCharacter = IronSoul::Anima::GetCharacter(a_guid);
		record.dragonSoulsStoredTotal = ClampNonNegative(IronSoul::DataStore::GetInt(MakeGuidKey(kDragonSoulsStoredTotalKey, a_guid), 0));
		record.sunderheartsUnlockedCharacter = ClampNonNegative(IronSoul::DataStore::GetInt(MakeGuidKey(kSunderheartsUnlockedCharacterKey, a_guid), 0));
		for (std::int32_t level = 1; level <= 5; ++level) {
			record.soulLevelSlain[static_cast<std::size_t>(level - 1)] = IronSoul::SoulLevel::GetCharacterSlain(a_guid, level);
		}
		record.entries = a_entries;
		if (!record.entries.empty()) {
			const auto lastIt = std::max_element(
				record.entries.begin(),
				record.entries.end(),
				[](const JournalEntry& lhs, const JournalEntry& rhs) { return lhs.sequence < rhs.sequence; });
			record.lastSequence = lastIt->sequence;
			record.lastRecord = lastIt->text;
			record.lastRecordShort = SanitizeLine(a_lastRecordShort);
		}
		return record;
	}

	std::string FormatEntrySequence(std::int64_t a_sequence)
	{
		std::ostringstream out;
		out.width(10);
		out.fill('0');
		out << (std::max)(a_sequence, static_cast<std::int64_t>(0));
		return out.str();
	}

	std::string BuildCharacterFileText(const CharacterRecord& a_record)
	{
		std::ostringstream out;
		out << "[Meta]\n";
		out << "Version=3\n";
		out << "Guid=" << a_record.guid << '\n';
		out << "Name=" << a_record.name << '\n';
		out << "TestCharacter=" << (a_record.testCharacter ? 1 : 0) << '\n';
		out << "LastSequence=" << a_record.lastSequence << '\n';
		out << "LastRecord=" << a_record.lastRecord << '\n';
		out << "LastRecordShort=" << a_record.lastRecordShort << '\n';
		out << "OverallDifficulty=" << a_record.overallDifficulty << '\n';
		out << "SoulStatus=" << a_record.soulStatus << '\n';
		out << "SoulTier=" << a_record.soulTier << '\n';
		out << "CurrentDeaths=" << a_record.currentDeaths << '\n';
		out << "LifetimeDeaths=" << a_record.lifetimeDeaths << '\n';
		out << "AnimaCharacter=" << a_record.animaCharacter << '\n';
		out << "DragonSoulsStoredTotal=" << a_record.dragonSoulsStoredTotal << '\n';
		out << "SunderheartsUnlockedCharacter=" << a_record.sunderheartsUnlockedCharacter << '\n';
		for (std::int32_t level = 1; level <= 5; ++level) {
			out << "SoulLevel" << level << "SlainCharacter=" <<
				a_record.soulLevelSlain[static_cast<std::size_t>(level - 1)] << '\n';
		}
		out << "\n[Entries]\n";
		for (const auto& entry : a_record.entries) {
			out << FormatEntrySequence(entry.sequence) << " | " << entry.text << '\n';
		}
		return out.str();
	}

	bool RewriteCurrentCharacterFile(
		std::string_view a_guid,
		const std::vector<JournalEntry>& a_entries,
		std::string_view a_lastRecordShort = {})
	{
		CharacterRecord record = BuildCurrentRecord(a_guid, a_entries, a_lastRecordShort);
		if (record.testCharacter) {
			return false;
		}
		return WriteTextAtomically(CharacterPath(a_guid), BuildCharacterFileText(record));
	}

	std::map<std::string, std::size_t> CountSummaryNames(const std::vector<CharacterRecord>& a_records)
	{
		std::map<std::string, std::size_t> counts;
		for (const auto& record : a_records) {
			const std::string key = MakeSummaryNameKey(record.name);
			if (!key.empty()) {
				++counts[key];
			}
		}
		return counts;
	}

	std::string FormatSummaryName(const CharacterRecord& a_record, const std::map<std::string, std::size_t>& a_nameCounts)
	{
		std::string displayName = a_record.name.empty() ? a_record.guid : a_record.name;
		const std::string key = MakeSummaryNameKey(a_record.name);
		const auto countIt = a_nameCounts.find(key);
		if (!key.empty() && countIt != a_nameCounts.end() && countIt->second > 1 && !a_record.guid.empty()) {
			displayName += ' ';
			displayName += a_record.guid;
		}
		return displayName;
	}

	void AppendSummary(
		std::ostringstream& a_out,
		const CharacterRecord& a_record,
		bool a_current,
		const std::map<std::string, std::size_t>& a_nameCounts,
		bool a_reserveLastRecordLine = false)
	{
		a_out << FormatSummaryName(a_record, a_nameCounts) << " | " << a_record.overallDifficulty << " | " << a_record.soulStatus << '\n';
		a_out << a_record.soulTier << " | Deaths: " << a_record.currentDeaths
			  << " [" << a_record.lifetimeDeaths << "]"
			  << " | Anima: " << a_record.animaCharacter << '\n';
		a_out << "Dragon Souls: " << a_record.dragonSoulsStoredTotal
			  << " | Sunderhearts unlocked: " << a_record.sunderheartsUnlockedCharacter << '\n';
		a_out << "Soul Level slain: "
			  << a_record.soulLevelSlain[0] << " | "
			  << a_record.soulLevelSlain[1] << " | "
			  << a_record.soulLevelSlain[2] << " | "
			  << a_record.soulLevelSlain[3] << " | "
			  << a_record.soulLevelSlain[4] << '\n';
		if (!a_current && (!a_record.lastRecordShort.empty() || a_reserveLastRecordLine)) {
			a_out << "Last record: " << (a_record.lastRecordShort.empty() ? "None recorded." : a_record.lastRecordShort) << '\n';
		}
	}

	void AppendMissingTopSoulSlot(std::ostringstream& a_out)
	{
		a_out << '\n';
		a_out << '\n';
		a_out << '\n';
		a_out << '\n';
		a_out << '\n';
		a_out << '\n';
	}

	std::string BuildBookBodyText(std::string_view a_currentGuid, const std::vector<CharacterRecord>& a_records)
	{
		const auto nameCounts = CountSummaryNames(a_records);
		const auto currentIt = std::find_if(
			a_records.begin(),
			a_records.end(),
			[&](const CharacterRecord& record) { return record.guid == a_currentGuid; });

		std::vector<CharacterRecord> others;
		for (const auto& record : a_records) {
			if (record.guid != a_currentGuid) {
				others.push_back(record);
			}
		}

		std::sort(
			others.begin(),
			others.end(),
			[](const CharacterRecord& lhs, const CharacterRecord& rhs) {
				if (lhs.animaCharacter != rhs.animaCharacter) {
					return lhs.animaCharacter > rhs.animaCharacter;
				}
				return lhs.lastSequence > rhs.lastSequence;
			});

		const std::size_t topCount = (std::min)(std::size_t{ 3 }, others.size());
		std::vector<CharacterRecord> top(others.begin(), others.begin() + static_cast<std::ptrdiff_t>(topCount));
		std::vector<CharacterRecord> remaining(others.begin() + static_cast<std::ptrdiff_t>(topCount), others.end());
		std::sort(
			remaining.begin(),
			remaining.end(),
			[](const CharacterRecord& lhs, const CharacterRecord& rhs) {
				return lhs.lastSequence > rhs.lastSequence;
			});

		std::ostringstream out;
		out << "THE OGHMA INFINIUM\n";
		out << "A Chronicle of Souls\n\n";
		out << "World Anima: " << IronSoul::Anima::GetWorld() << '\n';
		out << "World Deaths: " << ClampNonNegative(IronSoul::DataStore::GetInt(kWorldDeathCountKey, 0)) << '\n';
		out << "World Dragon Souls claimed: " << ClampNonNegative(IronSoul::DataStore::GetInt(kWorldDragonSoulsTotalKey, 0)) << '\n';
		out << "World Sunderhearts unlocked: " << ClampNonNegative(IronSoul::DataStore::GetInt(kSunderheartsUnlockedWorldKey, 0)) << '\n';
		out << "Soul Level slain: ";
		for (std::int32_t level = 1; level <= 5; ++level) {
			if (level > 1) {
				out << " | ";
			}
			out << IronSoul::SoulLevel::GetWorldSlain(level);
		}
		out << '\n';
		out << '\n';

		if (currentIt != a_records.end()) {
			AppendSummary(out, *currentIt, true, nameCounts);
			out << '\n';
		}

		out << kOghmaSectionStyleDirective << '\n';
		out << "TOP SOULS\n";
		for (const auto& record : top) {
			AppendSummary(out, record, false, nameCounts, true);
			out << '\n';
		}
		for (std::size_t missing = top.size(); missing < 3; ++missing) {
			AppendMissingTopSoulSlot(out);
		}

		out << kOghmaPageBreakDirective << '\n';
		out << kOghmaSectionStyleDirective << '\n';
		out << "SOUL LEDGER\n\n";
		if (currentIt != a_records.end() && !currentIt->entries.empty()) {
			std::vector<JournalEntry> entries = currentIt->entries;
			std::sort(
				entries.begin(),
				entries.end(),
				[](const JournalEntry& lhs, const JournalEntry& rhs) { return lhs.sequence > rhs.sequence; });
			for (const auto& entry : entries) {
				out << entry.text << '\n';
			}
			out << '\n';
		}
		for (const auto& record : remaining) {
			AppendSummary(out, record, false, nameCounts);
			out << '\n';
		}

		return out.str();
	}

	std::string FormatBookBodyText(std::string_view a_text)
	{
		std::ostringstream out;
		std::size_t start = 0;
		std::size_t textLineIndex = 0;
		while (start < a_text.size()) {
			const std::size_t end = a_text.find('\n', start);
			const std::size_t lineEnd = end == std::string_view::npos ? a_text.size() : end;
			std::string_view line = a_text.substr(start, lineEnd - start);
			if (!line.empty() && line.back() == '\r') {
				line.remove_suffix(1);
			}

			if (line.empty()) {
				out << '\n';
			} else {
				if (IsBookDirectiveLine(line)) {
					out << line << '\n';
				} else {
					if (textLineIndex == 0) {
						out << kOghmaTitleStyleDirective << '\n';
						out << kOghmaTitleCorruptionDirective << '\n';
					} else if (textLineIndex == 1) {
						out << kOghmaSubtitleStyleDirective << '\n';
						out << kOghmaSubtitleCorruptionDirective << '\n';
					}
					out << EscapeHtml(line) << '\n';
					++textLineIndex;
				}
			}

			if (end == std::string_view::npos) {
				break;
			}
			start = end + 1;
		}
		return out.str();
	}

	std::string BuildBookText(std::string_view a_currentGuid, const std::vector<CharacterRecord>& a_records)
	{
		std::ostringstream out;
		out << kOghmaTextStyleDirective << '\n';
		out << kOghmaCorruptionDirective << '\n';
		out << kOghmaImageFirst << '\n';
		out << FormatBookBodyText(BuildBookBodyText(a_currentGuid, a_records));
		out << "\n\n";
		out << kOghmaRightPageDirective << '\n';
		out << kOghmaImageSecond << '\n';
		return out.str();
	}

	std::vector<CharacterRecord> LoadBookRecords(std::string_view a_currentGuid)
	{
		std::vector<CharacterRecord> records;
		const fs::path dir = CharactersDir();
		std::error_code ec;
		if (!fs::exists(dir, ec)) {
			return records;
		}

		for (const auto& entry : fs::directory_iterator(dir, ec)) {
			if (ec) {
				logger::warn("Iron Soul Oghma: failed to enumerate character journals {}: {}", dir.string(), ec.message());
				break;
			}
			if (!entry.is_regular_file(ec) || entry.path().extension() != ".txt") {
				continue;
			}

			const bool loadEntries = entry.path().stem().string() == a_currentGuid;
			CharacterRecord record = ParseCharacterFile(entry.path(), loadEntries);
			if (!record.valid || record.testCharacter || record.guid.empty()) {
				continue;
			}
			records.push_back(std::move(record));
		}
		return records;
	}

	std::string BuildBookTextUnlocked(std::string_view a_currentGuid)
	{
		std::vector<CharacterRecord> records = LoadBookRecords(a_currentGuid);
		const std::string currentGuid = TrimCopy(a_currentGuid);
		if (!currentGuid.empty() && IsSafeGuid(currentGuid)) {
			const bool currentExists = std::any_of(
				records.begin(),
				records.end(),
				[&](const CharacterRecord& record) { return record.guid == currentGuid; });
			if (!currentExists) {
				records.push_back(BuildCurrentRecord(currentGuid, {}));
			}
		}
		return BuildBookText(a_currentGuid, records);
	}

	bool RefreshBookUnlocked(std::string_view a_currentGuid)
	{
		const std::string text = BuildBookTextUnlocked(a_currentGuid);
		return WriteTextAtomically(BookPath(), text);
	}

	CharacterRecord LoadCurrentCharacterRecord(std::string_view a_guid)
	{
		CharacterRecord existing = ParseCharacterFile(CharacterPath(a_guid), true);
		if (!existing.valid) {
			logger::warn("Iron Soul Oghma: rebuilding malformed active journal for guid={}", a_guid);
		}
		return existing;
	}
}

	bool RecordEvent(std::string_view a_guid, std::string_view a_dayLine, std::string_view a_summary)
	{
		std::lock_guard lock(g_mutex);

		if (!IsCharacterJournalEnabled()) {
			return true;
		}

		const std::string guid = TrimCopy(a_guid);
		const std::string dayLine = SanitizeLine(a_dayLine);
		const std::string summary = SanitizeLine(a_summary);
		if (!IsSafeGuid(guid) || dayLine.empty() || summary.empty() || !IronSoul::DataStore::IsInitialized()) {
			return false;
		}
		if (IsTestCharacter(guid)) {
			logger::debug("Iron Soul Oghma: skipped test character journal event guid={}", guid);
			return true;
		}

		const std::int32_t sequence = NextSequence();
		const DifficultyBucket difficulty = CurrentDifficultyBucket();
		NoteDifficulty(guid, difficulty, sequence);

		CharacterRecord existing = LoadCurrentCharacterRecord(guid);
		std::vector<JournalEntry> entries = std::move(existing.entries);
		entries.push_back({ sequence, dayLine });
		if (!RewriteCurrentCharacterFile(guid, entries, summary)) {
			return false;
		}
		if (!RefreshBookUnlocked(guid)) {
			logger::warn(
				"Iron Soul Oghma: recorded journal event for guid={} but failed to refresh generated book text",
				guid);
		}
		IronSoul::DataStore::FlushIfDirty();
		return true;
	}

	bool RefreshBook(std::string_view a_currentGuid)
	{
		std::lock_guard lock(g_mutex);

		if (!IsCharacterJournalEnabled()) {
			return true;
		}

		const std::string guid = TrimCopy(a_currentGuid);
		if (!guid.empty() && IsSafeGuid(guid) && !IsTestCharacter(guid) && fs::exists(CharacterPath(guid))) {
			CharacterRecord existing = LoadCurrentCharacterRecord(guid);
			RewriteCurrentCharacterFile(guid, existing.entries, existing.lastRecordShort);
		}
		return RefreshBookUnlocked(guid);
	}

	bool DynamicBookRefreshOghma(std::string_view a_currentGuid)
	{
		bool refreshed = true;
		{
			std::lock_guard lock(g_mutex);

			if (IsCharacterJournalEnabled()) {
				const std::string guid = TrimCopy(a_currentGuid);
				if (!guid.empty() && IsSafeGuid(guid) && !IsTestCharacter(guid) && fs::exists(CharacterPath(guid))) {
					CharacterRecord existing = LoadCurrentCharacterRecord(guid);
					RewriteCurrentCharacterFile(guid, existing.entries, existing.lastRecordShort);
				}
				refreshed = RefreshBookUnlocked(guid);
			}
		}

		return refreshed;
	}

	bool DeleteCharacter(std::string_view a_guid)
	{
		std::lock_guard lock(g_mutex);

		const std::string guid = TrimCopy(a_guid);
		if (!IsSafeGuid(guid)) {
			return false;
		}

		std::error_code ec;
		fs::remove(CharacterPath(guid), ec);
		if (ec) {
			logger::warn("Iron Soul Oghma: failed to delete character journal guid={} error={}", guid, ec.message());
			return false;
		}
		return true;
	}
}
