#include "pch.h"
#include "death_sink.h"

#include "anima.h"
#include "config.h"
#include "datastore.h"
#include "identity.h"
#include "journal.h"
#include "soul_level.h"

#include <algorithm>
#include <cctype>
#include <deque>
#include <format>
#include <sstream>
#include <unordered_set>

namespace IronSoul::DeathSink
{
namespace
{
    constexpr std::int32_t kDragonSoulLevel = 3;
    constexpr std::int32_t kDragonPriestSoulLevel = 2;
    constexpr std::int32_t kDragonAnima = 50;
    constexpr std::int32_t kDragonPriestAnima = 25;
    constexpr std::size_t kMaxProcessedVictims = 256;
    constexpr std::size_t kMaxSessionAwardClaims = 4096;

    struct Classification
    {
        std::int32_t soulLevel = 0;
        std::int32_t amount = 0;
        std::string sourcePrefix;
    };

    class Sink : public RE::BSTEventSink<RE::TESDeathEvent>
    {
    public:
        RE::BSEventNotifyControl ProcessEvent(
            const RE::TESDeathEvent* a_event,
            RE::BSTEventSource<RE::TESDeathEvent>*) override;
    };

    std::mutex g_lock;
    Sink g_sink;
    bool g_registered = false;
    std::deque<RE::FormID> g_processedOrder;
    std::unordered_set<RE::FormID> g_processedVictims;
    std::deque<std::string> g_sessionAwardOrder;
    std::unordered_set<std::string> g_sessionAwardClaims;
    std::deque<std::string> g_awards;

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

    std::string ToLowerAscii(std::string_view a_text)
    {
        std::string result(a_text);
        for (char& c : result) {
            c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        }
        return result;
    }

    bool ContainsAsciiInsensitive(std::string_view a_text, std::string_view a_needle)
    {
        if (a_text.empty() || a_needle.empty()) {
            return false;
        }
        return ToLowerAscii(a_text).find(ToLowerAscii(a_needle)) != std::string::npos;
    }

    const char* SafeName(const RE::TESFullName* a_named)
    {
        if (!a_named) {
            return "";
        }
        const char* name = a_named->GetFullName();
        return name ? name : "";
    }

    std::string GetEditorID(const RE::TESForm* a_form)
    {
        const char* editorID = a_form ? const_cast<RE::TESForm*>(a_form)->GetFormEditorID() : nullptr;
        return editorID ? std::string(editorID) : std::string{};
    }

    std::string GetVoiceTypeEditorID(RE::Actor* a_actor)
    {
        const auto* race = a_actor ? a_actor->GetRace() : nullptr;
        if (!race) {
            return {};
        }

        const auto* voiceType = race->defaultVoiceTypes[0];
        return GetEditorID(voiceType);
    }

    std::string GetDisplayName(const RE::TESObjectREFR* a_ref, const RE::TESBoundObject* a_base)
    {
        std::string name = a_ref && a_ref->GetName() ? a_ref->GetName() : "";
        if (name.empty()) {
            name = SafeName(a_base ? a_base->As<RE::TESFullName>() : nullptr);
        }
        if (name.empty()) {
            name = GetEditorID(a_base);
        }
        if (name.empty() && a_ref) {
            name = GetEditorID(a_ref);
        }
        return name.empty() ? "Unknown" : name;
    }

    bool HasKeyword(RE::Actor* a_actor, const char* a_keyword)
    {
        return a_actor && a_actor->HasKeywordString(a_keyword);
    }

    bool AnyTextContains(
        std::string_view a_refEditorID,
        std::string_view a_baseEditorID,
        std::string_view a_name,
        std::string_view a_needle)
    {
        return ContainsAsciiInsensitive(a_refEditorID, a_needle) ||
            ContainsAsciiInsensitive(a_baseEditorID, a_needle) ||
            ContainsAsciiInsensitive(a_name, a_needle);
    }

    bool IsAlduin(
        std::string_view a_refEditorID,
        std::string_view a_baseEditorID,
        std::string_view a_name)
    {
        return AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "Alduin");
    }

