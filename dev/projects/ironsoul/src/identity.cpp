#include "pch.h"
#include "identity.h"

#include "anima.h"
#include "config.h"
#include "datastore.h"

#include <array>
#include <cctype>
#include <format>
#include <random>
#include <sstream>

namespace IronSoul::Identity
{
namespace
{
    constexpr std::uint32_t kCurrentCharacterRecord = 'ISCC';
    constexpr std::uint32_t kCurrentCharacterRecordVersion = 5;
    constexpr std::uint16_t kMaxGuidLength = 7;
    constexpr std::uint32_t kSnapshotKnownMask =
        kSnapshotMaskCurrentDeaths |
        kSnapshotMaskLifetimeDeaths |
        kSnapshotMaskCharacterAnima |
        kSnapshotMaskDragonSoulsTotal |
        kSnapshotMaskWorldAnima |
        kSnapshotMaskSaveHighestUnlockedTier |
        kSnapshotMaskWorldDragonSoulsTotal |
        kSnapshotMaskSoulTier;

    struct CurrentCharacterSnapshot
    {
        std::string guid;
        std::uint32_t mask = 0;
        std::int32_t currentDeaths = 0;
        std::int32_t lifetimeDeaths = 0;
        std::int32_t characterAnima = 0;
        std::int32_t dragonSoulsTotal = 0;
        std::int32_t worldAnima = 0;
        std::int32_t saveHighestUnlockedTier = 0;
        std::int32_t worldDragonSoulsTotal = 0;
        std::int32_t soulTier = 0;
        bool applied = false;
    };

    std::mutex g_identityLock;
    std::string g_currentGuid;
    std::optional<CurrentCharacterSnapshot> g_loadedSnapshot;

    std::string TrimAscii(std::string value)
    {
        const auto first = value.find_first_not_of(" \t\r\n");
        if (first == std::string::npos) {
            return {};
        }

        const auto last = value.find_last_not_of(" \t\r\n");
        return value.substr(first, last - first + 1);
    }

    char FirstGuidLetterFromName(const std::string& a_playerName)
    {
        const std::string name = TrimAscii(a_playerName);
        for (unsigned char c : name) {
            if (std::isalpha(c)) {
                return static_cast<char>(std::toupper(c));
            }
        }
        return 'P';
    }

    bool ReadExact(SKSE::SerializationInterface* a_intfc, void* a_buf, std::uint32_t a_length)
    {
        return a_intfc && a_intfc->ReadRecordData(a_buf, a_length) == a_length;
    }

    template <class T>
    bool ReadExact(SKSE::SerializationInterface* a_intfc, T& a_value)
    {
        return ReadExact(a_intfc, std::addressof(a_value), static_cast<std::uint32_t>(sizeof(T)));
    }

    bool WriteIntIfPresent(CurrentCharacterSnapshot& a_snapshot, std::uint32_t a_mask, const std::string& a_key, std::int32_t& a_outValue)
    {
        if (!DataStore::HasKey(a_key)) {
            return false;
        }

        a_outValue = DataStore::GetInt(a_key, 0);
        a_snapshot.mask |= a_mask;
        return true;
    }

    CurrentCharacterSnapshot BuildSnapshot(std::string_view a_guid)
    {
        CurrentCharacterSnapshot snapshot;
        snapshot.guid = std::string(a_guid);

        WriteIntIfPresent(snapshot, kSnapshotMaskCurrentDeaths, std::format("{}:{}", kCurrentDeathsKey, a_guid), snapshot.currentDeaths);
        WriteIntIfPresent(snapshot, kSnapshotMaskLifetimeDeaths, std::format("{}:{}", kLifetimeDeathsKey, a_guid), snapshot.lifetimeDeaths);
        WriteIntIfPresent(snapshot, kSnapshotMaskCharacterAnima, Anima::MakeCharacterAnimaKey(a_guid), snapshot.characterAnima);
        WriteIntIfPresent(snapshot, kSnapshotMaskDragonSoulsTotal, std::format("{}:{}", kDragonSoulsTotalKey, a_guid), snapshot.dragonSoulsTotal);
        WriteIntIfPresent(snapshot, kSnapshotMaskWorldAnima, Anima::kWorldAnimaKey, snapshot.worldAnima);
        WriteIntIfPresent(snapshot, kSnapshotMaskSaveHighestUnlockedTier, Anima::kSaveHighestUnlockedTierKey, snapshot.saveHighestUnlockedTier);
        WriteIntIfPresent(snapshot, kSnapshotMaskWorldDragonSoulsTotal, kWorldDragonSoulsTotalKey, snapshot.worldDragonSoulsTotal);
        WriteIntIfPresent(snapshot, kSnapshotMaskSoulTier, std::format("{}:{}", kSoulTierKey, a_guid), snapshot.soulTier);

        return snapshot;
    }

