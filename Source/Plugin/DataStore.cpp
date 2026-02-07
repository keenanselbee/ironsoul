#include "pch.h"

#include "DataStore.h"
#include "PathUtil.h"
#include <vector>
#include <chrono>
#include <thread>
#include <cstring>

namespace fs = std::filesystem;

namespace IronSoul
{
    static std::filesystem::path MainDataPath()
    {
        return IronSoul::PathUtil::GetSksePluginsDir() / L"IronSoul" / L"CharacterData.dat";
    }

    static std::filesystem::path MirrorDataPath()
    {
        return IronSoul::PathUtil::GetSksePluginsDir() / L"StorageUtilData" / L"PapyrusUtil" / L"Runtime" / L"MD_5729.dat";
    }

    static constexpr std::uint32_t FILE_VERSION = 1;
    static constexpr char MAGIC[4] = { 'I','S','D','T' };

    // Hardening caps (v1): keep loads safe even if files are corrupted/tampered.
    // Iron Soul stores a small KV set; these limits are intentionally generous.
    static constexpr std::size_t  MAX_PAYLOAD_BYTES = 1u * 1024u * 1024u;   // 1 MiB
    static constexpr std::uint32_t MAX_RECORDS      = 50'000u;
    static constexpr std::uint32_t MAX_STRING_BYTES = 16u * 1024u;          // 16 KiB per string value
    static constexpr std::uint16_t MAX_KEY_BYTES    = 256u;

    // Simple integrity hash (FNV-1a 32-bit) for the payload.
    // NOTE: If you ever want a different integrity mechanism, swap fnv1a32() out for CRC32 or stronger.
    // We intentionally keep this lightweight (no external deps).
    static std::uint32_t fnv1a32(const std::uint8_t* data, std::size_t size)
    {
        std::uint32_t hash = 0x811C9DC5u;
        for (std::size_t i = 0; i < size; ++i) {
            hash ^= data[i];
            hash *= 0x01000193u;
        }
        return hash;
    }

    void DataStore::Initialize()
    {
        if (_initialized) {
            return;
        }

        EnsureDirectories();
        Load();

        // Periodic flush: every 30 seconds, only if dirty.
        _stopThread.store(false);
        _flushThread = std::thread([]() {
            using namespace std::chrono;
            auto lastFlush = steady_clock::now();

            while (!DataStore::_stopThread.load()) {
                std::this_thread::sleep_for(std::chrono::seconds(1));
                if (DataStore::_stopThread.load()) {
                    break;
                }

                auto now = steady_clock::now();
                if (now - lastFlush < std::chrono::seconds(30)) {
                    continue;
                }
                lastFlush = now;

                DataStore::FlushNow();
            }
        });

        _initialized = true;
    }

    void DataStore::Shutdown()
    {
        // Stop the background flush thread to avoid races with file writes.
        _stopThread.store(true);
        if (_flushThread.joinable()) {
            _flushThread.join();
        }

        // Final best-effort flush.
        FlushNow();
    }

    void DataStore::EnsureDirectories()
    {
        const auto plugins = IronSoul::PathUtil::GetSksePluginsDir();

        std::filesystem::create_directories(plugins / L"IronSoul");
        std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Runtime");

        std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Helpers");
        std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"Output");
        std::filesystem::create_directories(plugins / L"StorageUtilData" / L"PapyrusUtil" / L"SharedData");
    }

    void DataStore::Load()
    {
        bool restoreFromMirror = false;
        bool healMirrorFromMain = false;
        bool loadedMain = false;

        {
            std::lock_guard<std::mutex> lock(_mutex);

            if (LoadFile(MainDataPath().wstring())) {
                logger::info("IronSoul DataStore: loaded MainData");

                loadedMain = true;

                // Mirror self-heal: if Main is valid but Mirror is missing/tampered,
                // mark dirty so we rebuild Mirror from the loaded Main snapshot.
                // NOTE: LoadFile commits into _data on success, so preserve Main.
                const auto mainSnapshot = _data;
                const bool mirrorOk = LoadFile(MirrorDataPath().wstring());
                _data = mainSnapshot;
                _dirty = false;

                if (!mirrorOk) {
                    logger::warn("IronSoul DataStore: MirrorData missing/invalid; will rebuild from MainData");
                    _dirty = true;
                    healMirrorFromMain = true;
                }

                // If mirror is fine, we're done.
                if (!healMirrorFromMain) {
                    return;
                }
            }

            // If Main loaded but Mirror needs rebuild, do NOT attempt mirror-restore logic.
            if (loadedMain) {
                // We already have a valid Main snapshot in _data.
                // We'll rebuild Mirror after releasing the lock.
            } else {
                if (LoadFile(MirrorDataPath().wstring())) {
                    logger::warn("IronSoul DataStore: MainData invalid/missing, restored from MirrorData");

                    // IMPORTANT: mark dirty under lock so the flush thread can't race this flag
                    _dirty = true;
                    restoreFromMirror = true;
                } else {
                    logger::warn("IronSoul DataStore: no valid data files found, starting fresh");
                    _data.clear();
                    _dirty = false;
                    return;
                }
            }
        }

        if (restoreFromMirror || healMirrorFromMain) {
            // Restore Main from Mirror snapshot OR rebuild Mirror from Main.
            // Do disk I/O outside the mutex.
            FlushNow();
        }
    }

