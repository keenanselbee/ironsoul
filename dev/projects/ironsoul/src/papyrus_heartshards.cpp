#include "pch.h"
#include "papyrus_heartshards.h"
#include "papyrus_itemselect.h"
#include "papyrus_common.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <format>
#include <limits>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

namespace IronSoul::Papyrus::Heartshards
{
namespace
{
    enum class TonalResult : std::int32_t
    {
        kOk = 0,
        kNoInventoryMenu = 1,
        kNoSelectedItem = 2,
        kInvalidGear = 3,
        kAlreadyCapped = 4,
        kStackSplitFailed = 5,
        kItemMissingAtApply = 6,
        kApplyFailed = 7,
        kInvalidToken = 8,
        kInvalidRequest = 9,
        kAmbiguousStack = 10,
        kInvalidOption = 11,
        kNoEligibleOptions = 12,
        kUnsupportedEffect = 13
    };

    enum class HeartshardEffect : std::int32_t
    {
        kTonalTemper = 1
    };

    enum class TokenMode
    {
        kExistingExtraList,
        kPlainBaseStack
    };

    struct TonalToken
    {
        std::int32_t token{ 0 };
        RE::FormID baseFormID{ 0 };
        RE::ExtraDataList* extraList{ nullptr };
        std::int32_t addLevels{ 0 };
        std::int32_t maxTemperLevel{ 0 };
        TokenMode mode{ TokenMode::kPlainBaseStack };
    };

    struct TemperApplySummary
    {
        float currentHealth{ 1.0F };
        float newHealth{ 1.0F };
        std::int32_t currentLevel{ 0 };
        std::int32_t newLevel{ 0 };
    };

    struct HeartshardEnhanceOption
    {
        TonalToken token;
        std::string label;
    };

    struct HeartshardEnhanceSession
    {
        std::int32_t token{ 0 };
        HeartshardEffect effect{ HeartshardEffect::kTonalTemper };
        std::int32_t power{ 0 };
        std::int32_t cap{ 0 };
        std::vector<HeartshardEnhanceOption> options;
        std::unordered_map<std::int32_t, TonalToken> rowTokens;
    };

    std::unordered_map<std::int32_t, HeartshardEnhanceSession> g_enhanceSessions;
    std::int32_t g_nextEnhanceSession = 1;
    TonalResult g_lastResult = TonalResult::kOk;
    std::string g_lastResultText = "OK";

    void SetLastResult(TonalResult a_result, std::string a_text)
    {
        g_lastResult = a_result;
        g_lastResultText = std::move(a_text);
    }

    const char* GetFormName(const RE::TESForm* a_form)
    {
        if (!a_form) {
            return "<none>";
        }
        const char* name = a_form->GetName();
        return name && name[0] ? name : "<unnamed>";
    }

    const char* GetTokenModeName(TokenMode a_mode)
    {
        return a_mode == TokenMode::kPlainBaseStack ? "plain-stack" : "extra-list";
    }

    bool IsPracticalTonalGear(RE::TESBoundObject* a_object)
    {
        if (!a_object || !a_object->GetPlayable()) {
            return false;
        }

        if (auto* weapon = a_object->As<RE::TESObjectWEAP>()) {
            return !weapon->IsStaff() && !weapon->IsBound();
        }

        if (auto* armor = a_object->As<RE::TESObjectARMO>()) {
            return armor->GetArmorRating() > 0.0F;
        }

        return false;
    }

    float GetTemperHealth(const RE::ExtraDataList* a_extraList)
    {
        if (!a_extraList) {
            return 1.0F;
        }
        auto* health = a_extraList->GetByType<RE::ExtraHealth>();
        return health ? health->health : 1.0F;
    }

    std::int32_t GetTemperLevel(float a_health)
    {
        if (a_health < 1.0F) {
            return -1;
        }
        return static_cast<std::int32_t>(std::floor(((a_health - 1.0F) * 10.0F) + 0.5F));
    }

    float GetTemperHealthForLevel(std::int32_t a_level)
    {
        const float targetHealth = 1.0F + (static_cast<float>(a_level) * 0.1F);
        if (a_level <= 0) {
            return targetHealth;
        }
        return std::nextafter(targetHealth, std::numeric_limits<float>::infinity());
    }

    std::string FormatTemperSummary(const RE::TESForm* a_form, std::int32_t a_currentLevel, std::int32_t a_newLevel)
    {
        return std::format("{} +{} -> +{}", GetFormName(a_form), a_currentLevel, a_newLevel);
    }

