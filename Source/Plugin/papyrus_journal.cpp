#include "pch.h"
#include "papyrus_journal.h"
#include "papyrus_common.h"
#include "config.h"
#include "journal.h"

namespace IronSoul::Papyrus::Journal
{
namespace
{
    static void LogJournalEntry(RE::StaticFunctionTag*, std::string a_message)
    {
        // Papyrus supplies the full event text (including punctuation).
        // The plugin prepends the current player name and separator.
        const std::string name = ResolvePlayerName(true);
        std::string msg = Trim(a_message);
        if (msg.empty()) {
            return;  // nothing to log
        }

        std::string difficultyLabel;
        const auto preset = IronSoul::Config::GetAllowedInt("IronSoulPreset", 0);
        if (preset >= 1 && preset <= 3) {
            if (preset == 1) {
                difficultyLabel = "[D]";
            } else if (preset == 2) {
                difficultyLabel = "[H]";
            } else {
                difficultyLabel = "[A]";
            }

            auto plusCount = IronSoul::Config::GetIronSoulPresetPlus();
            if (plusCount < 0) {
                plusCount = 0;
            } else if (plusCount > 2) {
                plusCount = 2;
            }
            if (plusCount > 0) {
                difficultyLabel.insert(difficultyLabel.size() - 1, static_cast<std::size_t>(plusCount), '+');
            }
        }

        std::string prefix = name;
        if (!difficultyLabel.empty()) {
            prefix += " " + difficultyLabel;
        }
        IronSoul::Journal::AppendLine(prefix + " | " + msg);
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("LogJournalEntry", kScriptName, LogJournalEntry);
    }
}