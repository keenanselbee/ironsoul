#include "pch.h"
#include "papyrus_dynamicassets.h"
#include "papyrus_common.h"
#include "config.h"
#include "pathutil.h"

#include <array>
#include <cstring>
#include <fstream>
#include <limits>
#include <optional>
#include <vector>

namespace IronSoul::Papyrus::DynamicAssets
{
namespace
{
    static constexpr std::int32_t kDynamicAssetTiers[] = { 0, 1, 2, 3, 4, 5, 6, 9 };

    using DynamicAssetVariants = std::vector<std::filesystem::path>;

    static std::optional<const wchar_t*> ResolveDynamicSplashTierToken(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"0_defiant";
        case 1:
            return L"1_iron";
        case 2:
            return L"2_silver";
        case 3:
            return L"3_gold";
        case 4:
            return L"4_ebon";
        case 5:
            return L"5_platinum";
        case 6:
            return L"6_devour";
        case 9:
            return L"9_chim";
        default:
            return std::nullopt;
        }
    }

    static std::int32_t NormalizeDynamicSplashPreset(std::int32_t a_presetId)
    {
        if (a_presetId == 1 || a_presetId == 2 || a_presetId == 3) {
            return a_presetId;
        }

        return 0;
    }

    static std::optional<std::wstring> ResolveDynamicSplashFile(std::int32_t a_tierId, std::int32_t a_presetId)
    {
        const auto token = ResolveDynamicSplashTierToken(a_tierId);
        if (!token) {
            return std::nullopt;
        }

        std::wstring file = L"splash_";
        auto preset = NormalizeDynamicSplashPreset(a_presetId);
        if (a_tierId == 9 && preset > 1) {
            preset = 0;
        }
        file += std::to_wstring(preset);
        file += *token;
        file += L".png";

        return file;
    }

