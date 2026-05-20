#include "pch.h"
#include "papyrus_dynamicassets.h"
#include "papyrus_common.h"
#include "config.h"
#include "pathutil.h"

#include <optional>

namespace IronSoul::Papyrus::DynamicAssets
{
namespace
{
    static std::optional<const wchar_t*> ResolveDynamicSplashTierToken(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"0defiant";
        case 1:
            return L"1iron";
        case 2:
            return L"2silver";
        case 3:
            return L"3gold";
        case 4:
            return L"4ebon";
        case 5:
            return L"5platinum";
        case 6:
            return L"6devour";
        case 9:
            return L"9chim";
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

        std::wstring file = L"splash";
        auto preset = NormalizeDynamicSplashPreset(a_presetId);
        if (a_tierId == 9 && preset > 1) {
            preset = 0;
        }
        if (preset != 0) {
            file += std::to_wstring(preset);
        }
        file += *token;
        file += L".png";

        return file;
    }

    static std::optional<const wchar_t*> ResolveDynamicLevelWidgetFile(std::int32_t a_tierId)
    {
        switch (a_tierId) {
        case 0:
            return L"lvlWidget0defiant.swf";
        case 1:
            return L"lvlWidget1iron.swf";
        case 2:
            return L"lvlWidget2silver.swf";
        case 3:
            return L"lvlWidget3gold.swf";
        case 4:
            return L"lvlWidget4ebon.swf";
        case 5:
            return L"lvlWidget5platinum.swf";
        case 6:
            return L"lvlWidget6devour.swf";
        case 9:
            return L"lvlWidget9chim.swf";
        default:
            return std::nullopt;
        }
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

    static std::filesystem::path GetBackupPath(const std::filesystem::path& a_dst)
    {
        return a_dst.parent_path() / std::filesystem::path(a_dst.stem().wstring() + L"BACKUP" + a_dst.extension().wstring());
    }

    static bool EnsureBackupBeforeReplace(const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        const fs::path backup = GetBackupPath(a_dst);
        if (fs::exists(backup)) {
            return true;
        }

        if (!fs::exists(a_dst)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: live file missing, skipped backup/replacement: {}", a_context, a_dst.string());
            }
            return false;
        }

        std::error_code ec;
        fs::create_directories(backup.parent_path(), ec);
        if (ec) {
            logger::error("{}: backup directory creation failed '{}' (ec={})", a_context, backup.parent_path().string(), ec.value());
            return false;
        }

        fs::copy_file(a_dst, backup, fs::copy_options::none, ec);
        if (ec) {
            logger::error("{}: backup failed '{}' -> '{}' (ec={})", a_context, a_dst.string(), backup.string(), ec.value());
            return false;
        }

        if (InfoLoggingEnabled()) {
            logger::info("{}: backed up '{}' -> '{}'", a_context, a_dst.string(), backup.string());
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

    static bool CopyVariantWithBackup(const std::filesystem::path& a_src, const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        if (!fs::exists(a_src)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: source missing, skipped: {}", a_context, a_src.string());
            }
            return false;
        }

        if (!EnsureBackupBeforeReplace(a_dst, a_context)) {
            return false;
        }

        return CopyFileReplacing(a_src, a_dst, a_context);
    }

    static bool RestoreBackupIfPresent(const std::filesystem::path& a_dst, const char* a_context)
    {
        namespace fs = std::filesystem;

        const fs::path backup = GetBackupPath(a_dst);
        if (!fs::exists(backup)) {
            if (InfoLoggingEnabled()) {
                logger::info("{}: backup missing, skipped restore: {}", a_context, backup.string());
            }
            return false;
        }

        return CopyFileReplacing(backup, a_dst, a_context);
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

            const wchar_t* suffix = L"BACKUP";
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

                if (CopyVariantWithBackup(src, dst, "ApplyDynamicDraugrEyes")) {
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

            std::wstring file = L"splash1iron.png";
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
            const fs::path src = ifaceDir / fs::path(file);
            const fs::path dst = ifaceDir / L"splash.png";

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicSplash");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, "ApplyDynamicSplash")) {
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

        // Require the base destination to exist to confirm the user has the widget mod installed.
        // We still overwrite it, but its presence is used as the install signal.
        if (!fs::exists(ifaceDir / L"lvlWidget.swf")) {
            return false;
        }
        static constexpr const wchar_t* kVariants[] = {
            L"lvlWidget0defiant.swf",
            L"lvlWidget1iron.swf",
            L"lvlWidget2silver.swf",
            L"lvlWidget3gold.swf",
            L"lvlWidget4ebon.swf",
            L"lvlWidget5platinum.swf",
            L"lvlWidget6devour.swf",
            L"lvlWidget9chim.swf"
        };

        for (auto* f : kVariants) {
            if (!fs::exists(ifaceDir / f)) {
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

            const wchar_t* file = L"lvlWidget1iron.swf";
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

            const fs::path src = ifaceDir / file;
            const fs::path dst = ifaceDir / L"lvlWidget.swf";

            if (mode == 0) {
                RestoreBackupIfPresent(dst, "ApplyDynamicLevelWidget");
                return;
            }

            if (!CopyVariantWithBackup(src, dst, "ApplyDynamicLevelWidget")) {
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