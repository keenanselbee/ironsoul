#include "pch.h"
#include "anima.h"

#include "datastore.h"

#include <array>
#include <limits>
#include <sstream>

namespace IronSoul::Anima
{
namespace
{
    constexpr std::int32_t kIronMilestone = 0;
    constexpr std::int32_t kDefiantMilestone = 1;
    constexpr std::int32_t kSilverMilestone = 2;
    constexpr std::int32_t kGoldMilestone = 3;
    constexpr std::int32_t kEbonMilestone = 4;
    constexpr std::int32_t kPlatinumMilestone = 5;
    constexpr std::int32_t kDevourMilestone = 6;
    constexpr std::int32_t kIronSoulMaxLives = 10;

    struct MilestoneRequirement
    {
        std::int32_t firstAnima;
        std::int32_t repeatAnima;
        std::int32_t firstDragonSouls;
        std::int32_t repeatDragonSouls;
    };

    constexpr std::array<MilestoneRequirement, 7> kRequirements{ {
        { 0, 0, 0, 0 },
        { 100, 50, 0, 0 },
        { 250, 125, 0, 0 },
        { 500, 250, 0, 0 },
        { 1000, 500, 0, 0 },
        { 2000, 1000, 0, 0 },
        { 5000, 2500, 50, 25 },
    } };

    std::int32_t ClampNonNegative(std::int32_t a_value)
    {
        return a_value > 0 ? a_value : 0;
    }

    std::int32_t AddClamped(std::int32_t a_left, std::int32_t a_right)
    {
        const auto sum = static_cast<std::int64_t>(a_left) + static_cast<std::int64_t>(a_right);
        const auto maxValue = static_cast<std::int64_t>((std::numeric_limits<std::int32_t>::max)());
        return static_cast<std::int32_t>(sum > maxValue ? maxValue : sum);
    }

    std::int32_t ClampMilestone(std::int32_t a_milestone)
    {
        if (a_milestone < kIronMilestone) {
            return kIronMilestone;
        }
        if (a_milestone > kDevourMilestone) {
            return kDevourMilestone;
        }
        return a_milestone;
    }

    bool IsRepeatMilestone(std::int32_t a_milestone, std::int32_t a_saveHighestUnlockedTier)
    {
        return a_milestone > kIronMilestone && a_saveHighestUnlockedTier >= a_milestone;
    }

    std::int32_t GetAnimaRequiredForMilestone(std::int32_t a_milestone, std::int32_t a_saveHighestUnlockedTier)
    {
        const auto milestone = ClampMilestone(a_milestone);
        const auto& req = kRequirements[static_cast<std::size_t>(milestone)];
        return IsRepeatMilestone(milestone, a_saveHighestUnlockedTier) ? req.repeatAnima : req.firstAnima;
    }

    std::int32_t GetDragonSoulsRequiredForMilestone(std::int32_t a_milestone, std::int32_t a_saveHighestUnlockedTier)
    {
        const auto milestone = ClampMilestone(a_milestone);
        const auto& req = kRequirements[static_cast<std::size_t>(milestone)];
        return IsRepeatMilestone(milestone, a_saveHighestUnlockedTier) ? req.repeatDragonSouls : req.firstDragonSouls;
    }

    bool IsMilestoneEligible(
        std::int32_t a_milestone,
        std::int32_t a_characterAnima,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        std::int32_t a_saveHighestUnlockedTier)
    {
        if (a_milestone <= kIronMilestone || a_milestone > kDevourMilestone) {
            return false;
        }

        if (a_milestone == kDefiantMilestone && a_currentDeaths >= kIronSoulMaxLives) {
            return false;
        }

        if (a_characterAnima < GetAnimaRequiredForMilestone(a_milestone, a_saveHighestUnlockedTier)) {
            return false;
        }

        return a_characterDragonSouls >= GetDragonSoulsRequiredForMilestone(a_milestone, a_saveHighestUnlockedTier);
    }

