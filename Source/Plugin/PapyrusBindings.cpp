#include "pch.h"
#include "DataStore.h"
#include "PapyrusBindings.h"
#include "Config.h"
#include "JournalLog.h"

#include <random>
#include <format>
#include <cctype>

namespace IronSoul::Papyrus
{
	// Script name that owns the global native functions.
	// In Papyrus you will call:
	//   IronSoulNative.LogJournalEntry(msg)  (plugin will prepend player name + space)
	//   int v = IronSoulNative.GetConfigInt("SomeKey", 0)
	static constexpr const char* kScriptName = "IronSoulNative";

	static std::string Trim(std::string s)
	{
		const auto first = s.find_first_not_of(" \t\n\r");
		if (first == std::string::npos) {
			return {};
		}
		const auto last = s.find_last_not_of(" \t\n\r");
		return s.substr(first, last - first + 1);
	}

	static std::string ResolvePlayerName(bool a_fallbackToPrisoner)
	{
		// Player name can be unavailable very early (pre-RaceMenu / early load).
		// For journal logging we may want a stable fallback; for Papyrus callers we often
		// want an empty string so the controller can decide when identity is "ready".
		constexpr const char* kFallback = "Prisoner";
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player) {
			return a_fallbackToPrisoner ? kFallback : std::string{};
		}

		std::string name = player->GetName();
		name = Trim(name);
		if (name.empty()) {
			return a_fallbackToPrisoner ? kFallback : std::string{};
		}
		return name;
	}

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

static void LogJournalEntry(RE::StaticFunctionTag*, std::string a_message)
	{
		// Papyrus supplies the full event text (including punctuation).
		// The plugin prepends the current player name and a single space.
		const std::string name = ResolvePlayerName(true);
		std::string msg = Trim(a_message);
		if (msg.empty()) {
			return;  // nothing to log
		}

		IronSoul::JournalLog::AppendLine(name + " " + msg);
	}

	static std::int32_t GetConfigInt(RE::StaticFunctionTag*, std::string a_key, std::int32_t a_fallback)
	{
		return IronSoul::Config::GetInt(a_key, a_fallback);
	}

// ===============================
// DataStore native wrappers
// ===============================

static int32_t DataGetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_fallback)
{
	return IronSoul::DataStore::GetInt(a_key, a_fallback);
}

static void DataSetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
{
	IronSoul::DataStore::SetInt(a_key, a_value);
}

static bool DataSetIntIfChanged(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
{
	return IronSoul::DataStore::SetIntIfChanged(a_key, a_value);
}

static std::string DataGetString(RE::StaticFunctionTag*, std::string a_key, std::string a_fallback)
{
	return IronSoul::DataStore::GetString(a_key, a_fallback);
}

static void DataSetString(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
{
	IronSoul::DataStore::SetString(a_key, a_value);
}

static bool DataSetStringIfChanged(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
{
	return IronSoul::DataStore::SetStringIfChanged(a_key, a_value);
}

static bool DataHasKey(RE::StaticFunctionTag*, std::string a_key)
{
	return IronSoul::DataStore::HasKey(a_key);
}

static void DataDeleteKey(RE::StaticFunctionTag*, std::string a_key)
{
	IronSoul::DataStore::DeleteKey(a_key);
}

static void DataFlushNow(RE::StaticFunctionTag*)
{
	IronSoul::DataStore::FlushNow();
}


	bool Register()
	{
		auto* papyrus = SKSE::GetPapyrusInterface();
		if (!papyrus) {
			logger::error("Iron Soul: Papyrus interface unavailable");
			return false;
		}

		const bool ok = papyrus->Register([](RE::BSScript::IVirtualMachine* a_vm) {
			a_vm->RegisterFunction("IsAvailable", kScriptName, IsAvailable);
			a_vm->RegisterFunction("DataStoreReady", kScriptName, DataStoreReady);
			a_vm->RegisterFunction("LogJournalEntry", kScriptName, LogJournalEntry);
			a_vm->RegisterFunction("GetPlayerName", kScriptName, GetPlayerName);
			a_vm->RegisterFunction("GenerateGuidUnique", kScriptName, GenerateGuidUnique);
			a_vm->RegisterFunction("GetConfigInt", kScriptName, GetConfigInt);
			a_vm->RegisterFunction("DataGetInt", kScriptName, DataGetInt);
			a_vm->RegisterFunction("DataSetInt", kScriptName, DataSetInt);
			a_vm->RegisterFunction("DataSetIntIfChanged", kScriptName, DataSetIntIfChanged);
			a_vm->RegisterFunction("DataGetString", kScriptName, DataGetString);
			a_vm->RegisterFunction("DataSetString", kScriptName, DataSetString);
			a_vm->RegisterFunction("DataSetStringIfChanged", kScriptName, DataSetStringIfChanged);
			a_vm->RegisterFunction("DataHasKey", kScriptName, DataHasKey);
			a_vm->RegisterFunction("DataDeleteKey", kScriptName, DataDeleteKey);
			a_vm->RegisterFunction("DataFlushNow", kScriptName, DataFlushNow);
			return true;
		});

		if (ok) {
			logger::info("Iron Soul: Registered papyrus natives on script '{}'", kScriptName);
		} else {
			logger::critical("Iron Soul: Failed to register papyrus natives");
		}

		return ok;
	}
}
