#pragma once

#include <string_view>

namespace IronSoul::Journal
{
	// Appends a single line to Data/SKSE/plugins/ironsoul-character-journal.log
	void AppendLine(std::string_view line);
}
