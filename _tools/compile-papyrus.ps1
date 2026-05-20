param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Scripts,

    [switch]$RefreshRepoPex
)

$ErrorActionPreference = "Stop"

$repo = "C:\Repositories\Iron Soul"
$sourceDir = Join-Path $repo "Source\Scripts"
$compiledDir = Join-Path $repo "Scripts"
$tempDir = Join-Path $repo ".codex-temp\PapyrusCompile"
$compiler = "G:\Modding\LoreRim\Tools\Papyrus Compiler\PapyrusCompiler.exe"
$flags = "G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg"
$skse = "G:\Modding\LoreRim\Mod Organizer\mods\Skyrim Script Extender (SKSE64)\Scripts\Source"
$papyrusUtil = "G:\Modding\LoreRim\Mod Organizer\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Scripts\Source"
$stock = "G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts"
$imports = "$sourceDir;$skse;$papyrusUtil;$stock"

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

function Resolve-ScriptName([string]$Script) {
    $name = Split-Path -Leaf $Script
    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "Script name is empty."
    }

    $extension = [System.IO.Path]::GetExtension($name)
    if ([string]::IsNullOrEmpty($extension)) {
        return "$name.psc"
    }

    if (-not $extension.Equals(".psc", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Script must be a .psc file or bare script name: $Script"
    }

    return $name
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists $sourceDir "Papyrus source directory"
Assert-DirectoryExists $compiledDir "compiled script directory"
Assert-FileExists $compiler "Papyrus compiler"
Assert-FileExists $flags "Papyrus flags file"
Assert-DirectoryExists $skse "SKSE source import"
Assert-DirectoryExists $papyrusUtil "PapyrusUtil source import"
Assert-DirectoryExists $stock "stock source import"
Assert-PathInside $tempDir $repo "temporary compile directory"

New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

$failures = @()
$successes = @()

foreach ($scriptInput in $Scripts) {
    $scriptName = Resolve-ScriptName $scriptInput
    $sourcePath = Join-Path $sourceDir $scriptName
    $pexName = [System.IO.Path]::ChangeExtension($scriptName, ".pex")
    $tempPex = Join-Path $tempDir $pexName
    $repoPex = Join-Path $compiledDir $pexName

    Assert-PathInside $sourcePath $sourceDir "script source"
    Assert-PathInside $tempPex $tempDir "temporary PEX"
    Assert-PathInside $repoPex $compiledDir "repo PEX"
    Assert-FileExists $sourcePath "Papyrus source"

    Remove-Item -LiteralPath $tempPex -Force -ErrorAction SilentlyContinue

    Write-Host "[INFO] Compiling $scriptName..."
    Push-Location -LiteralPath $sourceDir
    try {
        $compilerOutput = & $compiler $scriptName "-f=$flags" "-i=$imports" "-o=$tempDir" 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }

    if ($compilerOutput) {
        $compilerOutput | ForEach-Object { Write-Host $_ }
    }

    if ($exitCode -ne 0) {
        $failures += "$scriptName failed with compiler exit code $exitCode"
        Write-Host "[ERROR] $scriptName compile failed."
        continue
    }

    if (-not (Test-Path -LiteralPath $tempPex -PathType Leaf)) {
        $failures += "$scriptName did not produce expected PEX: $tempPex"
        Write-Host "[ERROR] $scriptName did not produce expected PEX."
        continue
    }

    $tempPexInfo = Get-Item -LiteralPath $tempPex
    if ($tempPexInfo.Length -le 0) {
        $failures += "$scriptName produced an empty PEX: $tempPex"
        Write-Host "[ERROR] $scriptName produced an empty PEX."
        continue
    }

    if ($RefreshRepoPex) {
        Copy-Item -LiteralPath $tempPex -Destination $repoPex -Force
        $tempHash = (Get-FileHash -LiteralPath $tempPex -Algorithm SHA256).Hash
        $repoHash = (Get-FileHash -LiteralPath $repoPex -Algorithm SHA256).Hash
        if ($tempHash -ne $repoHash) {
            $failures += "$scriptName repo PEX hash does not match temp output after copy"
            Write-Host "[ERROR] $scriptName repo PEX hash mismatch after copy."
            continue
        }

        $successes += "$scriptName refreshed $pexName ($($tempPexInfo.Length) bytes)"
        Write-Host "[SUCCESS] $scriptName compiled and refreshed $pexName."
    } else {
        $successes += "$scriptName compiled to $tempPex ($($tempPexInfo.Length) bytes)"
        Write-Host "[SUCCESS] $scriptName compiled to temp output."
    }
}

Write-Host "[INFO] Papyrus compile summary:"
foreach ($success in $successes) {
    Write-Host "  OK    $success"
}
foreach ($failure in $failures) {
    Write-Host "  FAIL  $failure"
}

if ($failures.Count -gt 0) {
    throw "Papyrus compile failed for $($failures.Count) script(s). Existing repo PEX files were left untouched for failed scripts."
}
