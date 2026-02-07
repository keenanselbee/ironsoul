#pragma once
#include <cstdint>
#include <string>
#include <variant>
#include <unordered_map>
#include <mutex>
#include <thread>
#include <atomic>

namespace IronSoul
{
    // Simple binary KV store for Iron Soul persistent state.
    // File integrity: payload uses an FNV-1a 32-bit hash (lightweight corruption detection).
    // Types supported (v1):
    //   - int32
    //   - string (UTF-8)
    class DataStore
    {
    public:
        static void Initialize();
        static void Shutdown();

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
        static void FlushNow();

    private:
        static void Load();
        static bool LoadFile(const std::wstring& path);
        static void WriteFiles();
        static void EnsureDirectories();

        using Value = std::variant<std::int32_t, std::string>;

        static inline std::unordered_map<std::string, Value> _data;
        static inline std::mutex _mutex;

        static inline std::thread _flushThread;
        static inline std::atomic_bool _stopThread{ false };

        static inline bool _initialized = false;
        static inline bool _dirty = false;
    };
}
