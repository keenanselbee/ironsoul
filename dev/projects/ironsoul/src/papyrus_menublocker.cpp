#include "pch.h"
#include "papyrus_menublocker.h"
#include "papyrus_common.h"
#include "menu_blocker.h"

namespace IronSoul::Papyrus::MenuBlocker
{
namespace
{
    static std::int32_t BeginMenuBlock(RE::StaticFunctionTag*, std::string a_reason, bool a_releaseOnMainMenu)
    {
        return IronSoul::MenuBlocker::Begin(a_reason, a_releaseOnMainMenu);
    }

    static void EndMenuBlock(RE::StaticFunctionTag*, std::int32_t a_token)
    {
        IronSoul::MenuBlocker::End(a_token);
    }

    static void ClearMenuBlock(RE::StaticFunctionTag*)
    {
        IronSoul::MenuBlocker::Clear();
    }

    static void ClearMenuBlockPreserveLoad(RE::StaticFunctionTag*)
    {
        IronSoul::MenuBlocker::ClearPreservingLoadBoundary();
    }

    static void EndLoadMenuBlock(RE::StaticFunctionTag*, std::string a_reason)
    {
        IronSoul::MenuBlocker::EndLoadBoundaryBlock(a_reason);
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("BeginMenuBlock", kScriptName, BeginMenuBlock);
        a_vm->RegisterFunction("EndMenuBlock", kScriptName, EndMenuBlock);
        a_vm->RegisterFunction("ClearMenuBlock", kScriptName, ClearMenuBlock);
        a_vm->RegisterFunction("ClearMenuBlockPreserveLoad", kScriptName, ClearMenuBlockPreserveLoad);
        a_vm->RegisterFunction("EndLoadMenuBlock", kScriptName, EndLoadMenuBlock);
    }
}
