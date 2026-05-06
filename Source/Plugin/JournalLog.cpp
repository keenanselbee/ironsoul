#include "pch.h"

#include "JournalLog.h"
#include "PathUtil.h"

namespace fs = std::filesystem;

namespace IronSoul::JournalLog
{
	static std::mutex g_mutex;

	static fs::path GetLogPath()
	{
		return IronSoul::PathUtil::GetSksePluginsDir() / L"IronSoulCharacterJournal.log";
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
