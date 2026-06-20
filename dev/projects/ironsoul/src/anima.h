#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace IronSoul::Anima
{
    inline constexpr const char* kCharacterAnimaKey = "AN.C";
    inline constexpr const char* kWorldAnimaKey = "AN.W";
    inline constexpr const char* kSaveHighestUnlockedTierKey = "ST.W";

    std::string MakeCharacterAnimaKey(std::string_view a_guid);

    std::int32_t GetCharacter(std::string_view a_guid);
    std::int32_t GetWorld();
    std::int32_t GetSaveHighestUnlockedTier();
    std::int32_t GetEligibleMilestone(std::string_view a_guid, std::int32_t a_characterDragonSouls, std::int32_t a_currentDeaths);
    std::int32_t GetRequiredForMilestone(std::int32_t a_milestone);

    std::string AddCharacter(
        std::string_view a_guid,
        std::int32_t a_amount,
        std::string_view a_source,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld);
    std::string SetCharacter(
        std::string_view a_guid,
        std::int32_t a_value,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths);
    std::string SetWorld(std::int32_t a_value);
    std::string SetSaveHighestUnlockedTier(std::int32_t a_tier);
}
