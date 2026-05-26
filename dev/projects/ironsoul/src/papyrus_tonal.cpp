#include "pch.h"
#include "papyrus_tonal.h"
#include "papyrus_common.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <format>
#include <limits>
#include <string>
#include <unordered_map>

namespace IronSoul::Papyrus::Tonal
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
        kAmbiguousStack = 10
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

    std::unordered_map<std::int32_t, TonalToken> g_tokens;
    std::int32_t g_nextToken = 1;
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

    RE::TESForm* GetExtraListOwner(const RE::ExtraDataList* a_extraList)
    {
        return a_extraList ? const_cast<RE::ExtraDataList*>(a_extraList)->GetOwner() : nullptr;
    }

    bool ExtraListsMatchSelectedTraits(const RE::ExtraDataList* a_selected, const RE::ExtraDataList* a_candidate)
    {
        if (!a_selected || !a_candidate) {
            return false;
        }
        if (a_selected == a_candidate) {
            return true;
        }
        if (a_selected->GetCount() != a_candidate->GetCount()) {
            return false;
        }
        if (GetTemperLevel(GetTemperHealth(a_selected)) != GetTemperLevel(GetTemperHealth(a_candidate))) {
            return false;
        }
        if (GetExtraListOwner(a_selected) != GetExtraListOwner(a_candidate)) {
            return false;
        }
        if (a_selected->GetWorn() != a_candidate->GetWorn()) {
            return false;
        }

        auto* selectedUnique = a_selected->GetByType<RE::ExtraUniqueID>();
        auto* candidateUnique = a_candidate->GetByType<RE::ExtraUniqueID>();
        if (selectedUnique || candidateUnique) {
            return selectedUnique && candidateUnique &&
                   selectedUnique->baseID == candidateUnique->baseID &&
                   selectedUnique->uniqueID == candidateUnique->uniqueID;
        }

        return true;
    }

    RE::ExtraDataList* ResolveCanonicalExtraList(RE::TESBoundObject* a_object, RE::ExtraDataList* a_selectedExtraList)
    {
        auto* entry = FindCanonicalEntry(a_object);
        if (!entry || !entry->extraLists || !a_selectedExtraList) {
            SetLastResult(TonalResult::kAmbiguousStack, "Selected item could not be matched to one inventory instance");
            return nullptr;
        }

        if (EntryContainsExtraList(entry, a_selectedExtraList)) {
            return a_selectedExtraList;
        }

        RE::ExtraDataList* found = nullptr;
        for (auto* extraList : *entry->extraLists) {
            if (!extraList) {
                continue;
            }
            if (!ExtraListsMatchSelectedTraits(a_selectedExtraList, extraList)) {
                continue;
            }
            if (found) {
                SetLastResult(TonalResult::kAmbiguousStack, "Selected item matches multiple inventory instances");
                return nullptr;
            }
            found = extraList;
        }

        if (!found) {
            SetLastResult(TonalResult::kAmbiguousStack, "Selected item could not be matched to one inventory instance");
        }
        return found;
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

    std::int32_t CountPlainInventoryItems(RE::TESBoundObject* a_object)
    {
        return (std::max)(0, CountInventoryItems(a_object) - CountExtraListItems(FindCanonicalEntry(a_object)));
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

    std::int32_t NextToken()
    {
        if (g_nextToken <= 0) {
            g_nextToken = 1;
        }
        return g_nextToken++;
    }

    std::optional<TonalToken> ResolveSelectedToken(std::int32_t a_addLevels, std::int32_t a_maxTemperLevel)
    {
        if (a_addLevels <= 0 || a_maxTemperLevel <= 0) {
            SetLastResult(TonalResult::kInvalidRequest, "Invalid Tonal temper request");
            return std::nullopt;
        }

        auto* ui = RE::UI::GetSingleton();
        auto menu = ui ? ui->GetMenu<RE::InventoryMenu>() : nullptr;
        if (!menu) {
            SetLastResult(TonalResult::kNoInventoryMenu, "Inventory menu is not open");
            return std::nullopt;
        }

        auto* itemList = menu->GetRuntimeData().itemList;
        auto* selected = itemList ? itemList->GetSelectedItem() : nullptr;
        auto* entry = selected ? selected->data.objDesc : nullptr;
        auto* object = entry ? entry->object : nullptr;
        if (!entry || !object) {
            SetLastResult(TonalResult::kNoSelectedItem, "No inventory item is selected");
            return std::nullopt;
        }

        if (!IsPracticalTonalGear(object)) {
            SetLastResult(TonalResult::kInvalidGear, "Selected item is not practical weapon or armor gear");
            logger::info("Iron Soul Tonal: rejected invalid selected gear '{}'", GetFormName(object));
            return std::nullopt;
        }

        TonalToken token;
        token.token = NextToken();
        token.baseFormID = object->GetFormID();
        token.addLevels = a_addLevels;
        token.maxTemperLevel = a_maxTemperLevel;

        const std::int32_t extraListCount = CountExtraLists(entry);
        if (extraListCount == 0) {
            if (CountPlainInventoryItems(object) <= 0) {
                SetLastResult(TonalResult::kItemMissingAtApply, "Selected plain item is no longer in inventory");
                return std::nullopt;
            }
            token.mode = TokenMode::kPlainBaseStack;
            return token;
        }

        auto* extraList = ResolveSingleExtraList(entry);
        if (!extraList) {
            SetLastResult(TonalResult::kAmbiguousStack, "Selected inventory row contains multiple item instances");
            return std::nullopt;
        }

        if (extraList->GetCount() > 1) {
            SetLastResult(TonalResult::kAmbiguousStack, "Selected item stack has shared instance data");
            return std::nullopt;
        }

        const std::int32_t currentLevel = GetTemperLevel(GetTemperHealth(extraList));
        if (currentLevel < 0) {
            SetLastResult(TonalResult::kInvalidGear, "Selected item has invalid temper health");
            return std::nullopt;
        }
        if (currentLevel >= a_maxTemperLevel) {
            SetLastResult(TonalResult::kAlreadyCapped, "Selected item is already at the Tonal temper cap");
            return std::nullopt;
        }

        auto* canonicalExtraList = ResolveCanonicalExtraList(object, extraList);
        if (!canonicalExtraList) {
            return std::nullopt;
        }

        token.mode = TokenMode::kExistingExtraList;
        token.extraList = canonicalExtraList;
        return token;
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

    static std::int32_t TonalCaptureSelectedInventoryItem(RE::StaticFunctionTag*, std::int32_t a_addLevels, std::int32_t a_maxTemperLevel)
    {
        auto token = ResolveSelectedToken(a_addLevels, a_maxTemperLevel);
        if (!token) {
            logger::info("Iron Soul Tonal: capture failed: {}", g_lastResultText);
            return 0;
        }

        const std::int32_t tokenID = token->token;
        g_tokens[tokenID] = *token;
        SetLastResult(TonalResult::kOk, "OK");
        auto* object = RE::TESForm::LookupByID<RE::TESBoundObject>(token->baseFormID);
        const float capturedHealth = token->extraList ? GetTemperHealth(token->extraList) : 1.0F;
        const std::int32_t capturedLevel = GetTemperLevel(capturedHealth);
        logger::info(
            "Iron Soul Tonal: captured selected inventory item token={} form={:08X} item='{}' mode={} addLevels={} maxLevel={} health={:.9f} level=+{}",
            tokenID,
            token->baseFormID,
            GetFormName(object),
            GetTokenModeName(token->mode),
            token->addLevels,
            token->maxTemperLevel,
            capturedHealth,
            capturedLevel);
        return tokenID;
    }

    static bool TonalApplyCapturedInventoryTemper(RE::StaticFunctionTag*, std::int32_t a_token)
    {
        auto tokenIt = g_tokens.find(a_token);
        if (tokenIt == g_tokens.end()) {
            SetLastResult(TonalResult::kInvalidToken, "Tonal selection token is invalid or expired");
            return false;
        }

        TonalToken token = tokenIt->second;
        auto* object = RE::TESForm::LookupByID<RE::TESBoundObject>(token.baseFormID);
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
            token.mode == TokenMode::kExistingExtraList ?
                ApplyTemperToExistingExtraList(object, token, summary) :
                ApplyTemperToPlainBaseStack(object, token, summary);

        if (!applied) {
            logger::warn("Iron Soul Tonal: apply failed token={} form={:08X}: {}", a_token, token.baseFormID, g_lastResultText);
            return false;
        }

        g_tokens.erase(tokenIt);
        const std::string resultText = FormatTemperSummary(object, summary.currentLevel, summary.newLevel);
        SetLastResult(TonalResult::kOk, resultText);
        if (auto* player = RE::PlayerCharacter::GetSingleton()) {
            RE::SendUIMessage::SendInventoryUpdateMessage(player, object);
        }
        logger::info(
            "Iron Soul Tonal: applied inventory temper token={} form={:08X} item='{}' mode={} addLevels={} maxLevel={} health={:.9f}->{:.9f} level=+{}->+{} result='{}'",
            a_token,
            token.baseFormID,
            GetFormName(object),
            GetTokenModeName(token.mode),
            token.addLevels,
            token.maxTemperLevel,
            summary.currentHealth,
            summary.newHealth,
            summary.currentLevel,
            summary.newLevel,
            resultText);
        return true;
    }

    static void TonalReleaseCapturedInventoryItem(RE::StaticFunctionTag*, std::int32_t a_token)
    {
        g_tokens.erase(a_token);
        SetLastResult(TonalResult::kOk, "OK");
    }

    static std::int32_t TonalGetLastResult(RE::StaticFunctionTag*)
    {
        return static_cast<std::int32_t>(g_lastResult);
    }

    static std::string TonalGetLastResultText(RE::StaticFunctionTag*)
    {
        return g_lastResultText;
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("TonalCaptureSelectedInventoryItem", IronSoul::Papyrus::kScriptName, TonalCaptureSelectedInventoryItem);
        a_vm->RegisterFunction("TonalApplyCapturedInventoryTemper", IronSoul::Papyrus::kScriptName, TonalApplyCapturedInventoryTemper);
        a_vm->RegisterFunction("TonalReleaseCapturedInventoryItem", IronSoul::Papyrus::kScriptName, TonalReleaseCapturedInventoryItem);
        a_vm->RegisterFunction("TonalGetLastResult", IronSoul::Papyrus::kScriptName, TonalGetLastResult);
        a_vm->RegisterFunction("TonalGetLastResultText", IronSoul::Papyrus::kScriptName, TonalGetLastResultText);
    }
}