    bool SetTemperHealth(RE::ExtraDataList* a_extraList, float a_health)
    {
        if (!a_extraList || a_health <= 1.0F) {
            return false;
        }

        if (auto* health = a_extraList->GetByType<RE::ExtraHealth>()) {
            health->health = a_health;
            return true;
        }

        return a_extraList->Add(new RE::ExtraHealth(a_health)) != nullptr;
    }

    std::size_t GetExtraDataListRuntimeSize()
    {
        if (REL::Module::IsAE() && REL::Module::get().version().compare(SKSE::RUNTIME_SSE_1_6_629) != std::strong_ordering::less) {
            return 0x20;
        }
        return 0x18;
    }

    RE::ExtraDataList* CreateExtraDataList()
    {
        // CommonLib does not wrap the game constructor for ExtraDataList. A zeroed
        // list matches the runtime layout's empty state before extras are added.
        return reinterpret_cast<RE::ExtraDataList*>(RE::calloc(1, GetExtraDataListRuntimeSize()));
    }

    RE::InventoryEntryData* FindCanonicalEntry(RE::TESBoundObject* a_object)
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player || !a_object) {
            return nullptr;
        }

        auto* invChanges = player->GetInventoryChanges();
        if (!invChanges || !invChanges->entryList) {
            return nullptr;
        }

        for (auto* entry : *invChanges->entryList) {
            if (entry && entry->object == a_object) {
                return entry;
            }
        }

