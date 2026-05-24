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
        const auto presetOrdinal = IronSoul::Config::GetIronSoulPresetOrdinal();
        auto plusCount = 0;
        if (presetOrdinal >= 1 && presetOrdinal <= 3) {
            difficultyLabel = "[D]";
            plusCount = presetOrdinal - 1;
        } else if (presetOrdinal >= 5 && presetOrdinal <= 7) {
            difficultyLabel = "[H]";
            plusCount = presetOrdinal - 5;
        } else if (presetOrdinal >= 9 && presetOrdinal <= 11) {
            difficultyLabel = "[A]";
            plusCount = presetOrdinal - 9;
        }

        if (!difficultyLabel.empty() && plusCount > 0) {
            difficultyLabel.insert(difficultyLabel.size() - 1, static_cast<std::size_t>(plusCount), '+');
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
