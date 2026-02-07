#include "pch.h"

#include "Config.h"

namespace fs = std::filesystem;

namespace IronSoul::Config
{
	static std::mutex g_mutex;
	static std::unordered_map<std::string, std::int32_t> g_ints;

	static fs::path GetGameRoot()
	{
		wchar_t buf[MAX_PATH]{};
		DWORD len = GetModuleFileNameW(nullptr, buf, MAX_PATH);
		if (len == 0 || len >= MAX_PATH) {
			util::report_and_fail("Iron Soul: GetModuleFileNameW failed (Config)");
		}
		fs::path exePath{ buf };
		return exePath.parent_path();
	}

	static fs::path GetPluginDir()
	{
		return GetGameRoot() / L"Data" / L"SKSE" / L"Plugins";
	}

	static fs::path GetIniPath()
	{
		return GetPluginDir() / L"IronSoul.ini";
	}

	static void EnsureDirExists(const fs::path& a_path)
	{
		std::error_code ec;
		fs::create_directories(a_path.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul: could not create ini directory: {}", a_path.parent_path().string());
		}
	}

	static std::optional<std::int32_t> ParseInt(std::string_view s)
	{
		// Trim whitespace
		auto l = s.find_first_not_of(" \t\r\n");
		if (l == std::string_view::npos)
			return std::nullopt;
		auto r = s.find_last_not_of(" \t\r\n");
		s = s.substr(l, r - l + 1);

		try {
			std::string tmp(s);
			size_t idx = 0;
			long long v = std::stoll(tmp, &idx, 10);
			if (idx != tmp.size())
				return std::nullopt;
			if (v < INT32_MIN || v > INT32_MAX)
				return std::nullopt;
			return static_cast<std::int32_t>(v);
		} catch (...) {
			return std::nullopt;
		}
	}

	void Load()
	{
		std::lock_guard lock(g_mutex);
		g_ints.clear();

		const fs::path iniPath = GetIniPath();
		EnsureDirExists(iniPath);

		std::ifstream in(iniPath);
		if (!in.is_open()) {
			logger::warn("Iron Soul: IronSoul.ini not found at {} (using defaults/fallbacks)", iniPath.string());
			return;
		}

		std::string line;
		std::string currentSection;
		while (std::getline(in, line)) {
			// Strip BOM if present on first line
			if (!line.empty() && static_cast<unsigned char>(line[0]) == 0xEF) {
				// naive BOM strip for UTF-8 BOM
				if (line.size() >= 3 && static_cast<unsigned char>(line[1]) == 0xBB && static_cast<unsigned char>(line[2]) == 0xBF) {
					line.erase(0, 3);
				}
			}

			// Trim left
			auto start = line.find_first_not_of(" \t\r\n");
			if (start == std::string::npos)
				continue;

			// Comment lines (; or #)
			if (line[start] == ';' || line[start] == '#')
				continue;

			// Section [Name] (ignored, but accepted)
			if (line[start] == '[') {
				auto end = line.find(']', start + 1);
				if (end != std::string::npos) {
					currentSection = line.substr(start + 1, end - (start + 1));
				}
				continue;
			}

			// key=value
			auto eq = line.find('=', start);
			if (eq == std::string::npos)
				continue;

			std::string key = line.substr(start, eq - start);
			std::string val = line.substr(eq + 1);

// Strip inline comments (';' or '#') before parsing numbers
{
	std::size_t cut = val.size();

	std::size_t sc = val.find(';');
	if (sc != std::string::npos && sc < cut) {
		cut = sc;
	}

	std::size_t hc = val.find('#');
	if (hc != std::string::npos && hc < cut) {
		cut = hc;
	}

	val = val.substr(0, cut);

	// Trim val right
	while (!val.empty() && (val.back() == ' ' || val.back() == '\t' || val.back() == '\r' || val.back() == '\n'))
		val.pop_back();
}


			// Trim key right
			while (!key.empty() && (key.back() == ' ' || key.back() == '\t' || key.back() == '\r' || key.back() == '\n'))
				key.pop_back();

			// Ignore empty keys
			if (key.empty())
				continue;

			// Optional: allow section.key keys later if you want
			// For now, keep raw keys exactly as Papyrus will request.

			auto parsed = ParseInt(val);
			if (parsed.has_value()) {
				g_ints[key] = *parsed;
			} else {
				logger::warn("Iron Soul: invalid int for key '{}' in IronSoul.ini", key);
			}
		}

		logger::info("Iron Soul: loaded {} int config entries from IronSoul.ini", g_ints.size());
	}

	std::int32_t GetInt(std::string_view key, std::int32_t fallback)
	{
		std::lock_guard lock(g_mutex);
		auto it = g_ints.find(std::string(key));
		if (it == g_ints.end()) {
			return fallback;
		}
		return it->second;
	}
}
