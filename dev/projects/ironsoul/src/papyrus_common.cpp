#include "pch.h"
#include "papyrus_common.h"
#include "config.h"

namespace IronSoul::Papyrus
{
    bool InfoLoggingEnabled()
    {
        return IronSoul::Config::ShouldEmitInfoLog();
    }
    bool DeathSlowMoEnabled()
    {
        return IronSoul::Config::GetInt("SlowMoOnDeath", 1) == 1;
    }
    bool FeatSlowMoEnabled()
    {
        return IronSoul::Config::GetInt("SlowMoOnFeat", 1) == 1;
    }

    std::string Trim(std::string s)
    {
        const auto first = s.find_first_not_of(" \t\n\r");
        if (first == std::string::npos) {
            return {};
        }
        const auto last = s.find_last_not_of(" \t\n\r");
        return s.substr(first, last - first + 1);
    }

    std::string ResolvePlayerName(bool a_fallbackToPrisoner)
    {
        // Player name can be unavailable very early (pre-RaceMenu / early load).
        // For journal logging we may want a stable fallback; for Papyrus callers we often
        // want an empty string so the controller can decide when identity is "ready".
        constexpr const char* kFallback = "Prisoner";
        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player) {
            return a_fallbackToPrisoner ? kFallback : std::string{};
        }

        std::string name = player->GetName();
        name = Trim(name);
        if (name.empty()) {
            return a_fallbackToPrisoner ? kFallback : std::string{};
        }
        return name;
    }
}
