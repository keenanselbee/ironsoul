#include "pch.h"
#include "Config.h"
#include "PathUtil.h"
#include <atomic>
#include <unordered_set>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul::Config
{
	static std::mutex g_mutex;
	static std::atomic_bool g_infoGateArmed{ false };
	static std::atomic_bool g_enableInfoLoggingCached{ false };

	// Store case-insensitive keys (lowercased). Values are int32.
	static std::unordered_map<std::string, std::int32_t> g_ints;

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

	static fs::path GetIniPath()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"IronSoul.ini";
	}

	static void EnsureDirExists(const fs::path& a_path)
	{
		std::error_code ec;
		fs::create_directories(a_path.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul: could not create ini directory: {}", a_path.parent_path().string());
		}
	}

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

	static const std::unordered_set<std::string>& AllowedConfigKeys()
	{
		static const std::unordered_set<std::string> kAllowed = {
			"enablelogging",
			"loglevel",
			"enablelognotifications",
			"deathmessage",
			"dragonsoulrevive",
			"dragonsoulrevivemessage",
			"dragonsoulrevivelimit",
			"dynamicsplash",
			"dynamiclevelwidget",
			"characterjournallog",
			"ironsoulintro",
			"lucksystem",
			"luckcooldownremindernotification",
			"sfx",
			"musicfade",
			"musicvolumeoverride",
			"cursorhide",
			"slowmoondeath",
			"slowmosfx",
			"ironintrosfx",
			"deathsfx",
			"permadeathsfx",
			"respawnsfx",
			"defianttransitionsfx",
			"defiantresetsfx",
			"deathspurgedsfx",
			"dragonsoulrevivecastsfx",
			"dragonsoulrevivesfx",
			"featunlocksfx",
			"luckrollsfx",
			"luckoutcomesfx",
			"respawnheavybreathingsfx",
			"respawn",
			"respawnmessage",
			"loadnotificationmode",
			"luckrollmessagemode",
			"uninstallmode",
			"deathreset",
			"defiantsoul",
			"soulfeats",
			"soulbonus",
			"soulfatigue",
			"dragonsoulanticheat",
			"dragonsoulincreasenotification",
			"ironsoulpreset",
			"chim",
			"enabledebug",
			"enablecharactersheetcompatibility"
		};
		return kAllowed;
	}

	static std::optional<std::string> CanonicalizeAllowedKey(std::string_view key)
	{
		std::string keyLower = ToLowerCopy(key);
		TrimInPlace(keyLower);
		if (!IsValidConfigKey(keyLower)) {
			return std::nullopt;
		}

		const auto& allowed = AllowedConfigKeys();
		if (allowed.find(keyLower) != allowed.end()) {
			return keyLower;
		}

		// Permit "section.key" forms by canonicalizing to "key".
		const std::size_t dot = keyLower.rfind('.');
		if (dot != std::string::npos && dot + 1 < keyLower.size()) {
			std::string shortKey = keyLower.substr(dot + 1);
			if (allowed.find(shortKey) != allowed.end()) {
				return shortKey;
			}
		}

		return std::nullopt;
	}

	int GetAllowedInt(std::string_view key, int defaultValue)
	{
		std::lock_guard lock(g_mutex);

		const auto canonicalKey = CanonicalizeAllowedKey(key);
		if (!canonicalKey.has_value()) {
			return defaultValue;
		}

		auto it = g_ints.find(*canonicalKey);
		if (it == g_ints.end()) {
			return defaultValue;
		}

		return static_cast<int>(it->second);
	}

	static bool ReplaceIniIntForExistingKey(const fs::path& iniPath, const std::string& targetKeyLower, std::int32_t value)
	{
		std::ifstream in(iniPath, std::ios::in);
		if (!in.is_open()) {
			logger::error("Iron Soul: SetInt could not open INI for read: {}", iniPath.string());
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

							std::string newLine = line.substr(0, start) + keyPart + "=" + std::to_string(value);
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
			logger::error("Iron Soul: SetInt encountered read error for {}", iniPath.string());
			return false;
		}

		if (!anyMatched) {
			logger::warn("Iron Soul: SetInt rejected key '{}' because no existing INI entry was found", targetKeyLower);
			return false;
		}

		const fs::path tmpPath = iniPath.wstring() + L".tmp";
		std::ofstream out(tmpPath, std::ios::out | std::ios::trunc);
		if (!out.is_open()) {
			logger::error("Iron Soul: SetInt could not open temp INI for write: {}", tmpPath.string());
			return false;
		}

		// Text-mode streams translate '\n' to the platform newline sequence.
		// Writing "\r\n" explicitly here can produce doubled breaks on Windows.
		for (const auto& ln : lines) {
			out << ln << '\n';
		}
		if (!out.good()) {
			logger::error("Iron Soul: SetInt failed while writing temp INI: {}", tmpPath.string());
			return false;
		}
		out.close();

		std::error_code ec;
		fs::rename(tmpPath, iniPath, ec);
		if (ec) {
			ec.clear();
			fs::copy_file(tmpPath, iniPath, fs::copy_options::overwrite_existing, ec);
			if (ec) {
				logger::error("Iron Soul: SetInt failed replacing INI '{}' (ec={})", iniPath.string(), ec.value());
				ec.clear();
				fs::remove(tmpPath, ec);
				return false;
			}
			ec.clear();
			fs::remove(tmpPath, ec);
		}

		return true;
	}

	bool SetInt(std::string_view key, std::int32_t value, bool persistToIni)
	{
		std::lock_guard lock(g_mutex);

		std::string keyText(key);
		TrimInPlace(keyText);
		if (!IsValidConfigKey(keyText)) {
			logger::warn("Iron Soul: SetInt rejected invalid config key '{}'", EscapeForLog(keyText));
			return false;
		}

		auto canonicalKey = CanonicalizeAllowedKey(keyText);
		if (!canonicalKey.has_value()) {
			logger::warn("Iron Soul: SetInt rejected non-allowlisted config key '{}'", EscapeForLog(keyText));
			return false;
		}

		const std::string keyLower = *canonicalKey;

		if (!persistToIni) {
			g_ints[keyLower] = value;
			for (auto& [k, v] : g_ints) {
				if (k.size() > keyLower.size() + 1 &&
					k.compare(k.size() - keyLower.size(), keyLower.size(), keyLower) == 0 &&
					k[k.size() - keyLower.size() - 1] == '.') {
					v = value;
				}
			}
			RefreshInfoLoggingCacheLocked();
			return true;
		}

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		if (!ReplaceIniIntForExistingKey(iniPath, keyLower, value)) {
			return false;
		}

		g_ints[keyLower] = value;
		for (auto& [k, v] : g_ints) {
			if (k.size() > keyLower.size() + 1 &&
				k.compare(k.size() - keyLower.size(), keyLower.size(), keyLower) == 0 &&
				k[k.size() - keyLower.size() - 1] == '.') {
				v = value;
			}
		}
		RefreshInfoLoggingCacheLocked();

		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: INI key updated {}={} ({})", keyLower, value, iniPath.string());
		}
		return true;
	}

	void Load()
	{
		std::lock_guard lock(g_mutex);
		g_ints.clear();
		RefreshInfoLoggingCacheLocked();

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		std::ifstream in(iniPath, std::ios::in);
		if (!in.is_open()) {
			logger::warn("Iron Soul: IronSoul.ini not found at {} (using defaults/fallbacks)", iniPath.string());
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

			auto parsed = ParseIntStrict(val);
			if (!parsed.has_value()) {
				logger::warn(
					"Iron Soul: invalid int for key '{}' in IronSoul.ini (raw='{}')",
					key,
					EscapeForLog(val)
				);
				continue;
			}

			++settingsParsed;

			// Always log each setting + value (INFO)
			if (ShouldEmitInfoLogLocked()) {
				if (!currentSection.empty()) {
					logger::info("Iron Soul: INI [{}] {}={}", currentSection, key, *parsed);
				} else {
					logger::info("Iron Soul: INI {}={}", key, *parsed);
				}
			}

			// Insert raw key (lowercased)
			{
				auto [it, inserted] = g_ints.emplace(keyLower, *parsed);
				if (inserted) {
					++insertedRaw;
				} else {
					++dupRaw;
					if (it->second != *parsed) {
						logger::warn(
							"Iron Soul: duplicate key '{}' overwrote previous value {} -> {}",
							key, it->second, *parsed
						);
						it->second = *parsed;
					}
				}
			}

			// Insert section-qualified key (lowercased) if a section exists:
			if (!currentSectionKeyLower.empty()) {
				std::string sectionKey;
				sectionKey.reserve(currentSectionKeyLower.size() + 1 + keyLower.size());
				sectionKey.append(currentSectionKeyLower).append(".").append(keyLower);

				auto [it2, inserted2] = g_ints.emplace(sectionKey, *parsed);
				if (inserted2) {
					++insertedQualified;
				} else {
					++dupQualified;
					if (it2->second != *parsed) {
						it2->second = *parsed;
					}
				}
			}
		}

		RefreshInfoLoggingCacheLocked();

		// Accurate summary
		if (ShouldEmitInfoLogLocked()) {
			logger::info("Iron Soul: loaded {} int settings from IronSoul.ini", settingsParsed);
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
