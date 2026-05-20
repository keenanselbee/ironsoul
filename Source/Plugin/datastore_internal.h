#pragma once
#include <cstdint>
#include <filesystem>
#include <string>
#include <unordered_map>
#include <variant>

namespace IronSoul::DataStoreInternal
{
    using Value = std::variant<std::int32_t, std::string>;

    struct FileHeaderV2
    {
        char magic[4];
        std::uint32_t version;
        std::uint32_t recordCount;
        std::uint32_t payloadHash;
        std::uint64_t sequence;
    };

    struct ParsedSnapshot
    {
        bool valid = false;
        std::unordered_map<std::string, Value> data;
        std::uint64_t sequence = 0;
        std::uint32_t payloadHash = 0;
        std::uint32_t recordCount = 0;
    };

    inline constexpr std::uint32_t FILE_VERSION = 2;
    inline constexpr char MAGIC[4] = { 'I', 'S', 'D', 'T' };

    // Hardening caps (v2): keep loads/writes safe even if files are corrupted/tampered.
    // Iron Soul stores a small KV set; these limits are intentionally generous.
    inline constexpr std::size_t MAX_PAYLOAD_BYTES = 1u * 1024u * 1024u;  // 1 MiB
    inline constexpr std::uint32_t MAX_RECORDS = 50'000u;
    inline constexpr std::uint32_t MAX_STRING_BYTES = 16u * 1024u;  // 16 KiB per string value
    inline constexpr std::uint16_t MAX_KEY_BYTES = 256u;
    inline constexpr std::uint64_t HEADER_BYTES =
        sizeof(MAGIC) + (sizeof(std::uint32_t) * 3u) + sizeof(std::uint64_t);

    std::filesystem::path MainDataPath();
    std::filesystem::path MirrorDataPath();
    bool MirrorDataBackupEnabled();

    // Simple integrity hash (FNV-1a 32-bit) for datastore payloads.
    std::uint32_t fnv1a32(const std::uint8_t* data, std::size_t size);
}
