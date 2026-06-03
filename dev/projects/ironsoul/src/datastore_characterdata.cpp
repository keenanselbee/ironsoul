#include "pch.h"
#include "datastore.h"
#include "datastore_internal.h"
#include <algorithm>
#include <cctype>
#include <cstdio>
#include <vector>

namespace IronSoul
{
    using namespace DataStoreInternal;

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
        "account",
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

    static constexpr const char* kHeartshardsAbsorbedKey = "IS_2740";
    static constexpr const char* kHeartshardsUnlockedKey = "IS_2741";
    static constexpr const char* kHeartshardUsedPrefix = "HS.U.";

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
        if (section == "account") {
            return "Account";
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

    static bool StartsWith(const std::string& value, const std::string& prefix)
    {
        return value.size() >= prefix.size() && value.compare(0, prefix.size(), prefix) == 0;
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

    std::string DataStore::GetCharacterData(const std::string& guid, const std::string& section)
    {
        if (guid.empty()) {
            return "Error: character GUID cannot be empty.";
        }

        const std::string sectionLower = ToLowerAscii(TrimAscii(section));
        if (!IsCharacterDataSection(sectionLower)) {
            return "Error: unknown CharacterData section '" + section + "'. Expected identity, account, core, luck, ui, soul, dsr, bosses, defiant, or journal.";
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

        if (wantsSection("account")) {
            const auto heartshardsAbsorbedIt = snapshot.find(kHeartshardsAbsorbedKey);
            if (heartshardsAbsorbedIt != snapshot.end()) {
                appendValue("account", "HeartshardsAbsorbed", heartshardsAbsorbedIt->second, CharacterDataValueFormat::Plain);
            }

            const auto heartshardsUnlockedIt = snapshot.find(kHeartshardsUnlockedKey);
            if (heartshardsUnlockedIt != snapshot.end()) {
                appendValue("account", "HeartshardsUnlocked", heartshardsUnlockedIt->second, CharacterDataValueFormat::Plain);
            }

            std::vector<std::string> usedHeartshardEntries;
            for (const auto& [key, value] : snapshot) {
                if (!StartsWith(key, kHeartshardUsedPrefix)) {
                    continue;
                }

                const std::string suffix = key.substr(std::string(kHeartshardUsedPrefix).size());
                usedHeartshardEntries.push_back("HeartshardUnlocked(" + suffix + ")=" + formatValue(value, CharacterDataValueFormat::Plain));
            }
            std::sort(usedHeartshardEntries.begin(), usedHeartshardEntries.end());

            auto& accountEntries = entries["account"];
            accountEntries.insert(accountEntries.end(), usedHeartshardEntries.begin(), usedHeartshardEntries.end());
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
}
