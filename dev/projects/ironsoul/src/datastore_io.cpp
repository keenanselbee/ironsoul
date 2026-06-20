#include "pch.h"
#include "datastore.h"
#include "datastore_internal.h"
#include "config.h"
#include "pathutil.h"
#include <algorithm>
#include <cstring>
#include <limits>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul
{
    using namespace DataStoreInternal;

    static bool ReadExact(std::ifstream& in, void* dst, std::size_t n)
    {
        in.read(reinterpret_cast<char*>(dst), static_cast<std::streamsize>(n));
        return in.good();
    }

    static bool CheckMainDataFileSize(const fs::path& path)
    {
        if (Config::GetAllowedInt("DataStoreSizeWarning", 1) == 0) {
            return false;
        }

        std::error_code ec;
        const auto bytes = fs::file_size(path, ec);
        if (ec || bytes == 0) {
            return false;
        }

        const auto logKB = std::max<std::int32_t>(1, Config::GetAllowedInt("DataStoreSizeLogKB", 512));
        const auto warnKB = std::max<std::int32_t>(1, Config::GetAllowedInt("DataStoreSizeWarnKB", 900));
        constexpr std::uintmax_t kBytesPerKB = 1024u;
        const auto logBytes = static_cast<std::uintmax_t>(logKB) * kBytesPerKB;
        const auto warnBytes = static_cast<std::uintmax_t>(warnKB) * kBytesPerKB;

        if (bytes >= logBytes || bytes >= warnBytes) {
            logger::warn(
                "IronSoul DataStore: MainData unusually large ({} bytes; log={} KB warn={} KB): {}",
                bytes,
                logKB,
                warnKB,
                path.string());
        }

        return bytes >= warnBytes;
    }

    void DataStore::Initialize()
    {
        if (_initialized.load()) {
            return;
        }

        EnsureDirectories();
        Load();

        _initialized.store(true);
    }

    bool DataStore::SizeWarningPending()
    {
        return _sizeWarningPending.load(std::memory_order_acquire);
    }

    bool DataStore::ConsumeSizeWarning()
    {
        return _sizeWarningPending.exchange(false, std::memory_order_acq_rel);
    }

    void DataStore::EnsureDirectories()
    {
        std::filesystem::create_directories(MainDataPath().parent_path());

        if (MirrorDataBackupEnabled()) {
            std::filesystem::create_directories(MirrorDataPath().parent_path());
        }
    }

    void DataStore::Load()
    {
        const fs::path mainPath = MainDataPath();
        if (CheckMainDataFileSize(mainPath)) {
            _sizeWarningPending.store(true, std::memory_order_release);
        }

        const ParsedSnapshot mainSnapshot = LoadFile(mainPath.wstring());
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
        std::filesystem::create_directories(mainPath.parent_path());
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

}
