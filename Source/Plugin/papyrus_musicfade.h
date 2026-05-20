#pragma once

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::MusicFade
{
    void RefreshMusicVolumeOverrideCache();
    void Register(RE::BSScript::IVirtualMachine* a_vm);
}