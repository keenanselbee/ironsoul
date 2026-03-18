#pragma once
#include <cstdint>
#include <string>
#include <variant>
#include <unordered_map>
#include <mutex>
#include <atomic>

namespace IronSoul
{
    // Simple binary KV store for Iron Soul persistent state.
    // File integrity: payload uses an FNV-1a 32-bit hash (lightweight corruption detection).
    // Types supported:
    //   - int32
    //   - string (UTF-8)
    class DataStore
    {
    public:
        static void Initialize();

        // Returns true after Initialize() has run successfully.
        static bool IsInitialized() { return _initialized.load(); }

        static std::int32_t GetInt(const std::string& key, std::int32_t fallback);
        static bool         SetInt(const std::string& key, std::int32_t value);
        static bool         SetIntIfChanged(const std::string& key, std::int32_t value);

        static std::string  GetString(const std::string& key, const std::string& fallback);
        static bool         SetString(const std::string& key, const std::string& value);
        static bool         SetStringIfChanged(const std::string& key, const std::string& value);

        static bool HasKey(const std::string& key);
        // Sets an integer value ONLY if the key does not already exist.
        // Returns true if the key was absent and is now set.
        static bool SetIntIfAbsent(const std::string& key, std::int32_t value);
        static void DeleteKey(const std::string& key);

        // Force a disk write if dirty.
        static void FlushIfDirty();

    private:
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

        static void Load();
        static ParsedSnapshot LoadFile(const std::wstring& path);
        static void WriteFiles();
        static void EnsureDirectories();

        static inline std::unordered_map<std::string, Value> _data;
        static inline std::mutex _mutex;
        static inline std::mutex _flushMutex;

        // NOTE: Keep this atomic to avoid accidental data races if any call sites ever
        // cross threads (e.g. save callback vs VM call).
        static inline std::atomic_bool _initialized{ false };
        static inline bool _dirty = false;
        static inline std::uint64_t _sequence = 0;
    };
}
