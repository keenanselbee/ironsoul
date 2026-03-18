#pragma once

#include <cstdint>
#include <string_view>

namespace IronSoul::Config
{
	// Logging policy:
	// - Before the plugin prints "Iron Soul loaded successfully", INFO logs may be unconditional.
	// - After that point, INFO logs must be emitted only when EnableLogging=1.
	// Use SetInfoGateArmed(true) once startup is complete, then guard INFO logs with ShouldEmitInfoLog().
	void SetInfoGateArmed(bool armed);
	bool ShouldEmitInfoLog();

	// Reads Data/SKSE/Plugins/IronSoul.ini
	void Load();

	// Gets an int value by key. Returns fallback if missing/invalid.
	std::int32_t GetInt(std::string_view key, std::int32_t fallback = 0);

	// Sets an int value in the in-memory config cache.
	// When persistToIni is true, updates an existing key=value line in IronSoul.ini.
	// Returns false when key is invalid, not allowlisted, missing from INI, or write fails.
	bool SetInt(std::string_view key, std::int32_t value, bool persistToIni = true);
}
