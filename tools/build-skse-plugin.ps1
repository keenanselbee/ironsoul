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
$releaseDll = Join-Path $pluginProject "build\windows\x64\release\IronSoul.dll"
$xmake = Join-Path $repo "dev\tools\xmake\xmake.exe"
$xmakeGlobalDir = Join-Path $repo "dev\.xmake"

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

if ((Get-FullPath (Get-Location).Path) -ne (Get-FullPath $repo)) {
    Set-Location -LiteralPath $repo
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists $pluginProject "plugin project"
Assert-DirectoryExists $pluginSource "plugin source"
Assert-FileExists $xmake "xmake"
Assert-PathInside $pluginSource $pluginProject "plugin source"
Assert-PathInside $releaseDll $pluginProject "release DLL"
Assert-PathInside $repoDll $repo "repo DLL"

$env:XMAKE_GLOBALDIR = $xmakeGlobalDir
Set-Location -LiteralPath $pluginProject

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
