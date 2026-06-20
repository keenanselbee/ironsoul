#include "pch.h"

#include "storage_paths.h"

#include "config.h"
#include "pathutil.h"

#include <algorithm>
#include <array>
#include <cctype>
#include <cwctype>
#include <system_error>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul::StoragePaths
{
namespace
{
    constexpr const wchar_t* kMainDataFile = L"ironsoul-main-data.dat";
    constexpr const wchar_t* kMirrorDataFile = L"ironsoul-mirror-data.dat";
    constexpr const wchar_t* kDefaultMirrorRoot = L"%USERPROFILE%\\Documents\\My Games\\Skyrim Special Edition\\SKSE";

    struct StorageRoots
    {
        fs::path characterDataRoot;
        fs::path mirrorDataPath;
    };

    static std::string TrimCopy(std::string value)
    {
        const auto first = value.find_first_not_of(" \t\r\n");
        if (first == std::string::npos) {
            return {};
        }
        const auto last = value.find_last_not_of(" \t\r\n");
        return value.substr(first, last - first + 1);
    }

    static std::wstring TrimCopy(std::wstring value)
    {
        const auto first = value.find_first_not_of(L" \t\r\n");
        if (first == std::wstring::npos) {
            return {};
        }
        const auto last = value.find_last_not_of(L" \t\r\n");
        return value.substr(first, last - first + 1);
    }

    static std::string ToLowerAscii(std::string value)
    {
        for (char& ch : value) {
            ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
        }
        return value;
    }

    static std::wstring ToLowerWide(std::wstring value)
    {
        for (wchar_t& ch : value) {
            ch = static_cast<wchar_t>(std::towlower(ch));
        }
        return value;
    }

    static bool EqualsToken(std::string value, std::string_view token)
    {
        return ToLowerAscii(TrimCopy(std::move(value))) == token;
    }

    static std::wstring WidenUtf8(std::string_view value)
    {
        if (value.empty()) {
            return {};
        }

        const int required = MultiByteToWideChar(
            CP_UTF8,
            MB_ERR_INVALID_CHARS,
            value.data(),
            static_cast<int>(value.size()),
            nullptr,
            0);
        if (required > 0) {
            std::wstring result(static_cast<std::size_t>(required), L'\0');
            MultiByteToWideChar(
                CP_UTF8,
                MB_ERR_INVALID_CHARS,
                value.data(),
                static_cast<int>(value.size()),
                result.data(),
                required);
            return result;
        }

        std::wstring result;
        result.reserve(value.size());
        for (unsigned char ch : value) {
            result.push_back(static_cast<wchar_t>(ch));
        }
        return result;
    }

    static std::wstring StripWrappingQuotes(std::wstring value)
    {
        value = TrimCopy(std::move(value));
        if (value.size() >= 2) {
            const wchar_t front = value.front();
            const wchar_t back = value.back();
            if ((front == L'"' && back == L'"') || (front == L'\'' && back == L'\'')) {
                value = value.substr(1, value.size() - 2);
                value = TrimCopy(std::move(value));
            }
        }
        return value;
    }

    static std::wstring ExpandEnvironmentStringsCopy(const std::wstring& value)
    {
        if (value.empty()) {
            return {};
        }

        const DWORD required = ExpandEnvironmentStringsW(value.c_str(), nullptr, 0);
        if (required == 0) {
            return value;
        }

        std::wstring result(static_cast<std::size_t>(required), L'\0');
        const DWORD written = ExpandEnvironmentStringsW(value.c_str(), result.data(), required);
        if (written == 0 || written > required) {
            return value;
        }

        if (!result.empty() && result.back() == L'\0') {
            result.pop_back();
        }
        return result;
    }

    static fs::path ExpandConfiguredPath(std::string_view value)
    {
        std::wstring wide = StripWrappingQuotes(WidenUtf8(value));
        wide = ExpandEnvironmentStringsCopy(wide);
        return fs::path(wide);
    }

    static fs::path NormalizeFinalPathPrefix(std::wstring value)
    {
        constexpr std::wstring_view longPrefix = L"\\\\?\\";
        constexpr std::wstring_view longUncPrefix = L"\\\\?\\UNC\\";

        if (value.rfind(longUncPrefix.data(), 0) == 0) {
            value = L"\\\\" + value.substr(longUncPrefix.size());
        } else if (value.rfind(longPrefix.data(), 0) == 0) {
            value = value.substr(longPrefix.size());
        }
        return fs::path(value);
    }

    static std::optional<fs::path> GetModulePath(HMODULE module)
    {
        std::wstring buffer(MAX_PATH, L'\0');
        while (true) {
            const DWORD len = GetModuleFileNameW(module, buffer.data(), static_cast<DWORD>(buffer.size()));
            if (len == 0) {
                return std::nullopt;
            }
            if (len < buffer.size() - 1) {
                buffer.resize(len);
                return fs::path(buffer);
            }
            buffer.resize(buffer.size() * 2);
        }
    }

    static std::optional<fs::path> GetCurrentModulePath()
    {
        HMODULE module = nullptr;
        if (!GetModuleHandleExW(
            GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            reinterpret_cast<LPCWSTR>(&GetCurrentModulePath),
            &module)) {
            return std::nullopt;
        }
        return GetModulePath(module);
    }

    static std::optional<fs::path> GetFinalPathForFile(const fs::path& path)
    {
        HANDLE handle = CreateFileW(
            path.c_str(),
            FILE_READ_ATTRIBUTES,
            FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
            nullptr,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            nullptr);
        if (handle == INVALID_HANDLE_VALUE) {
            return std::nullopt;
        }

        std::wstring buffer(MAX_PATH, L'\0');
        DWORD len = GetFinalPathNameByHandleW(handle, buffer.data(), static_cast<DWORD>(buffer.size()), FILE_NAME_NORMALIZED);
        if (len >= buffer.size()) {
            buffer.resize(static_cast<std::size_t>(len) + 1);
            len = GetFinalPathNameByHandleW(handle, buffer.data(), static_cast<DWORD>(buffer.size()), FILE_NAME_NORMALIZED);
        }
        CloseHandle(handle);

        if (len == 0 || len >= buffer.size()) {
            return std::nullopt;
        }

        buffer.resize(len);
        return NormalizeFinalPathPrefix(std::move(buffer));
    }

    static bool IsMo2Detected()
    {
        return GetModuleHandleW(L"usvfs_x64.dll") != nullptr ||
            GetModuleHandleW(L"usvfs_x86.dll") != nullptr;
    }

    static std::optional<fs::path> TryFindModsRootInPath(fs::path path)
    {
        std::error_code ec;
        if (!fs::is_directory(path, ec)) {
            path = path.parent_path();
        }

        while (!path.empty()) {
            if (ToLowerWide(path.filename().wstring()) == L"mods" && fs::is_directory(path, ec) && !ec) {
                return path;
            }

            const fs::path parent = path.parent_path();
            if (parent == path || parent.empty()) {
                break;
            }
            path = parent;
        }
        return std::nullopt;
    }

    static bool IsLikelyMo2Root(const fs::path& path)
    {
        std::error_code ec;
        if (!fs::is_directory(path / L"mods", ec) || ec) {
            return false;
        }
        ec.clear();
        if (!fs::is_directory(path / L"profiles", ec) || ec) {
            return false;
        }
        ec.clear();

        return fs::is_regular_file(path / L"ModOrganizer.ini", ec) ||
            fs::is_regular_file(path / L"ModOrganizer.exe", ec) ||
            fs::is_regular_file(path / L"portable.txt", ec);
    }

    static std::optional<fs::path> TryResolveStockGameModsRoot()
    {
        const fs::path gameRoot = PathUtil::GetGameRoot();
        logger::info("Iron Soul Storage: game root={}", gameRoot.string());

        if (ToLowerWide(gameRoot.filename().wstring()) != L"stock game") {
            return std::nullopt;
        }

        const fs::path mo2Root = gameRoot.parent_path();
        if (mo2Root.empty() || mo2Root == gameRoot) {
            logger::warn("Iron Soul Storage: Stock Game has no parent folder; cannot infer MO2 mods root");
            return std::nullopt;
        }

        if (!IsLikelyMo2Root(mo2Root)) {
            logger::warn("Iron Soul Storage: Stock Game parent is missing MO2 markers; cannot infer MO2 mods root");
            return std::nullopt;
        }

        const fs::path modsRoot = mo2Root / L"mods";
        logger::info("Iron Soul Storage: inferred MO2 mods root from Stock Game parent={}", modsRoot.string());
        return modsRoot;
    }

    static std::optional<fs::path> TryResolveMo2ModsRoot()
    {
        if (const auto modulePath = GetCurrentModulePath()) {
            logger::info("Iron Soul Storage: current module path={}", modulePath->string());
            if (const auto modsRoot = TryFindModsRootInPath(*modulePath)) {
                return modsRoot;
            }
        } else {
            logger::warn("Iron Soul Storage: could not resolve current module path");
        }

        const fs::path iniPath = PathUtil::GetIronSoulPluginDir() / L"ironsoul.ini";
        if (const auto finalIniPath = GetFinalPathForFile(iniPath)) {
            logger::info("Iron Soul Storage: final INI path={}", finalIniPath->string());
            if (const auto modsRoot = TryFindModsRootInPath(*finalIniPath)) {
                return modsRoot;
            }
        } else {
            logger::warn("Iron Soul Storage: could not resolve final INI path");
        }

        if (const auto stockGameModsRoot = TryResolveStockGameModsRoot()) {
            return stockGameModsRoot;
        }

        return std::nullopt;
    }

    static std::wstring CompactNoDeleteToken(std::wstring value)
    {
        value = ToLowerWide(std::move(value));
        std::wstring result;
        for (wchar_t ch : value) {
            if ((ch >= L'a' && ch <= L'z') || (ch >= L'0' && ch <= L'9')) {
                result.push_back(ch);
            }
        }
        return result;
    }

    static std::wstring NormalizeCharacterDataModName(std::wstring name)
    {
        name = ToLowerWide(std::move(name));
        std::wstring result;
        for (std::size_t i = 0; i < name.size();) {
            if (name[i] == L'[') {
                const std::size_t end = name.find(L']', i + 1);
                if (end != std::wstring::npos) {
                    if (CompactNoDeleteToken(name.substr(i + 1, end - i - 1)) == L"nodelete") {
                        i = end + 1;
                        continue;
                    }
                }
            }

            const wchar_t ch = name[i];
            if ((ch >= L'a' && ch <= L'z') || (ch >= L'0' && ch <= L'9')) {
                result.push_back(ch);
            }
            ++i;
        }
        return result;
    }

    static bool ProbeWritableDirectory(const fs::path& root)
    {
        std::error_code ec;
        fs::create_directories(root, ec);
        if (ec) {
            logger::warn("Iron Soul Storage: could not create directory '{}': {}", root.string(), ec.message());
            return false;
        }

        const fs::path probePath = root / L".ironsoul-write-test.tmp";
        {
            std::ofstream out(probePath, std::ios::out | std::ios::trunc | std::ios::binary);
            if (!out.is_open()) {
                logger::warn("Iron Soul Storage: write probe could not open '{}'", probePath.string());
                return false;
            }
            out << "ok";
            out.flush();
            if (!out.good()) {
                logger::warn("Iron Soul Storage: write probe failed for '{}'", probePath.string());
                return false;
            }
        }

        fs::remove(probePath, ec);
        if (ec) {
            logger::warn("Iron Soul Storage: write probe cleanup failed for '{}': {}", probePath.string(), ec.message());
        }
        return true;
    }

    static std::optional<fs::path> TryExactCharacterDataMod(const fs::path& modsRoot, std::wstring_view folderName)
    {
        const fs::path candidate = modsRoot / fs::path(folderName);
        std::error_code ec;
        if (fs::is_directory(candidate, ec) && !ec) {
            return candidate;
        }
        return std::nullopt;
    }

    static std::optional<fs::path> TryFindAutoCharacterDataMod(const fs::path& modsRoot)
    {
        constexpr std::array<std::wstring_view, 2> exactNames = {
            L"[NoDelete] Iron Soul - Character Data",
            L"Iron Soul - Character Data"
        };

        for (std::wstring_view exactName : exactNames) {
            if (auto candidate = TryExactCharacterDataMod(modsRoot, exactName)) {
                return candidate;
            }
        }

        std::vector<fs::path> normalizedMatches;
        std::error_code ec;
        for (const fs::directory_entry& entry : fs::directory_iterator(modsRoot, ec)) {
            if (ec) {
                break;
            }
            if (!entry.is_directory(ec) || ec) {
                ec.clear();
                continue;
            }
            if (NormalizeCharacterDataModName(entry.path().filename().wstring()) == L"ironsoulcharacterdata") {
                normalizedMatches.push_back(entry.path());
            }
        }

        if (normalizedMatches.size() == 1) {
            return normalizedMatches.front();
        }
        if (normalizedMatches.size() > 1) {
            logger::warn("Iron Soul Storage: found {} normalized Character Data mod matches; falling back to Data", normalizedMatches.size());
        }
        return std::nullopt;
    }

    static fs::path CharacterDataRuntimeRootFromFolder(const fs::path& folderRoot)
    {
        return folderRoot / L"SKSE" / L"Plugins" / L"ironsoul";
    }

    static bool PathFilenameEquals(const fs::path& path, const wchar_t* expected)
    {
        return ToLowerWide(path.filename().wstring()) == expected;
    }

    static bool IsFinalCharacterDataRuntimeRoot(const fs::path& path)
    {
        const fs::path pluginsDir = path.parent_path();
        const fs::path skseDir = pluginsDir.parent_path();
        return PathFilenameEquals(path, L"ironsoul") &&
            PathFilenameEquals(pluginsDir, L"plugins") &&
            PathFilenameEquals(skseDir, L"skse");
    }

    static fs::path ResolveExplicitCharacterDataPath(const fs::path& explicitPath)
    {
        if (IsFinalCharacterDataRuntimeRoot(explicitPath)) {
            logger::info("Iron Soul Storage: explicit CharacterDataPath is final runtime root={}", explicitPath.string());
            return explicitPath;
        }

        const fs::path runtimeRoot = CharacterDataRuntimeRootFromFolder(explicitPath);
        logger::info(
            "Iron Soul Storage: using explicit CharacterDataPath folder={}, runtime root={}",
            explicitPath.string(),
            runtimeRoot.string());
        return runtimeRoot;
    }

    static std::optional<fs::path> TryResolveMo2CharacterDataRoot()
    {
        if (!IsMo2Detected()) {
            logger::info("Iron Soul Storage: MO2 usvfs not detected; using Data-relative storage");
            return std::nullopt;
        }

        logger::info("Iron Soul Storage: MO2 usvfs detected");
        const auto modsRoot = TryResolveMo2ModsRoot();
        if (!modsRoot) {
            logger::warn("Iron Soul Storage: could not infer active MO2 mods root; using Data-relative storage");
            return std::nullopt;
        }

        logger::info("Iron Soul Storage: inferred MO2 mods root={}", modsRoot->string());

        std::optional<fs::path> dataMod = TryFindAutoCharacterDataMod(*modsRoot);
        if (!dataMod) {
            logger::warn("Iron Soul Storage: no Iron Soul Character Data mod found; using Data-relative storage");
            return std::nullopt;
        }

        const fs::path candidateRoot = CharacterDataRuntimeRootFromFolder(*dataMod);
        if (!ProbeWritableDirectory(candidateRoot)) {
            logger::warn("Iron Soul Storage: Character Data mod root is not writable; using Data-relative storage");
            return std::nullopt;
        }

        logger::info("Iron Soul Storage: using Character Data mod root={}", candidateRoot.string());
        return candidateRoot;
    }

    static fs::path ResolveCharacterDataRoot()
    {
        const std::string configuredPath = Config::GetAllowedString("CharacterDataPath", "Auto");
        if (EqualsToken(configuredPath, "auto")) {
            if (auto mo2Root = TryResolveMo2CharacterDataRoot()) {
                return *mo2Root;
            }
            return PathUtil::GetIronSoulPluginDir();
        }

        fs::path explicitPath = ExpandConfiguredPath(configuredPath);
        if (!explicitPath.is_absolute()) {
            logger::warn(
                "Iron Soul Storage: CharacterDataPath='{}' is not Auto or an absolute path; using Data-relative storage",
                configuredPath);
            return PathUtil::GetIronSoulPluginDir();
        }

        const fs::path runtimeRoot = ResolveExplicitCharacterDataPath(explicitPath);
        if (!ProbeWritableDirectory(runtimeRoot)) {
            logger::warn("Iron Soul Storage: explicit CharacterDataPath runtime root is not writable; using Data-relative storage");
            return PathUtil::GetIronSoulPluginDir();
        }
        return runtimeRoot;
    }

    static fs::path ResolveMirrorDataPath()
    {
        const std::string configuredPath = Config::GetAllowedString(
            "MirrorDataPath",
            "%USERPROFILE%\\Documents\\My Games\\Skyrim Special Edition\\SKSE");
        fs::path mirrorRoot;
        if (EqualsToken(configuredPath, "auto")) {
            mirrorRoot = fs::path(ExpandEnvironmentStringsCopy(kDefaultMirrorRoot));
        } else {
            mirrorRoot = ExpandConfiguredPath(configuredPath);
        }

        if (!mirrorRoot.is_absolute()) {
            logger::warn("Iron Soul Storage: MirrorDataPath is not absolute after expansion; using default Documents SKSE folder");
            mirrorRoot = fs::path(ExpandEnvironmentStringsCopy(kDefaultMirrorRoot));
        }

        const fs::path mirrorPath = mirrorRoot / kMirrorDataFile;
        logger::info("Iron Soul Storage: using MirrorDataPath root={}, mirror file={}", mirrorRoot.string(), mirrorPath.string());
        return mirrorPath;
    }


    static const StorageRoots& ResolveStorageRoots()
    {
        static const StorageRoots roots = []() {
            StorageRoots resolved;
            resolved.characterDataRoot = ResolveCharacterDataRoot();
            resolved.mirrorDataPath = ResolveMirrorDataPath();
            logger::info("Iron Soul Storage: selected CharacterDataPath runtime root={}", resolved.characterDataRoot.string());
            logger::info("Iron Soul Storage: selected MirrorDataPath={}", resolved.mirrorDataPath.string());
            return resolved;
        }();
        return roots;
    }
}

    fs::path GetCharacterDataRoot()
    {
        return ResolveStorageRoots().characterDataRoot;
    }

    fs::path MainDataPath()
    {
        return GetCharacterDataRoot() / kMainDataFile;
    }

    fs::path MirrorDataPath()
    {
        return ResolveStorageRoots().mirrorDataPath;
    }
}
