#pragma once

#include <string_view>

namespace IronSoul::JournalBook
{
	bool RecordEvent(std::string_view a_guid, std::string_view a_dayLine, std::string_view a_summary);
	bool RefreshBook(std::string_view a_currentGuid);
	bool DynamicBookRefreshOghma(std::string_view a_currentGuid);
	bool DeleteCharacter(std::string_view a_guid);
}
