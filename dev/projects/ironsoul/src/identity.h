#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace SKSE
{
    class SerializationInterface;
}

namespace IronSoul::Identity
{
    inline constexpr const char* kCurrentDeathsKey = "IS_8155";
    inline constexpr const char* kLifetimeDeathsKey = "IS_9132";
    inline constexpr const char* kSoulTierKey = "IS_2204";
    inline constexpr const char* kDragonSoulsTotalKey = "IS_9646";
    inline constexpr const char* kWorldDragonSoulsTotalKey = "DS.W";

    inline constexpr std::uint32_t kSnapshotMaskCurrentDeaths = 1u;
    inline constexpr std::uint32_t kSnapshotMaskLifetimeDeaths = 2u;
    inline constexpr std::uint32_t kSnapshotMaskCharacterAnima = 4u;
    inline constexpr std::uint32_t kSnapshotMaskDragonSoulsTotal = 8u;
    inline constexpr std::uint32_t kSnapshotMaskWorldAnima = 16u;
    inline constexpr std::uint32_t kSnapshotMaskSaveHighestUnlockedTier = 32u;
    inline constexpr std::uint32_t kSnapshotMaskWorldDragonSoulsTotal = 64u;
    inline constexpr std::uint32_t kSnapshotMaskSoulTier = 128u;

    bool IsValidGuid(std::string_view a_guid);
    std::string GenerateGuidUnique(std::string_view a_playerName);

    std::string GetCurrentGuid();
    bool SetCurrentGuid(std::string_view a_guid);
    void ClearCurrentGuid();

    void SaveCallback(SKSE::SerializationInterface* a_intfc);
    void LoadCallback(SKSE::SerializationInterface* a_intfc);
    void RevertCallback(SKSE::SerializationInterface* a_intfc);

    std::string GetLoadedSnapshotPayload();
    std::string ApplyLoadedSnapshot(std::string_view a_guid);
}