    std::int32_t ResolveEligibleMilestone(
        std::int32_t a_characterAnima,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        std::int32_t a_saveHighestUnlockedTier)
    {
        const auto anima = ClampNonNegative(a_characterAnima);
        const auto dragonSouls = ClampNonNegative(a_characterDragonSouls);
        const auto deaths = ClampNonNegative(a_currentDeaths);
        const auto highest = ClampMilestone(a_saveHighestUnlockedTier);

        for (std::int32_t milestone = kDevourMilestone; milestone >= kDefiantMilestone; --milestone) {
            if (IsMilestoneEligible(milestone, anima, dragonSouls, deaths, highest)) {
                return milestone;
            }
        }

        return kIronMilestone;
    }

    std::string SanitizePayloadField(std::string_view a_value)
    {
        std::string result(a_value);
        for (char& c : result) {
            if (c == '|') {
                c = '/';
            } else if (c == '\r' || c == '\n') {
                c = ' ';
            }
        }
        return result;
    }

    std::string ResultPayload(
        std::int32_t a_characterAnima,
        std::int32_t a_worldAnima,
        std::int32_t a_oldSaveHighestUnlockedTier,
        std::int32_t a_newSaveHighestUnlockedTier,
        std::int32_t a_eligibleMilestone,
        std::int32_t a_amount,
        std::string_view a_source)
    {
        std::ostringstream out;
        out << "ok|"
            << a_characterAnima << '|'
            << a_worldAnima << '|'
            << a_oldSaveHighestUnlockedTier << '|'
            << a_newSaveHighestUnlockedTier << '|'
            << a_eligibleMilestone << '|'
            << a_amount << '|'
            << SanitizePayloadField(a_source);
        return out.str();
    }

    std::string ErrorPayload(std::string_view a_reason)
    {
        return "error|" + SanitizePayloadField(a_reason);
    }

    std::string CommitCharacterResult(
        std::string_view a_guid,
        std::int32_t a_characterAnima,
        std::int32_t a_worldAnima,
        std::int32_t a_oldSaveHighestUnlockedTier,
        std::int32_t a_eligibleMilestone,
        std::int32_t a_amount,
        std::string_view a_source)
    {
        const auto oldSaveHighestUnlockedTier = ClampMilestone(a_oldSaveHighestUnlockedTier);
        const auto eligibleMilestone = ClampMilestone(a_eligibleMilestone);
        const auto newSaveHighestUnlockedTier = eligibleMilestone > oldSaveHighestUnlockedTier ? eligibleMilestone : oldSaveHighestUnlockedTier;
        if (!DataStore::SetIntIfChanged(MakeCharacterAnimaKey(a_guid), a_characterAnima)) {
            // Unchanged is fine; invalid keys are already guarded by empty GUID checks.
        }
        if (newSaveHighestUnlockedTier != oldSaveHighestUnlockedTier) {
            DataStore::SetIntIfChanged(kSaveHighestUnlockedTierKey, newSaveHighestUnlockedTier);
        }

        return ResultPayload(a_characterAnima, a_worldAnima, oldSaveHighestUnlockedTier, newSaveHighestUnlockedTier, eligibleMilestone, a_amount, a_source);
    }
}

    std::string MakeCharacterAnimaKey(std::string_view a_guid)
    {
        if (a_guid.empty()) {
            return {};
        }
        std::string key(kCharacterAnimaKey);
        key += ':';
        key += a_guid;
        return key;
    }

    std::int32_t GetCharacter(std::string_view a_guid)
    {
        const auto key = MakeCharacterAnimaKey(a_guid);
        if (key.empty()) {
            return 0;
        }
        return ClampNonNegative(DataStore::GetInt(key, 0));
    }

    std::int32_t GetWorld()
    {
        return ClampNonNegative(DataStore::GetInt(kWorldAnimaKey, 0));
    }

    std::int32_t GetSaveHighestUnlockedTier()
    {
        return ClampMilestone(DataStore::GetInt(kSaveHighestUnlockedTierKey, 0));
    }

