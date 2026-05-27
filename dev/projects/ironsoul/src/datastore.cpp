#include "pch.h"
#include "datastore.h"
#include "datastore_internal.h"

namespace IronSoul
{
    using namespace DataStoreInternal;

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

    std::int32_t DataStore::DeleteKeysWithPrefix(const std::string& prefix)
    {
        if (prefix.empty() || prefix.size() > MAX_KEY_BYTES) {
            return 0;
        }

        std::lock_guard<std::mutex> lock(_mutex);

        std::int32_t deletedCount = 0;
        for (auto it = _data.begin(); it != _data.end();) {
            const std::string& key = it->first;
            if (key.size() >= prefix.size() && key.compare(0, prefix.size(), prefix) == 0) {
                it = _data.erase(it);
                ++deletedCount;
            } else {
                ++it;
            }
        }

        if (deletedCount > 0) {
            _dirty = true;
        }
        return deletedCount;
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
