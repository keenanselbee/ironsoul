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

$repo = "C:\Repositories\Iron Soul"
$repoPluginSource = Join-Path $repo "Source\Plugin"
$repoDll = Join-Path $repo "SKSE\plugins\ironsoul.dll"
$externalProject = "G:\Modding\LoreRim\Dev\projects\ironsoul"
$externalSource = Join-Path $externalProject "src"
$externalReleaseDll = Join-Path $externalProject "build\windows\x64\release\IronSoul.dll"
$xmake = "G:\Modding\LoreRim\Dev\tools\xmake\xmake.exe"
$xmakeGlobalDir = "G:\Modding\LoreRim\Dev\.xmake"

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

Write-Host "WARNING: THIS WILL MODIFY THE EXTERNAL BUILD PROJECT"

if ((Get-FullPath (Get-Location).Path) -ne (Get-FullPath $repo)) {
    Set-Location -LiteralPath $repo
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists $repoPluginSource "repo plugin source"
Assert-DirectoryExists $externalProject "external project"
Assert-DirectoryExists $externalSource "external source"
Assert-FileExists $xmake "xmake"
Assert-PathInside $externalSource $externalProject "external source"
Assert-PathInside $repoDll $repo "repo DLL"

Write-Host "[INFO] Mirroring plugin source to external project..."

$repoFiles = Get-ChildItem -LiteralPath $repoPluginSource -Recurse -File -Include *.cpp,*.h
$repoRelative = @{}
foreach ($file in $repoFiles) {
    $relative = $file.FullName.Substring($repoPluginSource.Length).TrimStart('\')
    $repoRelative[$relative.ToLowerInvariant()] = $true
    $destination = Join-Path $externalSource $relative
    Assert-PathInside $destination $externalSource "external destination"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
}

Write-Host "[INFO] Removing stale external plugin source files..."

$externalFiles = Get-ChildItem -LiteralPath $externalSource -Recurse -File -Include *.cpp,*.h
foreach ($file in $externalFiles) {
    $relative = $file.FullName.Substring($externalSource.Length).TrimStart('\')
    if (-not $repoRelative.ContainsKey($relative.ToLowerInvariant())) {
        Assert-PathInside $file.FullName $externalSource "stale external file"
        Remove-Item -LiteralPath $file.FullName -Force
    }
}

$env:XMAKE_GLOBALDIR = $xmakeGlobalDir
Set-Location -LiteralPath $externalProject

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

Assert-FileExists $externalReleaseDll "external release DLL"
$releaseDllInfo = Get-Item -LiteralPath $externalReleaseDll
if ($releaseDllInfo.Length -le 0) {
    throw "External release DLL is empty: $externalReleaseDll"
}

if ($RefreshRepoDll) {
    Write-Host "[INFO] Refreshing repo DLL..."
    Copy-Item -LiteralPath $externalReleaseDll -Destination $repoDll -Force

    $externalHash = (Get-FileHash -LiteralPath $externalReleaseDll -Algorithm SHA256).Hash
    $repoHash = (Get-FileHash -LiteralPath $repoDll -Algorithm SHA256).Hash
    if ($externalHash -ne $repoHash) {
        throw "Repo DLL hash does not match external release DLL after copy."
    }

    Write-Host "[SUCCESS] Repo DLL refreshed: $repoDll"
    Write-Host "[SUCCESS] SHA256: $repoHash"
} else {
    Write-Host "[SUCCESS] Verify-only build completed; repo DLL was not changed."
}
