#pragma once

#include <string_view>
#include "REL/Version.h"

namespace Plugin
{
    inline constexpr std::string_view NAME = "Iron Soul";
    // Increment as you iterate. This is your SKSE plugin version, not the mod's.
    inline constexpr REL::Version VERSION{ 0, 1, 1, 0 };
}
