#include "pch.h"
#include "datastore.h"
#include "config.h"
#include "pathutil.h"
#include <algorithm>
#include <cctype>
#include <cstring>
#include <cstdio>
#include <limits>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul
{
    // --- Paths and Constants ---
    // ===========================

    static std::filesystem::path MainDataPath()
    {
        return IronSoul::PathUtil::GetSksePluginsDir() / L"ironsoul" / L"characterdata.dat";
    }

    static std::filesystem::path MirrorDataPath()
    {
        return IronSoul::PathUtil::GetSksePluginsDir() / L"StorageUtilData" / L"PapyrusUtil" / L"Runtime" / L"MD_5729.dat";
    }

    static bool MirrorDataBackupEnabled()
    {
        return IronSoul::Config::GetAllowedInt("MirrorDataBackup", 1) != 0;
    }

    static constexpr std::uint32_t FILE_VERSION = 2;
    static constexpr char MAGIC[4] = { 'I', 'S', 'D', 'T' };

    // Hardening caps (v2): keep loads/writes safe even if files are corrupted/tampered.
    // Iron Soul stores a small KV set; these limits are intentionally generous.
    static constexpr std::size_t MAX_PAYLOAD_BYTES = 1u * 1024u * 1024u;  // 1 MiB
    static constexpr std::uint32_t MAX_RECORDS = 50'000u;
    static constexpr std::uint32_t MAX_STRING_BYTES = 16u * 1024u;  // 16 KiB per string value
    static constexpr std::uint16_t MAX_KEY_BYTES = 256u;
    static constexpr std::uint64_t HEADER_BYTES =
        sizeof(MAGIC) + (sizeof(std::uint32_t) * 3u) + sizeof(std::uint64_t);

    // --- Schema and Display Metadata ---
    // ===================================

    enum class CharacterDataValueFormat
    {
        Plain,
        Bool,
        SoulTier,
        DraugnarokOverride,
        EbonFeatVariant,
        PlatinumFeatVariant,
        LuckNotificationTier,
        PlayedToken,
        DsrUse,
        RaceFormId
    };

    struct CharacterDataKeySpec
    {
        const char* section;
        const char* key;
        const char* displayName;
        CharacterDataValueFormat format;
    };

    static constexpr const char* kCharacterDataSections[] = {
        "identity",
        "core",
        "luck",
        "ui",
        "soul",
        "dsr",
        "bosses",
        "defiant",
        "journal"
    };

    static constexpr CharacterDataKeySpec kCharacterDataKeySpecs[] = {
        { "identity", "I.N", "IdentityName", CharacterDataValueFormat::Plain },
        { "identity", "I.R", "IdentityRaceFormId", CharacterDataValueFormat::RaceFormId },
        { "identity", "I.L", "IdentityLastSeenLevel", CharacterDataValueFormat::Plain },
        { "identity", "I.D", "IdentityLastSeenGameDay", CharacterDataValueFormat::Plain },

        { "core", "IS_8155", "CurrentDeaths", CharacterDataValueFormat::Plain },
        { "core", "IS_9132", "LifetimeDeaths", CharacterDataValueFormat::Plain },
        { "core", "IS_7341", "DraugnarokOverride", CharacterDataValueFormat::DraugnarokOverride },

        { "luck", "IS_7314", "LuckLastRealSecond", CharacterDataValueFormat::Plain },
        { "luck", "IS_7315", "LuckPlayedToken", CharacterDataValueFormat::PlayedToken },
        { "luck", "IS_7316", "LuckNotificationTier", CharacterDataValueFormat::LuckNotificationTier },

        { "ui", "IS_7317", "PostDeathLoadFlavorPending", CharacterDataValueFormat::Bool },
        { "ui", "IS_8597", "IronIntroShown", CharacterDataValueFormat::Bool },
        { "ui", "IS_9921", "SilverFeatMessageShown", CharacterDataValueFormat::Bool },
        { "ui", "IS_4797", "GoldFeatMessageShown", CharacterDataValueFormat::Bool },
        { "ui", "IS_4513", "EbonFeatMessageShown", CharacterDataValueFormat::Bool },
        { "ui", "IS_1155", "PlatinumFeatMessageShown", CharacterDataValueFormat::Bool },
        { "ui", "IS_1156", "DevourFeatMessageShown", CharacterDataValueFormat::Bool },

        { "soul", "IS_2204", "SoulTier", CharacterDataValueFormat::SoulTier },
        { "soul", "IS_2719", "ManualTierOverride", CharacterDataValueFormat::Bool },
        { "soul", "IS_4520", "EbonFeatVariant", CharacterDataValueFormat::EbonFeatVariant },
        { "soul", "IS_4779", "PlatinumFeatVariant", CharacterDataValueFormat::PlatinumFeatVariant },
        { "soul", "IS_9646", "DragonSoulsStoredTotal", CharacterDataValueFormat::Plain },
        { "soul", "IS_7440", "DragonSoulsLastSeenLive", CharacterDataValueFormat::Plain },

        { "dsr", "IS_8201", "DragonSoulReviveLimitLastRealSecond", CharacterDataValueFormat::Plain },
        { "dsr", "IS_8202", "DragonSoulReviveLimitPlayedSeconds", CharacterDataValueFormat::Plain },
        { "dsr", "IS_8203", "DragonSoulReviveRecentUse1", CharacterDataValueFormat::DsrUse },
        { "dsr", "IS_8204", "DragonSoulReviveRecentUse2", CharacterDataValueFormat::DsrUse },
        { "dsr", "IS_8205", "DragonSoulReviveRecentUse3", CharacterDataValueFormat::DsrUse },

        { "bosses", "IS_4911", "MiraakKilled", CharacterDataValueFormat::Bool },
        { "bosses", "IS_9897", "AlduinKilled", CharacterDataValueFormat::Bool },
        { "bosses", "IS_9808", "HarkonKilled", CharacterDataValueFormat::Bool },
        { "bosses", "IS_1627", "MolagBalKilled", CharacterDataValueFormat::Bool },

        { "defiant", "IS_1989", "DefiantFeatUnlocked", CharacterDataValueFormat::Bool },
        { "defiant", "IS_9131", "DefiantStoredTier", CharacterDataValueFormat::SoulTier },
        { "defiant", "IS_9136", "DefiantEnteredByConsole", CharacterDataValueFormat::Bool },
        { "defiant", "IS_9137", "CHIMEnteredByConsole", CharacterDataValueFormat::Bool },

        { "journal", "IS_5341", "JournalStartGameDay", CharacterDataValueFormat::Plain },
        { "journal", "IS_2270", "JournalOpenerLogged", CharacterDataValueFormat::Bool },
        { "journal", "IS_1927", "JournalCHIMLogged", CharacterDataValueFormat::Bool }
    };

    // --- Formatting Helpers ---
    // ==========================

    static std::string TrimAscii(std::string value)
    {
        const auto first = value.find_first_not_of(" \t\r\n");
        if (first == std::string::npos) {
            return {};
        }

        const auto last = value.find_last_not_of(" \t\r\n");
        return value.substr(first, last - first + 1);
    }

    static std::string ToLowerAscii(std::string value)
    {
        for (char& c : value) {
            c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        }
        return value;
    }

    static bool IsCharacterDataSection(const std::string& section)
    {
        if (section.empty()) {
            return true;
        }

        for (const char* candidate : kCharacterDataSections) {
            if (section == candidate) {
                return true;
            }
        }
        return false;
    }

    static const char* CharacterDataSectionTitle(const std::string& section)
    {
        if (section == "identity") {
            return "Identity";
        }
        if (section == "core") {
            return "Core";
        }
        if (section == "luck") {
            return "Luck";
        }
        if (section == "ui") {
            return "UI";
        }
        if (section == "soul") {
            return "Soul";
        }
        if (section == "dsr") {
            return "DSR";
        }
        if (section == "bosses") {
            return "Bosses";
        }
        if (section == "defiant") {
            return "Defiant";
        }
        if (section == "journal") {
            return "Journal";
        }
        if (section == "unknown") {
            return "Unknown";
        }
        return "CharacterData";
    }

    static std::string MakeGuidKey(const std::string& key, const std::string& guid)
    {
        return key + ":" + guid;
    }

    static bool EndsWith(const std::string& value, const std::string& suffix)
    {
        return value.size() >= suffix.size() &&
            value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0;
    }

    static std::string EscapeCharacterDataString(const std::string& value)
    {
        std::string escaped;
        escaped.reserve(value.size());

        for (const char c : value) {
            switch (c) {
            case '\\':
                escaped += "\\\\";
                break;
            case '"':
                escaped += "\\\"";
                break;
            case '\n':
                escaped += "\\n";
                break;
            case '\r':
                escaped += "\\r";
                break;
            case '\t':
                escaped += "\\t";
                break;
            default:
                escaped.push_back(c);
                break;
            }
        }

        return escaped;
    }

    static std::string QuoteCharacterDataString(const std::string& value)
    {
        return "\"" + EscapeCharacterDataString(value) + "\"";
    }

    static std::string LabeledInt(std::int32_t value, const char* label)
    {
        if (!label || label[0] == '\0') {
            return std::to_string(value);
        }
        return std::to_string(value) + "(" + label + ")";
    }

    static const char* SoulTierLabel(std::int32_t value)
    {
        switch (value) {
        case 0:
            return "Defiant";
        case 1:
            return "Iron";
        case 2:
            return "Silver";
        case 3:
            return "Gold";
        case 4:
            return "Ebon";
        case 5:
            return "Platinum";
        case 6:
            return "Devour";
        case 9:
            return "CHIM";
        default:
            return "";
        }
    }

    static const char* DraugnarokOverrideLabel(std::int32_t value)
    {
        switch (value) {
        case 0:
            return "None";
        case 1:
            return "ForceOn";
        case 2:
            return "ForceOff";
        default:
            return "";
        }
    }

    static const char* EbonFeatVariantLabel(std::int32_t value)
    {
        switch (value) {
        case 0:
            return "Unresolved";
        case 1:
            return "Alduin";
        case 2:
            return "Harkon";
        default:
            return "";
        }
    }

    static const char* PlatinumFeatVariantLabel(std::int32_t value)
    {
        switch (value) {
        case 0:
            return "Unresolved";
        case 1:
            return "MolagBal";
        case 2:
            return "Miraak";
        default:
            return "";
        }
    }

    static const char* LuckNotificationTierLabel(std::int32_t value)
    {
        switch (value) {
        case 0:
            return "<25%";
        case 1:
            return ">=25%";
        case 2:
            return ">=50%";
        case 3:
            return ">=75%";
        case 4:
            return "Max";
        default:
            return "";
        }
    }

    static std::string FormatRaceFormId(std::int32_t value)
    {
        char hex[16]{};
        std::snprintf(hex, sizeof(hex), "%08X", static_cast<std::uint32_t>(value));
        return std::to_string(value) + "(0x" + hex + ")";
    }

    static std::string FormatPlayedToken(std::int32_t value)
    {
        if (value < 0) {
            return std::to_string(value);
        }

        const std::int32_t played = value < 8192 ? value : value - ((value / 8192) * 8192);
        return std::to_string(value) + "(played=" + std::to_string(played) + "s)";
    }

    static std::string FormatDsrUse(std::int32_t value)
    {
        if (value < 0) {
            return std::to_string(value) + "(None)";
        }
        return std::to_string(value);
    }

    static std::string FormatCharacterDataInt(std::int32_t value, CharacterDataValueFormat format)
    {
        switch (format) {
        case CharacterDataValueFormat::Bool:
            if (value == 0) {
                return "0(False)";
            }
            if (value == 1) {
                return "1(True)";
            }
            return std::to_string(value);
        case CharacterDataValueFormat::SoulTier:
            return LabeledInt(value, SoulTierLabel(value));
        case CharacterDataValueFormat::DraugnarokOverride:
            return LabeledInt(value, DraugnarokOverrideLabel(value));
        case CharacterDataValueFormat::EbonFeatVariant:
            return LabeledInt(value, EbonFeatVariantLabel(value));
        case CharacterDataValueFormat::PlatinumFeatVariant:
            return LabeledInt(value, PlatinumFeatVariantLabel(value));
        case CharacterDataValueFormat::LuckNotificationTier:
            return LabeledInt(value, LuckNotificationTierLabel(value));
        case CharacterDataValueFormat::PlayedToken:
            return FormatPlayedToken(value);
        case CharacterDataValueFormat::DsrUse:
            return FormatDsrUse(value);
        case CharacterDataValueFormat::RaceFormId:
            return FormatRaceFormId(value);
        case CharacterDataValueFormat::Plain:
        default:
            return std::to_string(value);
        }
    }

    static bool IsKnownGuidScopedCharacterDataKey(const std::string& key, const std::string& guid)
    {
        for (const auto& spec : kCharacterDataKeySpecs) {
            if (key == MakeGuidKey(spec.key, guid)) {
                return true;
            }
        }
        return false;
    }

    static void AppendCharacterDataSection(
        std::string& result,
        const std::string& section,
        const std::vector<std::string>& entries)
    {
        if (!result.empty()) {
            result += "\n";
        }

        result += "[";
        result += CharacterDataSectionTitle(section);
        result += "]\n";

        if (entries.empty()) {
            result += "<none>";
            return;
        }

        for (std::size_t i = 0; i < entries.size(); ++i) {
            if (i > 0) {
                if ((i % 5) == 0) {
                    result += "\n";
                } else {
                    result += ", ";
                }
            }
            result += entries[i];
        }
    }

    // Simple integrity hash (FNV-1a 32-bit) for the payload.
    static std::uint32_t fnv1a32(const std::uint8_t* data, std::size_t size)
    {
        std::uint32_t hash = 0x811C9DC5u;
        for (std::size_t i = 0; i < size; ++i) {
            hash ^= data[i];
            hash *= 0x01000193u;
        }
        return hash;
    }

    static bool ReadExact(std::ifstream& in, void* dst, std::size_t n)
    {
        in.read(reinterpret_cast<char*>(dst), static_cast<std::streamsize>(n));
        return in.good();
    }

    // --- Load and Heal ---
    // =====================

    void DataStore::Initialize()
    {
        if (_initialized.load()) {
            return;
        }

        EnsureDirectories();
        Load();

        _initialized.store(true);
    }

    void DataStore::EnsureDirectories()
    {
        const auto plugins = IronSoul::PathUtil::GetSksePluginsDir();

        std::filesystem::create_directories(plugins / L"ironsoul");

        if (MirrorDataBackupEnabled()) {
            std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Runtime");
            std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Helpers");
            std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Output");
            std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"SharedData");
        }
    }

    void DataStore::Load()
    {
        const ParsedSnapshot mainSnapshot = LoadFile(MainDataPath().wstring());
        const bool mirrorEnabled = MirrorDataBackupEnabled();
        if (!mirrorEnabled) {
            std::lock_guard<std::mutex> lock(_mutex);

            if (!mainSnapshot.valid) {
                logger::warn("IronSoul DataStore: MainData invalid/missing and MirrorDataBackup=0; starting fresh");
                _data.clear();
                _sequence = 0;
                _dirty = false;
                return;
            }

            _data = mainSnapshot.data;
            _sequence = mainSnapshot.sequence;
            _dirty = false;
            return;
        }

        const ParsedSnapshot mirrorSnapshot = LoadFile(MirrorDataPath().wstring());

        bool shouldHeal = false;

        {
            std::lock_guard<std::mutex> lock(_mutex);

            if (!mainSnapshot.valid && !mirrorSnapshot.valid) {
                logger::warn("IronSoul DataStore: no valid v2 data files found, starting fresh");
                _data.clear();
                _sequence = 0;
                _dirty = false;
                return;
            }

            if (mainSnapshot.valid && mirrorSnapshot.valid) {
                if (mainSnapshot.sequence > mirrorSnapshot.sequence) {
                    _data = mainSnapshot.data;
                    _sequence = mainSnapshot.sequence;
                    _dirty = true;
                    shouldHeal = true;
                    logger::warn("IronSoul DataStore: MirrorData stale (main seq={} mirror seq={}); scheduling heal",
                        mainSnapshot.sequence, mirrorSnapshot.sequence);
                } else if (mirrorSnapshot.sequence > mainSnapshot.sequence) {
                    _data = mirrorSnapshot.data;
                    _sequence = mirrorSnapshot.sequence;
                    _dirty = true;
                    shouldHeal = true;
                    logger::warn("IronSoul DataStore: MainData stale (main seq={} mirror seq={}); restoring from Mirror and scheduling heal",
                        mainSnapshot.sequence, mirrorSnapshot.sequence);
                } else {
                    if (mainSnapshot.payloadHash != mirrorSnapshot.payloadHash ||
                        mainSnapshot.recordCount != mirrorSnapshot.recordCount ||
                        mainSnapshot.data != mirrorSnapshot.data) {
                        _data = mainSnapshot.data;
                        _sequence = mainSnapshot.sequence;
                        _dirty = true;
                        shouldHeal = true;
                        logger::warn("IronSoul DataStore: Main/Mirror divergence at seq={}; selecting MainData and scheduling heal",
                            mainSnapshot.sequence);
                    } else {
                        _data = mainSnapshot.data;
                        _sequence = mainSnapshot.sequence;
                        _dirty = false;
                    }
                }
            } else if (mainSnapshot.valid) {
                _data = mainSnapshot.data;
                _sequence = mainSnapshot.sequence;
                _dirty = true;
                shouldHeal = true;
                logger::warn("IronSoul DataStore: MirrorData invalid/missing; loading MainData seq={} and scheduling heal",
                    mainSnapshot.sequence);
            } else {
                _data = mirrorSnapshot.data;
                _sequence = mirrorSnapshot.sequence;
                _dirty = true;
                shouldHeal = true;
                logger::warn("IronSoul DataStore: MainData invalid/missing; loading MirrorData seq={} and scheduling heal",
                    mirrorSnapshot.sequence);
            }
        }

        if (shouldHeal) {
            // Heal stale/invalid side after selection; do disk I/O outside lock.
            FlushIfDirty();
        }
    }

    // --- File Parsing ---
    // ====================

    DataStore::ParsedSnapshot DataStore::LoadFile(const std::wstring& path)
    {
        ParsedSnapshot parsed{};

        const fs::path p(path);
        const std::string fileName = p.filename().string();

        std::ifstream in(path, std::ios::binary);
        if (!in.good()) {
            return parsed;
        }

        constexpr std::uint64_t kHeaderBytes = HEADER_BYTES;
        {
            std::error_code ec;
            const auto fsz = fs::file_size(p, ec);
            if (!ec) {
                if (fsz < kHeaderBytes) {
                    return parsed;
                }
                const auto remaining = static_cast<std::uint64_t>(fsz - kHeaderBytes);
                if (remaining > static_cast<std::uint64_t>(MAX_PAYLOAD_BYTES)) {
                    logger::warn(
                        "IronSoul DataStore: {} rejected (payload {} bytes exceeds max {} bytes)",
                        fileName,
                        remaining,
                        static_cast<std::uint64_t>(MAX_PAYLOAD_BYTES));
                    return parsed;
                }
            }
        }

        FileHeaderV2 header{};
        if (!ReadExact(in, header.magic, sizeof(header.magic))) {
            return parsed;
        }
        if (!ReadExact(in, &header.version, sizeof(header.version))) {
            return parsed;
        }
        if (!ReadExact(in, &header.recordCount, sizeof(header.recordCount))) {
            return parsed;
        }
        if (!ReadExact(in, &header.payloadHash, sizeof(header.payloadHash))) {
            return parsed;
        }
        if (!ReadExact(in, &header.sequence, sizeof(header.sequence))) {
            return parsed;
        }

        if (std::memcmp(header.magic, MAGIC, sizeof(header.magic)) != 0 || header.version != FILE_VERSION) {
            return parsed;
        }

        if (header.recordCount > MAX_RECORDS) {
            logger::warn("IronSoul DataStore: {} rejected (recordCount {} exceeds max {})",
                fileName, header.recordCount, MAX_RECORDS);
            return parsed;
        }

        std::vector<std::uint8_t> payload;
        in.seekg(0, std::ios::end);
        const auto endPos = in.tellg();
        if (endPos < 0) {
            return parsed;
        }
        const auto endPosU64 = static_cast<std::uint64_t>(endPos);
        if (endPosU64 < kHeaderBytes) {
            return parsed;
        }
        const auto payloadBytes = static_cast<std::size_t>(endPosU64 - kHeaderBytes);
        if (payloadBytes > MAX_PAYLOAD_BYTES) {
            logger::warn(
                "IronSoul DataStore: {} rejected (payload {} bytes exceeds max {} bytes)",
                fileName,
                payloadBytes,
                MAX_PAYLOAD_BYTES);
            return parsed;
        }
        in.seekg(static_cast<std::streamoff>(kHeaderBytes), std::ios::beg);
        if (!in.good()) {
            return parsed;
        }

        payload.resize(payloadBytes);
        if (payloadBytes > 0) {
            in.read(reinterpret_cast<char*>(payload.data()), static_cast<std::streamsize>(payloadBytes));
            if (!in.good()) {
                return parsed;
            }
        }

        if (fnv1a32(payload.data(), payload.size()) != header.payloadHash) {
            return parsed;
        }

        std::unordered_map<std::string, Value> tmp;
        std::size_t offset = 0;

        auto require = [&](bool ok) -> bool {
            return ok;
        };

        auto read_u8 = [&](std::uint8_t& v) -> bool {
            if (!require(offset + 1 <= payload.size())) {
                return false;
            }
            v = payload[offset];
            offset += 1;
            return true;
        };

        auto read_u16 = [&](std::uint16_t& v) -> bool {
            if (!require(offset + 2 <= payload.size())) {
                return false;
            }
            std::memcpy(&v, payload.data() + offset, 2);
            offset += 2;
            return true;
        };

        auto read_u32 = [&](std::uint32_t& v) -> bool {
            if (!require(offset + 4 <= payload.size())) {
                return false;
            }
            std::memcpy(&v, payload.data() + offset, 4);
            offset += 4;
            return true;
        };

        for (std::uint32_t i = 0; i < header.recordCount; ++i) {
            std::uint8_t type = 0;
            std::uint16_t keyLen = 0;
            std::uint32_t valLen = 0;

            if (!read_u8(type)) {
                return parsed;
            }
            if (!read_u16(keyLen)) {
                return parsed;
            }
            if (keyLen == 0 || keyLen > MAX_KEY_BYTES) {
                logger::warn("IronSoul DataStore: {} rejected (invalid key length {})", fileName, keyLen);
                return parsed;
            }
            if (!require(offset + keyLen <= payload.size())) {
                return parsed;
            }
            std::string key(reinterpret_cast<const char*>(payload.data() + offset), keyLen);
            offset += keyLen;

            if (!read_u32(valLen)) {
                return parsed;
            }
            if (type == 2 && valLen > MAX_STRING_BYTES) {
                logger::warn("IronSoul DataStore: {} rejected (string length {} exceeds max {})",
                    fileName, valLen, MAX_STRING_BYTES);
                return parsed;
            }
            if (!require(offset + valLen <= payload.size())) {
                return parsed;
            }

            if (type == 1) {
                if (!require(valLen == 4)) {
                    return parsed;
                }
                std::int32_t iv = 0;
                std::memcpy(&iv, payload.data() + offset, 4);
                tmp[key] = iv;
            } else if (type == 2) {
                std::string sv(reinterpret_cast<const char*>(payload.data() + offset), valLen);
                tmp[key] = sv;
            } else {
                return parsed;
            }

            offset += valLen;
        }

        if (offset != payload.size()) {
            logger::warn(
                "IronSoul DataStore: {} rejected (payload parse ended at {} of {} bytes)",
                fileName,
                offset,
                payload.size());
            return parsed;
        }

        parsed.valid = true;
        parsed.data = std::move(tmp);
        parsed.sequence = header.sequence;
        parsed.payloadHash = header.payloadHash;
        parsed.recordCount = header.recordCount;
        return parsed;
    }

    // --- File Writing ---
    // ====================

    void DataStore::WriteFiles()
    {
        // Snapshot under lock, then do disk I/O without holding the mutex.
        std::unordered_map<std::string, Value> snapshot;
        std::uint64_t nextSequence = 0;
        {
            std::lock_guard<std::mutex> lock(_mutex);
            if (!_dirty) {
                return;
            }

            snapshot = _data;
            if (_sequence == (std::numeric_limits<std::uint64_t>::max)()) {
                nextSequence = _sequence;
                logger::warn("IronSoul DataStore: sequence reached max; future flushes will reuse max sequence");
            } else {
                nextSequence = _sequence + 1;
            }

            // Optimistically clear dirty; if new writes happen while we flush, Set* will set _dirty=true.
            _dirty = false;
        }

        const fs::path mainPath = MainDataPath();
        const bool mirrorEnabled = MirrorDataBackupEnabled();
        const fs::path mirrorPath = mirrorEnabled ? MirrorDataPath() : fs::path{};
        if (mirrorEnabled) {
            std::filesystem::create_directories(mirrorPath.parent_path());
        }

        if (snapshot.size() > MAX_RECORDS) {
            logger::error("IronSoul DataStore: flush rejected (record count {} exceeds max {})",
                snapshot.size(), MAX_RECORDS);
            std::lock_guard<std::mutex> lock(_mutex);
            _dirty = true;
            return;
        }

        std::vector<std::uint8_t> payload;
        payload.reserve(std::min<std::size_t>(snapshot.size() * 32, MAX_PAYLOAD_BYTES));

        std::uint32_t recordCount = 0;
        for (const auto& [k, v] : snapshot) {
            if (k.empty() || k.size() > MAX_KEY_BYTES) {
                logger::error("IronSoul DataStore: flush rejected (invalid key length {})", k.size());
                std::lock_guard<std::mutex> lock(_mutex);
                _dirty = true;
                return;
            }
            if (recordCount >= MAX_RECORDS) {
                logger::error("IronSoul DataStore: flush rejected (record count exceeds max {})", MAX_RECORDS);
                std::lock_guard<std::mutex> lock(_mutex);
                _dirty = true;
                return;
            }

            const bool isInt = std::holds_alternative<std::int32_t>(v);
            const std::uint8_t type = isInt ? 1 : 2;
            const std::uint32_t valueLen = [&]() -> std::uint32_t {
                if (isInt) {
                    return 4u;
                }
                const auto& sv = std::get<std::string>(v);
                if (sv.size() > MAX_STRING_BYTES) {
                    return (std::numeric_limits<std::uint32_t>::max)();
                }
                return static_cast<std::uint32_t>(sv.size());
            }();

            if (valueLen == (std::numeric_limits<std::uint32_t>::max)()) {
                logger::error("IronSoul DataStore: flush rejected (string value exceeds max {} bytes)",
                    MAX_STRING_BYTES);
                std::lock_guard<std::mutex> lock(_mutex);
                _dirty = true;
                return;
            }

            const std::size_t recordBytes = 1u + 2u + k.size() + 4u + static_cast<std::size_t>(valueLen);
            if (payload.size() + recordBytes > MAX_PAYLOAD_BYTES) {
                logger::error("IronSoul DataStore: flush rejected (payload {} + record {} exceeds max {})",
                    payload.size(), recordBytes, MAX_PAYLOAD_BYTES);
                std::lock_guard<std::mutex> lock(_mutex);
                _dirty = true;
                return;
            }

            payload.push_back(type);

            const std::uint16_t keyLen = static_cast<std::uint16_t>(k.size());
            payload.insert(payload.end(),
                reinterpret_cast<const std::uint8_t*>(&keyLen),
                reinterpret_cast<const std::uint8_t*>(&keyLen) + sizeof(keyLen));
            payload.insert(payload.end(), k.begin(), k.end());

            payload.insert(payload.end(),
                reinterpret_cast<const std::uint8_t*>(&valueLen),
                reinterpret_cast<const std::uint8_t*>(&valueLen) + sizeof(valueLen));

            if (isInt) {
                const std::int32_t iv = std::get<std::int32_t>(v);
                payload.insert(payload.end(),
                    reinterpret_cast<const std::uint8_t*>(&iv),
                    reinterpret_cast<const std::uint8_t*>(&iv) + sizeof(iv));
            } else {
                const auto& sv = std::get<std::string>(v);
                payload.insert(payload.end(), sv.begin(), sv.end());
            }

            ++recordCount;
        }

        const std::uint32_t payloadHash = fnv1a32(payload.data(), payload.size());
        const FileHeaderV2 header{
            { MAGIC[0], MAGIC[1], MAGIC[2], MAGIC[3] },
            FILE_VERSION,
            recordCount,
            payloadHash,
            nextSequence
        };

        auto writeOne = [&](const fs::path& path, bool writeThrough) -> bool
        {
            fs::path tmpPath = path;
            tmpPath += L".tmp";

            std::ofstream out(tmpPath, std::ios::binary | std::ios::trunc);
            if (!out.is_open()) {
                logger::warn("IronSoul DataStore: failed to open tmp for write: {}", tmpPath.string());
                return false;
            }

            out.write(header.magic, sizeof(header.magic));
            out.write(reinterpret_cast<const char*>(&header.version), sizeof(header.version));
            out.write(reinterpret_cast<const char*>(&header.recordCount), sizeof(header.recordCount));
            out.write(reinterpret_cast<const char*>(&header.payloadHash), sizeof(header.payloadHash));
            out.write(reinterpret_cast<const char*>(&header.sequence), sizeof(header.sequence));
            if (!out.good()) {
                logger::warn("IronSoul DataStore: header write failed: {}", tmpPath.string());
                out.close();
                std::error_code ec;
                fs::remove(tmpPath, ec);
                return false;
            }

            if (!payload.empty()) {
                out.write(reinterpret_cast<const char*>(payload.data()), static_cast<std::streamsize>(payload.size()));
                if (!out.good()) {
                    logger::warn("IronSoul DataStore: payload write failed: {}", tmpPath.string());
                    out.close();
                    std::error_code ec;
                    fs::remove(tmpPath, ec);
                    return false;
                }
            }

            out.flush();
            if (!out.good()) {
                logger::warn("IronSoul DataStore: flush to tmp failed: {}", tmpPath.string());
                out.close();
                std::error_code ec;
                fs::remove(tmpPath, ec);
                return false;
            }

            out.close();
            if (out.fail()) {
                logger::warn("IronSoul DataStore: close tmp failed: {}", tmpPath.string());
                std::error_code ec;
                fs::remove(tmpPath, ec);
                return false;
            }

            // Atomic replace; WRITE_THROUGH only for MainData.
            DWORD flags = MOVEFILE_REPLACE_EXISTING;
            if (writeThrough) {
                flags |= MOVEFILE_WRITE_THROUGH;
            }

            if (!MoveFileExW(tmpPath.c_str(), path.c_str(), flags)) {
                const DWORD err = GetLastError();
                logger::warn("IronSoul DataStore: MoveFileExW failed (err={}): {}", err, path.string());
                // Leave tmp for debugging.
                return false;
            }

            return true;
        };

        const bool okMain = writeOne(mainPath, true);
        const bool okMirror = !mirrorEnabled || writeOne(mirrorPath, false);

        {
            std::lock_guard<std::mutex> lock(_mutex);
            if (okMain && okMirror) {
                _sequence = nextSequence;
            } else {
                // If any write failed, mark dirty so we retry later.
                _dirty = true;
                if (mirrorEnabled) {
                    logger::warn("IronSoul DataStore: flush incomplete (mainOk={} mirrorOk={}); will retry",
                        okMain, okMirror);
                } else {
                    logger::warn("IronSoul DataStore: flush incomplete (mainOk={}); will retry", okMain);
                }
            }
        }
    }

    // --- Public API ---
    // ==================

    std::int32_t DataStore::GetInt(const std::string& key, std::int32_t fallback)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it == _data.end()) {
            return fallback;
        }

        if (auto p = std::get_if<std::int32_t>(&it->second)) {
            return *p;
        }

        return fallback;
    }

    bool DataStore::SetInt(const std::string& key, std::int32_t value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);
        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetIntIfChanged(const std::string& key, std::int32_t value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::int32_t>(&it->second)) {
                if (*p == value) {
                    return false;
                }
            }
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetIntChecked(const std::string& key, std::int32_t value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::int32_t>(&it->second)) {
                if (*p == value) {
                    return true;
                }
            }
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetIntBatch(const IntBatch4& writes)
    {
        for (const auto& [key, value] : writes) {
            (void)value;
            if (key.empty() || key.size() > MAX_KEY_BYTES) {
                return false;
            }
        }

        std::lock_guard<std::mutex> lock(_mutex);

        bool changed = false;
        for (const auto& [key, value] : writes) {
            auto it = _data.find(key);
            if (it != _data.end()) {
                if (auto current = std::get_if<std::int32_t>(&it->second)) {
                    if (*current == value) {
                        continue;
                    }
                }
            }

            _data[key] = value;
            changed = true;
        }

        if (changed) {
            _dirty = true;
        }

        return true;
    }

    bool DataStore::SetIntBatch(const IntBatch5& writes)
    {
        for (const auto& [key, value] : writes) {
            (void)value;
            if (key.empty() || key.size() > MAX_KEY_BYTES) {
                return false;
            }
        }

        std::lock_guard<std::mutex> lock(_mutex);

        bool changed = false;
        for (const auto& [key, value] : writes) {
            auto it = _data.find(key);
            if (it != _data.end()) {
                if (auto current = std::get_if<std::int32_t>(&it->second)) {
                    if (*current == value) {
                        continue;
                    }
                }
            }

            _data[key] = value;
            changed = true;
        }

        if (changed) {
            _dirty = true;
        }

        return true;
    }

    std::string DataStore::GetString(const std::string& key, const std::string& fallback)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it == _data.end()) {
            return fallback;
        }

        if (auto p = std::get_if<std::string>(&it->second)) {
            return *p;
        }

        return fallback;
    }

    std::string DataStore::GetCharacterData(const std::string& guid, const std::string& section)
    {
        if (guid.empty()) {
            return "Error: character GUID cannot be empty.";
        }

        const std::string sectionLower = ToLowerAscii(TrimAscii(section));
        if (!IsCharacterDataSection(sectionLower)) {
            return "Error: unknown CharacterData section '" + section + "'. Expected identity, core, luck, ui, soul, dsr, bosses, defiant, or journal.";
        }

        std::unordered_map<std::string, Value> snapshot;
        {
            std::lock_guard<std::mutex> lock(_mutex);
            snapshot = _data;
        }

        std::unordered_map<std::string, std::vector<std::string>> entries;

        auto wantsSection = [&](const char* candidate) -> bool
        {
            return sectionLower.empty() || sectionLower == candidate;
        };

        auto formatValue = [](const Value& value, CharacterDataValueFormat format) -> std::string
        {
            if (const auto* iv = std::get_if<std::int32_t>(&value)) {
                return FormatCharacterDataInt(*iv, format);
            }
            if (const auto* sv = std::get_if<std::string>(&value)) {
                return QuoteCharacterDataString(*sv);
            }
            return "";
        };

        auto appendValue = [&](const std::string& sectionName, const std::string& displayName, const Value& value, CharacterDataValueFormat format)
        {
            entries[sectionName].push_back(displayName + "=" + formatValue(value, format));
        };

        if (wantsSection("identity")) {
            entries["identity"].push_back("CharacterGuid=" + QuoteCharacterDataString(guid));

            const auto markerIt = snapshot.find("G.U." + guid);
            if (markerIt != snapshot.end()) {
                appendValue("identity", "GuidClaimed", markerIt->second, CharacterDataValueFormat::Bool);
            }

            const auto indexIt = snapshot.find("G.U.INDEX");
            if (indexIt != snapshot.end()) {
                appendValue("identity", "GuidIndex", indexIt->second, CharacterDataValueFormat::Plain);
            }
        }

        for (const auto& spec : kCharacterDataKeySpecs) {
            if (!wantsSection(spec.section)) {
                continue;
            }

            const auto it = snapshot.find(MakeGuidKey(spec.key, guid));
            if (it != snapshot.end()) {
                appendValue(spec.section, spec.displayName, it->second, spec.format);
            }
        }

        if (sectionLower.empty()) {
            std::vector<std::string> unknownEntries;
            const std::string suffix = ":" + guid;

            for (const auto& [key, value] : snapshot) {
                if (!EndsWith(key, suffix)) {
                    continue;
                }
                if (IsKnownGuidScopedCharacterDataKey(key, guid)) {
                    continue;
                }

                const std::string rawKey = key.substr(0, key.size() - suffix.size());
                unknownEntries.push_back("Unknown(" + rawKey + ")=" + formatValue(value, CharacterDataValueFormat::Plain));
            }

            if (!unknownEntries.empty()) {
                std::sort(unknownEntries.begin(), unknownEntries.end());
                entries["unknown"] = std::move(unknownEntries);
            }
        }

        std::string result;
        if (sectionLower.empty()) {
            for (const char* sectionName : kCharacterDataSections) {
                const auto it = entries.find(sectionName);
                if (it != entries.end() && !it->second.empty()) {
                    AppendCharacterDataSection(result, sectionName, it->second);
                }
            }

            const auto unknownIt = entries.find("unknown");
            if (unknownIt != entries.end() && !unknownIt->second.empty()) {
                AppendCharacterDataSection(result, "unknown", unknownIt->second);
            }

            if (result.empty()) {
                return "No CharacterData values found for GUID " + QuoteCharacterDataString(guid) + ".";
            }
            return result;
        }

        const auto it = entries.find(sectionLower);
        if (it == entries.end()) {
            AppendCharacterDataSection(result, sectionLower, {});
        } else {
            AppendCharacterDataSection(result, sectionLower, it->second);
        }
        return result;
    }

    bool DataStore::SetString(const std::string& key, const std::string& value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        if (value.size() > MAX_STRING_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);
        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetStringIfChanged(const std::string& key, const std::string& value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        if (value.size() > MAX_STRING_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::string>(&it->second)) {
                if (*p == value) {
                    return false;
                }
            }
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetStringChecked(const std::string& key, const std::string& value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        if (value.size() > MAX_STRING_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::string>(&it->second)) {
                if (*p == value) {
                    return true;
                }
            }
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::HasKey(const std::string& key)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        return _data.contains(key);
    }

    bool DataStore::SetIntIfAbsent(const std::string& key, std::int32_t value)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return false;
        }
        std::lock_guard<std::mutex> lock(_mutex);

        if (_data.contains(key)) {
            return false;
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    void DataStore::DeleteKey(const std::string& key)
    {
        if (key.empty() || key.size() > MAX_KEY_BYTES) {
            return;
        }
        std::lock_guard<std::mutex> lock(_mutex);
        if (_data.erase(key) != 0) {
            _dirty = true;
        }
    }

    void DataStore::FlushIfDirty()
    {
        // Explicit flush requests should be deterministic: if another flush is in flight,
        // wait for it instead of dropping this request.
        std::unique_lock<std::mutex> flushLock(_flushMutex);

        // WriteFiles snapshots under lock and performs disk I/O without holding the mutex.
        WriteFiles();
    }
}
