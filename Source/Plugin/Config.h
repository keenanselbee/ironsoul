#pragma once

#include <cstdint>
#include <string_view>

namespace IronSoul::Config
{
	// Reads Data/SKSE/Plugins/IronSoul.ini
	void Load();

	// Gets an int value by key. Returns fallback if missing/invalid.
	std::int32_t GetInt(std::string_view key, std::int32_t fallback = 0);
}
