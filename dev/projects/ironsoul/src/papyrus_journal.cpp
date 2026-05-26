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

        std::string prefix = name;
        const std::string difficultyLabel = IronSoul::Config::GetEffectiveDisplayDifficultyJournalPrefix();
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
