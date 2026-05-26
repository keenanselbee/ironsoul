#include "pch.h"
#include "papyrusbindings.h"
#include "papyrus_common.h"
#include "papyrus_config.h"
#include "papyrus_core.h"
#include "papyrus_cursor.h"
#include "papyrus_data.h"
#include "papyrus_dynamicassets.h"
#include "papyrus_healthmonitor.h"
#include "papyrus_journal.h"
#include "papyrus_musicfade.h"
#include "papyrus_runtime.h"
#include "papyrus_tonal.h"

namespace IronSoul::Papyrus
{
    bool Register()
    {
        auto* papyrus = SKSE::GetPapyrusInterface();
        if (!papyrus) {
            logger::error("Iron Soul: Papyrus interface unavailable");
            return false;
        }

        Runtime::RefreshRuntimeConfigCaches();

        const bool ok = papyrus->Register([](RE::BSScript::IVirtualMachine* a_vm) {
            // Preserve the old registration order: LogJournalEntry sits between
            // the core availability probe and identity helpers.
            Core::RegisterAvailability(a_vm);
            Journal::Register(a_vm);
            Core::RegisterIdentity(a_vm);
            Config::Register(a_vm);
            DynamicAssets::Register(a_vm);
            MusicFade::Register(a_vm);
            HealthMonitor::Register(a_vm);
            Cursor::Register(a_vm);
            Data::Register(a_vm);
            Tonal::Register(a_vm);
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