    bool IsDragonPriest(
        RE::Actor* a_actor,
        std::string_view a_refEditorID,
        std::string_view a_baseEditorID,
        std::string_view a_name)
    {
        const std::string voice = GetVoiceTypeEditorID(a_actor);
        if (voice == "CrDragonPriestVoice") {
            return true;
        }

        return AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "DragonPriest") ||
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "Dragon Priest");
    }

    bool IsRecognizableNamedUndeadCultBoss(
        RE::Actor* a_actor,
        std::string_view a_refEditorID,
        std::string_view a_baseEditorID,
        std::string_view a_name)
    {
        if (!HasKeyword(a_actor, "ActorTypeUndead")) {
            return false;
        }

        const bool cultText =
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "DragonCult") ||
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "UndeadCult") ||
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "CultBoss");
        const bool bossText =
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "Boss") ||
            AnyTextContains(a_refEditorID, a_baseEditorID, a_name, "Priest");
        return cultText && bossText;
    }

    Classification ClassifyVictim(
        RE::Actor* a_actor,
        std::string_view a_refEditorID,
        std::string_view a_baseEditorID,
        std::string_view a_name)
    {
        if (HasKeyword(a_actor, "ActorTypeDragon") && !IsAlduin(a_refEditorID, a_baseEditorID, a_name)) {
            return { kDragonSoulLevel, kDragonAnima, "Dragon" };
        }

        if (IsDragonPriest(a_actor, a_refEditorID, a_baseEditorID, a_name)) {
            return { kDragonPriestSoulLevel, kDragonPriestAnima, "Dragon Priest" };
        }

        if (IsRecognizableNamedUndeadCultBoss(a_actor, a_refEditorID, a_baseEditorID, a_name)) {
            return { kDragonPriestSoulLevel, kDragonPriestAnima, "Undead Boss" };
        }

        return {};
    }

    bool IsPlayerOrPlayerAlly(RE::Actor* a_actor)
    {
        if (!a_actor) {
            return false;
        }
        if (a_actor->IsPlayerRef() || a_actor->IsPlayerTeammate()) {
            return true;
        }

        const auto commander = a_actor->GetCommandingActor();
        return commander && commander->IsPlayerRef();
    }

    bool IsCreditedKiller(const RE::TESObjectREFRPtr& a_killer)
    {
        if (!a_killer) {
            return false;
        }

        if (auto* killerActor = a_killer->As<RE::Actor>()) {
            return IsPlayerOrPlayerAlly(killerActor);
        }

        const auto* actorCause = a_killer->GetActorCause();
        RE::NiPointer<RE::Actor> causeActor;
        if (actorCause) {
            causeActor = actorCause->actor.get();
        }
        return IsPlayerOrPlayerAlly(causeActor.get());
    }

    std::string MakeGuidKey(std::string_view a_key, std::string_view a_guid)
    {
        return std::format("{}:{}", a_key, a_guid);
    }

    bool IsSessionAwardAnticheatEnabled()
    {
        return Config::GetAllowedInt("Anticheat", 1) == 1;
    }

    std::string MakeSessionAwardClaimKey(
        std::string_view a_guid,
        RE::FormID a_victimFormID,
        RE::FormID a_baseFormID,
        std::int32_t a_soulLevel)
    {
        return std::format(
            "{}|{}|{}|{}",
            a_guid,
            static_cast<std::uint32_t>(a_victimFormID),
            static_cast<std::uint32_t>(a_baseFormID),
            a_soulLevel);
    }

    bool IsTestCharacter(std::string_view a_guid)
    {
        if (DataStore::GetInt(MakeGuidKey("I.T", a_guid), 0) == 1) {
            return true;
        }

        if (Config::GetInt("PrisonerTestCharacters", 1) != 1) {
            return false;
        }

        const auto* player = RE::PlayerCharacter::GetSingleton();
        const std::string playerName = player && player->GetName() ? player->GetName() : "";
        return ContainsAsciiInsensitive(playerName, "prisoner");
    }

    std::int32_t DailyAnimaPriorityForClassification(const Classification& a_classification)
    {
        if (a_classification.soulLevel >= kDragonSoulLevel) {
            return Journal::kDailyAnimaPriorityDragon;
        }
        if (a_classification.soulLevel >= kDragonPriestSoulLevel) {
            return Journal::kDailyAnimaPriorityNamedUndead;
        }
        return Journal::kDailyAnimaPriorityMinor;
    }

    void NoteDeathSinkDailyAnimaAward(
        std::string_view a_guid,
        std::string_view a_source,
        std::int32_t a_amount,
        const Classification& a_classification)
    {
        const bool noted = Journal::NoteDailyAnimaAward(
            a_guid,
            a_source,
            a_amount,
            DailyAnimaPriorityForClassification(a_classification));
        if (!noted && Config::GetAllowedInt("CharacterJournal", 1) == 1) {
            logger::warn("IronSoul DeathSink: failed to note daily Anima award source='{}' amount={}", a_source, a_amount);
        }
    }

    bool TryMarkProcessed(RE::FormID a_formID)
    {
        if (a_formID == 0) {
            return false;
        }

        std::lock_guard lock(g_lock);
        if (!g_processedVictims.insert(a_formID).second) {
            return false;
        }

        g_processedOrder.push_back(a_formID);
        while (g_processedOrder.size() > kMaxProcessedVictims) {
            const auto oldest = g_processedOrder.front();
            g_processedOrder.pop_front();
            g_processedVictims.erase(oldest);
        }
        return true;
    }

    void ClearProcessed(RE::FormID a_formID)
    {
        if (a_formID == 0) {
            return;
        }

        std::lock_guard lock(g_lock);
        g_processedVictims.erase(a_formID);
    }

    bool TryClaimSessionAward(const std::string& a_claimKey)
    {
        if (a_claimKey.empty()) {
            return true;
        }

        std::lock_guard lock(g_lock);
        if (!g_sessionAwardClaims.insert(a_claimKey).second) {
            return false;
        }

        g_sessionAwardOrder.push_back(a_claimKey);
        while (g_sessionAwardOrder.size() > kMaxSessionAwardClaims) {
            const std::string oldest = std::move(g_sessionAwardOrder.front());
            g_sessionAwardOrder.pop_front();
            g_sessionAwardClaims.erase(oldest);
        }
        return true;
    }

    void ReleaseSessionAwardClaim(const std::string& a_claimKey)
    {
        if (a_claimKey.empty()) {
            return;
        }

        std::lock_guard lock(g_lock);
        g_sessionAwardClaims.erase(a_claimKey);
        g_sessionAwardOrder.erase(
            std::remove(g_sessionAwardOrder.begin(), g_sessionAwardOrder.end(), a_claimKey),
            g_sessionAwardOrder.end());
    }

    void QueueAwardPayload(std::string payload)
    {
        std::lock_guard lock(g_lock);
        g_awards.push_back(std::move(payload));
    }

    void ClearTransientState(std::string_view a_reason)
    {
        std::lock_guard lock(g_lock);
        g_processedOrder.clear();
        g_processedVictims.clear();
        g_awards.clear();
        if (Config::ShouldEmitInfoLog()) {
            logger::info("IronSoul DeathSink: cleared transient state reason={}", a_reason);
        }
    }

    void ClearSessionAwardClaims(std::string_view a_reason)
    {
        std::lock_guard lock(g_lock);
        g_sessionAwardOrder.clear();
        g_sessionAwardClaims.clear();
        if (Config::ShouldEmitInfoLog()) {
            logger::info("IronSoul DeathSink: cleared session award claims reason={}", a_reason);
        }
    }

    std::string AppendDeathSinkFields(
        std::string payload,
        const Classification& a_classification,
        std::string_view a_victimName,
        RE::FormID a_victimFormID,
        RE::FormID a_baseFormID)
    {
        std::ostringstream out;
        out << payload << '|'
            << a_classification.soulLevel << '|'
            << SanitizePayloadField(a_victimName) << '|'
            << static_cast<std::uint32_t>(a_victimFormID) << '|'
            << static_cast<std::uint32_t>(a_baseFormID);
        return out.str();
    }

    bool StartsWith(std::string_view a_text, std::string_view a_prefix)
    {
        return a_text.size() >= a_prefix.size() && a_text.substr(0, a_prefix.size()) == a_prefix;
    }

    void ProcessDeathEvent(const RE::TESDeathEvent* a_event)
    {
        if (!a_event) {
            return;
        }

        const auto& victimRef = a_event->actorDying;
        if (!victimRef) {
            return;
        }

        const RE::FormID victimFormID = victimRef->GetFormID();
        if (a_event->dead) {
            ClearProcessed(victimFormID);
            return;
        }

        if (!DataStore::IsInitialized()) {
            return;
        }

        const std::string guid = Identity::GetCurrentGuid();
        if (guid.empty()) {
            return;
        }

        auto* victimActor = victimRef->As<RE::Actor>();
        if (!victimActor || victimActor->IsPlayerRef() || victimRef->IsDisabled() || victimRef->IsDeleted()) {
            return;
        }

        if (!IsCreditedKiller(a_event->actorKiller)) {
            return;
        }

        const auto* base = victimRef->GetBaseObject();
        const RE::FormID baseFormID = base ? base->GetFormID() : 0;
        const std::string victimName = GetDisplayName(victimRef.get(), base);
        const std::string refEditorID = GetEditorID(victimRef.get());
        const std::string baseEditorID = GetEditorID(base);
        const Classification classification = ClassifyVictim(victimActor, refEditorID, baseEditorID, victimName);
        if (classification.amount <= 0 || classification.soulLevel <= 0) {
            return;
        }

        if (!TryMarkProcessed(victimFormID)) {
            return;
        }

        std::string sessionClaimKey;
        if (IsSessionAwardAnticheatEnabled()) {
            sessionClaimKey = MakeSessionAwardClaimKey(guid, victimFormID, baseFormID, classification.soulLevel);
            if (!TryClaimSessionAward(sessionClaimKey)) {
                if (Config::ShouldEmitInfoLog()) {
                    logger::info(
                        "IronSoul DeathSink: blocked repeated session Anima award guid={} victim={} base={} soulLevel={}",
                        guid,
                        static_cast<std::uint32_t>(victimFormID),
                        static_cast<std::uint32_t>(baseFormID),
                        classification.soulLevel);
                }
                return;
            }
        }

        const std::string source = classification.sourcePrefix + ": " + victimName;
        const std::int32_t characterDragonSouls = DataStore::GetInt(MakeGuidKey(Identity::kDragonSoulsTotalKey, guid), 0);
        const std::int32_t currentDeaths = DataStore::GetInt(MakeGuidKey(Identity::kCurrentDeathsKey, guid), 0);
        const bool updateWorld = !IsTestCharacter(guid);
        std::string payload = Anima::AddCharacter(guid, classification.amount, source, characterDragonSouls, currentDeaths, updateWorld);
        if (!StartsWith(payload, "ok|")) {
            ReleaseSessionAwardClaim(sessionClaimKey);
            logger::warn("IronSoul DeathSink: Anima award failed payload={}", payload);
            return;
        }

        SoulLevel::NoteSlain(guid, classification.soulLevel, updateWorld);

        NoteDeathSinkDailyAnimaAward(guid, source, classification.amount, classification);

        payload = AppendDeathSinkFields(std::move(payload), classification, victimName, victimFormID, baseFormID);
        QueueAwardPayload(std::move(payload));

        if (Config::ShouldEmitInfoLog()) {
            logger::info(
                "IronSoul DeathSink: awarded {} Anima source='{}' soulLevel={} guid={} updateWorld={}",
                classification.amount,
                source,
                classification.soulLevel,
                guid,
                updateWorld);
        }
    }

    void RegisterSink()
    {
        std::lock_guard lock(g_lock);
        if (g_registered) {
            return;
        }

        auto* holder = RE::ScriptEventSourceHolder::GetSingleton();
        if (!holder) {
            logger::warn("IronSoul DeathSink: ScriptEventSourceHolder unavailable");
            return;
        }

        holder->AddEventSink<RE::TESDeathEvent>(&g_sink);
        g_registered = true;
        logger::info("IronSoul DeathSink: TESDeathEvent sink registered");
    }

    void OnSKSEMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }

        if (a_message->type == SKSE::MessagingInterface::kDataLoaded) {
            RegisterSink();
            ClearTransientState("data-loaded");
        } else if (a_message->type == SKSE::MessagingInterface::kNewGame) {
            ClearTransientState("new-game");
            ClearSessionAwardClaims("new-game");
        } else if (a_message->type == SKSE::MessagingInterface::kPostLoadGame) {
            ClearTransientState("post-load-game");
        }
    }
}

    RE::BSEventNotifyControl Sink::ProcessEvent(
        const RE::TESDeathEvent* a_event,
        RE::BSTEventSource<RE::TESDeathEvent>*)
    {
        ProcessDeathEvent(a_event);
        return RE::BSEventNotifyControl::kContinue;
    }

    void RegisterLifecycleHooks()
    {
        auto* messaging = SKSE::GetMessagingInterface();
        if (!messaging) {
            logger::warn("IronSoul DeathSink: messaging interface unavailable; death sink disabled");
            return;
        }

        if (!messaging->RegisterListener(OnSKSEMessage)) {
            logger::warn("IronSoul DeathSink: failed to register lifecycle listener");
            return;
        }

        logger::info("IronSoul DeathSink: lifecycle listener registered");
    }

    void HandleSerializationRevert()
    {
        ClearTransientState("serialization-revert");
    }

    std::string DrainAnimaAwards()
    {
        std::deque<std::string> local;
        {
            std::lock_guard lock(g_lock);
            local.swap(g_awards);
        }

        std::ostringstream out;
        for (const auto& payload : local) {
            if (payload.empty()) {
                continue;
            }
            if (out.tellp() > 0) {
                out << '\n';
            }
            out << payload;
        }
        return out.str();
    }
}
