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

	// Reads Data/SKSE/plugins/ironsoul.ini
	void Load();

	// Gets an int value by key. Returns fallback if missing/invalid.
	std::int32_t GetInt(std::string_view key, std::int32_t fallback = 0);

	// Gets an allowlisted config-facing int value by key. Returns fallback for
	// invalid, non-allowlisted, or missing keys.
	std::int32_t GetAllowedInt(std::string_view key, std::int32_t fallback = 0);

	// Returns 1 when IronSoulPreset was configured with a plus suffix, otherwise 0.
	std::int32_t GetIronSoulPresetPlus();

	// Sets an int value in the in-memory config cache.
	// When persistToIni is true, updates an existing key=value line in ironsoul.ini.
	// Returns false when key is invalid, not allowlisted, missing from INI, or write fails.
	bool SetInt(std::string_view key, std::int32_t value, bool persistToIni = true);

	// Sets a config value from text. IronSoulPreset accepts values like "3+".
	bool SetString(std::string_view key, std::string_view value, bool persistToIni = true);
}
