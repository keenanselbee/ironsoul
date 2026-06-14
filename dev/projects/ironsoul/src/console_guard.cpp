#include "pch.h"
#include "console_guard.h"
#include "config.h"

#include <algorithm>
#include <array>
#include <cctype>
#include <span>
#include <string_view>

namespace IronSoul::ConsoleGuard
{
namespace
{
    using ExecuteFn = RE::SCRIPT_FUNCTION::Execute_t;

    constexpr const char* kBlockedMessage = "Dragon Soul commands are disabled by Iron Soul anticheat.";

    ExecuteFn* g_originalSetActorValue = nullptr;
    ExecuteFn* g_originalModActorValue = nullptr;
    bool g_installed = false;

    bool EqualsIgnoreCase(std::string_view a_left, std::string_view a_right)
    {
        if (a_left.size() != a_right.size()) {
            return false;
        }

        for (std::size_t i = 0; i < a_left.size(); ++i) {
            const auto left = static_cast<unsigned char>(a_left[i]);
            const auto right = static_cast<unsigned char>(a_right[i]);
            if (std::tolower(left) != std::tolower(right)) {
                return false;
            }
        }

        return true;
    }

    bool NameMatches(const char* a_value, std::span<const std::string_view> a_names)
    {
        if (!a_value || !a_value[0]) {
            return false;
        }

        const std::string_view value{ a_value };
        return std::any_of(a_names.begin(), a_names.end(), [value](std::string_view a_name) {
            return EqualsIgnoreCase(value, a_name);
        });
    }

    RE::SCRIPT_FUNCTION* LocateScriptCommand(std::span<const std::string_view> a_names)
    {
        auto* commands = RE::SCRIPT_FUNCTION::GetFirstScriptCommand();
        if (!commands) {
            return nullptr;
        }

        for (std::uint32_t i = 0; i < RE::SCRIPT_FUNCTION::Commands::kScriptCommandsEnd; ++i) {
            auto& command = commands[i];
            if (NameMatches(command.functionName, a_names) || NameMatches(command.shortName, a_names)) {
                return &command;
            }
        }
        return nullptr;
    }

    bool TryParseActorValue(
        const RE::SCRIPT_PARAMETER* a_paramInfo,
        RE::SCRIPT_FUNCTION::ScriptData* a_scriptData,
        RE::TESObjectREFR* a_thisObj,
        RE::TESObjectREFR* a_containingObj,
        RE::Script* a_scriptObj,
        RE::ScriptLocals* a_locals,
        std::uint32_t a_opcodeOffset,
        RE::ActorValue& a_actorValue)
    {
        float value = 0.0F;
        auto parseOffset = a_opcodeOffset;
        a_actorValue = RE::ActorValue::kNone;
        return RE::Script::ParseParameters(
            a_paramInfo,
            a_scriptData,
            parseOffset,
            a_thisObj,
            a_containingObj,
            a_scriptObj,
            a_locals,
            &a_actorValue,
            &value);
    }

    void PrintBlockedMessage()
    {
        if (auto* consoleLog = RE::ConsoleLog::GetSingleton()) {
            consoleLog->Print(kBlockedMessage);
        }

        if (IronSoul::Config::ShouldEmitInfoLog()) {
            logger::info("ConsoleGuard: blocked DragonSouls setav/modav command");
        }
    }

    bool ShouldBlockDragonSoulCommand(
        const RE::SCRIPT_PARAMETER* a_paramInfo,
        RE::SCRIPT_FUNCTION::ScriptData* a_scriptData,
        RE::TESObjectREFR* a_thisObj,
        RE::TESObjectREFR* a_containingObj,
        RE::Script* a_scriptObj,
        RE::ScriptLocals* a_locals,
        std::uint32_t a_opcodeOffset)
    {
        if (!RE::ConsoleLog::IsConsoleMode()) {
            return false;
        }

        if (IronSoul::Config::GetAllowedInt("Anticheat", 1) != 1) {
            return false;
        }

        RE::ActorValue actorValue = RE::ActorValue::kNone;
        if (!TryParseActorValue(
                a_paramInfo,
                a_scriptData,
                a_thisObj,
                a_containingObj,
                a_scriptObj,
                a_locals,
                a_opcodeOffset,
                actorValue)) {
            return false;
        }

        return actorValue == RE::ActorValue::kDragonSouls;
    }

