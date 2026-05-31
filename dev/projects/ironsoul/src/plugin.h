#pragma once

#include <string_view>
#include "REL/Version.h"

namespace Plugin
{
    inline constexpr std::string_view NAME = "Iron Soul";
    // Synced with xmake.lua by tools/build-skse-plugin.ps1 refresh builds.
    inline constexpr REL::Version VERSION{ 1, 8, 9, 0 };
}
