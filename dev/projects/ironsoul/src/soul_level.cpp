#include "pch.h"
#include "soul_level.h"

#include "datastore.h"

#include <limits>

namespace IronSoul::SoulLevel
{
namespace
{
    bool IsValidLevel(std::int32_t a_level)
    {
        return a_level >= kMinimumLevel && a_level <= kMaximumLevel;
    }

    std::int32_t ClampNonNegative(std::int32_t a_value)
    {
        return a_value > 0 ? a_value : 0;
    }

    std::int32_t IncrementClamped(std::int32_t a_value)
    {
        const auto maxValue = (std::numeric_limits<std::int32_t>::max)();
        return a_value >= maxValue ? maxValue : a_value + 1;
    }
}

    std::string MakeWorldSlainKey(std::int32_t a_level)
    {
        if (!IsValidLevel(a_level)) {
            return {};
        }
        return "SL." + std::to_string(a_level) + ".W";
    }

    std::string MakeCharacterSlainKey(std::string_view a_guid, std::int32_t a_level)
    {
        if (a_guid.empty() || !IsValidLevel(a_level)) {
            return {};
        }
        return "SL." + std::to_string(a_level) + ".C:" + std::string(a_guid);
    }

    std::int32_t GetWorldSlain(std::int32_t a_level)
    {
        const auto key = MakeWorldSlainKey(a_level);
        return key.empty() ? 0 : ClampNonNegative(DataStore::GetInt(key, 0));
    }

    std::int32_t GetCharacterSlain(std::string_view a_guid, std::int32_t a_level)
    {
        const auto key = MakeCharacterSlainKey(a_guid, a_level);
        return key.empty() ? 0 : ClampNonNegative(DataStore::GetInt(key, 0));
    }

    bool NoteSlain(std::string_view a_guid, std::int32_t a_level, bool a_updateWorld)
    {
        const auto characterKey = MakeCharacterSlainKey(a_guid, a_level);
        if (characterKey.empty()) {
            return false;
        }

        DataStore::SetIntIfChanged(characterKey, IncrementClamped(GetCharacterSlain(a_guid, a_level)));
        if (a_updateWorld) {
            const auto worldKey = MakeWorldSlainKey(a_level);
            DataStore::SetIntIfChanged(worldKey, IncrementClamped(GetWorldSlain(a_level)));
        }
        return true;
    }
}
