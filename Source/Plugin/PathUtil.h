#pragma once
#include <filesystem>

namespace IronSoul::PathUtil
{
    std::filesystem::path GetGameRoot();
    std::filesystem::path GetDataRoot();
    std::filesystem::path GetSksePluginsDir();
}
