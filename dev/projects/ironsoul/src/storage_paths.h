#pragma once

#include <filesystem>

namespace IronSoul::StoragePaths
{
    std::filesystem::path GetCharacterDataRoot();
    std::filesystem::path MainDataPath();
    std::filesystem::path MirrorDataPath();
}
