#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace IronSoul::BossLatches
{
    std::string PollAnimaBossLatches(
        std::string_view a_guid,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld);
}
