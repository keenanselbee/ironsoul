#include "pch.h"
#include "PathUtil.h"

namespace fs = std::filesystem;

namespace IronSoul::PathUtil
{
    fs::path GetGameRoot()
    {
        wchar_t buf[MAX_PATH]{};
        DWORD len = GetModuleFileNameW(nullptr, buf, MAX_PATH);
        if (len == 0 || len >= MAX_PATH) {
            util::report_and_fail("Iron Soul: GetModuleFileNameW failed (PathUtil)");
        }
        fs::path exePath{ buf };
        return exePath.parent_path();
    }

    fs::path GetDataRoot()
    {
        return GetGameRoot() / L"Data";
    }

    fs::path GetSksePluginsDir()
    {
        return GetDataRoot() / L"SKSE" / L"Plugins";
    }
}
