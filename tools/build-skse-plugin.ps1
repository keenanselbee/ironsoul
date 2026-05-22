param(
    [switch]$VerifyOnly,
    [switch]$RefreshRepoDll
)

$ErrorActionPreference = "Stop"

if ($VerifyOnly -and $RefreshRepoDll) {
    throw "Choose either -VerifyOnly or -RefreshRepoDll, not both."
}

if (-not $VerifyOnly -and -not $RefreshRepoDll) {
    $VerifyOnly = $true
}

$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$repoDll = Join-Path $repo "mod\SKSE\plugins\ironsoul.dll"
$pluginProject = Join-Path $repo "dev\projects\ironsoul"
$pluginSource = Join-Path $pluginProject "src"
$xmakeLua = Join-Path $pluginProject "xmake.lua"
$pluginHeader = Join-Path $pluginSource "plugin.h"
$releaseDll = Join-Path $pluginProject "build\windows\x64\release\IronSoul.dll"
$xmake = Join-Path $repo "dev\tools\xmake\xmake.exe"
$xmakeGlobalDir = Join-Path $repo "dev\.xmake"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-PathInside([string]$Path, [string]$Root, [string]$Label) {
    $fullPath = Get-FullPath $Path
    $fullRoot = (Get-FullPath $Root).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label path is outside expected root: $fullPath"
    }
}

function Assert-FileExists([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label not found: $Path"
    }
}

function Assert-DirectoryExists([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label not found: $Path"
    }
}

function Get-NextPluginVersion([string]$Version) {
    if ($Version -notmatch '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)$') {
        throw "Unsupported SKSE plugin version format: $Version"
    }

    $major = [int]$Matches.major
    $minor = [int]$Matches.minor
    $patch = [int]$Matches.patch

    if ($minor -gt 9 -or $patch -gt 9) {
        throw "SKSE plugin version auto-bump expects minor and patch values from 0-9: $Version"
    }

    $patch += 1
    if ($patch -gt 9) {
        $patch = 0
        $minor += 1
    }
    if ($minor -gt 9) {
        $minor = 0
        $major += 1
    }

    return "$major.$minor.$patch"
}

function Set-PluginBuildVersion([string]$XmakeLuaPath, [string]$PluginHeaderPath) {
    $xmakeText = [System.IO.File]::ReadAllText($XmakeLuaPath)
    $pluginHeaderText = [System.IO.File]::ReadAllText($PluginHeaderPath)

    $xmakePattern = "(?m)^set_version\('(?<version>\d+\.\d+\.\d+)'\)"
    $xmakeMatches = [regex]::Matches($xmakeText, $xmakePattern)
    if ($xmakeMatches.Count -ne 1) {
        throw "Expected exactly one set_version('x.y.z') entry in $XmakeLuaPath; found $($xmakeMatches.Count)."
    }

    $oldVersion = $xmakeMatches[0].Groups["version"].Value
    $newVersion = Get-NextPluginVersion $oldVersion
    $parts = $newVersion.Split('.')

    $headerPattern = "(?m)^(\s*inline constexpr REL::Version VERSION\{\s*)\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*0\s*(\};)"
    $headerMatches = [regex]::Matches($pluginHeaderText, $headerPattern)
    if ($headerMatches.Count -ne 1) {
        throw "Expected exactly one Plugin::VERSION entry in $PluginHeaderPath; found $($headerMatches.Count)."
    }

    $newXmakeText = [regex]::Replace(
        $xmakeText,
        $xmakePattern,
        "set_version('$newVersion')",
        1
    )
    $newPluginHeaderText = [regex]::Replace(
        $pluginHeaderText,
        $headerPattern,
        "`${1}$($parts[0]), $($parts[1]), $($parts[2]), 0 `${2}",
        1
    )

    [System.IO.File]::WriteAllText($XmakeLuaPath, $newXmakeText, $utf8NoBom)
    [System.IO.File]::WriteAllText($PluginHeaderPath, $newPluginHeaderText, $utf8NoBom)

    return [pscustomobject]@{
        OldVersion = $oldVersion
        NewVersion = $newVersion
        XmakeText = $xmakeText
        PluginHeaderText = $pluginHeaderText
    }
}

if ((Get-FullPath (Get-Location).Path) -ne (Get-FullPath $repo)) {
    Set-Location -LiteralPath $repo
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists $pluginProject "plugin project"
Assert-DirectoryExists $pluginSource "plugin source"
Assert-FileExists $xmakeLua "xmake.lua"
Assert-FileExists $pluginHeader "plugin header"
Assert-FileExists $xmake "xmake"
Assert-PathInside $pluginSource $pluginProject "plugin source"
Assert-PathInside $releaseDll $pluginProject "release DLL"
Assert-PathInside $repoDll $repo "repo DLL"
Assert-PathInside $xmakeLua $pluginProject "xmake.lua"
Assert-PathInside $pluginHeader $pluginProject "plugin header"

$versionBump = $null
if ($RefreshRepoDll) {
    $versionBump = Set-PluginBuildVersion $xmakeLua $pluginHeader
    Write-Host "[INFO] Bumped SKSE plugin version: $($versionBump.OldVersion) -> $($versionBump.NewVersion)"
} else {
    Write-Host "[INFO] Verify-only build; SKSE plugin version will not be bumped."
}

$env:XMAKE_GLOBALDIR = $xmakeGlobalDir
Set-Location -LiteralPath $pluginProject

try {
    Write-Host "[INFO] Configuring release build..."
    & $xmake f -y -m release --toolchain=msvc --skyrim_se=y --skyrim_ae=y
    if ($LASTEXITCODE -ne 0) {
        throw "xmake configure failed with exit code $LASTEXITCODE."
    }

    Write-Host "[INFO] Building release DLL..."
    & $xmake build ironsoul
    if ($LASTEXITCODE -ne 0) {
        throw "xmake build failed with exit code $LASTEXITCODE."
    }

    Assert-FileExists $releaseDll "release DLL"
    $releaseDllInfo = Get-Item -LiteralPath $releaseDll
    if ($releaseDllInfo.Length -le 0) {
        throw "Release DLL is empty: $releaseDll"
    }

    if ($RefreshRepoDll) {
        Write-Host "[INFO] Refreshing repo DLL..."
        Copy-Item -LiteralPath $releaseDll -Destination $repoDll -Force

        $releaseHash = (Get-FileHash -LiteralPath $releaseDll -Algorithm SHA256).Hash
        $repoHash = (Get-FileHash -LiteralPath $repoDll -Algorithm SHA256).Hash
        if ($releaseHash -ne $repoHash) {
            throw "Repo DLL hash does not match release DLL after copy."
        }

        Write-Host "[SUCCESS] Repo DLL refreshed: $repoDll"
        Write-Host "[SUCCESS] SHA256: $repoHash"
    } else {
        Write-Host "[SUCCESS] Verify-only build completed; repo DLL was not changed."
    }
} catch {
    if ($versionBump) {
        [System.IO.File]::WriteAllText($xmakeLua, $versionBump.XmakeText, $utf8NoBom)
        [System.IO.File]::WriteAllText($pluginHeader, $versionBump.PluginHeaderText, $utf8NoBom)
        Write-Host "[INFO] Restored SKSE plugin version after failed build."
    }
    throw
}
