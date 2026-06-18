#include "pch.h"
#include "datastore_internal.h"
#include "config.h"
#include "pathutil.h"

namespace IronSoul::DataStoreInternal
{
    std::filesystem::path MainDataPath()
    {
        return IronSoul::PathUtil::GetIronSoulPluginDir() / L"ironsoul-character-data.dat";
    }

    std::filesystem::path MirrorDataPath()
    {
        return IronSoul::PathUtil::GetIronSoulPluginDir() / L"ironsoul-character-mirror-data.dat";
    }

    bool MirrorDataBackupEnabled()
    {
        return IronSoul::Config::GetAllowedInt("MirrorDataBackup", 1) != 0;
    }

    std::uint32_t fnv1a32(const std::uint8_t* data, std::size_t size)
    {
        std::uint32_t hash = 0x811C9DC5u;
        for (std::size_t i = 0; i < size; ++i) {
            hash ^= data[i];
            hash *= 0x01000193u;
        }
        return hash;
    }
}
