#pragma once

#include <cstdint>
#include <string_view>

namespace IronSoul::MenuBlocker
{
    void RegisterSinks();
    void RegisterLifecycleHooks();
    void BeginHealthDepletedBlock();
    void EndHealthDepletedBlock(std::string_view a_reason);
    void EndLoadBoundaryBlock(std::string_view a_reason);
    std::int32_t Begin(std::string_view a_reason, bool a_releaseOnMainMenu);
    void End(std::int32_t a_token);
    void Clear();
    void ClearPreservingLoadBoundary();
}