    std::int32_t GetEligibleMilestone(std::string_view a_guid, std::int32_t a_characterDragonSouls, std::int32_t a_currentDeaths)
    {
        return ResolveEligibleMilestone(
            GetCharacter(a_guid),
            a_characterDragonSouls,
            a_currentDeaths,
            GetSaveHighestUnlockedTier());
    }

    std::int32_t GetRequiredForMilestone(std::int32_t a_milestone)
    {
        return GetAnimaRequiredForMilestone(a_milestone, GetSaveHighestUnlockedTier());
    }

    std::string AddCharacter(
        std::string_view a_guid,
        std::int32_t a_amount,
        std::string_view a_source,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld)
    {
        if (a_guid.empty()) {
            return ErrorPayload("guid");
        }

        const auto oldSaveHighestUnlockedTier = GetSaveHighestUnlockedTier();
        const auto oldCharacterAnima = GetCharacter(a_guid);
        const auto oldWorldAnima = GetWorld();
        const auto amount = ClampNonNegative(a_amount);
        if (amount <= 0) {
            const auto eligibleMilestone = ResolveEligibleMilestone(oldCharacterAnima, a_characterDragonSouls, a_currentDeaths, oldSaveHighestUnlockedTier);
            return ResultPayload(oldCharacterAnima, oldWorldAnima, oldSaveHighestUnlockedTier, oldSaveHighestUnlockedTier, eligibleMilestone, 0, a_source);
        }

        const auto newCharacterAnima = AddClamped(oldCharacterAnima, amount);
        const auto newWorldAnima = a_updateWorld ? AddClamped(oldWorldAnima, amount) : oldWorldAnima;
        const auto eligibleMilestone = ResolveEligibleMilestone(newCharacterAnima, a_characterDragonSouls, a_currentDeaths, oldSaveHighestUnlockedTier);

        if (amount > 0 && a_updateWorld) {
            DataStore::SetIntIfChanged(kWorldAnimaKey, newWorldAnima);
        }

        return CommitCharacterResult(a_guid, newCharacterAnima, newWorldAnima, oldSaveHighestUnlockedTier, eligibleMilestone, amount, a_source);
    }

    std::string SetCharacter(
        std::string_view a_guid,
        std::int32_t a_value,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths)
    {
        if (a_guid.empty()) {
            return ErrorPayload("guid");
        }

        const auto characterAnima = ClampNonNegative(a_value);
        const auto oldSaveHighestUnlockedTier = GetSaveHighestUnlockedTier();
        const auto worldAnima = GetWorld();
        const auto eligibleMilestone = ResolveEligibleMilestone(characterAnima, a_characterDragonSouls, a_currentDeaths, oldSaveHighestUnlockedTier);

        return CommitCharacterResult(a_guid, characterAnima, worldAnima, oldSaveHighestUnlockedTier, eligibleMilestone, 0, "SetAnima");
    }

    std::string SetWorld(std::int32_t a_value)
    {
        const auto worldAnima = ClampNonNegative(a_value);
        DataStore::SetIntIfChanged(kWorldAnimaKey, worldAnima);
        return ResultPayload(0, worldAnima, GetSaveHighestUnlockedTier(), GetSaveHighestUnlockedTier(), kIronMilestone, 0, "SetWorldAnima");
    }

    std::string SetSaveHighestUnlockedTier(std::int32_t a_tier)
    {
        const auto oldSaveHighestUnlockedTier = GetSaveHighestUnlockedTier();
        const auto newSaveHighestUnlockedTier = ClampMilestone(a_tier);
        DataStore::SetIntIfChanged(kSaveHighestUnlockedTierKey, newSaveHighestUnlockedTier);
        return ResultPayload(0, GetWorld(), oldSaveHighestUnlockedTier, newSaveHighestUnlockedTier, newSaveHighestUnlockedTier, 0, "SetSaveHighestUnlockedTier");
    }
}
