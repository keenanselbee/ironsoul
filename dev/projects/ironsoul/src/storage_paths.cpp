#include "pch.h"

#include "storage_paths.h"

#include "config.h"
#include "pathutil.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <cctype>
#include <cwctype>
#include <fstream>
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

    struct HardlinkBuilderModsRootResult
    {
        std::optional<fs::path> modsRoot;
        bool metadataObserved = false;
    };

    struct HardlinkBuilderCharacterDataRootResult
    {
        std::optional<fs::path> root;
        bool metadataObserved = false;
    };

    static std::atomic_bool g_characterDataPathWarningPending{ false };

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

    static std::int32_t HexValue(char ch)
    {
        if (ch >= '0' && ch <= '9') {
            return ch - '0';
        }
        if (ch >= 'a' && ch <= 'f') {
            return 10 + (ch - 'a');
        }
        if (ch >= 'A' && ch <= 'F') {
            return 10 + (ch - 'A');
        }
        return -1;
    }

    static std::optional<std::uint32_t> ParseJsonHex4(std::string_view text, std::size_t pos)
    {
        if (pos + 4 > text.size()) {
            return std::nullopt;
        }

        std::uint32_t value = 0;
        for (std::size_t i = 0; i < 4; ++i) {
            const std::int32_t hex = HexValue(text[pos + i]);
            if (hex < 0) {
                return std::nullopt;
            }
            value = (value << 4) | static_cast<std::uint32_t>(hex);
        }
        return value;
    }

    static void AppendUtf8(std::string& out, std::uint32_t codePoint)
    {
        if (codePoint <= 0x7Fu) {
            out.push_back(static_cast<char>(codePoint));
        } else if (codePoint <= 0x7FFu) {
            out.push_back(static_cast<char>(0xC0u | (codePoint >> 6)));
            out.push_back(static_cast<char>(0x80u | (codePoint & 0x3Fu)));
        } else if (codePoint <= 0xFFFFu) {
            out.push_back(static_cast<char>(0xE0u | (codePoint >> 12)));
            out.push_back(static_cast<char>(0x80u | ((codePoint >> 6) & 0x3Fu)));
            out.push_back(static_cast<char>(0x80u | (codePoint & 0x3Fu)));
        } else {
            out.push_back(static_cast<char>(0xF0u | (codePoint >> 18)));
            out.push_back(static_cast<char>(0x80u | ((codePoint >> 12) & 0x3Fu)));
            out.push_back(static_cast<char>(0x80u | ((codePoint >> 6) & 0x3Fu)));
            out.push_back(static_cast<char>(0x80u | (codePoint & 0x3Fu)));
        }
    }

    static bool IsJsonSpace(char ch)
    {
        return ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n';
    }

    static std::size_t SkipJsonSpace(std::string_view text, std::size_t pos)
    {
        while (pos < text.size() && IsJsonSpace(text[pos])) {
            ++pos;
        }
        return pos;
    }

    static std::optional<std::string> DecodeJsonStringAt(std::string_view text, std::size_t quotePos, std::size_t& endPos)
    {
        if (quotePos >= text.size() || text[quotePos] != '"') {
            return std::nullopt;
        }

        std::string out;
        for (std::size_t i = quotePos + 1; i < text.size(); ++i) {
            const char ch = text[i];
            if (ch == '"') {
                endPos = i + 1;
                return out;
            }
            if (static_cast<unsigned char>(ch) < 0x20u) {
                return std::nullopt;
            }
            if (ch != '\\') {
                out.push_back(ch);
                continue;
            }

            if (++i >= text.size()) {
                return std::nullopt;
            }

            const char esc = text[i];
            switch (esc) {
            case '"':
            case '\\':
            case '/':
                out.push_back(esc);
                break;
            case 'b':
                out.push_back('\b');
                break;
            case 'f':
                out.push_back('\f');
                break;
            case 'n':
                out.push_back('\n');
                break;
            case 'r':
                out.push_back('\r');
                break;
            case 't':
                out.push_back('\t');
                break;
            case 'u':
            {
                auto codePoint = ParseJsonHex4(text, i + 1);
                if (!codePoint) {
                    return std::nullopt;
                }
                i += 4;

                if (*codePoint >= 0xD800u && *codePoint <= 0xDBFFu) {
                    if (i + 6 >= text.size() || text[i + 1] != '\\' || text[i + 2] != 'u') {
                        return std::nullopt;
                    }
                    auto low = ParseJsonHex4(text, i + 3);
                    if (!low || *low < 0xDC00u || *low > 0xDFFFu) {
                        return std::nullopt;
                    }
                    codePoint = 0x10000u + (((*codePoint - 0xD800u) << 10) | (*low - 0xDC00u));
                    i += 6;
                } else if (*codePoint >= 0xDC00u && *codePoint <= 0xDFFFu) {
                    return std::nullopt;
                }

                AppendUtf8(out, *codePoint);
                break;
            }
            default:
                return std::nullopt;
            }
        }

        return std::nullopt;
    }

    static std::optional<std::size_t> FindJsonPropertyValue(std::string_view objectText, std::string_view property)
    {
        std::size_t pos = 0;
        while (pos < objectText.size()) {
            pos = objectText.find('"', pos);
            if (pos == std::string_view::npos) {
                return std::nullopt;
            }

            std::size_t endPos = 0;
            auto name = DecodeJsonStringAt(objectText, pos, endPos);
            if (!name) {
                ++pos;
                continue;
            }

            std::size_t colonPos = SkipJsonSpace(objectText, endPos);
            if (colonPos < objectText.size() && objectText[colonPos] == ':' && *name == property) {
                return SkipJsonSpace(objectText, colonPos + 1);
            }

            pos = endPos;
        }

        return std::nullopt;
    }

    static std::optional<std::string_view> ExtractJsonObjectProperty(std::string_view objectText, std::string_view property)
    {
        const auto valuePos = FindJsonPropertyValue(objectText, property);
        if (!valuePos || *valuePos >= objectText.size() || objectText[*valuePos] != '{') {
            return std::nullopt;
        }

        std::uint32_t depth = 0;
        for (std::size_t i = *valuePos; i < objectText.size(); ++i) {
            if (objectText[i] == '"') {
                std::size_t endPos = 0;
                if (!DecodeJsonStringAt(objectText, i, endPos)) {
                    return std::nullopt;
                }
                i = endPos - 1;
                continue;
            }

            if (objectText[i] == '{') {
                ++depth;
            } else if (objectText[i] == '}') {
                if (depth == 0) {
                    return std::nullopt;
                }
                --depth;
                if (depth == 0) {
                    return objectText.substr(*valuePos, i - *valuePos + 1);
                }
            }
        }

        return std::nullopt;
    }

    static std::optional<std::string> ExtractJsonStringProperty(std::string_view objectText, std::string_view property)
    {
        const auto valuePos = FindJsonPropertyValue(objectText, property);
        if (!valuePos || *valuePos >= objectText.size() || objectText[*valuePos] != '"') {
            return std::nullopt;
        }

        std::size_t endPos = 0;
        return DecodeJsonStringAt(objectText, *valuePos, endPos);
    }

    static std::optional<std::string> ReadTextFileCapped(const fs::path& path, std::uintmax_t maxBytes)
    {
        std::error_code ec;
        const auto bytes = fs::file_size(path, ec);
        if (ec || bytes > maxBytes) {
            return std::nullopt;
        }

        std::ifstream in(path, std::ios::in | std::ios::binary);
        if (!in.is_open()) {
            return std::nullopt;
        }

        std::string text(static_cast<std::size_t>(bytes), '\0');
        if (!text.empty()) {
            in.read(text.data(), static_cast<std::streamsize>(text.size()));
            if (!in.good()) {
                return std::nullopt;
            }
        }
        return text;
    }

    static fs::path PathFromJsonString(std::string_view value)
    {
        return NormalizeFinalPathPrefix(TrimCopy(WidenUtf8(value))).lexically_normal();
    }

    static std::wstring NormalizePathForCompare(const fs::path& path)
    {
        std::wstring value = NormalizeFinalPathPrefix(path.wstring()).lexically_normal().wstring();
        while (value.size() > 3 && (value.back() == L'\\' || value.back() == L'/')) {
            value.pop_back();
        }
        return ToLowerWide(std::move(value));
    }

    static bool PathsEqualCaseInsensitive(const fs::path& lhs, const fs::path& rhs)
    {
        return NormalizePathForCompare(lhs) == NormalizePathForCompare(rhs);
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

    static void QueueCharacterDataPathWarning(std::string_view reason)
    {
        const bool alreadyPending = g_characterDataPathWarningPending.exchange(true, std::memory_order_acq_rel);
        if (!alreadyPending) {
            logger::warn("Iron Soul Storage: queued CharacterDataPath warning: {}", reason);
        }
    }

    static HardlinkBuilderModsRootResult TryResolveHardlinkBuilderModsRoot()
    {
        const fs::path gameRoot = PathUtil::GetGameRoot();
        const fs::path metadataDir = gameRoot / L"standalone_metadata";
        const fs::path metadataPath = metadataDir / L"standalone_metadata.json";
        HardlinkBuilderModsRootResult result;

        std::error_code ec;
        if (!fs::is_regular_file(metadataPath, ec) || ec) {
            std::error_code dirEc;
            if (fs::is_directory(metadataDir, dirEc) && !dirEc) {
                logger::warn(
                    "Iron Soul Storage: Hardlink Builder metadata directory exists but standalone_metadata.json is missing; using normal Auto fallback");
                result.metadataObserved = true;
            }
            return result;
        }

        result.metadataObserved = true;
        logger::info("Iron Soul Storage: Hardlink Builder metadata found={}", metadataPath.string());

        constexpr std::uintmax_t kMaxMetadataBytes = 1024u * 1024u;
        const auto metadata = ReadTextFileCapped(metadataPath, kMaxMetadataBytes);
        if (!metadata) {
            logger::warn("Iron Soul Storage: could not read Hardlink Builder metadata; ignoring {}", metadataPath.string());
            return result;
        }

        if (const auto standaloneInfo = ExtractJsonObjectProperty(*metadata, "standalone_info")) {
            if (const auto standalonePathValue = ExtractJsonStringProperty(*standaloneInfo, "standalone_path")) {
                const fs::path standalonePath = PathFromJsonString(*standalonePathValue);
                if (!PathsEqualCaseInsensitive(standalonePath, gameRoot)) {
                    logger::warn(
                        "Iron Soul Storage: Hardlink Builder metadata standalone_path={} does not match game root={}; ignoring metadata",
                        standalonePath.string(),
                        gameRoot.string());
                    return result;
                }
            }
        }

        const auto mo2Info = ExtractJsonObjectProperty(*metadata, "mo2_info");
        if (!mo2Info) {
            logger::warn("Iron Soul Storage: Hardlink Builder metadata missing mo2_info; using normal Auto fallback");
            return result;
        }

        std::optional<fs::path> modsRoot;
        const auto modsPathValue = ExtractJsonStringProperty(*mo2Info, "mo2_mods_path");
        if (modsPathValue && !TrimCopy(*modsPathValue).empty()) {
            modsRoot = PathFromJsonString(*modsPathValue);
        } else if (const auto basePathValue = ExtractJsonStringProperty(*mo2Info, "mo2_base_path");
                   basePathValue && !TrimCopy(*basePathValue).empty()) {
            modsRoot = PathFromJsonString(*basePathValue) / L"mods";
            logger::warn("Iron Soul Storage: Hardlink Builder metadata missing mo2_mods_path; trying mo2_base_path\\mods");
        }

        if (!modsRoot) {
            logger::warn("Iron Soul Storage: Hardlink Builder metadata missing MO2 mods path; using normal Auto fallback");
            return result;
        }

        if (!modsRoot->is_absolute()) {
            logger::warn(
                "Iron Soul Storage: Hardlink Builder MO2 mods path is not absolute after decoding: {}; using normal Auto fallback",
                modsRoot->string());
            return result;
        }

        if (!fs::is_directory(*modsRoot, ec) || ec) {
            logger::warn(
                "Iron Soul Storage: Hardlink Builder MO2 mods path does not exist or is not a directory: {}; using normal Auto fallback",
                modsRoot->string());
            return result;
        }

        logger::info("Iron Soul Storage: inferred MO2 mods root from Hardlink Builder metadata={}", modsRoot->string());
        result.modsRoot = *modsRoot;
        return result;
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

    static std::optional<fs::path> TryResolveCharacterDataRootFromModsRoot(const fs::path& modsRoot, std::string_view sourceLabel)
    {
        std::error_code ec;
        if (!fs::is_directory(modsRoot, ec) || ec) {
            logger::warn(
                "Iron Soul Storage: {} mods root is not a directory: {}; using Data-relative storage",
                sourceLabel,
                modsRoot.string());
            return std::nullopt;
        }

        std::optional<fs::path> dataMod = TryFindAutoCharacterDataMod(modsRoot);
        if (!dataMod) {
            logger::warn(
                "Iron Soul Storage: no Iron Soul Character Data mod found under {} mods root {}; using Data-relative storage",
                sourceLabel,
                modsRoot.string());
            return std::nullopt;
        }

        const fs::path candidateRoot = CharacterDataRuntimeRootFromFolder(*dataMod);
        if (!ProbeWritableDirectory(candidateRoot)) {
            logger::warn(
                "Iron Soul Storage: Character Data mod root from {} is not writable; using Data-relative storage",
                sourceLabel);
            return std::nullopt;
        }

        logger::info("Iron Soul Storage: using Character Data mod root={} (source={})", candidateRoot.string(), sourceLabel);
        return candidateRoot;
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
        return TryResolveCharacterDataRootFromModsRoot(*modsRoot, "MO2/USVFS");
    }

    static HardlinkBuilderCharacterDataRootResult TryResolveHardlinkBuilderCharacterDataRoot()
    {
        HardlinkBuilderCharacterDataRootResult result;
        const HardlinkBuilderModsRootResult modsRootResult = TryResolveHardlinkBuilderModsRoot();
        result.metadataObserved = modsRootResult.metadataObserved;
        if (!modsRootResult.modsRoot) {
            return result;
        }
        result.root = TryResolveCharacterDataRootFromModsRoot(*modsRootResult.modsRoot, "Hardlink Builder metadata");
        return result;
    }

    static fs::path ResolveCharacterDataRoot()
    {
        const std::string configuredPath = Config::GetAllowedString("CharacterDataPath", "Auto");
        if (EqualsToken(configuredPath, "auto")) {
            const HardlinkBuilderCharacterDataRootResult hardlinkResult = TryResolveHardlinkBuilderCharacterDataRoot();
            if (hardlinkResult.root) {
                return *hardlinkResult.root;
            }
            if (auto mo2Root = TryResolveMo2CharacterDataRoot()) {
                return *mo2Root;
            }
            if (hardlinkResult.metadataObserved) {
                QueueCharacterDataPathWarning("Hardlink Builder metadata was detected, but Auto could not use an Iron Soul Character Data mod");
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

    bool CharacterDataPathWarningPending()
    {
        return g_characterDataPathWarningPending.load(std::memory_order_acquire);
    }

    bool ConsumeCharacterDataPathWarning()
    {
        return g_characterDataPathWarningPending.exchange(false, std::memory_order_acq_rel);
    }
}
