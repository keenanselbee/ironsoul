#include "pch.h"

#include "text_catalog.h"
#include "config.h"
#include "pathutil.h"

#include <cctype>
#include <cstdio>
#include <unordered_map>
#include <unordered_set>

namespace fs = std::filesystem;

namespace IronSoul::Text
{
namespace
{
	std::mutex g_mutex;
	std::unordered_map<std::string, std::string> g_strings;
	std::unordered_set<std::string> g_missingKeysWarned;

	static inline void TrimInPlace(std::string& a_value)
	{
		const char* ws = " \t\r\n";
		const auto start = a_value.find_first_not_of(ws);
		if (start == std::string::npos) {
			a_value.clear();
			return;
		}

		const auto end = a_value.find_last_not_of(ws);
		a_value = a_value.substr(start, end - start + 1);
	}

	static inline std::string ToLowerCopy(std::string_view a_value)
	{
		std::string out;
		out.reserve(a_value.size());
		for (unsigned char c : a_value) {
			out.push_back(static_cast<char>(std::tolower(c)));
		}
		return out;
	}

	static inline void StripUtf8BomIfPresent(std::string& a_line)
	{
		if (a_line.size() >= 3 &&
			static_cast<unsigned char>(a_line[0]) == 0xEF &&
			static_cast<unsigned char>(a_line[1]) == 0xBB &&
			static_cast<unsigned char>(a_line[2]) == 0xBF) {
			a_line.erase(0, 3);
		}
	}

	static inline void StripInlineCommentRespectQuotes(std::string& a_value)
	{
		bool inQuote = false;
		char quoteChar = 0;

		for (std::size_t i = 0; i < a_value.size(); ++i) {
			const char c = a_value[i];

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
				a_value.resize(i);
				break;
			}
		}

		TrimInPlace(a_value);
	}

