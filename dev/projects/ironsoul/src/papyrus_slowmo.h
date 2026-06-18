#pragma once

#include <string>

namespace RE::BSScript
{
    class IVirtualMachine;
}

namespace IronSoul::Papyrus::SlowMo
{
    void Register(RE::BSScript::IVirtualMachine* a_vm);

    void ResetDeathSlowMoTracking();
    void RestoreDeathSlowMo(std::string a_reason);
    void OnHealthDepleted(double a_nowWallSec);
    void TickDeathSlowMo(double a_nowWallSec);
}