    std::string SnapshotPayload(std::string_view a_status, const CurrentCharacterSnapshot& a_snapshot)
    {
        std::ostringstream out;
        out << a_status << '|'
            << a_snapshot.guid << '|'
            << a_snapshot.mask << '|'
            << a_snapshot.currentDeaths << '|'
            << a_snapshot.lifetimeDeaths << '|'
            << a_snapshot.characterAnima << '|'
            << a_snapshot.dragonSoulsTotal << '|'
            << a_snapshot.worldAnima << '|'
            << a_snapshot.saveHighestUnlockedTier << '|'
            << a_snapshot.worldDragonSoulsTotal << '|'
            << a_snapshot.soulTier;
        return out.str();
    }

    std::string SkipPayload(std::string_view a_reason)
    {
        return "skip|" + std::string(a_reason);
    }

    std::string ErrorPayload(std::string_view a_reason)
    {
        return "error|" + std::string(a_reason);
    }

    bool WriteSnapshot(SKSE::SerializationInterface* a_intfc, const CurrentCharacterSnapshot& a_snapshot)
    {
        if (!a_intfc) {
            return false;
        }

        const auto guidLength = static_cast<std::uint16_t>(a_snapshot.guid.size());
        const std::uint16_t reserved = 0;

        if (!a_intfc->OpenRecord(kCurrentCharacterRecord, kCurrentCharacterRecordVersion)) {
            logger::warn("IronSoul Identity: failed to open SKSE serialization record");
            return false;
        }

        if (!a_intfc->WriteRecordData(guidLength) ||
            !a_intfc->WriteRecordData(reserved) ||
            !a_intfc->WriteRecordData(a_snapshot.mask) ||
            !a_intfc->WriteRecordData(a_snapshot.currentDeaths) ||
            !a_intfc->WriteRecordData(a_snapshot.lifetimeDeaths) ||
            !a_intfc->WriteRecordData(a_snapshot.characterAnima) ||
            !a_intfc->WriteRecordData(a_snapshot.dragonSoulsTotal) ||
            !a_intfc->WriteRecordData(a_snapshot.worldAnima) ||
            !a_intfc->WriteRecordData(a_snapshot.saveHighestUnlockedTier) ||
            !a_intfc->WriteRecordData(a_snapshot.worldDragonSoulsTotal) ||
            !a_intfc->WriteRecordData(a_snapshot.soulTier)) {
            logger::warn("IronSoul Identity: failed to write SKSE serialization snapshot header");
            return false;
        }

        if (guidLength > 0 &&
            !a_intfc->WriteRecordData(a_snapshot.guid.data(), guidLength)) {
            logger::warn("IronSoul Identity: failed to write SKSE serialization GUID");
            return false;
        }

        return true;
    }

