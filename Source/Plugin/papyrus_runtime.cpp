#include "pch.h"
#include "papyrus_runtime.h"

namespace IronSoul::Papyrus::MusicFade
{
    void RefreshMusicVolumeOverrideCache();
}

namespace IronSoul::Papyrus::Runtime
{
    void RefreshRuntimeConfigCaches()
    {
        MusicFade::RefreshMusicVolumeOverrideCache();
    }
}
