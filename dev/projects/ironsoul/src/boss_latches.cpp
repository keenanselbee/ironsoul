#include "pch.h"
#include "boss_latches.h"

#include "anima.h"
#include "config.h"
#include "datastore.h"
#include "soul_level.h"

#include <array>
#include <format>
#include <sstream>

namespace IronSoul::BossLatches
{
namespace
{
    struct BossLatchSpec
    {
        const char* key;
        const char* source;
        std::int32_t award;
        std::int32_t soulLevel;
        bool (*defeated)();
    };

    struct QuestCache
    {
        RE::TESQuest* mq305 = nullptr;
        RE::TESQuest* dlc1vq08 = nullptr;
        RE::TESQuest* dlc2mq06 = nullptr;
        RE::TESQuest* vigilantMq08 = nullptr;
        bool triedMq305 = false;
        bool triedDlc1Vq08 = false;
        bool triedDlc2Mq06 = false;
        bool triedVigilantMq08 = false;
    };

    std::mutex g_cacheLock;
    QuestCache g_cache;

    RE::TESQuest* LookupQuestByEditorID(std::string_view a_editorID)
    {
        return RE::TESForm::LookupByEditorID<RE::TESQuest>(a_editorID);
    }

    RE::TESQuest* LookupQuestByLocalFormID(RE::FormID a_localFormID, std::string_view a_modName)
    {
        auto* dataHandler = RE::TESDataHandler::GetSingleton();
        if (!dataHandler) {
            return nullptr;
        }
        return dataHandler->LookupForm<RE::TESQuest>(a_localFormID, a_modName);
    }

    RE::TESQuest* GetMQ305()
    {
        std::lock_guard lock(g_cacheLock);
        if (!g_cache.triedMq305) {
            g_cache.triedMq305 = true;
            g_cache.mq305 = LookupQuestByEditorID("MQ305");
        }
        return g_cache.mq305;
    }

    RE::TESQuest* GetDLC1VQ08()
    {
        std::lock_guard lock(g_cacheLock);
        if (!g_cache.triedDlc1Vq08) {
            g_cache.triedDlc1Vq08 = true;
            g_cache.dlc1vq08 = LookupQuestByEditorID("DLC1VQ08");
        }
        return g_cache.dlc1vq08;
    }

    RE::TESQuest* GetDLC2MQ06()
    {
        std::lock_guard lock(g_cacheLock);
        if (!g_cache.triedDlc2Mq06) {
            g_cache.triedDlc2Mq06 = true;
            g_cache.dlc2mq06 = LookupQuestByEditorID("DLC2MQ06");
        }
        return g_cache.dlc2mq06;
    }

    RE::TESQuest* GetVigilantMQ08()
    {
        std::lock_guard lock(g_cacheLock);
        if (!g_cache.triedVigilantMq08) {
            g_cache.triedVigilantMq08 = true;
            g_cache.vigilantMq08 = LookupQuestByLocalFormID(0x0000EA8A, "Vigilant.esm");
        }
        return g_cache.vigilantMq08;
    }

    bool IsQuestStageDone(const RE::TESQuest* a_quest, std::uint16_t a_stage)
    {
        if (!a_quest || !a_quest->executedStages) {
            return false;
        }

        for (const auto& stage : *a_quest->executedStages) {
            if (stage && stage.data.index == a_stage) {
                return true;
            }
        }
        return false;
    }

    bool IsMiraakDefeated()
    {
        const auto* quest = GetDLC2MQ06();
        if (!quest) {
            return false;
        }
        return IsQuestStageDone(quest, 580) || IsQuestStageDone(quest, 600) || quest->IsCompleted();
    }

    bool IsAlduinDefeated()
    {
        const auto* quest = GetMQ305();
        return quest && quest->GetCurrentStageID() >= 190;
    }

    bool IsHarkonDefeated()
    {
        const auto* quest = GetDLC1VQ08();
        return quest && quest->GetCurrentStageID() >= 200;
    }

    bool IsMolagBalDefeated()
    {
        const auto* quest = GetVigilantMQ08();
        return quest && quest->GetCurrentStageID() >= 310;
    }

    std::string MakeGuidKey(std::string_view a_key, std::string_view a_guid)
    {
        return std::format("{}:{}", a_key, a_guid);
    }

    void AppendPayload(std::ostringstream& a_out, const std::string& a_payload)
    {
        if (a_payload.empty()) {
            return;
        }
        if (a_out.tellp() > 0) {
            a_out << '\n';
        }
        a_out << a_payload;
    }

    std::string PollBoss(
        const BossLatchSpec& a_spec,
        std::string_view a_guid,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld)
    {
        const std::string latchKey = MakeGuidKey(a_spec.key, a_guid);
        if (DataStore::GetInt(latchKey, 0) == 1) {
            return {};
        }

        if (!a_spec.defeated()) {
            return {};
        }

        DataStore::SetIntIfChanged(latchKey, 1);
        if (Config::ShouldEmitInfoLog()) {
            logger::info("IronSoul BossLatches: {} latched TRUE (one-shot)", a_spec.source);
        }

        const std::string payload = Anima::AddCharacter(a_guid, a_spec.award, a_spec.source, a_characterDragonSouls, a_currentDeaths, a_updateWorld);
        if (payload.rfind("ok|", 0) == 0) {
            SoulLevel::NoteSlain(a_guid, a_spec.soulLevel, a_updateWorld);
        }
        return payload;
    }

    constexpr std::array<BossLatchSpec, 4> kBosses{ {
        { "IS_1627", "Molag Bal", 1000, 5, IsMolagBalDefeated },
        { "IS_4911", "Miraak", 1000, 5, IsMiraakDefeated },
        { "IS_9897", "Alduin", 500, 4, IsAlduinDefeated },
        { "IS_9808", "Harkon", 500, 4, IsHarkonDefeated },
    } };
}

    std::string PollAnimaBossLatches(
        std::string_view a_guid,
        std::int32_t a_characterDragonSouls,
        std::int32_t a_currentDeaths,
        bool a_updateWorld)
    {
        if (a_guid.empty()) {
            return "error|guid";
        }
        if (!DataStore::IsInitialized()) {
            return "skip|datastore";
        }

        std::ostringstream out;
        for (const auto& boss : kBosses) {
            AppendPayload(out, PollBoss(boss, a_guid, a_characterDragonSouls, a_currentDeaths, a_updateWorld));
        }

        const std::string payload = out.str();
        return payload.empty() ? "skip|none" : payload;
    }
}