    bool ExecuteOriginal(
        ExecuteFn* a_original,
        const RE::SCRIPT_PARAMETER* a_paramInfo,
        RE::SCRIPT_FUNCTION::ScriptData* a_scriptData,
        RE::TESObjectREFR* a_thisObj,
        RE::TESObjectREFR* a_containingObj,
        RE::Script* a_scriptObj,
        RE::ScriptLocals* a_locals,
        double& a_result,
        std::uint32_t& a_opcodeOffsetPtr)
    {
        if (!a_original) {
            logger::warn("ConsoleGuard: original console command handler unavailable");
            return false;
        }

        return a_original(
            a_paramInfo,
            a_scriptData,
            a_thisObj,
            a_containingObj,
            a_scriptObj,
            a_locals,
            a_result,
            a_opcodeOffsetPtr);
    }

    bool GuardedSetActorValue(
        const RE::SCRIPT_PARAMETER* a_paramInfo,
        RE::SCRIPT_FUNCTION::ScriptData* a_scriptData,
        RE::TESObjectREFR* a_thisObj,
        RE::TESObjectREFR* a_containingObj,
        RE::Script* a_scriptObj,
        RE::ScriptLocals* a_locals,
        double& a_result,
        std::uint32_t& a_opcodeOffsetPtr)
    {
        if (ShouldBlockDragonSoulCommand(
                a_paramInfo,
                a_scriptData,
                a_thisObj,
                a_containingObj,
                a_scriptObj,
                a_locals,
                a_opcodeOffsetPtr)) {
            PrintBlockedMessage();
            a_result = 0.0;
            return true;
        }

        return ExecuteOriginal(
            g_originalSetActorValue,
            a_paramInfo,
            a_scriptData,
            a_thisObj,
            a_containingObj,
            a_scriptObj,
            a_locals,
            a_result,
            a_opcodeOffsetPtr);
    }

    bool GuardedModActorValue(
        const RE::SCRIPT_PARAMETER* a_paramInfo,
        RE::SCRIPT_FUNCTION::ScriptData* a_scriptData,
        RE::TESObjectREFR* a_thisObj,
        RE::TESObjectREFR* a_containingObj,
        RE::Script* a_scriptObj,
        RE::ScriptLocals* a_locals,
        double& a_result,
        std::uint32_t& a_opcodeOffsetPtr)
    {
        if (ShouldBlockDragonSoulCommand(
                a_paramInfo,
                a_scriptData,
                a_thisObj,
                a_containingObj,
                a_scriptObj,
                a_locals,
                a_opcodeOffsetPtr)) {
            PrintBlockedMessage();
            a_result = 0.0;
            return true;
        }

        return ExecuteOriginal(
            g_originalModActorValue,
            a_paramInfo,
            a_scriptData,
            a_thisObj,
            a_containingObj,
            a_scriptObj,
            a_locals,
            a_result,
            a_opcodeOffsetPtr);
    }

    bool InstallCommand(
        std::span<const std::string_view> a_names,
        ExecuteFn*& a_original,
        ExecuteFn* a_wrapper,
        std::string_view a_logName)
    {
        auto* command = LocateScriptCommand(a_names);
        if (!command) {
            logger::warn("ConsoleGuard: could not find {} script command", a_logName);
            return false;
        }

        if (!command->executeFunction) {
            logger::warn("ConsoleGuard: {} script command has no execute handler", a_logName);
            return false;
        }

        if (command->executeFunction == a_wrapper) {
            return true;
        }

        a_original = command->executeFunction;
        const auto wrapperAddress = reinterpret_cast<std::uintptr_t>(a_wrapper);
        REL::safe_write(reinterpret_cast<std::uintptr_t>(&command->executeFunction), wrapperAddress);

        logger::info(
            "ConsoleGuard: installed {} guard on script command '{}'/'{}'",
            a_logName,
            command->functionName ? command->functionName : "",
            command->shortName ? command->shortName : "");
        return true;
    }
}

    void Install()
    {
        if (g_installed) {
            return;
        }

        constexpr std::array<std::string_view, 3> setActorValueNames{
            "SetActorValue",
            "SetAV",
            "setav"
        };
        constexpr std::array<std::string_view, 3> modActorValueNames{
            "ModActorValue",
            "ModAV",
            "modav"
        };

        const bool installedSet = InstallCommand(
            setActorValueNames,
            g_originalSetActorValue,
            GuardedSetActorValue,
            "SetActorValue");
        const bool installedMod = InstallCommand(
            modActorValueNames,
            g_originalModActorValue,
            GuardedModActorValue,
            "ModActorValue");

        g_installed = installedSet || installedMod;
    }
}