    static std::optional<const wchar_t*> ResolveDynamicLevelWidgetFile(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"lvlWidget_0_defiant.swf";
        case 1:
            return L"lvlWidget_1_iron.swf";
        case 2:
            return L"lvlWidget_2_silver.swf";
        case 3:
            return L"lvlWidget_3_gold.swf";
        case 4:
            return L"lvlWidget_4_ebon.swf";
        case 5:
            return L"lvlWidget_5_platinum.swf";
        case 6:
            return L"lvlWidget_6_devour.swf";
        case 9:
            return L"lvlWidget_9_chim.swf";
        default:
            return std::nullopt;
        }
    }

    static DynamicAssetVariants GetDynamicSplashVariants(const std::filesystem::path& a_variantDir)
    {
        DynamicAssetVariants variants;
        for (std::int32_t preset = 0; preset <= 3; ++preset) {
            for (const auto tier : kDynamicAssetTiers) {
                const auto file = ResolveDynamicSplashFile(tier, preset);
                if (file) {
                    variants.push_back(a_variantDir / std::filesystem::path(*file));
                }
            }
        }
        return variants;
    }

    static DynamicAssetVariants GetDynamicLevelWidgetVariants(const std::filesystem::path& a_variantDir)
    {
        DynamicAssetVariants variants;
        for (const auto tier : kDynamicAssetTiers) {
            const auto file = ResolveDynamicLevelWidgetFile(tier);
            if (file) {
                variants.push_back(a_variantDir / *file);
            }
        }
        return variants;
    }

    static DynamicAssetVariants GetDynamicDraugrEyeVariants(const std::filesystem::path& a_dst)
    {
        const std::wstring stem = a_dst.stem().wstring();
        const std::wstring extension = a_dst.extension().wstring();
        const auto parent = a_dst.parent_path();

        return DynamicAssetVariants{
            parent / std::filesystem::path(stem + L"ORIGINAL" + extension),
            parent / std::filesystem::path(stem + L"BLUE" + extension),
            parent / std::filesystem::path(stem + L"PURPLE" + extension),
            parent / std::filesystem::path(stem + L"RED" + extension)
        };
    }

    static std::int32_t NormalizeDynamicDraugrEyePreset(std::int32_t a_presetId)
    {
        if (a_presetId == 1 || a_presetId == 2 || a_presetId == 3) {
            return a_presetId;
        }

        return 0;
    }

    static const wchar_t* ResolveDynamicDraugrEyeSuffix(std::int32_t a_presetId)
    {
        switch (NormalizeDynamicDraugrEyePreset(a_presetId)) {
        case 1:
            return L"BLUE";
        case 2:
            return L"PURPLE";
        case 3:
            return L"RED";
        default:
            return L"ORIGINAL";
        }
    }

    static std::int32_t NormalizeDynamicAssetMode(std::int32_t a_mode)
    {
        if (a_mode == 0 || a_mode == 2) {
            return a_mode;
        }

        return 1;
    }

    struct NumberedBackup
    {
        std::filesystem::path path;
        std::int32_t index{ 0 };
    };

    static std::optional<std::int32_t> TryParseBackupIndex(const std::filesystem::path& a_path, const std::filesystem::path& a_dst)
    {
        const std::wstring file = a_path.filename().wstring();
        const std::wstring prefix = a_dst.stem().wstring() + L"BACKUP-";
        const std::wstring extension = a_dst.extension().wstring();

        if (file.size() <= prefix.size() + extension.size()) {
            return std::nullopt;
        }
        if (file.compare(0, prefix.size(), prefix) != 0) {
            return std::nullopt;
        }
        if (file.compare(file.size() - extension.size(), extension.size(), extension) != 0) {
            return std::nullopt;
        }

        const auto numberStart = prefix.size();
        const auto numberEnd = file.size() - extension.size();
        std::int32_t index = 0;
        for (auto i = numberStart; i < numberEnd; ++i) {
            const wchar_t ch = file[i];
            if (ch < L'0' || ch > L'9') {
                return std::nullopt;
            }
            const auto digit = static_cast<std::int32_t>(ch - L'0');
            if (index > ((std::numeric_limits<std::int32_t>::max)() - digit) / 10) {
                return std::nullopt;
            }
            index = index * 10 + digit;
        }

        if (index <= 0) {
            return std::nullopt;
        }
        return index;
    }

    static std::optional<NumberedBackup> FindLatestNumberedBackup(const std::filesystem::path& a_dst)
    {
        namespace fs = std::filesystem;

        const fs::path parent = a_dst.parent_path();
        std::error_code ec;
        if (!fs::exists(parent, ec)) {
            return std::nullopt;
        }

        std::optional<NumberedBackup> latest;
        for (fs::directory_iterator it(parent, ec), end; !ec && it != end; it.increment(ec)) {
            std::error_code fileEc;
            if (!it->is_regular_file(fileEc) || fileEc) {
                continue;
            }

            const auto index = TryParseBackupIndex(it->path(), a_dst);
            if (index && (!latest || *index > latest->index)) {
                latest = NumberedBackup{ it->path(), *index };
            }
        }

        return latest;
    }

    static std::filesystem::path GetNumberedBackupPath(const std::filesystem::path& a_dst, std::int32_t a_index)
    {
        return a_dst.parent_path() / std::filesystem::path(a_dst.stem().wstring() + L"BACKUP-" + std::to_wstring(a_index) + a_dst.extension().wstring());
    }

    static std::optional<std::filesystem::path> GetNextNumberedBackupPath(const std::filesystem::path& a_dst)
    {
        const auto latest = FindLatestNumberedBackup(a_dst);
        if (latest && latest->index == (std::numeric_limits<std::int32_t>::max)()) {
            return std::nullopt;
        }

        const auto nextIndex = latest ? latest->index + 1 : 1;
        return GetNumberedBackupPath(a_dst, nextIndex);
    }

    static bool FileContentsEqual(const std::filesystem::path& a_lhs, const std::filesystem::path& a_rhs)
    {
        namespace fs = std::filesystem;

        std::error_code ec;
        if (!fs::exists(a_lhs, ec) || ec) {
            return false;
        }
        ec.clear();
        if (!fs::exists(a_rhs, ec) || ec) {
            return false;
        }

        ec.clear();
        const auto lhsSize = fs::file_size(a_lhs, ec);
        if (ec) {
            return false;
        }
        ec.clear();
        const auto rhsSize = fs::file_size(a_rhs, ec);
        if (ec || lhsSize != rhsSize) {
            return false;
        }

        std::ifstream lhs(a_lhs, std::ios::binary);
        std::ifstream rhs(a_rhs, std::ios::binary);
        if (!lhs || !rhs) {
            return false;
        }

        std::array<char, 64 * 1024> lhsBuffer{};
        std::array<char, 64 * 1024> rhsBuffer{};
        while (true) {
            lhs.read(lhsBuffer.data(), lhsBuffer.size());
            rhs.read(rhsBuffer.data(), rhsBuffer.size());

            const auto lhsRead = lhs.gcount();
            const auto rhsRead = rhs.gcount();
            if (lhsRead != rhsRead) {
                return false;
            }
            if (lhsRead > 0 && std::memcmp(lhsBuffer.data(), rhsBuffer.data(), static_cast<std::size_t>(lhsRead)) != 0) {
                return false;
            }
            if (lhsRead < static_cast<std::streamsize>(lhsBuffer.size())) {
                return lhs.eof() && rhs.eof();
            }
        }
    }

    static bool FileMatchesAnyVariant(const std::filesystem::path& a_file, const DynamicAssetVariants& a_variants)
    {
        for (const auto& variant : a_variants) {
            if (FileContentsEqual(a_file, variant)) {
                return true;
            }
        }
        return false;
    }

    static bool EnsureBackupBeforeReplace(const std::filesystem::path& a_dst, const DynamicAssetVariants& a_knownVariants, const char* a_context)
    {
        namespace fs = std::filesystem;

        if (!fs::exists(a_dst)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: live file missing, skipped backup/replacement: {}", a_context, a_dst.string());
            }
            return false;
        }

        if (FileMatchesAnyVariant(a_dst, a_knownVariants)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: live file already matches a known Iron Soul variant, skipped backup: {}", a_context, a_dst.string());
            }
            return true;
        }

        const auto latest = FindLatestNumberedBackup(a_dst);
        if (latest && FileContentsEqual(a_dst, latest->path)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: live file already matches latest numbered backup, skipped duplicate backup: {}", a_context, latest->path.string());
            }
            return true;
        }

        const auto backup = GetNextNumberedBackupPath(a_dst);
        if (!backup) {
            logger::error("{}: backup numbering exhausted for '{}'", a_context, a_dst.string());
            return false;
        }

        std::error_code ec;
        fs::create_directories(backup->parent_path(), ec);
        if (ec) {
            logger::error("{}: backup directory creation failed '{}' (ec={})", a_context, backup->parent_path().string(), ec.value());
            return false;
        }

        fs::copy_file(a_dst, *backup, fs::copy_options::none, ec);
        if (ec) {
            logger::error("{}: backup failed '{}' -> '{}' (ec={})", a_context, a_dst.string(), backup->string(), ec.value());
            return false;
        }

        if (InfoLoggingEnabled()) {
            logger::info("{}: backed up '{}' -> '{}'", a_context, a_dst.string(), backup->string());
        }
        return true;
    }

    static bool CopyFileReplacing(const std::filesystem::path& a_src, const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        std::error_code ec;
        fs::create_directories(a_dst.parent_path(), ec);
        if (ec) {
            logger::warn("{}: create_directories failed: {} (ec={})", a_context, a_dst.parent_path().string(), ec.value());
            ec.clear();
        }

        fs::path tmp = a_dst;
        tmp += L".tmp";

        fs::copy_file(a_src, tmp, fs::copy_options::overwrite_existing, ec);
        if (ec) {
            logger::error("{}: copy failed '{}' -> '{}' (ec={})", a_context, a_src.string(), tmp.string(), ec.value());
            return false;
        }

        ec.clear();
        fs::rename(tmp, a_dst, ec);
        if (ec) {
            ec.clear();
            fs::copy_file(a_src, a_dst, fs::copy_options::overwrite_existing, ec);
            if (ec) {
                logger::error("{}: overwrite failed '{}' -> '{}' (ec={})", a_context, a_src.string(), a_dst.string(), ec.value());
                ec.clear();
                fs::remove(tmp, ec);
                return false;
            }
            ec.clear();
            fs::remove(tmp, ec);
        }

        return true;
    }

    static bool CopyVariantWithBackup(const std::filesystem::path& a_src, const std::filesystem::path& a_dst, const DynamicAssetVariants& a_knownVariants, const char* a_context)
    {
        namespace fs = std::filesystem;

        if (!fs::exists(a_src)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: source missing, skipped: {}", a_context, a_src.string());
            }
            return false;
        }

        if (FileContentsEqual(a_src, a_dst)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: requested variant already installed, skipped replacement: {}", a_context, a_dst.string());
            }
            return false;
        }

        if (!EnsureBackupBeforeReplace(a_dst, a_knownVariants, a_context)) {
            return false;
        }

        return CopyFileReplacing(a_src, a_dst, a_context);
    }

    static bool RestoreBackupIfPresent(const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        const auto backup = FindLatestNumberedBackup(a_dst);
        if (!backup) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: numbered backup missing, skipped restore for: {}", a_context, a_dst.string());
            }
            return false;
        }

        return CopyFileReplacing(backup->path, a_dst, a_context);
    }

    // --- Dynamic Asset Bindings ---
    // ==============================

    static void ApplyDynamicDraugrEyes(RE::StaticFunctionTag*, std::int32_t a_presetId)
    {
        static constexpr const wchar_t* kTargets[] = {
            L"meshes\\actors\\draugr\\character assets\\fxdraugrmaleeyes.nif",
            L"meshes\\actors\\draugr\\character assets\\fxdraugrfemaleeyes.nif"
        };

        const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicDraugrEyes", 1));
        const std::int32_t preset = NormalizeDynamicDraugrEyePreset(a_presetId);

        try {
            namespace fs = std::filesystem;

            const wchar_t* suffix = L"RESTORE";
            if (mode != 0) {
                suffix = (mode == 2 || preset == 0) ? L"ORIGINAL" : ResolveDynamicDraugrEyeSuffix(preset);
            }
            bool copiedAny = false;

            for (auto* target : kTargets) {
                const fs::path dst = IronSoul::PathUtil::GetDataRoot() / fs::path(target);
                if (mode == 0) {
                    if (RestoreBackupIfPresent(dst, "ApplyDynamicDraugrEyes")) {
                        copiedAny = true;
                    }
                    continue;
                }

                const fs::path src = dst.parent_path() / fs::path(dst.stem().wstring() + suffix + dst.extension().wstring());
                const auto knownVariants = GetDynamicDraugrEyeVariants(dst);

                if (CopyVariantWithBackup(src, dst, knownVariants, "ApplyDynamicDraugrEyes")) {
                    copiedAny = true;
                    if (InfoLoggingEnabled()) {
                        logger::info("ApplyDynamicDraugrEyes: applied '{}' -> '{}'", src.string(), dst.string());
                    }
                }
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicDraugrEyes: mode={} presetId={} suffix={} copiedAny={}", mode, a_presetId, fs::path(suffix).string(), copiedAny ? 1 : 0);
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicDraugrEyes: exception: {}", e.what());
        }
    }

    static void ApplyDynamicSplash(RE::StaticFunctionTag*, std::int32_t a_tierId, std::int32_t a_presetId)
    {
        // Plugin performs the file copy.
        try {
            namespace fs = std::filesystem;

            std::wstring file = L"splash_01_iron.png";
            const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicSplash", 1));
            if (mode == 1) {
                const auto resolved = ResolveDynamicSplashFile(a_tierId, a_presetId);
                if (!resolved) {
                    logger::warn("ApplyDynamicSplash: invalid tierId={}", a_tierId);
                    return;
                }
                file = *resolved;
            }

            const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";
            const fs::path splashDir = ifaceDir / L"splash";
            const fs::path src = splashDir / fs::path(file);
            const fs::path dst = ifaceDir / L"splash.png";
            const auto knownVariants = GetDynamicSplashVariants(splashDir);

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicSplash");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, knownVariants, "ApplyDynamicSplash")) {
                return;
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicSplash: applied tierId={} presetId={} mode={} ('{}' -> '{}')", a_tierId, a_presetId, mode, src.string(), dst.string());
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicSplash: exception: {}", e.what());
        }
    }

    static bool DynamicLevelWidgetAssetsPresent()
    {
        namespace fs = std::filesystem;
        const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";
        const fs::path widgetDir = ifaceDir / L"lvlWidget";

        // Require the base destination to exist to confirm the user has the widget mod installed.
        // We still overwrite it, but its presence is used as the install signal.
        if (!fs::exists(ifaceDir / L"lvlWidget.swf")) {
            return false;
        }
        const auto variants = GetDynamicLevelWidgetVariants(widgetDir);
        for (const auto& variant : variants) {
            if (!fs::exists(variant)) {
                return false;
            }
        }
        return true;
    }

    static void ApplyDynamicLevelWidget(RE::StaticFunctionTag*, std::int32_t a_tierId)
    {
        try {
            namespace fs = std::filesystem;
            const fs::path ifaceDir = IronSoul::PathUtil::GetDataRoot() / L"Interface";
            const fs::path widgetDir = ifaceDir / L"lvlWidget";

            const wchar_t* file = L"lvlWidget_1_iron.swf";
            const std::int32_t mode = NormalizeDynamicAssetMode(IronSoul::Config::GetInt("DynamicLevelWidget", 1));
            if (mode == 1) {
                if (!DynamicLevelWidgetAssetsPresent()) {
                    return;
                }

                const auto resolved = ResolveDynamicLevelWidgetFile(a_tierId);
                if (!resolved) {
                    logger::warn("ApplyDynamicLevelWidget: invalid tierId={}", a_tierId);
                    return;
                }
                file = *resolved;
            }

            const fs::path src = widgetDir / file;
            const fs::path dst = ifaceDir / L"lvlWidget.swf";
            const auto knownVariants = GetDynamicLevelWidgetVariants(widgetDir);

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicLevelWidget");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, knownVariants, "ApplyDynamicLevelWidget")) {
                return;
            }

            if (InfoLoggingEnabled()) {
                logger::info("ApplyDynamicLevelWidget: applied tierId={} mode={} ('{}' -> '{}')", a_tierId, mode, src.string(), dst.string());
            }
        }
        catch (const std::exception& e) {
            logger::error("ApplyDynamicLevelWidget: exception: {}", e.what());
        }
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("ApplyDynamicDraugrEyes", kScriptName, ApplyDynamicDraugrEyes);
        a_vm->RegisterFunction("ApplyDynamicSplash", kScriptName, ApplyDynamicSplash);
        a_vm->RegisterFunction("ApplyDynamicLevelWidget", kScriptName, ApplyDynamicLevelWidget);
    }
}
