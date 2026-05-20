#include "pch.h"
#include "papyrus_core.h"
#include "papyrus_common.h"
#include "datastore.h"

#include <cctype>
#include <format>
#include <random>

namespace IronSoul::Papyrus::Core
{
namespace
{
    static std::string GetPlayerName(RE::StaticFunctionTag*)
    {
        // Return empty if the name is not yet available (Papyrus uses this to gate GUID assignment).
        return ResolvePlayerName(false);
    }

    static char FirstGuidLetterFromName(const std::string& a_playerName)
    {
        // GUID prefix letter is derived from the character name (uppercase).
        // We skip leading whitespace and prefer the first ASCII alphabetic character.
        // If unavailable, fall back to 'P' (Prisoner).
        std::string name = Trim(a_playerName);
        for (unsigned char c : name) {
            if (std::isalpha(c)) {
                return static_cast<char>(std::toupper(c));
            }
        }
        return 'P';
    }

    static std::string GenerateGuidUnique(RE::StaticFunctionTag*, std::string a_playerName)
    {
        // GUID format (v2): "<LETTER><####>" where:
        //   - LETTER is the first letter of the player name (uppercase), fallback 'P'
        //   - #### is 1000-9999
        // Collision handling:
        //   - We maintain a dedicated collision index in MainData:
        //       "G.U.<GUID>" = 1
        //   - Generation checks for key existence and CLAIMS the GUID by writing the marker
        //     before returning it.
        // This avoids scanning the entire datastore.
        thread_local std::mt19937 rng{ std::random_device{}() };
        std::uniform_int_distribution<std::int32_t> dist(1000, 9999);

        const char prefix = FirstGuidLetterFromName(a_playerName);

        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = dist(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);

            // Atomically claim the GUID marker. If it already exists, it's a collision.
            if (IronSoul::DataStore::SetIntIfAbsent(usedKey, 1)) {
                if (attempt > 1) {
                    logger::warn("IronSoul GUID: collision(s) avoided; claimed '{}' on attempt {}", guid, attempt);
                }
                return guid;
            }
        }

        // Extremely unlikely fallback: widen the space slightly.
        std::uniform_int_distribution<std::int32_t> distWide(100000, 999999);
        for (std::int32_t attempt = 1; attempt <= 64; ++attempt) {
            const auto n = distWide(rng);
            std::string guid = std::format("{}{}", prefix, n);
            std::string usedKey = std::format("G.U.{}", guid);
            if (IronSoul::DataStore::SetIntIfAbsent(usedKey, 1)) {
                logger::error("IronSoul GUID: exhausted 4-digit space; claimed widened GUID '{}'", guid);
                return guid;
            }
        }

        logger::critical("IronSoul GUID: failed to claim a unique GUID (unexpected)");
        return {};
    }

    // --- Core Native Bindings ---
    // ============================

    static bool IsAvailable(RE::StaticFunctionTag*)
    {
        // Simple probe to confirm the Iron Soul SKSE plugin is loaded and Papyrus natives are registered.
        return true;
    }

    static bool DataStoreReady(RE::StaticFunctionTag*)
    {
        // True once the native datastore has been initialized.
        return IronSoul::DataStore::IsInitialized();
    }
}

    void RegisterAvailability(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("IsAvailable", kScriptName, IsAvailable);
        a_vm->RegisterFunction("DataStoreReady", kScriptName, DataStoreReady);
    }

    void RegisterIdentity(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("GetPlayerName", kScriptName, GetPlayerName);
        a_vm->RegisterFunction("GenerateGuidUnique", kScriptName, GenerateGuidUnique);
    }

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        RegisterAvailability(a_vm);
        RegisterIdentity(a_vm);
    }
}