static bool ReadExact(std::ifstream& in, void* dst, std::size_t n)
{
    in.read(reinterpret_cast<char*>(dst), static_cast<std::streamsize>(n));
    return in.good();
}

static bool read_all(std::ifstream& in, std::vector<std::uint8_t>& out)
    {
        out.assign(std::istreambuf_iterator<char>(in), {});
        return true;
    }

    bool DataStore::LoadFile(const std::wstring& path)
    {
        const fs::path p(path);
        const std::string fileName = p.filename().string();

        std::ifstream in(path, std::ios::binary);
        if (!in.good()) {
            return false;
        }

        char magic[4]{};
        std::uint32_t version = 0;
        std::uint32_t count = 0;
        std::uint32_t payloadHash = 0;

        if (!ReadExact(in, magic, 4)) return false;
        if (!ReadExact(in, &version, 4)) return false;
        if (!ReadExact(in, &count, 4)) return false;
        if (!ReadExact(in, &payloadHash, 4)) return false;

        if (std::memcmp(magic, MAGIC, 4) != 0 || version != FILE_VERSION) {
            // Wrong file or incompatible version.
            return false;
        }

        if (count > MAX_RECORDS) {
            logger::warn("IronSoul DataStore: {} rejected (recordCount {} exceeds max {})", fileName, count, MAX_RECORDS);
            return false;
        }

        std::vector<std::uint8_t> payload;
        read_all(in, payload);

        if (payload.size() > MAX_PAYLOAD_BYTES) {
            logger::warn("IronSoul DataStore: {} rejected (payload {} bytes exceeds max {} bytes)", fileName, payload.size(), MAX_PAYLOAD_BYTES);
            return false;
        }

        if (fnv1a32(payload.data(), payload.size()) != payloadHash) {
            return false;
        }

        auto require = [&](bool ok) -> bool {
            return ok;
        };

        std::unordered_map<std::string, Value> tmp;
        std::size_t offset = 0;

        auto read_u8 = [&](std::uint8_t& v) -> bool {
            if (!require(offset + 1 <= payload.size())) return false;
            v = payload[offset];
            offset += 1;
            return true;
        };
        auto read_u16 = [&](std::uint16_t& v) -> bool {
            if (!require(offset + 2 <= payload.size())) return false;
            std::memcpy(&v, payload.data() + offset, 2);
            offset += 2;
            return true;
        };
        auto read_u32 = [&](std::uint32_t& v) -> bool {
            if (!require(offset + 4 <= payload.size())) return false;
            std::memcpy(&v, payload.data() + offset, 4);
            offset += 4;
            return true;
        };

        for (std::uint32_t i = 0; i < count; i++) {
            std::uint8_t type = 0;
            std::uint16_t keyLen = 0;
            std::uint32_t valLen = 0;

            if (!read_u8(type)) return false;
            if (!read_u16(keyLen)) return false;
            if (keyLen == 0 || keyLen > MAX_KEY_BYTES) {
                logger::warn("IronSoul DataStore: {} rejected (invalid key length {})", fileName, keyLen);
                return false;
            }

            if (!require(offset + keyLen <= payload.size())) return false;
            std::string key(reinterpret_cast<const char*>(payload.data() + offset), keyLen);
            offset += keyLen;

            if (!read_u32(valLen)) return false;
            if (type == 2 && valLen > MAX_STRING_BYTES) {
                logger::warn("IronSoul DataStore: {} rejected (string length {} exceeds max {})", fileName, valLen, MAX_STRING_BYTES);
                return false;
            }
            if (!require(offset + valLen <= payload.size())) return false;

            if (type == 1) {
                if (!require(valLen == 4)) return false;
                std::int32_t iv = 0;
                std::memcpy(&iv, payload.data() + offset, 4);
                tmp[key] = iv;
            } else if (type == 2) {
                std::string sv(reinterpret_cast<const char*>(payload.data() + offset), valLen);
                tmp[key] = sv;
            } else {
                // Unknown type => reject file (keeps it simple)
                return false;
            }

            offset += valLen;
        }

        // Tighten: require that the payload is fully consumed by the record loop.
        if (offset != payload.size()) {
            logger::warn(
                "IronSoul DataStore: {} rejected (payload parse ended at {} of {} bytes)",
                fileName,
                offset,
                payload.size());
            return false;
        }

        // Successful parse, commit.
        _data = std::move(tmp);
        _dirty = false;
        return true;
    }

    void DataStore::WriteFiles()
    {
        std::lock_guard<std::mutex> lock(_mutex);

        const fs::path mainPath = MainDataPath();
        const fs::path mirrorPath = MirrorDataPath();

        auto writeOne = [&](const fs::path& path, bool writeThrough)
        {
            std::vector<std::uint8_t> payload;
            payload.reserve(_data.size() * 32);

            for (auto& [k, v] : _data) {
                if (std::holds_alternative<std::int32_t>(v)) {
                    payload.push_back(1);
                    std::uint16_t klen = static_cast<std::uint16_t>(k.size());
                    payload.insert(payload.end(),
                        reinterpret_cast<std::uint8_t*>(&klen),
                        reinterpret_cast<std::uint8_t*>(&klen) + 2);
                    payload.insert(payload.end(), k.begin(), k.end());

                    std::uint32_t vlen = 4;
                    payload.insert(payload.end(),
                        reinterpret_cast<std::uint8_t*>(&vlen),
                        reinterpret_cast<std::uint8_t*>(&vlen) + 4);

                    std::int32_t iv = std::get<std::int32_t>(v);
                    payload.insert(payload.end(),
                        reinterpret_cast<std::uint8_t*>(&iv),
                        reinterpret_cast<std::uint8_t*>(&iv) + 4);
                } else {
                    payload.push_back(2);
                    std::uint16_t klen = static_cast<std::uint16_t>(k.size());
                    payload.insert(payload.end(),
                        reinterpret_cast<std::uint8_t*>(&klen),
                        reinterpret_cast<std::uint8_t*>(&klen) + 2);
                    payload.insert(payload.end(), k.begin(), k.end());

                    const auto& sv = std::get<std::string>(v);
                    std::uint32_t vlen = static_cast<std::uint32_t>(sv.size());
                    payload.insert(payload.end(),
                        reinterpret_cast<std::uint8_t*>(&vlen),
                        reinterpret_cast<std::uint8_t*>(&vlen) + 4);
                    payload.insert(payload.end(), sv.begin(), sv.end());
                }
            }

            const std::uint32_t payloadHash = fnv1a32(payload.data(), payload.size());

            fs::path tmpPath = path.wstring() + L".tmp";
            std::ofstream out(tmpPath, std::ios::binary | std::ios::trunc);
            if (!out.is_open()) {
                logger::warn("IronSoul DataStore: failed to open tmp for write: {}", tmpPath.string());
                return;
            }

            out.write(MAGIC, 4);
            out.write(reinterpret_cast<const char*>(&FILE_VERSION), 4);

            std::uint32_t count = static_cast<std::uint32_t>(_data.size());
            out.write(reinterpret_cast<const char*>(&count), 4);
            out.write(reinterpret_cast<const char*>(&payloadHash), 4);
            out.write(reinterpret_cast<const char*>(payload.data()), static_cast<std::streamsize>(payload.size()));
            out.flush();
            out.close();

            // Atomic replace; WRITE_THROUGH only for MainData
            DWORD flags = MOVEFILE_REPLACE_EXISTING;
            if (writeThrough) {
                flags |= MOVEFILE_WRITE_THROUGH;
            }

            if (!MoveFileExW(tmpPath.c_str(), path.c_str(), flags)) {
                const DWORD err = GetLastError();
                logger::warn("IronSoul DataStore: MoveFileExW failed (err={}): {}", err, path.string());
                // Best effort: leave tmp file behind for debugging.
                return;
            }
        };

        writeOne(mainPath, true);
        writeOne(mirrorPath, false);

        _dirty = false;
    }

    std::int32_t DataStore::GetInt(const std::string& key, std::int32_t fallback)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it == _data.end())
            return fallback;

        if (auto p = std::get_if<std::int32_t>(&it->second))
            return *p;

        return fallback;
    }

    bool DataStore::SetInt(const std::string& key, std::int32_t value)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetIntIfChanged(const std::string& key, std::int32_t value)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::int32_t>(&it->second)) {
                if (*p == value)
                    return false;
            }
        }

        _data[key] = value;
        _dirty = true;
        return true;
    }

    std::string DataStore::GetString(const std::string& key, const std::string& fallback)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it == _data.end())
            return fallback;

        if (auto p = std::get_if<std::string>(&it->second))
            return *p;

        return fallback;
    }

    bool DataStore::SetString(const std::string& key, const std::string& value)
    {
        std::lock_guard<std::mutex> lock(_mutex);
        _data[key] = value;
        _dirty = true;
        return true;
    }

    bool DataStore::SetStringIfChanged(const std::string& key, const std::string& value)
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _data.find(key);
        if (it != _data.end()) {
            if (auto p = std::get_if<std::string>(&it->second)) {
                if (*p == value)
                    return false;
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
        std::lock_guard<std::mutex> lock(_mutex);
        if (_data.erase(key) != 0) {
            _dirty = true;
        }
    }

    void DataStore::FlushNow()
    {
        // Quick check under lock; write outside lock? WriteFiles locks, so just call it after checking.
        {
            std::lock_guard<std::mutex> lock(_mutex);
            if (!_dirty) {
                return;
            }
        }
        WriteFiles();
    }
}