    bool ReadSnapshot(SKSE::SerializationInterface* a_intfc, std::uint32_t a_length, CurrentCharacterSnapshot& a_snapshot)
    {
        constexpr std::uint32_t fixedBytes =
            sizeof(std::uint16_t) +
            sizeof(std::uint16_t) +
            sizeof(std::uint32_t) +
            sizeof(std::int32_t) * 8u;

        if (a_length < fixedBytes) {
            logger::warn("IronSoul Identity: ignored short SKSE serialization record length={}", a_length);
            return false;
        }

        std::uint16_t guidLength = 0;
        std::uint16_t reserved = 0;
        CurrentCharacterSnapshot snapshot;

        if (!ReadExact(a_intfc, guidLength) ||
            !ReadExact(a_intfc, reserved) ||
            !ReadExact(a_intfc, snapshot.mask) ||
            !ReadExact(a_intfc, snapshot.currentDeaths) ||
            !ReadExact(a_intfc, snapshot.lifetimeDeaths) ||
            !ReadExact(a_intfc, snapshot.characterAnima) ||
            !ReadExact(a_intfc, snapshot.dragonSoulsTotal) ||
            !ReadExact(a_intfc, snapshot.worldAnima) ||
            !ReadExact(a_intfc, snapshot.saveHighestUnlockedTier) ||
            !ReadExact(a_intfc, snapshot.worldDragonSoulsTotal) ||
            !ReadExact(a_intfc, snapshot.soulTier)) {
            logger::warn("IronSoul Identity: failed to read SKSE serialization snapshot header");
            return false;
        }

        if (guidLength == 0 || guidLength > kMaxGuidLength || a_length != fixedBytes + guidLength) {
            logger::warn("IronSoul Identity: ignored invalid SKSE serialization GUID length={}", guidLength);
            return false;
        }

        snapshot.guid.resize(guidLength);
        if (!ReadExact(a_intfc, snapshot.guid.data(), guidLength)) {
            logger::warn("IronSoul Identity: failed to read SKSE serialization GUID");
            return false;
        }

        if (!IsValidGuid(snapshot.guid)) {
            logger::warn("IronSoul Identity: ignored invalid SKSE serialization GUID '{}'", snapshot.guid);
            return false;
        }

        snapshot.mask &= kSnapshotKnownMask;

        a_snapshot = std::move(snapshot);
        return true;
    }

    bool RestoreMissingInt(std::uint32_t a_mask, std::uint32_t a_bit, const std::string& a_key, std::int32_t a_value)
    {
        if ((a_mask & a_bit) == 0) {
            return false;
        }
        if (DataStore::HasKey(a_key)) {
            return false;
        }

        DataStore::SetIntIfChanged(a_key, a_value);
        return true;
    }
}

    bool IsValidGuid(std::string_view a_guid)
    {
        if (a_guid.size() != 5 && a_guid.size() != 7) {
            return false;
        }
        const unsigned char first = static_cast<unsigned char>(a_guid[0]);
        if (!std::isupper(first)) {
            return false;
        }

        for (std::size_t i = 1; i < a_guid.size(); ++i) {
            if (!std::isdigit(static_cast<unsigned char>(a_guid[i]))) {
                return false;
            }
        }
        return true;
    }

    std::string GenerateGuidUnique(std::string_view a_playerName)
    {
        thread_local std::mt19937 rng{ std::random_device{}() };
        std::uniform_int_distribution<std::int32_t> dist(1000, 9999);

        const char prefix = FirstGuidLetterFromName(std::string(a_playerName));

        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = dist(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);

            if (DataStore::SetIntIfAbsent(usedKey, 1)) {
                if (attempt > 1) {
                    logger::warn("IronSoul GUID: collision(s) avoided; claimed '{}' on attempt {}", guid, attempt);
                }
                return guid;
            }
        }

