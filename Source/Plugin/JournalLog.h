#pragma once

#include <string_view>

namespace IronSoul::JournalLog
{
	// Appends a single line to Data/SKSE/Plugins/IronSoulCharacterJournal.log
	void AppendLine(std::string_view line);
}
