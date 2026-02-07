#include "pch.h"

#include "JournalLog.h"

namespace fs = std::filesystem;

namespace IronSoul::JournalLog
{
	static std::mutex g_mutex;

	static fs::path GetGameRoot()
	{
		wchar_t buf[MAX_PATH]{};
		DWORD len = GetModuleFileNameW(nullptr, buf, MAX_PATH);
		if (len == 0 || len >= MAX_PATH) {
			util::report_and_fail("Iron Soul: GetModuleFileNameW failed (JournalLog)");
		}
		fs::path exePath{ buf };
		return exePath.parent_path();
	}

	static fs::path GetLogPath()
	{
		return GetGameRoot() / L"Data" / L"SKSE" / L"Plugins" / L"IronSoulCharacterJournal.log";
	}

	void AppendLine(std::string_view line)
	{
		std::lock_guard lock(g_mutex);

		const fs::path logPath = GetLogPath();
		std::error_code ec;
		fs::create_directories(logPath.parent_path(), ec);
		if (ec) {
			logger::warn("Iron Soul: could not create log directory: {}", logPath.parent_path().string());
			return;
		}

		std::ofstream out(logPath, std::ios::out | std::ios::app);
		if (!out.is_open()) {
			logger::warn("Iron Soul: could not open IronSoulCharacterJournal.log for append: {}", logPath.string());
			return;
		}

		out.write(line.data(), static_cast<std::streamsize>(line.size()));
		out.put('\n');
		out.flush();
	}
}
