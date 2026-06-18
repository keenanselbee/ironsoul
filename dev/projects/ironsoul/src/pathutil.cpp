#include "pch.h"
#include "pathutil.h"

namespace fs = std::filesystem;

namespace IronSoul::PathUtil
{
    fs::path GetGameRoot()
    {
        // Cache the resolved root path. GetModuleFileNameW is relatively expensive and
        // this path is stable for the lifetime of the process.
        static const fs::path cachedRoot = []() -> fs::path {
            wchar_t buf[MAX_PATH]{};
            DWORD len = GetModuleFileNameW(nullptr, buf, MAX_PATH);
            if (len == 0 || len >= MAX_PATH) {
                util::report_and_fail("Iron Soul: GetModuleFileNameW failed (PathUtil)");
            }
            fs::path exePath{ buf };
            return exePath.parent_path();
        }();

        return cachedRoot;
    }

    fs::path GetDataRoot()
    {
        static const fs::path cachedDataRoot = GetGameRoot() / L"Data";
        return cachedDataRoot;
    }

    fs::path GetSksePluginsDir()
    {
        static const fs::path cachedSksePluginsDir = GetDataRoot() / L"SKSE" / L"plugins";
        return cachedSksePluginsDir;
    }

    fs::path GetIronSoulPluginDir()
    {
        static const fs::path cachedIronSoulPluginDir = GetSksePluginsDir() / L"ironsoul";
        return cachedIronSoulPluginDir;
    }
}
