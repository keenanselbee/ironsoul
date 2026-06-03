#include "pch.h"
#include "config.h"
#include "pathutil.h"
#include <atomic>
#include <unordered_map>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul::Config
{
	// --- Logging State ---
	// =====================

	static std::mutex g_mutex;
	static std::atomic_bool g_infoGateArmed{ false };
	static std::atomic_bool g_enableInfoLoggingCached{ false };

	// Store case-insensitive keys (lowercased). Values are int32.
	static std::unordered_map<std::string, std::int32_t> g_ints;
	static std::int32_t g_effectiveDisplayPresetFamily = 0;
	static std::int32_t g_effectiveDisplayRank = 0;

	static constexpr std::int32_t kConfigFlagIronSoulPreset = 1 << 0;
	static constexpr std::int32_t kConfigFlagPresetLockedCore = 1 << 1;
	static constexpr std::int32_t kConfigFlagDraugrThreat = 1 << 2;
	static constexpr std::int32_t kConfigFlagLuck = 1 << 3;
	static constexpr std::int32_t kConfigFlagUninstallMode = 1 << 4;
	static constexpr std::int32_t kConfigFlagDraugnarokRefresh = 1 << 5;

struct ConfigKeySpec
{
	const char* canonicalKey;
	const char* displayName;
	const char* sectionName;
	std::int32_t defaultValue;
	bool hasMin;
	std::int32_t minValue;
	bool hasMax;
	std::int32_t maxValue;
	std::int32_t flags;
};

struct ConfigKeyAliasSpec
{
	const char* aliasKey;
	const char* canonicalKey;
};

static constexpr ConfigKeySpec kConfigKeySpecs[] = {
	{ "ironsoulpreset", "IronSoulPreset", "Difficulty", 0, false, 0, false, 0,
		kConfigFlagIronSoulPreset | kConfigFlagDraugnarokRefresh },
	{ "permadeath", "Permadeath", "Difficulty", 1, true, 0, true, 1, kConfigFlagPresetLockedCore },
	{ "defiantsoul", "DefiantSoul", "Difficulty", 1, true, 0, true, 1, kConfigFlagPresetLockedCore },
	{ "lucklevel", "LuckLevel", "Difficulty", 5, true, 1, true, 5,
		kConfigFlagPresetLockedCore | kConfigFlagLuck },
	{ "draugrthreatlevel", "DraugrThreatLevel", "Difficulty", 2, true, 1, true, 5,
		kConfigFlagDraugrThreat | kConfigFlagDraugnarokRefresh },

	{ "anticheat", "Anticheat", "General", 1, true, 0, true, 1, 0 },
	{ "characterjournal", "CharacterJournal", "General", 1, true, 0, true, 1, 0 },
	{ "deathmessage", "DeathMessage", "General", 1, true, 0, true, 1, 0 },
	{ "dragonsoulnotification", "DragonSoulNotification", "General", 1, true, 0, true, 1, 0 },
	{ "ironsoulintro", "IronSoulIntro", "General", 1, true, 0, true, 1, 0 },
	{ "ironsoulintrodelayseconds", "IronSoulIntroDelaySeconds", "General", 23, true, 0, true, 120, 0 },
	{ "loadnotification", "LoadNotification", "General", 1, true, 0, true, 1, 0 },
	{ "soulbonus", "SoulBonus", "General", 1, true, 0, true, 1, 0 },
	{ "soulfatigue", "SoulFatigue", "General", 1, true, 0, true, 1, 0 },
	{ "soulfeats", "SoulFeats", "General", 1, true, 0, true, 1, 0 },

	{ "dragonsoulrevive", "DragonSoulRevive", "DragonSoulRevive", 1, true, 0, true, 1, 0 },
	{ "dragonsoulrevivelimit", "DragonSoulReviveLimit", "DragonSoulRevive", 1, true, 0, true, 3, 0 },
	{ "dragonsoulrevivemessage", "DragonSoulReviveMessage", "DragonSoulRevive", 1, true, 0, true, 1, 0 },
	{ "dragonsoulrevivetransform", "DragonSoulReviveTransform", "DragonSoulRevive", 1, true, 0, true, 1, 0 },

	{ "luckremindernotification", "LuckReminderNotification", "Respawn", 1, true, 0, true, 1, 0 },
	{ "luckrollmessagemode", "LuckRollMessageMode", "Respawn", 1, true, 0, true, 2, 0 },
	{ "respawn", "Respawn", "Respawn", 1, true, 0, true, 1, 0 },
	{ "respawnmessage", "RespawnMessage", "Respawn", 1, true, 0, true, 1, 0 },

	{ "draugnaroksystem", "DraugnarokSystem", "Draugnarok", 1, true, 0, true, 1,
		kConfigFlagDraugnarokRefresh },
	{ "draugnarokbaseintervalhours", "DraugnarokBaseIntervalHours", "Draugnarok", 8, true, 1, true, 24, 0 },
	{ "draugnarokcooldownintervals", "DraugnarokCooldownIntervals", "Draugnarok", 3, true, 0, true, 90, 0 },
	{ "draugnarokforcecleanupintervals", "DraugnarokForceCleanupIntervals", "Draugnarok", 6, true, 0, true, 90, 0 },
	{ "draugnarokgatepressureintervals", "DraugnarokGatePressureIntervals", "Draugnarok", 6, true, 0, true, 90, 0 },
	{ "draugnarokjournalmode", "DraugnarokJournalMode", "Draugnarok", 1, true, 0, true, 3, 0 },
	{ "draugnaroklevelprogression", "DraugnarokLevelProgression", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "draugnaroknotificationmode", "DraugnarokNotificationMode", "Draugnarok", 1, true, 0, true, 4, 0 },
	{ "draugnarokvisiblequest", "DraugnarokVisibleQuest", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "draugnarokweathermode", "DraugnarokWeatherMode", "Draugnarok", 1, true, 0, true, 4, 0 },
	{ "raidsmall", "RaidSmall", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidservice", "RaidService", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidtown", "RaidTown", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidmedium", "RaidMedium", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidpillage", "RaidPillage", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidminorcapital", "RaidMinorCapital", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidgate", "RaidGate", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "raidcapital", "RaidCapital", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "roadencounters", "RoadEncounters", "Draugnarok", 1, true, 0, true, 1, 0 },
	{ "wildernessencounters", "WildernessEncounters", "Draugnarok", 1, true, 0, true, 1, 0 },

	{ "heartshardmessage", "HeartshardMessage", "Heartshards", 1, true, 0, true, 1, 0 },
	{ "heartshardnotification", "HeartshardNotification", "Heartshards", 1, true, 0, true, 1, 0 },
	{ "heartshardinventorymode", "HeartshardInventoryMode", "Heartshards", 1, true, 0, true, 3, 0 },
	{ "heartshardtonalmaxtemper", "HeartshardTonalMaxTemper", "Heartshards", 10, true, 1, true, 100, 0 },

	{ "cosaverecoverybackup", "CosaveRecoveryBackup", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "mirrordatabackup", "MirrorDataBackup", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "cursorhide", "CursorHide", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "dynamicdraugreyes", "DynamicDraugrEyes", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "dynamiclevelwidget", "DynamicLevelWidget", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "dynamicsplash", "DynamicSplash", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "musicfade", "MusicFade", "SKSEPlugin", 1, true, 0, true, 1, 0 },
	{ "slowmoondeath", "SlowMoOnDeath", "SKSEPlugin", 1, true, 0, true, 1, 0 },

	{ "musicvolumeoverride", "MusicVolumeOverride", "Sound", -1, true, -1, true, 100, 0 },
	{ "sfx", "SFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "deathslowmosfx", "DeathSlowMoSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "ironintrosfx", "IronIntroSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "deathsfx", "DeathSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "permadeathsfx", "PermadeathSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "respawnsfx", "RespawnSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "defianttransitionsfx", "DefiantTransitionSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "chimtransitionsfx", "CHIMTransitionSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "defiantrestoresfx", "DefiantRestoreSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "heartshardabsorbsfx", "HeartshardAbsorbSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "dragonsoulrevivecastsfx", "DragonSoulReviveCastSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "dragonsoulrevivesfx", "DragonSoulReviveSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "featunlocksfx", "FeatUnlockSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "luckrollsfx", "LuckRollSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "luckoutcomesfx", "LuckOutcomeSFX", "Sound", 1, true, 0, true, 1, 0 },
	{ "respawnheavybreathingsfx", "RespawnHeavyBreathingSFX", "Sound", 1, true, 0, true, 1, 0 },

	{ "enablecharactersheetcompatibility", "EnableCharacterSheetCompatibility", "Experimental", 0, true, 0, true, 1, 0 },

	{ "enabledebug", "EnableDebug", "Debug", 0, true, 0, true, 1, 0 },
	{ "enablelogging", "EnableLogging", "Debug", 0, true, 0, true, 1, 0 },
	{ "enablelognotifications", "EnableLogNotifications", "Debug", 0, true, 0, true, 1, 0 },
	{ "loglevel", "LogLevel", "Debug", 2, true, 1, true, 3, 0 },
	{ "uninstallmode", "UninstallMode", "Debug", 0, true, 0, true, 1, kConfigFlagUninstallMode },
};

static constexpr ConfigKeyAliasSpec kConfigKeyAliases[] = {
	{ "dragonsoulanticheat", "anticheat" },
};

	static bool IsInfoLoggingEnabledLocked()
	{
		const auto it = g_ints.find("enablelogging");
		if (it != g_ints.end() && it->second == 1) {
			return true;
		}

		const auto itLegacy = g_ints.find("logging.enablelogging");
		return itLegacy != g_ints.end() && itLegacy->second == 1;
	}

	static void RefreshInfoLoggingCacheLocked()
	{
		g_enableInfoLoggingCached.store(IsInfoLoggingEnabledLocked(), std::memory_order_release);
	}

	static bool ShouldEmitInfoLogLocked()
	{
		if (!g_infoGateArmed.load(std::memory_order_acquire)) {
			return true;
		}
		return IsInfoLoggingEnabledLocked();
	}

	void SetInfoGateArmed(bool armed)
	{
		g_infoGateArmed.store(armed, std::memory_order_release);
	}

	bool ShouldEmitInfoLog()
	{
		if (!g_infoGateArmed.load(std::memory_order_acquire)) {
			return true;
		}
		return g_enableInfoLoggingCached.load(std::memory_order_acquire);
	}

	// --- Parsing Helpers ---
	// =======================

	static inline void TrimInPlace(std::string& s)
	{
		const char* ws = " \t\r\n";
		const auto b = s.find_first_not_of(ws);
		if (b == std::string::npos) {
			s.clear();
			return;
		}
		const auto e = s.find_last_not_of(ws);
		s = s.substr(b, e - b + 1);
	}

	static inline std::string ToLowerCopy(std::string_view sv)
	{
		std::string out;
		out.reserve(sv.size());
		for (unsigned char c : sv) {
			out.push_back(static_cast<char>(std::tolower(c)));
		}
		return out;
	}

	// Strip UTF-8 BOM if present at the start of the line.
	static inline void StripUtf8BomIfPresent(std::string& line)
	{
		if (line.size() >= 3 &&
			static_cast<unsigned char>(line[0]) == 0xEF &&
			static_cast<unsigned char>(line[1]) == 0xBB &&
			static_cast<unsigned char>(line[2]) == 0xBF) {
			line.erase(0, 3);
		}
	}

	// Remove inline comments starting with ';' or '#', but *not* inside quotes.
	static inline void StripInlineCommentRespectQuotes(std::string& s)
	{
		bool inQuote = false;
		char quoteChar = 0;

		for (std::size_t i = 0; i < s.size(); ++i) {
			const char c = s[i];

			if (!inQuote && (c == '"' || c == '\'')) {
				inQuote = true;
				quoteChar = c;
				continue;
			}
			if (inQuote && c == quoteChar) {
				inQuote = false;
				quoteChar = 0;
				continue;
			}

			if (!inQuote && (c == ';' || c == '#')) {
				s.resize(i);
				break;
			}
		}

		TrimInPlace(s);
	}

	// Convert a "possibly quoted" string to unquoted if it is fully wrapped in quotes.
	static inline void UnquoteIfWrapped(std::string& s)
	{
		TrimInPlace(s);
		if (s.size() >= 2) {
			const char a = s.front();
			const char b = s.back();
			if ((a == '"' && b == '"') || (a == '\'' && b == '\'')) {
				s = s.substr(1, s.size() - 2);
				TrimInPlace(s);
			}
		}
	}

	// For warnings: make raw values readable even if they contain weird bytes.
	static inline std::string EscapeForLog(std::string_view sv)
	{
		std::string out;
		out.reserve(sv.size() + 16);
		for (unsigned char c : sv) {
			if (c == '\\') out += "\\\\";
			else if (c == '\n') out += "\\n";
			else if (c == '\r') out += "\\r";
			else if (c == '\t') out += "\\t";
			else if (c >= 32 && c < 127) out.push_back(static_cast<char>(c));
			else {
				char buf[8];
				std::snprintf(buf, sizeof(buf), "\\x%02X", c);
				out += buf;
			}
		}
		return out;
	}

	static std::optional<std::int32_t> ParseIntStrict(std::string_view s)
	{
		// Trim whitespace
		auto l = s.find_first_not_of(" \t\r\n");
		if (l == std::string_view::npos)
			return std::nullopt;
		auto r = s.find_last_not_of(" \t\r\n");
		s = s.substr(l, r - l + 1);

		// Optional: allow wrapping quotes like "3"
		if (s.size() >= 2 && ((s.front() == '"' && s.back() == '"') || (s.front() == '\'' && s.back() == '\''))) {
			s = s.substr(1, s.size() - 2);
			l = s.find_first_not_of(" \t\r\n");
			if (l == std::string_view::npos) return std::nullopt;
			r = s.find_last_not_of(" \t\r\n");
			s = s.substr(l, r - l + 1);
		}

		try {
			std::string tmp(s);
			size_t idx = 0;
			long long v = std::stoll(tmp, &idx, 10);

			// Must consume whole string (no trailing garbage)
			if (idx != tmp.size())
				return std::nullopt;

			if (v < INT32_MIN || v > INT32_MAX)
				return std::nullopt;

			return static_cast<std::int32_t>(v);
		} catch (...) {
			return std::nullopt;
		}
	}

	struct ParsedConfigValue
	{
		std::int32_t value = 0;
		std::string canonicalText;
	};

	static std::int32_t ClampInt(std::int32_t value, std::int32_t minValue, std::int32_t maxValue);
	static std::int32_t GetConfigValueLocked(std::string_view canonicalKey, std::int32_t defaultValue);

	static std::int32_t PresetOrdinalFromFamilyAndPlus(std::int32_t presetFamily, std::int32_t plusCount)
	{
		if (presetFamily <= 0) {
			return 0;
		}
		return ((presetFamily - 1) * 4) + 1 + plusCount;
	}

	static bool IsImplementedPresetOrdinal(std::int32_t presetOrdinal)
	{
		return presetOrdinal == 0 ||
			(presetOrdinal >= 1 && presetOrdinal <= 3) ||
			(presetOrdinal >= 5 && presetOrdinal <= 7) ||
			(presetOrdinal >= 9 && presetOrdinal <= 11);
	}

	static std::int32_t NormalizePresetOrdinal(std::int32_t presetOrdinal)
	{
		return IsImplementedPresetOrdinal(presetOrdinal) ? presetOrdinal : 0;
	}

	static std::int32_t PresetFamilyFromOrdinal(std::int32_t presetOrdinal)
	{
		presetOrdinal = NormalizePresetOrdinal(presetOrdinal);
		if (presetOrdinal >= 1 && presetOrdinal <= 3) {
			return 1;
		}
		if (presetOrdinal >= 5 && presetOrdinal <= 7) {
			return 2;
		}
		if (presetOrdinal >= 9 && presetOrdinal <= 11) {
			return 3;
		}
		return 0;
	}

	static std::int32_t PresetPlusFromOrdinal(std::int32_t presetOrdinal)
	{
		presetOrdinal = NormalizePresetOrdinal(presetOrdinal);
		if (presetOrdinal >= 1 && presetOrdinal <= 3) {
			return presetOrdinal - 1;
		}
		if (presetOrdinal >= 5 && presetOrdinal <= 7) {
			return presetOrdinal - 5;
		}
		if (presetOrdinal >= 9 && presetOrdinal <= 11) {
			return presetOrdinal - 9;
		}
		return 0;
	}

	static std::int32_t ClampDisplayDifficultyRank(std::int32_t rank)
	{
		return ClampInt(rank, -1, 2);
	}

	static void ResetEffectiveDisplayDifficultyToPresetLocked()
	{
		const std::int32_t presetOrdinal = NormalizePresetOrdinal(GetConfigValueLocked("ironsoulpreset", 0));
		g_effectiveDisplayPresetFamily = PresetFamilyFromOrdinal(presetOrdinal);
		g_effectiveDisplayRank = PresetPlusFromOrdinal(presetOrdinal);
	}

	static void MaybeResetEffectiveDisplayDifficultyForKeyLocked(std::string_view key)
	{
		if (key == "ironsoulpreset" || key == "respawn" || key == "draugnaroksystem") {
			ResetEffectiveDisplayDifficultyToPresetLocked();
		}
	}

	static std::optional<ParsedConfigValue> ParseIronSoulPresetValue(std::string_view s)
	{
		std::string text(s);
		TrimInPlace(text);
		UnquoteIfWrapped(text);

		std::int32_t plusCount = 0;
		while (!text.empty() && text.back() == '+') {
			++plusCount;
			if (plusCount > 2) {
				return std::nullopt;
			}
			text.pop_back();
			TrimInPlace(text);
		}

		auto parsed = ParseIntStrict(text);
		if (!parsed.has_value() || *parsed < 0 || *parsed > 3) {
			return std::nullopt;
		}
		if (plusCount > 0 && *parsed == 0) {
			return std::nullopt;
		}

		ParsedConfigValue out;
		out.value = PresetOrdinalFromFamilyAndPlus(*parsed, plusCount);
		out.canonicalText = std::to_string(*parsed);
		out.canonicalText.append(static_cast<std::size_t>(plusCount), '+');
		return out;
	}

	static std::optional<ParsedConfigValue> ParseConfigValueForKey(const std::string& keyLower, std::string_view valueText)
	{
		if (keyLower == "ironsoulpreset") {
			return ParseIronSoulPresetValue(valueText);
		}

		auto parsed = ParseIntStrict(valueText);
		if (!parsed.has_value()) {
			return std::nullopt;
		}

		ParsedConfigValue out;
		out.value = *parsed;
		out.canonicalText = std::to_string(out.value);
		return out;
	}

	static fs::path GetIniPath()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"ironsoul.ini";
	}

	static void EnsureDirExists(const fs::path& a_path)
	{
		std::error_code ec;
		fs::create_directories(a_path.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul: could not create ini directory: {}", a_path.parent_path().string());
		}
	}

	// --- Public Reads ---
	// ====================

	int GetInt(std::string_view key, int defaultValue)
	{
		std::lock_guard lock(g_mutex);

		std::string k = ToLowerCopy(key);
		TrimInPlace(k);

		auto it = g_ints.find(k);
		if (it == g_ints.end()) {
			return defaultValue;
		}

		return static_cast<int>(it->second);
	}

	static bool IsValidConfigKey(std::string_view key)
	{
		if (key.empty()) {
			return false;
		}
		if (key.size() > 128) {
			return false;
		}
		for (char c : key) {
			if (c == '=' || c == '\r' || c == '\n' || c == '\0') {
				return false;
			}
		}
		return true;
	}

	// --- Config Metadata ---
	// =======================

	static const ConfigKeySpec* FindConfigKeySpecByCanonical(std::string_view canonicalKey)
	{
		for (const ConfigKeySpec& spec : kConfigKeySpecs) {
			if (spec.canonicalKey == canonicalKey) {
				return &spec;
			}
		}
		return nullptr;
	}

	static const ConfigKeySpec* FindConfigKeySpec(std::string_view key)
	{
		std::string keyLower = ToLowerCopy(key);
		TrimInPlace(keyLower);
		if (!IsValidConfigKey(keyLower)) {
			return nullptr;
		}

		if (const ConfigKeySpec* spec = FindConfigKeySpecByCanonical(keyLower)) {
			return spec;
		}

		for (const ConfigKeyAliasSpec& alias : kConfigKeyAliases) {
			if (alias.aliasKey == keyLower) {
				return FindConfigKeySpecByCanonical(alias.canonicalKey);
			}
		}

		// Permit "section.key" forms by canonicalizing to "key".
		const std::size_t dot = keyLower.rfind('.');
		if (dot != std::string::npos && dot + 1 < keyLower.size()) {
			return FindConfigKeySpec(std::string_view(keyLower).substr(dot + 1));
		}

		return nullptr;
	}

	static std::optional<std::string> CanonicalizeAllowedKey(std::string_view key)
	{
		if (const ConfigKeySpec* spec = FindConfigKeySpec(key)) {
			return std::string(spec->canonicalKey);
		}
		return std::nullopt;
	}

	static bool HasConfigFlag(const ConfigKeySpec& spec, std::int32_t flag)
	{
		return (spec.flags & flag) != 0;
	}

	static std::int32_t ClampInt(std::int32_t value, std::int32_t minValue, std::int32_t maxValue)
	{
		if (value < minValue) {
			return minValue;
		}
		if (value > maxValue) {
			return maxValue;
		}
		return value;
	}

	static std::int32_t NormalizePreset(std::int32_t presetOrdinal)
	{
		return NormalizePresetOrdinal(presetOrdinal);
	}

	static std::int32_t NormalizeBool(std::int32_t value, std::int32_t fallback)
	{
		if (value == 0 || value == 1) {
			return value;
		}
		return fallback;
	}

	static std::int32_t GetConfigValueLocked(std::string_view canonicalKey, std::int32_t defaultValue)
	{
		auto it = g_ints.find(std::string(canonicalKey));
		if (it == g_ints.end()) {
			return defaultValue;
		}
		return it->second;
	}

	static std::string PresetPlusTextLocked(std::int32_t presetOrdinal)
	{
		const std::int32_t plusCount = PresetPlusFromOrdinal(presetOrdinal);
		if (plusCount <= 0) {
			return "";
		}
		if (plusCount == 1) {
			return "+";
		}
		return "++";
	}

	static std::string DisplayDifficultyRankTextLocked(std::int32_t rank)
	{
		rank = ClampDisplayDifficultyRank(rank);
		if (rank < 0) {
			return "-";
		}
		if (rank == 0) {
			return "";
		}
		if (rank == 1) {
			return "+";
		}
		return "++";
	}

	static std::string DisplayDifficultyConfigTextLocked(std::int32_t presetFamily, std::int32_t rank)
	{
		if (presetFamily < 1 || presetFamily > 3) {
			return "Custom";
		}
		return std::to_string(presetFamily) + DisplayDifficultyRankTextLocked(rank);
	}

	static std::string DisplayDifficultyJournalPrefixLocked(std::int32_t presetFamily, std::int32_t rank)
	{
		std::string text;
		switch (presetFamily) {
		case 1:
			text = "[D]";
			break;
		case 2:
			text = "[H]";
			break;
		case 3:
			text = "[A]";
			break;
		default:
			return "";
		}

		const std::string rankText = DisplayDifficultyRankTextLocked(rank);
		if (!rankText.empty()) {
			text.insert(text.size() - 1, rankText);
		}
		return text;
	}

	static std::string DifficultyLabelLocked(std::int32_t presetOrdinal)
	{
		presetOrdinal = NormalizePreset(presetOrdinal);
		switch (PresetFamilyFromOrdinal(presetOrdinal)) {
		case 1:
			return "Dreamer" + PresetPlusTextLocked(presetOrdinal);
		case 2:
			return "Harbinger" + PresetPlusTextLocked(presetOrdinal);
		case 3:
			return "Apocalypse" + PresetPlusTextLocked(presetOrdinal);
		default:
			return "Custom";
		}
	}

	static std::string PresetConfigTextLocked(std::int32_t presetOrdinal)
	{
		presetOrdinal = NormalizePreset(presetOrdinal);
		const std::int32_t presetFamily = PresetFamilyFromOrdinal(presetOrdinal);
		std::string text = std::to_string(presetFamily);
		if (presetFamily != 0) {
			text += PresetPlusTextLocked(presetOrdinal);
		}
		return text;
	}

	static std::int32_t GetEffectivePermadeathLocked(std::int32_t presetOrdinal)
	{
		switch (PresetFamilyFromOrdinal(presetOrdinal)) {
		case 1:
			return 0;
		case 2:
		case 3:
			return 1;
		default:
			return NormalizeBool(GetConfigValueLocked("permadeath", 1), 1);
		}
	}

	static std::int32_t GetEffectiveDefiantSoulLocked(std::int32_t presetOrdinal)
	{
		switch (PresetFamilyFromOrdinal(presetOrdinal)) {
		case 1:
		case 2:
			return 1;
		case 3:
			return 0;
		default:
			return NormalizeBool(GetConfigValueLocked("defiantsoul", 1), 1);
		}
	}

	static std::int32_t GetEffectiveDraugrThreatLevelLocked(std::int32_t presetOrdinal)
	{
		std::int32_t threatLevel = 1;
		const std::int32_t presetFamily = PresetFamilyFromOrdinal(presetOrdinal);
		switch (presetFamily) {
		case 1:
			threatLevel = 2;
			break;
		case 2:
			threatLevel = 3;
			break;
		case 3:
			threatLevel = 4;
			break;
		default:
			threatLevel = ClampInt(GetConfigValueLocked("draugrthreatlevel", 2), 1, 5);
			break;
		}

		if (presetFamily != 0 && PresetPlusFromOrdinal(presetOrdinal) >= 2 &&
			NormalizeBool(GetConfigValueLocked("draugnaroksystem", 1), 1) != 0) {
			threatLevel += 1;
		}

		return ClampInt(threatLevel, 1, 5);
	}

	static std::int32_t GetEffectiveLuckLevelLocked(std::int32_t presetOrdinal)
	{
		std::int32_t luckLevel = 5;
		const std::int32_t presetFamily = PresetFamilyFromOrdinal(presetOrdinal);
		switch (presetFamily) {
		case 1:
			luckLevel = 4;
			break;
		case 2:
			luckLevel = 3;
			break;
		case 3:
			luckLevel = 2;
			break;
		default:
			luckLevel = ClampInt(GetConfigValueLocked("lucklevel", 5), 1, 5);
			break;
		}

		if (presetFamily != 0 && PresetPlusFromOrdinal(presetOrdinal) >= 1) {
			luckLevel -= 1;
		}

		return ClampInt(luckLevel, 1, 5);
	}

	static std::string BuildRangeError(const ConfigKeySpec& spec)
	{
		if (spec.hasMin && spec.hasMax) {
			if (spec.minValue == 0 && spec.maxValue == 1) {
				return std::string("Error: ") + spec.displayName + " must be 0 or 1.";
			}
			if (spec.minValue == 1 && spec.maxValue == 5) {
				return std::string("Error: ") + spec.displayName + " must be 1, 2, 3, 4, or 5.";
			}
			if (spec.minValue == -1 && spec.maxValue == 1) {
				return std::string("Error: ") + spec.displayName + " must be -1, 0, or 1.";
			}
			return std::string("Error: ") + spec.displayName + " must be between " +
				std::to_string(spec.minValue) + " and " + std::to_string(spec.maxValue) + ".";
		}
		if (spec.hasMin) {
			return std::string("Error: ") + spec.displayName + " must be at least " +
				std::to_string(spec.minValue) + ".";
		}
		return std::string("Error: ") + spec.displayName + " must be no greater than " +
			std::to_string(spec.maxValue) + ".";
	}

	static std::string ValidateParsedConfigValueLocked(const ConfigKeySpec& spec, std::int32_t value)
	{
		if ((spec.hasMin && value < spec.minValue) || (spec.hasMax && value > spec.maxValue)) {
			return BuildRangeError(spec);
		}
		return "";
	}

	static std::string ValidateConfigSetErrorLocked(std::string_view key, std::string_view valueText)
	{
		std::string keyText(key);
		TrimInPlace(keyText);
		if (keyText.empty()) {
			return "Error: config key cannot be empty.";
		}
		if (!IsValidConfigKey(keyText)) {
			return std::string("Error: invalid INI key '") + EscapeForLog(keyText) + "'.";
		}

		const ConfigKeySpec* spec = FindConfigKeySpec(keyText);
		if (!spec) {
			return std::string("Error: unknown INI key '") + EscapeForLog(keyText) + "'.";
		}

		auto parsed = ParseConfigValueForKey(spec->canonicalKey, valueText);
		if (!parsed.has_value()) {
			if (HasConfigFlag(*spec, kConfigFlagIronSoulPreset)) {
				return "Error: IronSoulPreset must be 0, 1, 1+, 1++, 2, 2+, 2++, 3, 3+, or 3++.";
			}
			return std::string("Error: INI key '") + spec->displayName + "' requires an integer value.";
		}

		if (HasConfigFlag(*spec, kConfigFlagPresetLockedCore) || HasConfigFlag(*spec, kConfigFlagDraugrThreat)) {
			const std::int32_t currentPreset = NormalizePreset(GetConfigValueLocked("ironsoulpreset", 0));
			if (currentPreset != 0) {
				return std::string("Error: IronSoulPreset must be 0 (Override) before setting ") +
					spec->displayName + ". Current preset is " + DifficultyLabelLocked(currentPreset) + ".";
			}
		}

		return ValidateParsedConfigValueLocked(*spec, parsed->value);
	}

	static void AppendConfigSummarySection(std::string& result, std::string_view sectionName)
	{
		bool wroteHeader = false;
		int valuesOnLine = 0;

		for (const ConfigKeySpec& spec : kConfigKeySpecs) {
			if (std::string_view(spec.sectionName) != sectionName) {
				continue;
			}

			if (!wroteHeader) {
				if (!result.empty() && result.back() == '\n') {
					result += "\n";
				}
				result += "[";
				result.append(sectionName.data(), sectionName.size());
				result += "]\n";
				wroteHeader = true;
			}

			if (valuesOnLine > 0) {
				result += ", ";
			}

			result += spec.displayName;
			result += "=";
			result += std::to_string(GetConfigValueLocked(spec.canonicalKey, spec.defaultValue));

			++valuesOnLine;
			if (valuesOnLine >= 5) {
				result += "\n";
				valuesOnLine = 0;
			}
		}

		if (wroteHeader && valuesOnLine != 0) {
			result += "\n";
		}
	}

	int GetAllowedInt(std::string_view key, int defaultValue)
	{
		std::lock_guard lock(g_mutex);

		const auto canonicalKey = CanonicalizeAllowedKey(key);
		if (!canonicalKey.has_value()) {
			return defaultValue;
		}

		return static_cast<int>(GetConfigValueLocked(*canonicalKey, defaultValue));
	}

	std::int32_t GetIronSoulPresetOrdinal()
	{
		std::lock_guard lock(g_mutex);
		return NormalizePreset(GetConfigValueLocked("ironsoulpreset", 0));
	}

	bool SetEffectiveDisplayDifficulty(std::int32_t presetFamily, std::int32_t displayRank)
	{
		std::lock_guard lock(g_mutex);
		if (presetFamily < 0 || presetFamily > 3) {
			return false;
		}
		g_effectiveDisplayPresetFamily = presetFamily;
		g_effectiveDisplayRank = (presetFamily == 0) ? 0 : ClampDisplayDifficultyRank(displayRank);
		return true;
	}

	std::string GetEffectiveDisplayDifficultyJournalPrefix()
	{
		std::lock_guard lock(g_mutex);
		return DisplayDifficultyJournalPrefixLocked(g_effectiveDisplayPresetFamily, g_effectiveDisplayRank);
	}

	std::string GetConfigKeyCanonical(std::string_view key)
	{
		std::lock_guard lock(g_mutex);
		if (const ConfigKeySpec* spec = FindConfigKeySpec(key)) {
			return spec->canonicalKey;
		}
		return "";
	}

	std::string GetConfigKeyDisplayName(std::string_view key)
	{
		std::lock_guard lock(g_mutex);
		if (const ConfigKeySpec* spec = FindConfigKeySpec(key)) {
			return spec->displayName;
		}
		return "";
	}

	std::int32_t GetConfigKeyFlags(std::string_view key)
	{
		std::lock_guard lock(g_mutex);
		if (const ConfigKeySpec* spec = FindConfigKeySpec(key)) {
			return spec->flags;
		}
		return 0;
	}

	std::string GetConfigSetError(std::string_view key, std::string_view value)
	{
		std::lock_guard lock(g_mutex);
		return ValidateConfigSetErrorLocked(key, value);
	}

	std::string GetConfigSummary()
	{
		std::lock_guard lock(g_mutex);

		const std::int32_t preset = NormalizePreset(GetConfigValueLocked("ironsoulpreset", 0));

		std::string result;
		result.reserve(2048);
		result += "[Difficulty]\n";
		result += "IronSoulPreset=" + PresetConfigTextLocked(preset);
		result += ", DisplayDifficulty=" + DisplayDifficultyConfigTextLocked(g_effectiveDisplayPresetFamily, g_effectiveDisplayRank);
		result += ", Permadeath=" + std::to_string(GetEffectivePermadeathLocked(preset));
		result += ", DefiantSoul=" + std::to_string(GetEffectiveDefiantSoulLocked(preset));
		result += ", LuckLevel=" + std::to_string(GetEffectiveLuckLevelLocked(preset));
		result += ", DraugrThreatLevel=" + std::to_string(GetEffectiveDraugrThreatLevelLocked(preset));
		result += "\n";

		AppendConfigSummarySection(result, "General");
		AppendConfigSummarySection(result, "DragonSoulRevive");
		AppendConfigSummarySection(result, "Respawn");
		AppendConfigSummarySection(result, "Draugnarok");
		AppendConfigSummarySection(result, "Heartshards");
		AppendConfigSummarySection(result, "SKSEPlugin");
		AppendConfigSummarySection(result, "Sound");
		AppendConfigSummarySection(result, "Experimental");
		AppendConfigSummarySection(result, "Debug");

		if (!result.empty() && result.back() == '\n') {
			result.pop_back();
		}
		return result;
	}

	// --- INI Updates ---
	// ===================

	static void UpsertConfigValueLocked(const std::string& keyLower, const ParsedConfigValue& parsed)
	{
		g_ints[keyLower] = parsed.value;
		for (auto& [k, v] : g_ints) {
			if (k.size() > keyLower.size() + 1 &&
				k.compare(k.size() - keyLower.size(), keyLower.size(), keyLower) == 0 &&
				k[k.size() - keyLower.size() - 1] == '.') {
				v = parsed.value;
			}
		}
	}

	static bool ReplaceIniValueForExistingKey(const fs::path& iniPath, const std::string& targetKeyLower, const std::string& valueText)
	{
		std::ifstream in(iniPath, std::ios::in);
		if (!in.is_open()) {
			logger::error("Iron Soul: SetConfig could not open INI for read: {}", iniPath.string());
			return false;
		}

		std::vector<std::string> lines;
		lines.reserve(256);

		std::string line;
		bool firstLine = true;
		bool anyMatched = false;

		while (std::getline(in, line)) {
			if (!line.empty() && line.back() == '\r') {
				line.pop_back();
			}
			if (firstLine) {
				StripUtf8BomIfPresent(line);
				firstLine = false;
			}

			std::size_t start = line.find_first_not_of(" \t");
			if (start != std::string::npos && line[start] != ';' && line[start] != '#' && line[start] != '[') {
				std::size_t eq = line.find('=', start);
				if (eq != std::string::npos) {
					std::string keyPart = line.substr(start, eq - start);
					TrimInPlace(keyPart);
					if (!keyPart.empty()) {
						std::string keyLower = ToLowerCopy(keyPart);
						if (const ConfigKeySpec* spec = FindConfigKeySpec(keyLower)) {
							keyLower = spec->canonicalKey;
						}
						if (keyLower == targetKeyLower) {
							std::string valuePart = line.substr(eq + 1);
							std::string commentPart;
							bool inQuote = false;
							char quoteChar = 0;
							for (std::size_t i = 0; i < valuePart.size(); ++i) {
								const char c = valuePart[i];
								if (!inQuote && (c == '"' || c == '\'')) {
									inQuote = true;
									quoteChar = c;
								} else if (inQuote && c == quoteChar) {
									inQuote = false;
									quoteChar = 0;
								} else if (!inQuote && (c == ';' || c == '#')) {
									commentPart = valuePart.substr(i);
									break;
								}
							}

							std::string newLine = line.substr(0, start) + keyPart + "=" + valueText;
							if (!commentPart.empty()) {
								const std::size_t cStart = commentPart.find_first_not_of(" \t");
								if (cStart != std::string::npos) {
									newLine += " " + commentPart.substr(cStart);
								}
							}

							line = std::move(newLine);
							anyMatched = true;
						}
					}
				}
			}

			lines.push_back(std::move(line));
		}

		if (!in.good() && !in.eof()) {
			logger::error("Iron Soul: SetConfig encountered read error for {}", iniPath.string());
			return false;
		}

		if (!anyMatched) {
			logger::warn("Iron Soul: SetConfig rejected key '{}' because no existing INI entry was found", targetKeyLower);
			return false;
		}

		const fs::path tmpPath = iniPath.wstring() + L".tmp";
		std::ofstream out(tmpPath, std::ios::out | std::ios::trunc);
		if (!out.is_open()) {
			logger::error("Iron Soul: SetConfig could not open temp INI for write: {}", tmpPath.string());
			return false;
		}

		// Text-mode streams translate '\n' to the platform newline sequence.
		// Writing "\r\n" explicitly here can produce doubled breaks on Windows.
		for (const auto& ln : lines) {
			out << ln << '\n';
		}
		if (!out.good()) {
			logger::error("Iron Soul: SetConfig failed while writing temp INI: {}", tmpPath.string());
			return false;
		}
		out.close();

		std::error_code ec;
		fs::rename(tmpPath, iniPath, ec);
		if (ec) {
			ec.clear();
			fs::copy_file(tmpPath, iniPath, fs::copy_options::overwrite_existing, ec);
			if (ec) {
				logger::error("Iron Soul: SetConfig failed replacing INI '{}' (ec={})", iniPath.string(), ec.value());
				ec.clear();
				fs::remove(tmpPath, ec);
				return false;
			}
			ec.clear();
			fs::remove(tmpPath, ec);
		}

		return true;
	}

	// --- Public Writes ---
	// =====================

	bool SetInt(std::string_view key, std::int32_t value, bool persistToIni)
	{
		std::lock_guard lock(g_mutex);

		std::string keyText(key);
		TrimInPlace(keyText);
		const std::string valueText = std::to_string(value);
		const std::string validationError = ValidateConfigSetErrorLocked(keyText, valueText);
		if (!validationError.empty()) {
			logger::warn("Iron Soul: SetInt rejected config update '{}={}' ({})",
				EscapeForLog(keyText),
				value,
				validationError);
			return false;
		}

		const ConfigKeySpec* spec = FindConfigKeySpec(keyText);
		const std::string keyLower = spec ? spec->canonicalKey : "";
		auto parsed = ParseConfigValueForKey(keyLower, valueText);
		if (!parsed.has_value()) {
			logger::warn("Iron Soul: SetInt rejected invalid config value for key '{}' (value={})", EscapeForLog(keyText), value);
			return false;
		}

		if (!persistToIni) {
			UpsertConfigValueLocked(keyLower, *parsed);
			MaybeResetEffectiveDisplayDifficultyForKeyLocked(keyLower);
			RefreshInfoLoggingCacheLocked();
			return true;
		}

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		if (!ReplaceIniValueForExistingKey(iniPath, keyLower, parsed->canonicalText)) {
			return false;
		}

		UpsertConfigValueLocked(keyLower, *parsed);
		MaybeResetEffectiveDisplayDifficultyForKeyLocked(keyLower);
		RefreshInfoLoggingCacheLocked();

		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: INI key updated {}={} ({})", keyLower, parsed->canonicalText, iniPath.string());
		}
		return true;
	}

	bool SetString(std::string_view key, std::string_view value, bool persistToIni)
	{
		std::lock_guard lock(g_mutex);

		std::string keyText(key);
		TrimInPlace(keyText);
		const std::string validationError = ValidateConfigSetErrorLocked(keyText, value);
		if (!validationError.empty()) {
			logger::warn(
				"Iron Soul: SetString rejected config update '{}={}' ({})",
				EscapeForLog(keyText),
				EscapeForLog(value),
				validationError
			);
			return false;
		}

		const ConfigKeySpec* spec = FindConfigKeySpec(keyText);
		const std::string keyLower = spec ? spec->canonicalKey : "";
		auto parsed = ParseConfigValueForKey(keyLower, value);
		if (!parsed.has_value()) {
			logger::warn(
				"Iron Soul: SetString rejected invalid config value for key '{}' (raw='{}')",
				EscapeForLog(keyText),
				EscapeForLog(value)
			);
			return false;
		}

		if (!persistToIni) {
			UpsertConfigValueLocked(keyLower, *parsed);
			MaybeResetEffectiveDisplayDifficultyForKeyLocked(keyLower);
			RefreshInfoLoggingCacheLocked();
			return true;
		}

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		if (!ReplaceIniValueForExistingKey(iniPath, keyLower, parsed->canonicalText)) {
			return false;
		}

		UpsertConfigValueLocked(keyLower, *parsed);
		MaybeResetEffectiveDisplayDifficultyForKeyLocked(keyLower);
		RefreshInfoLoggingCacheLocked();

		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: INI key updated {}={} ({})", keyLower, parsed->canonicalText, iniPath.string());
		}
		return true;
	}

	// --- Load ---
	// ============

	void Load()
	{
		std::lock_guard lock(g_mutex);
		g_ints.clear();
		ResetEffectiveDisplayDifficultyToPresetLocked();
		RefreshInfoLoggingCacheLocked();

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		std::ifstream in(iniPath, std::ios::in);
		if (!in.is_open()) {
			logger::warn("Iron Soul: ironsoul.ini not found at {} (using defaults/fallbacks)", iniPath.string());
			if (ShouldEmitInfoLogLocked()) {
				logger::info("Iron Soul: INI path={}", iniPath.string());
			}
			RefreshInfoLoggingCacheLocked();
			return;
		}

		std::string currentSection;            // original case
		std::string currentSectionKeyLower;    // lower(section)

		std::string line;
		bool firstLine = true;

		// Accurate accounting
		std::size_t settingsParsed = 0;        // successful int settings (actual INI entries)
		std::size_t insertedRaw = 0;
		std::size_t insertedQualified = 0;
		std::size_t dupRaw = 0;
		std::size_t dupQualified = 0;

		while (std::getline(in, line)) {

			if (firstLine) {
				StripUtf8BomIfPresent(line);
				firstLine = false;
			}

			auto start = line.find_first_not_of(" \t\r\n");
			if (start == std::string::npos)
				continue;

			if (line[start] == ';' || line[start] == '#')
				continue;

			// Section header
			if (line[start] == '[') {
				auto end = line.find(']', start + 1);
				if (end != std::string::npos) {
					currentSection = line.substr(start + 1, end - (start + 1));
					TrimInPlace(currentSection);
					currentSectionKeyLower = ToLowerCopy(currentSection);
				}
				continue;
			}

			// key=value
			auto eq = line.find('=', start);
			if (eq == std::string::npos)
				continue;

			std::string key = line.substr(start, eq - start);
			std::string val = line.substr(eq + 1);

			TrimInPlace(key);
			TrimInPlace(val);

			if (key.empty())
				continue;

			StripInlineCommentRespectQuotes(val);
			UnquoteIfWrapped(val);

			std::string keyLower = ToLowerCopy(key);
			if (const ConfigKeySpec* spec = FindConfigKeySpec(keyLower)) {
				keyLower = spec->canonicalKey;
			}

			auto parsed = ParseConfigValueForKey(keyLower, val);
			if (!parsed.has_value()) {
				logger::warn(
					"Iron Soul: invalid config value for key '{}' in ironsoul.ini (raw='{}')",
					key,
					EscapeForLog(val)
				);
				continue;
			}

			if (const ConfigKeySpec* spec = FindConfigKeySpecByCanonical(keyLower)) {
				const std::string validationError = ValidateParsedConfigValueLocked(*spec, parsed->value);
				if (!validationError.empty()) {
					logger::warn(
						"Iron Soul: invalid config value for key '{}' in ironsoul.ini (raw='{}'): {}",
						key,
						EscapeForLog(val),
						validationError
					);
					continue;
				}
			}

			++settingsParsed;

			// Always log each setting + value (INFO)
			if (ShouldEmitInfoLogLocked()) {
				if (!currentSection.empty()) {
					logger::info("Iron Soul: INI [{}] {}={}", currentSection, key, parsed->canonicalText);
				} else {
					logger::info("Iron Soul: INI {}={}", key, parsed->canonicalText);
				}
			}

			// Insert raw key (lowercased)
			{
				auto [it, inserted] = g_ints.emplace(keyLower, parsed->value);
				if (inserted) {
					++insertedRaw;
				} else {
					++dupRaw;
					if (it->second != parsed->value) {
						logger::warn(
							"Iron Soul: duplicate key '{}' overwrote previous value {} -> {}",
							key, it->second, parsed->value
						);
						it->second = parsed->value;
					}
				}
			}

			// Insert section-qualified key (lowercased) if a section exists:
			if (!currentSectionKeyLower.empty()) {
				std::string sectionKey;
				sectionKey.reserve(currentSectionKeyLower.size() + 1 + keyLower.size());
				sectionKey.append(currentSectionKeyLower).append(".").append(keyLower);

				auto [it2, inserted2] = g_ints.emplace(sectionKey, parsed->value);
				if (inserted2) {
					++insertedQualified;
				} else {
					++dupQualified;
					if (it2->second != parsed->value) {
						it2->second = parsed->value;
					}
				}
			}
		}

		RefreshInfoLoggingCacheLocked();
		ResetEffectiveDisplayDifficultyToPresetLocked();

		// Accurate summary
		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: loaded {} int settings from ironsoul.ini", settingsParsed);
			logger::info("Iron Soul: lookup keys inserted: raw={} qualified={} (total map entries={})",
				insertedRaw, insertedQualified, g_ints.size());
		}

		if (dupRaw || dupQualified) {
			logger::warn("Iron Soul: INI duplicates encountered: raw={} qualified={}", dupRaw, dupQualified);
		}

		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: INI path={}", iniPath.string());
		}
	}
}