        return nullptr;
    }

    bool EntryContainsExtraList(RE::InventoryEntryData* a_entry, RE::ExtraDataList* a_extraList)
    {
        if (!a_entry || !a_entry->extraLists || !a_extraList) {
            return false;
        }

        for (auto* extraList : *a_entry->extraLists) {
            if (extraList == a_extraList) {
                return true;
            }
        }

        return false;
    }

    bool InventoryContainsExtraList(RE::TESBoundObject* a_object, RE::ExtraDataList* a_extraList)
    {
        return EntryContainsExtraList(FindCanonicalEntry(a_object), a_extraList);
    }

    std::int32_t CountInventoryItems(RE::TESBoundObject* a_object)
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player || !a_object) {
            return 0;
        }

        const auto inventory = player->GetInventory([&](RE::TESBoundObject& a_item) {
            return std::addressof(a_item) == a_object;
        });
        const auto it = inventory.find(a_object);
        if (it == inventory.end()) {
            return 0;
        }
        return it->second.first;
    }

    std::int32_t CountExtraListItems(const RE::InventoryEntryData* a_entry)
    {
        if (!a_entry || !a_entry->extraLists) {
            return 0;
        }

        std::int32_t count = 0;
        for (auto* extraList : *a_entry->extraLists) {
            if (!extraList) {
                continue;
            }

            const std::int32_t extraCount = extraList->GetCount();
            if (extraCount > 0) {
                count += extraCount;
            }
        }
        return count;
    }

    std::int32_t CountExtraLists(const RE::InventoryEntryData* a_entry)
    {
        if (!a_entry || !a_entry->extraLists) {
            return 0;
        }

        std::int32_t count = 0;
        for (auto* extraList : *a_entry->extraLists) {
            if (extraList) {
                ++count;
            }
        }
        return count;
    }

    RE::ExtraDataList* ResolveSingleExtraList(RE::InventoryEntryData* a_entry)
    {
        if (!a_entry || !a_entry->extraLists) {
            return nullptr;
        }

        RE::ExtraDataList* found = nullptr;
        for (auto* extraList : *a_entry->extraLists) {
            if (!extraList) {
                continue;
            }
            if (found) {
                return nullptr;
            }
            found = extraList;
        }
        return found;
    }

    std::int32_t CountPlainInventoryItems(RE::TESBoundObject* a_object)
    {
        return (std::max)(0, CountInventoryItems(a_object) - CountExtraListItems(FindCanonicalEntry(a_object)));
    }

    std::int32_t NextEnhanceSessionToken()
    {
        if (g_nextEnhanceSession <= 0) {
            g_nextEnhanceSession = 1;
        }
        return g_nextEnhanceSession++;
    }

    HeartshardEnhanceOption BuildTonalEnhanceOption(
        RE::TESBoundObject* a_object,
        RE::ExtraDataList* a_extraList,
        TokenMode a_mode,
        std::int32_t a_currentLevel,
        std::int32_t a_addLevels,
        std::int32_t a_maxTemperLevel)
    {
        const std::int32_t newLevel = (std::min)(a_currentLevel + a_addLevels, a_maxTemperLevel);

        TonalToken token;
        token.token = 0;
        token.baseFormID = a_object ? a_object->GetFormID() : 0;
        token.extraList = a_extraList;
        token.addLevels = a_addLevels;
        token.maxTemperLevel = a_maxTemperLevel;
        token.mode = a_mode;

        return { token, FormatTemperSummary(a_object, a_currentLevel, newLevel) };
    }

    std::optional<HeartshardEnhanceOption> BuildTonalEnhanceOptionFromInventoryEntry(
        RE::InventoryEntryData* a_entry,
        std::int32_t a_addLevels,
        std::int32_t a_maxTemperLevel)
    {
        auto* object = a_entry ? a_entry->object : nullptr;
        if (!object || a_entry->countDelta <= 0 || !IsPracticalTonalGear(object)) {
            return std::nullopt;
        }

        const std::int32_t extraListCount = CountExtraLists(a_entry);
        if (extraListCount == 0) {
            if (CountPlainInventoryItems(object) <= 0) {
                return std::nullopt;
            }
            return BuildTonalEnhanceOption(
                object,
                nullptr,
                TokenMode::kPlainBaseStack,
                0,
                a_addLevels,
                a_maxTemperLevel);
        }

        auto* extraList = ResolveSingleExtraList(a_entry);
        if (!extraList || extraList->GetCount() > 1) {
            return std::nullopt;
        }

        const std::int32_t currentLevel = GetTemperLevel(GetTemperHealth(extraList));
        if (currentLevel < 0 || currentLevel >= a_maxTemperLevel) {
            return std::nullopt;
        }

        return BuildTonalEnhanceOption(
            object,
            extraList,
            TokenMode::kExistingExtraList,
            currentLevel,
            a_addLevels,
            a_maxTemperLevel);
    }

    void AppendSerializedRow(std::string& a_output, std::int32_t a_rowIndex, std::string_view a_label)
    {
        if (!a_output.empty()) {
            a_output += "_|_";
        }
        a_output += std::format("{}_:_{}", a_rowIndex, a_label);
    }

    std::vector<HeartshardEnhanceOption> BuildTonalEnhanceOptions(std::int32_t a_addLevels, std::int32_t a_maxTemperLevel)
    {
        std::vector<HeartshardEnhanceOption> options;

        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player || a_addLevels <= 0 || a_maxTemperLevel <= 0) {
            return options;
        }

        const auto inventory = player->GetInventory([](RE::TESBoundObject& a_item) {
            return IsPracticalTonalGear(std::addressof(a_item));
        });

        for (const auto& [object, itemData] : inventory) {
            if (!object || itemData.first <= 0 || !IsPracticalTonalGear(object)) {
                continue;
            }

            auto* entry = FindCanonicalEntry(object);
            const std::int32_t plainCount = (std::max)(0, itemData.first - CountExtraListItems(entry));
            if (plainCount > 0) {
                options.push_back(BuildTonalEnhanceOption(
                    object,
                    nullptr,
                    TokenMode::kPlainBaseStack,
                    0,
                    a_addLevels,
                    a_maxTemperLevel));
            }

            if (!entry || !entry->extraLists) {
                continue;
            }

            for (auto* extraList : *entry->extraLists) {
                if (!extraList || extraList->GetCount() > 1) {
                    continue;
                }

                const std::int32_t currentLevel = GetTemperLevel(GetTemperHealth(extraList));
                if (currentLevel < 0 || currentLevel >= a_maxTemperLevel) {
                    continue;
                }

                options.push_back(BuildTonalEnhanceOption(
                    object,
                    extraList,
                    TokenMode::kExistingExtraList,
                    currentLevel,
                    a_addLevels,
                    a_maxTemperLevel));
            }
        }

        return options;
    }

    bool ApplyTemperToExistingExtraList(RE::TESBoundObject* a_object, const TonalToken& a_token, TemperApplySummary& a_summary)
    {
        auto* extraList = a_token.extraList;
        if (!InventoryContainsExtraList(a_object, extraList)) {
            extraList = nullptr;
        }
        if (!extraList) {
            SetLastResult(TonalResult::kItemMissingAtApply, "Selected item is no longer in inventory");
            return false;
        }

        const float currentHealth = GetTemperHealth(extraList);
        const std::int32_t currentLevel = GetTemperLevel(currentHealth);
        if (currentLevel < 0) {
            SetLastResult(TonalResult::kInvalidGear, "Selected item has invalid temper health");
            return false;
        }
        if (currentLevel >= a_token.maxTemperLevel) {
            SetLastResult(TonalResult::kAlreadyCapped, "Selected item is already at the Tonal temper cap");
            return false;
        }

        const std::int32_t newLevel = (std::min)(currentLevel + a_token.addLevels, a_token.maxTemperLevel);
        const float newHealth = GetTemperHealthForLevel(newLevel);
        if (!SetTemperHealth(extraList, newHealth)) {
            SetLastResult(TonalResult::kApplyFailed, "Could not write Tonal temper data");
            return false;
        }

        a_summary = { currentHealth, newHealth, currentLevel, newLevel };
        return true;
    }

    bool ApplyTemperToPlainBaseStack(RE::TESBoundObject* a_object, const TonalToken& a_token, TemperApplySummary& a_summary)
    {
        auto* player = RE::PlayerCharacter::GetSingleton();
        if (!player || !a_object) {
            SetLastResult(TonalResult::kItemMissingAtApply, "Player or selected item is unavailable");
            return false;
        }

        if (CountInventoryItems(a_object) <= 0) {
            SetLastResult(TonalResult::kItemMissingAtApply, "Selected item is no longer in inventory");
            return false;
        }
        if (CountPlainInventoryItems(a_object) <= 0) {
            SetLastResult(TonalResult::kItemMissingAtApply, "Selected plain item is no longer in inventory");
            return false;
        }

        auto* extraList = CreateExtraDataList();
        if (!extraList) {
            SetLastResult(TonalResult::kApplyFailed, "Could not allocate Tonal temper data");
            return false;
        }
        const std::int32_t newLevel = (std::min)(a_token.addLevels, a_token.maxTemperLevel);
        const float newHealth = GetTemperHealthForLevel(newLevel);
        if (!SetTemperHealth(extraList, newHealth)) {
            RE::free(extraList);
            SetLastResult(TonalResult::kApplyFailed, "Could not prepare Tonal temper data");
            return false;
        }

        player->RemoveItem(a_object, 1, RE::ITEM_REMOVE_REASON::kRemove, nullptr, nullptr);
        player->AddObjectToContainer(a_object, extraList, 1, nullptr);
        a_summary = { 1.0F, newHealth, 0, newLevel };
        return true;
    }

    static std::int32_t HeartshardBuildEnhanceSession(
        RE::StaticFunctionTag*,
        std::int32_t a_effectID,
        std::int32_t a_power,
        std::int32_t a_cap)
    {
        if (a_power <= 0 || a_cap <= 0) {
            SetLastResult(TonalResult::kInvalidRequest, "Invalid Heartshard enhancement request");
            return 0;
        }

        if (a_effectID != static_cast<std::int32_t>(HeartshardEffect::kTonalTemper)) {
            SetLastResult(TonalResult::kUnsupportedEffect, "Unsupported Heartshard enhancement effect");
            return 0;
        }

        HeartshardEnhanceSession session;
        session.token = NextEnhanceSessionToken();
        session.effect = HeartshardEffect::kTonalTemper;
        session.power = a_power;
        session.cap = a_cap;
        session.options = BuildTonalEnhanceOptions(a_power, a_cap);

        if (session.options.empty()) {
            SetLastResult(TonalResult::kNoEligibleOptions, "No eligible gear can be strengthened");
            logger::info("Iron Soul Heartshard: no eligible enhancement options effect={} power={} cap={}", a_effectID, a_power, a_cap);
            return 0;
        }

        const std::int32_t sessionToken = session.token;
        const std::size_t optionCount = session.options.size();
        g_enhanceSessions[sessionToken] = std::move(session);
        SetLastResult(TonalResult::kOk, "OK");
        logger::info(
            "Iron Soul Heartshard: built enhancement session token={} effect={} power={} cap={} options={}",
            sessionToken,
            a_effectID,
            a_power,
            a_cap,
            optionCount);
        return sessionToken;
    }

    static std::int32_t HeartshardGetEnhanceSessionOptionCount(RE::StaticFunctionTag*, std::int32_t a_sessionToken)
    {
        auto sessionIt = g_enhanceSessions.find(a_sessionToken);
        if (sessionIt == g_enhanceSessions.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Heartshard enhancement session is invalid or expired");
            return 0;
        }

        return static_cast<std::int32_t>(sessionIt->second.options.size());
    }

    static std::string HeartshardGetEnhanceSessionOptionLabel(
        RE::StaticFunctionTag*,
        std::int32_t a_sessionToken,
        std::int32_t a_optionIndex)
    {
        auto sessionIt = g_enhanceSessions.find(a_sessionToken);
        if (sessionIt == g_enhanceSessions.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Heartshard enhancement session is invalid or expired");
            return "";
        }

        const auto& options = sessionIt->second.options;
        if (a_optionIndex < 0 || static_cast<std::size_t>(a_optionIndex) >= options.size()) {
            SetLastResult(TonalResult::kInvalidOption, "Heartshard enhancement option is invalid");
            return "";
        }

        return options[static_cast<std::size_t>(a_optionIndex)].label;
    }

    static std::string HeartshardRefreshEnhanceSessionInventoryRows(RE::StaticFunctionTag*, std::int32_t a_sessionToken)
    {
        auto sessionIt = g_enhanceSessions.find(a_sessionToken);
        if (sessionIt == g_enhanceSessions.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Heartshard enhancement session is invalid or expired");
            return "";
        }

        auto& session = sessionIt->second;
        session.rowTokens.clear();

        auto* itemList = ItemSelect::GetOpenInventoryItemList();
        if (!itemList) {
            SetLastResult(TonalResult::kNoInventoryMenu, "Inventory menu is not open");
            return "";
        }

        std::string serializedRows;
        const auto rowCount = ItemSelect::GetInventoryRowCount(itemList);
        for (std::uint32_t rowIndex = 0; rowIndex < rowCount; ++rowIndex) {
            auto* entry = ItemSelect::GetInventoryRowEntry(itemList, rowIndex);
            auto option = BuildTonalEnhanceOptionFromInventoryEntry(entry, session.power, session.cap);
            if (!option) {
                continue;
            }

            const auto row = static_cast<std::int32_t>(rowIndex);
            session.rowTokens[row] = option->token;
            AppendSerializedRow(serializedRows, row, option->label);
        }

        if (session.rowTokens.empty()) {
            SetLastResult(TonalResult::kNoEligibleOptions, "No eligible visible inventory rows can be strengthened");
            logger::info(
                "Iron Soul Heartshard: no eligible InventoryMenu rows for session={} effect={} power={} cap={}",
                a_sessionToken,
                static_cast<std::int32_t>(session.effect),
                session.power,
                session.cap);
            return "";
        }

        SetLastResult(TonalResult::kOk, "OK");
        logger::info(
            "Iron Soul Heartshard: refreshed enhancement session rows session={} rows={}",
            a_sessionToken,
            session.rowTokens.size());
        return serializedRows;
    }

    bool ApplyEnhanceToken(
        std::int32_t a_sessionToken,
        std::int32_t a_selectionIndex,
        std::string_view a_selectionKind,
        const TonalToken& a_token)
    {
        auto* object = RE::TESForm::LookupByID<RE::TESBoundObject>(a_token.baseFormID);
        if (!object) {
            SetLastResult(TonalResult::kItemMissingAtApply, "Selected item form is no longer available");
            return false;
        }
        if (!IsPracticalTonalGear(object)) {
            SetLastResult(TonalResult::kInvalidGear, "Selected item is no longer valid Tonal gear");
            return false;
        }

        TemperApplySummary summary;
        const bool applied =
            a_token.mode == TokenMode::kExistingExtraList ?
                ApplyTemperToExistingExtraList(object, a_token, summary) :
                ApplyTemperToPlainBaseStack(object, a_token, summary);

        if (!applied) {
            logger::warn(
                "Iron Soul Heartshard: apply failed session={} {}={} form={:08X}: {}",
                a_sessionToken,
                a_selectionKind,
                a_selectionIndex,
                a_token.baseFormID,
                g_lastResultText);
            return false;
        }

        const std::string resultText = FormatTemperSummary(object, summary.currentLevel, summary.newLevel);
        SetLastResult(TonalResult::kOk, resultText);
        if (auto* player = RE::PlayerCharacter::GetSingleton()) {
            RE::SendUIMessage::SendInventoryUpdateMessage(player, object);
        }
        logger::info(
            "Iron Soul Heartshard: applied enhancement session={} {}={} form={:08X} item='{}' mode={} power={} cap={} health={:.9f}->{:.9f} level=+{}->+{} result='{}'",
            a_sessionToken,
            a_selectionKind,
            a_selectionIndex,
            a_token.baseFormID,
            GetFormName(object),
            GetTokenModeName(a_token.mode),
            a_token.addLevels,
            a_token.maxTemperLevel,
            summary.currentHealth,
            summary.newHealth,
            summary.currentLevel,
            summary.newLevel,
            resultText);
        return true;
    }

    static bool HeartshardApplyEnhanceSessionOption(
        RE::StaticFunctionTag*,
        std::int32_t a_sessionToken,
        std::int32_t a_optionIndex)
    {
        auto sessionIt = g_enhanceSessions.find(a_sessionToken);
        if (sessionIt == g_enhanceSessions.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Heartshard enhancement session is invalid or expired");
            return false;
        }

        HeartshardEnhanceSession session = std::move(sessionIt->second);
        g_enhanceSessions.erase(sessionIt);

        if (a_optionIndex < 0 || static_cast<std::size_t>(a_optionIndex) >= session.options.size()) {
            SetLastResult(TonalResult::kInvalidOption, "Heartshard enhancement option is invalid");
            return false;
        }

        if (session.effect != HeartshardEffect::kTonalTemper) {
            SetLastResult(TonalResult::kUnsupportedEffect, "Unsupported Heartshard enhancement effect");
            return false;
        }

        const TonalToken token = session.options[static_cast<std::size_t>(a_optionIndex)].token;
        return ApplyEnhanceToken(a_sessionToken, a_optionIndex, "option", token);
    }

    static bool HeartshardApplyEnhanceSessionInventoryRow(
        RE::StaticFunctionTag*,
        std::int32_t a_sessionToken,
        std::int32_t a_rowIndex)
    {
        auto sessionIt = g_enhanceSessions.find(a_sessionToken);
        if (sessionIt == g_enhanceSessions.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Heartshard enhancement session is invalid or expired");
            return false;
        }

        HeartshardEnhanceSession session = std::move(sessionIt->second);
        g_enhanceSessions.erase(sessionIt);

        auto rowIt = session.rowTokens.find(a_rowIndex);
        if (rowIt == session.rowTokens.end()) {
            SetLastResult(TonalResult::kInvalidOption, "Heartshard enhancement inventory row is invalid");
            return false;
        }

        if (session.effect != HeartshardEffect::kTonalTemper) {
            SetLastResult(TonalResult::kUnsupportedEffect, "Unsupported Heartshard enhancement effect");
            return false;
        }

        return ApplyEnhanceToken(a_sessionToken, a_rowIndex, "row", rowIt->second);
    }

    static void HeartshardReleaseEnhanceSession(RE::StaticFunctionTag*, std::int32_t a_sessionToken)
    {
        g_enhanceSessions.erase(a_sessionToken);
        SetLastResult(TonalResult::kOk, "OK");
    }

    static std::int32_t HeartshardGetEnhanceResult(RE::StaticFunctionTag*)
    {
        return static_cast<std::int32_t>(g_lastResult);
    }

    static std::string HeartshardGetEnhanceResultText(RE::StaticFunctionTag*)
    {
        return g_lastResultText;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("HeartshardBuildEnhanceSession", IronSoul::Papyrus::kScriptName, HeartshardBuildEnhanceSession);
        a_vm->RegisterFunction("HeartshardGetEnhanceSessionOptionCount", IronSoul::Papyrus::kScriptName, HeartshardGetEnhanceSessionOptionCount);
        a_vm->RegisterFunction("HeartshardGetEnhanceSessionOptionLabel", IronSoul::Papyrus::kScriptName, HeartshardGetEnhanceSessionOptionLabel);
        a_vm->RegisterFunction("HeartshardRefreshEnhanceSessionInventoryRows", IronSoul::Papyrus::kScriptName, HeartshardRefreshEnhanceSessionInventoryRows);
        a_vm->RegisterFunction("HeartshardApplyEnhanceSessionOption", IronSoul::Papyrus::kScriptName, HeartshardApplyEnhanceSessionOption);
        a_vm->RegisterFunction("HeartshardApplyEnhanceSessionInventoryRow", IronSoul::Papyrus::kScriptName, HeartshardApplyEnhanceSessionInventoryRow);
        a_vm->RegisterFunction("HeartshardReleaseEnhanceSession", IronSoul::Papyrus::kScriptName, HeartshardReleaseEnhanceSession);
        a_vm->RegisterFunction("HeartshardGetEnhanceResult", IronSoul::Papyrus::kScriptName, HeartshardGetEnhanceResult);
        a_vm->RegisterFunction("HeartshardGetEnhanceResultText", IronSoul::Papyrus::kScriptName, HeartshardGetEnhanceResultText);
    }
}
