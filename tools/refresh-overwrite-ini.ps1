[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$SourceIni,
    [string]$DestinationIni = "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"
)

$ErrorActionPreference = "Stop"

$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$tempRoot = Join-Path $repo ".codex-temp"
$defaultDestinationIni = "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"
$requiredDebugSettings = [ordered]@{
    EnableDebug = "1"
    EnableLogging = "1"
    EnableLogNotifications = "1"
    LogLevel = "3"
}

if ([string]::IsNullOrWhiteSpace($SourceIni)) {
    $SourceIni = Join-Path $repo "mod\SKSE\plugins\ironsoul.ini"
}

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-FileExists([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label not found: $Path"
    }
}

function Assert-PathInside([string]$Path, [string]$Root, [string]$Label) {
    $fullPath = Get-FullPath $Path
    $fullRoot = (Get-FullPath $Root).TrimEnd('\') + '\'
    if (-not $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label path is outside expected root: $fullPath"
    }
}

function Assert-AllowedDestination([string]$Path) {
    $fullPath = Get-FullPath $Path
    $expectedPath = Get-FullPath $defaultDestinationIni
    $fullTempRoot = (Get-FullPath $tempRoot).TrimEnd('\') + '\'

    if ($fullPath.Equals($expectedPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    if ($fullPath.StartsWith($fullTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    throw "Destination INI must be the LoreRim+ Overwrite INI or a .codex-temp test path: $fullPath"
}

function Add-MissingDebugSettings($Lines, [string[]]$MissingKeys, $Settings) {
    $debugSectionIndex = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*\[Debug\]\s*$') {
            $debugSectionIndex = $i
            break
        }
    }

    if ($debugSectionIndex -lt 0) {
        if ($Lines.Count -gt 0 -and $Lines[$Lines.Count - 1].Trim().Length -ne 0) {
            [void]$Lines.Add("")
        }

        [void]$Lines.Add("[Debug]")
        foreach ($key in $MissingKeys) {
            [void]$Lines.Add("$key = $($Settings[$key])")
        }
        return
    }

    $insertIndex = $Lines.Count
    for ($i = $debugSectionIndex + 1; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*\[[^\]]+\]\s*$') {
            $insertIndex = $i
            break
        }
    }

    if ($insertIndex -gt 0 -and $Lines[$insertIndex - 1].Trim().Length -ne 0) {
        $Lines.Insert($insertIndex, "")
        $insertIndex++
    }

    foreach ($key in $MissingKeys) {
        $Lines.Insert($insertIndex, "$key = $($Settings[$key])")
        $insertIndex++
    }
}

Assert-PathInside $SourceIni $repo "source INI"
Assert-FileExists $SourceIni "source INI"
Assert-AllowedDestination $DestinationIni

$destinationDir = Split-Path -Parent $DestinationIni
if ([string]::IsNullOrWhiteSpace($destinationDir)) {
    throw "Destination directory could not be resolved: $DestinationIni"
}

$destinationPath = Get-FullPath $DestinationIni
if (-not $PSCmdlet.ShouldProcess($destinationPath, "Refresh from $SourceIni and force debug logging")) {
    return
}

[System.IO.Directory]::CreateDirectory((Get-FullPath $destinationDir)) | Out-Null
[System.IO.File]::Copy((Get-FullPath $SourceIni), $destinationPath, $true)

$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in [System.IO.File]::ReadAllLines($destinationPath)) {
    [void]$lines.Add($line)
}

$foundSettings = @{}
for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($key in $requiredDebugSettings.Keys) {
        $escapedKey = [regex]::Escape($key)
        $pattern = "^(?<prefix>\s*$escapedKey\s*=\s*)(?<value>[^;#]*?)(?<suffix>\s*(?:[;#].*)?)$"

        if ($lines[$i] -match $pattern) {
            $lines[$i] = $Matches["prefix"] + $requiredDebugSettings[$key] + $Matches["suffix"]
            $foundSettings[$key] = $true
            break
        }
    }
}

$missingSettings = [System.Collections.Generic.List[string]]::new()
foreach ($key in $requiredDebugSettings.Keys) {
    if (-not $foundSettings.ContainsKey($key)) {
        [void]$missingSettings.Add($key)
    }
}

if ($missingSettings.Count -gt 0) {
    Add-MissingDebugSettings $lines ($missingSettings.ToArray()) $requiredDebugSettings
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllLines($destinationPath, [string[]]$lines, $utf8NoBom)

Write-Host "Refreshed overwrite INI: $destinationPath"
foreach ($key in $requiredDebugSettings.Keys) {
    Write-Host "  $key = $($requiredDebugSettings[$key])"
}