        std::uniform_int_distribution<std::int32_t> distWide(100000, 999999);
        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = distWide(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);
            if (DataStore::SetIntIfAbsent(usedKey, 1)) {
                logger::error("IronSoul GUID: exhausted 4-digit space; claimed widened GUID '{}'", guid);
                return guid;
            }
        }

        logger::critical("IronSoul GUID: failed to claim a unique GUID (unexpected)");
        return {};
    }

    std::string GetCurrentGuid()
    {
        std::lock_guard lock(g_identityLock);
        return g_currentGuid;
    }

    bool SetCurrentGuid(std::string_view a_guid)
    {
        if (!IsValidGuid(a_guid)) {
            logger::warn("IronSoul Identity: rejected invalid current GUID '{}'", a_guid);
            return false;
        }

        std::lock_guard lock(g_identityLock);
        g_currentGuid = std::string(a_guid);
        return true;
    }

    void ClearCurrentGuid()
    {
        std::lock_guard lock(g_identityLock);
        g_currentGuid.clear();
    }

    void SaveCallback(SKSE::SerializationInterface* a_intfc)
    {
        const auto guid = GetCurrentGuid();
        if (guid.empty()) {
            return;
        }

        const CurrentCharacterSnapshot snapshot = BuildSnapshot(guid);
        if (WriteSnapshot(a_intfc, snapshot) && Config::ShouldEmitInfoLog()) {
            logger::info("IronSoul Identity: wrote SKSE current-character snapshot guid={} mask={}", guid, snapshot.mask);
        }
    }

    void LoadCallback(SKSE::SerializationInterface* a_intfc)
    {
        RevertCallback(a_intfc);

        if (!a_intfc) {
            return;
        }

        std::uint32_t type = 0;
        std::uint32_t version = 0;
        std::uint32_t length = 0;
        while (a_intfc->GetNextRecordInfo(type, version, length)) {
            if (type != kCurrentCharacterRecord) {
                continue;
            }

            if (version != kCurrentCharacterRecordVersion) {
                logger::warn("IronSoul Identity: ignored SKSE serialization record version={}", version);
                continue;
            }

            CurrentCharacterSnapshot snapshot;
            if (!ReadSnapshot(a_intfc, length, snapshot)) {
                continue;
            }

            std::lock_guard lock(g_identityLock);
            g_currentGuid = snapshot.guid;
            g_loadedSnapshot = std::move(snapshot);
            if (Config::ShouldEmitInfoLog()) {
                logger::info("IronSoul Identity: loaded SKSE current-character snapshot guid={} mask={}",
                    g_currentGuid,
                    g_loadedSnapshot->mask);
            }
        }
    }

    void RevertCallback(SKSE::SerializationInterface*)
    {
        std::lock_guard lock(g_identityLock);
        g_currentGuid.clear();
        g_loadedSnapshot.reset();
    }

    std::string GetLoadedSnapshotPayload()
    {
        std::lock_guard lock(g_identityLock);
        if (!g_loadedSnapshot) {
            return SkipPayload("none");
        }

        return SnapshotPayload("ok", *g_loadedSnapshot);
    }

    std::string ApplyLoadedSnapshot(std::string_view a_guid)
    {
        if (!IsValidGuid(a_guid)) {
            return ErrorPayload("guid");
        }
        if (!DataStore::IsInitialized()) {
            return SkipPayload("datastore");
        }

        CurrentCharacterSnapshot snapshot;
        {
            std::lock_guard lock(g_identityLock);
            if (!g_loadedSnapshot) {
                return SkipPayload("none");
            }
            if (g_loadedSnapshot->applied) {
                return SkipPayload("applied");
            }
            if (g_loadedSnapshot->guid != a_guid) {
                return SkipPayload("guid");
            }

            snapshot = *g_loadedSnapshot;
            g_loadedSnapshot->applied = true;
        }

        RestoreMissingInt(snapshot.mask, kSnapshotMaskCurrentDeaths, std::format("{}:{}", kCurrentDeathsKey, snapshot.guid), snapshot.currentDeaths);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskLifetimeDeaths, std::format("{}:{}", kLifetimeDeathsKey, snapshot.guid), snapshot.lifetimeDeaths);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskCharacterAnima, Anima::MakeCharacterAnimaKey(snapshot.guid), snapshot.characterAnima);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskDragonSoulsTotal, std::format("{}:{}", kDragonSoulsTotalKey, snapshot.guid), snapshot.dragonSoulsTotal);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskWorldAnima, Anima::kWorldAnimaKey, snapshot.worldAnima);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskSaveHighestUnlockedTier, Anima::kSaveHighestUnlockedTierKey, snapshot.saveHighestUnlockedTier);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskWorldDragonSoulsTotal, kWorldDragonSoulsTotalKey, snapshot.worldDragonSoulsTotal);
        RestoreMissingInt(snapshot.mask, kSnapshotMaskSoulTier, std::format("{}:{}", kSoulTierKey, snapshot.guid), snapshot.soulTier);

        return SnapshotPayload("ok", snapshot);
    }
}
