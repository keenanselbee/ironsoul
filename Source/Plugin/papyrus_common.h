#pragma once
#include <string>

namespace IronSoul::Papyrus
{
    inline constexpr const char* kScriptName = "IronSoulNative";

    bool InfoLoggingEnabled();
    bool DeathSlowMoEnabled();
    std::string Trim(std::string a_value);
    std::string ResolvePlayerName(bool a_fallbackToPrisoner);
}