	static inline void UnquoteIfWrapped(std::string& a_value)
	{
		TrimInPlace(a_value);
		if (a_value.size() >= 2) {
			const char first = a_value.front();
			const char last = a_value.back();
			if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
				a_value = a_value.substr(1, a_value.size() - 2);
			}
		}
	}

	static inline void DecodeEscapes(std::string& a_value)
	{
		std::string out;
		out.reserve(a_value.size());

		for (std::size_t i = 0; i < a_value.size(); ++i) {
			const char c = a_value[i];
			if (c != '\\' || i + 1 >= a_value.size()) {
				out.push_back(c);
				continue;
			}

			const char next = a_value[++i];
			if (next == 'n') {
				out.push_back('\n');
			} else if (next == 'r') {
				out.push_back('\r');
			} else if (next == 't') {
				out.push_back('\t');
			} else if (next == '\\') {
				out.push_back('\\');
			} else {
				out.push_back('\\');
				out.push_back(next);
			}
		}

		a_value = std::move(out);
	}

	static inline std::string EscapeForLog(std::string_view a_value)
	{
		std::string out;
		out.reserve(a_value.size() + 16);
		for (unsigned char c : a_value) {
			if (c == '\\') {
				out += "\\\\";
			} else if (c == '\n') {
				out += "\\n";
			} else if (c == '\r') {
				out += "\\r";
			} else if (c == '\t') {
				out += "\\t";
			} else if (c >= 32 && c < 127) {
				out.push_back(static_cast<char>(c));
			} else {
				char buf[8];
				std::snprintf(buf, sizeof(buf), "\\x%02X", c);
				out += buf;
			}
		}
		return out;
	}

	struct CatalogLanguage
	{
		const char* displayName;
		const char* code;
	};

	struct CatalogLoadStats
	{
		std::size_t parsed = 0;
		std::size_t duplicates = 0;
		std::size_t overrides = 0;
	};

	static constexpr CatalogLanguage kCatalogLanguages[] = {
		{ "English", "en" },
		{ "French", "fr" },
		{ "German", "de" },
		{ "Italian", "it" },
		{ "Spanish", "es" },
		{ "Polish", "pl" },
		{ "Russian", "ru" },
		{ "Japanese", "ja" },
		{ "Chinese", "zh" },
	};

	static fs::path GetTextDir()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"ironsoul" / L"text";
	}

	static fs::path GetTextPath(std::string_view a_code)
	{
		return GetTextDir() / (std::string(a_code) + ".ini");
	}

	static void EnsureTextDirExists(const fs::path& a_dir)
	{
		std::error_code ec;
		fs::create_directories(a_dir, ec);
		if (ec) {
			logger::warn("Iron Soul: could not create text catalog directory: {}", a_dir.string());
		}
	}

	static std::string NormalizeLookupKey(std::string_view a_key)
	{
		std::string key = ToLowerCopy(a_key);
		TrimInPlace(key);
		return key;
	}

	static std::string MissingTextMarker(std::string_view a_key)
	{
		std::string displayKey(a_key);
		TrimInPlace(displayKey);
		if (displayKey.empty()) {
			displayKey = "<empty>";
		}
		return "[IronSoul missing text: " + displayKey + "]";
	}

	static std::string CompactLanguageToken(std::string_view a_value)
	{
		std::string text(a_value);
		TrimInPlace(text);
		UnquoteIfWrapped(text);
		text = ToLowerCopy(text);

		std::string out;
		out.reserve(text.size());
		for (unsigned char c : text) {
			if (std::isalnum(c)) {
				out.push_back(static_cast<char>(c));
			}
		}
		return out;
	}

	static const CatalogLanguage* FindCatalogLanguage(std::string_view a_value)
	{
		const std::string token = CompactLanguageToken(a_value);
		if (token == "en" || token == "english") {
			return &kCatalogLanguages[0];
		}
		if (token == "fr" || token == "french" || token == "francais") {
			return &kCatalogLanguages[1];
		}
		if (token == "de" || token == "ger" || token == "german" || token == "deutsch") {
			return &kCatalogLanguages[2];
		}
		if (token == "it" || token == "ita" || token == "italian" || token == "italiano") {
			return &kCatalogLanguages[3];
		}
		if (token == "es" || token == "spa" || token == "spanish" || token == "spanishspain") {
			return &kCatalogLanguages[4];
		}
		if (token == "pl" || token == "pol" || token == "polish" || token == "polski") {
			return &kCatalogLanguages[5];
		}
		if (token == "ru" || token == "rus" || token == "russian") {
			return &kCatalogLanguages[6];
		}
		if (token == "ja" || token == "jp" || token == "jpn" || token == "japanese") {
			return &kCatalogLanguages[7];
		}
		if (token == "zh" || token == "chi" || token == "zho" || token == "chinese" ||
			token == "tchinese" || token == "schinese" || token == "traditionalchinese" ||
			token == "simplifiedchinese") {
			return &kCatalogLanguages[8];
		}
		return nullptr;
	}

	static bool IsAutoLanguage(std::string_view a_value)
	{
		return CompactLanguageToken(a_value) == "auto";
	}

	static std::string ReadSkyrimLanguageSetting()
	{
		auto* iniSettings = RE::INISettingCollection::GetSingleton();
		auto* setting = iniSettings ? iniSettings->GetSetting("sLanguage:General") : nullptr;
		if (!setting || setting->GetType() != RE::Setting::Type::kString || !setting->data.s) {
			return "";
		}
		return setting->data.s;
	}

	static void ReplaceAll(std::string& a_text, std::string_view a_token, std::string_view a_value)
	{
		if (a_token.empty()) {
			return;
		}

		std::string marker;
		marker.reserve(a_token.size() + 2);
		marker.push_back('{');
		marker.append(a_token);
		marker.push_back('}');

		std::size_t pos = 0;
		while ((pos = a_text.find(marker, pos)) != std::string::npos) {
			a_text.replace(pos, marker.size(), a_value);
			pos += a_value.size();
		}
	}

	static bool LoadCatalogFile(
		const fs::path& a_textPath,
		std::string_view a_label,
		bool a_overlay,
		CatalogLoadStats& a_stats)
	{
		std::ifstream in(a_textPath, std::ios::in);
		if (!in.is_open()) {
			logger::warn("Iron Soul: text catalog {} not found at {}", a_label, a_textPath.string());
			return false;
		}

		std::string currentSection;
		std::string line;
		bool firstLine = true;
		std::unordered_set<std::string> fileKeys;

		while (std::getline(in, line)) {
			if (firstLine) {
				StripUtf8BomIfPresent(line);
				firstLine = false;
			}

			auto start = line.find_first_not_of(" \t\r\n");
			if (start == std::string::npos) {
				continue;
			}
			if (line[start] == ';' || line[start] == '#') {
				continue;
			}

			if (line[start] == '[') {
				const auto end = line.find(']', start + 1);
				if (end != std::string::npos) {
					currentSection = line.substr(start + 1, end - (start + 1));
					TrimInPlace(currentSection);
					currentSection = ToLowerCopy(currentSection);
				}
				continue;
			}

			const auto eq = line.find('=', start);
			if (eq == std::string::npos) {
				continue;
			}

			std::string key = line.substr(start, eq - start);
			std::string value = line.substr(eq + 1);

			TrimInPlace(key);
			TrimInPlace(value);
			if (key.empty()) {
				continue;
			}

			StripInlineCommentRespectQuotes(value);
			UnquoteIfWrapped(value);
			DecodeEscapes(value);

			std::string lookupKey = ToLowerCopy(key);
			TrimInPlace(lookupKey);
			if (!currentSection.empty()) {
				lookupKey = currentSection + "." + lookupKey;
			}

			const bool firstInFile = fileKeys.emplace(lookupKey).second;
			auto [it, inserted] = g_strings.emplace(lookupKey, value);
			if (!inserted) {
				if (a_overlay && firstInFile) {
					++a_stats.overrides;
				} else {
					++a_stats.duplicates;
					logger::warn(
						"Iron Soul: duplicate text catalog key '{}' in {} overwrote '{}' -> '{}'",
						lookupKey,
						a_label,
						EscapeForLog(it->second),
						EscapeForLog(value));
				}
				it->second = std::move(value);
			}
			++a_stats.parsed;
		}

		logger::info("Iron Soul: loaded {} text catalog strings from {}", a_stats.parsed, a_textPath.string());
		return true;
	}
}

	void Load()
	{
		const std::string configuredLanguage = IronSoul::Config::GetLanguage();
		const CatalogLanguage* selectedLanguage = FindCatalogLanguage(configuredLanguage);
		std::string skyrimLanguage;

		if (IsAutoLanguage(configuredLanguage)) {
			skyrimLanguage = ReadSkyrimLanguageSetting();
			selectedLanguage = FindCatalogLanguage(skyrimLanguage);
			if (!selectedLanguage) {
				selectedLanguage = &kCatalogLanguages[0];
				logger::warn(
					"Iron Soul: Skyrim language '{}' is unsupported or unavailable; using English text catalog",
					EscapeForLog(skyrimLanguage));
			}
		} else if (!selectedLanguage) {
			selectedLanguage = &kCatalogLanguages[0];
			logger::warn(
				"Iron Soul: configured language '{}' is unsupported; using English text catalog",
				EscapeForLog(configuredLanguage));
		}

		std::lock_guard lock(g_mutex);
		g_strings.clear();
		g_missingKeysWarned.clear();

		const fs::path textDir = GetTextDir();
		EnsureTextDirExists(textDir);

		CatalogLoadStats baselineStats;
		const fs::path englishPath = GetTextPath("en");
		LoadCatalogFile(englishPath, "English", false, baselineStats);

		CatalogLoadStats overlayStats;
		if (std::string_view(selectedLanguage->code) != "en") {
			const fs::path overlayPath = GetTextPath(selectedLanguage->code);
			LoadCatalogFile(overlayPath, selectedLanguage->displayName, true, overlayStats);
		}

		if (IsAutoLanguage(configuredLanguage)) {
			logger::info(
				"Iron Soul: text catalog language Auto resolved to {} (sLanguage='{}')",
				selectedLanguage->displayName,
				EscapeForLog(skyrimLanguage));
		} else {
			logger::info("Iron Soul: text catalog language configured as {}", selectedLanguage->displayName);
		}

		if (baselineStats.duplicates > 0 || overlayStats.duplicates > 0) {
			logger::warn(
				"Iron Soul: text catalog duplicates encountered: baseline={} overlay={}",
				baselineStats.duplicates,
				overlayStats.duplicates);
		}
		if (overlayStats.overrides > 0) {
			logger::info("Iron Soul: text catalog overlay overrides applied: {}", overlayStats.overrides);
		}
	}

	std::string Get(std::string_view a_key)
	{
		const std::string key = NormalizeLookupKey(a_key);

		std::lock_guard lock(g_mutex);
		const auto it = g_strings.find(key);
		if (it == g_strings.end()) {
			if (g_missingKeysWarned.emplace(key).second) {
				logger::warn("Iron Soul: missing text catalog key '{}'", EscapeForLog(a_key));
			}
			return MissingTextMarker(a_key);
		}
		return it->second;
	}

	std::string Format(
		std::string_view a_key,
		std::initializer_list<Replacement> a_replacements)
	{
		std::string text = Get(a_key);
		for (const auto& [token, value] : a_replacements) {
			ReplaceAll(text, token, value);
		}
		return text;
	}
}
