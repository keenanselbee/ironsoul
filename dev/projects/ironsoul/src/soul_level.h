#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace IronSoul::SoulLevel
{
    inline constexpr std::int32_t kMinimumLevel = 1;
    inline constexpr std::int32_t kMaximumLevel = 5;

    std::string MakeWorldSlainKey(std::int32_t a_level);
    std::string MakeCharacterSlainKey(std::string_view a_guid, std::int32_t a_level);

    std::int32_t GetWorldSlain(std::int32_t a_level);
    std::int32_t GetCharacterSlain(std::string_view a_guid, std::int32_t a_level);
    bool NoteSlain(std::string_view a_guid, std::int32_t a_level, bool a_updateWorld);
}
