#include "pch.h"
#include "papyrusbindings.h"
#include "papyrus_anima.h"
#include "papyrus_audio.h"
#include "papyrus_common.h"
#include "papyrus_config.h"
#include "papyrus_core.h"
#include "papyrus_cursor.h"
#include "papyrus_data.h"
#include "papyrus_dynamicassets.h"
#include "papyrus_healthmonitor.h"
#include "papyrus_identity.h"
#include "papyrus_sunderhearts.h"
#include "papyrus_itemselect.h"
#include "papyrus_journal.h"
#include "papyrus_menublocker.h"
#include "papyrus_musicfade.h"
#include "papyrus_runtime.h"
#include "papyrus_runtimepulse.h"
#include "papyrus_slowmo.h"
#include "papyrus_soul_level.h"
#include "papyrus_sunderheart_focus.h"
#include "papyrus_text.h"

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
            Core::RegisterAvailability(a_vm);
            ItemSelect::Register(a_vm);
            Journal::Register(a_vm);
            Core::RegisterIdentity(a_vm);
            Config::Register(a_vm);
            Text::Register(a_vm);
            DynamicAssets::Register(a_vm);
            Audio::Register(a_vm);
            MusicFade::Register(a_vm);
            Identity::Register(a_vm);
            RuntimePulse::Register(a_vm);
            HealthMonitor::Register(a_vm);
            SlowMo::Register(a_vm);
            Cursor::Register(a_vm);
            MenuBlocker::Register(a_vm);
            Data::Register(a_vm);
            Anima::Register(a_vm);
            SoulLevel::Register(a_vm);
            Sunderhearts::Register(a_vm);
            SunderheartFocus::Register(a_vm);
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
