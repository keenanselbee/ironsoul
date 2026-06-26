#pragma once

#include <string_view>

namespace IronSoul::DynamicBook
{
	void RegisterSinks();
	void RegisterLifecycleHooks();
	bool RefreshOpen(std::string_view a_bookId);
}
