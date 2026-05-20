param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Plugin,

    [string]$Filter,

    [switch]$StageInStockData
)

$ErrorActionPreference = "Stop"

$repo = "C:\Repositories\Iron Soul"
$stockData = "G:\Modding\LoreRim\Mod Organizer\Stock Game\Data"
$xeditDir = "G:\Modding\LoreRim\Tools\xEdit"
$dumpExe = Join-Path $xeditDir "SSEDump64.exe"
$exceptionLog = Join-Path $xeditDir "SSEDump64Exception.log"
$outputDir = Join-Path $repo ".codex-temp\xedit"

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

function Convert-ToSafeFilePart([string]$Value) {
    $safe = $Value
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safe = $safe.Replace($char, '_')
    }
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "filter"
    }
    return $safe
}

function Resolve-PluginPath([string]$PluginName) {
    if ([System.IO.Path]::IsPathRooted($PluginName)) {
        $full = Get-FullPath $PluginName
    } else {
        $full = Get-FullPath (Join-Path $repo $PluginName)
    }

    Assert-PathInside $full $repo "plugin"
    $extension = [System.IO.Path]::GetExtension($full)
    if ($extension -notin @(".esp", ".esm", ".esl")) {
        throw "Plugin must be an .esp, .esm, or .esl file: $PluginName"
    }

    return $full
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists $stockData "xEdit stock Data path"
Assert-FileExists $dumpExe "SSEDump64"
Assert-PathInside $outputDir $repo "xEdit dump output directory"

$pluginPath = Resolve-PluginPath $Plugin
Assert-FileExists $pluginPath "plugin"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$pluginFileName = [System.IO.Path]::GetFileName($pluginPath)
$pluginBaseName = [System.IO.Path]::GetFileNameWithoutExtension($pluginPath)
$dumpPath = Join-Path $outputDir ("{0}.dump.txt" -f (Convert-ToSafeFilePart $pluginBaseName))
$stagedPluginPath = Join-Path $stockData $pluginFileName

if ($StageInStockData) {
    Assert-PathInside $stagedPluginPath $stockData "staged plugin"
    if (Test-Path -LiteralPath $stagedPluginPath) {
        throw "Refusing to overwrite existing plugin in Stock Game Data: $stagedPluginPath"
    }
}

Write-Host "[INFO] Running SSEDump64 for $pluginFileName..."
Write-Host "[INFO] Output: $dumpPath"

$runDirectory = $repo
$arguments = @("-D:$stockData", $pluginPath)
$sourceHash = $null

try {
    if ($StageInStockData) {
        Write-Host "WARNING: THIS WILL TEMPORARILY STAGE THE REPO ESP IN STOCK GAME DATA"
        $sourceHash = (Get-FileHash -LiteralPath $pluginPath -Algorithm SHA256).Hash
        Copy-Item -LiteralPath $pluginPath -Destination $stagedPluginPath -Force

        $stagedHash = (Get-FileHash -LiteralPath $stagedPluginPath -Algorithm SHA256).Hash
        if ($stagedHash -ne $sourceHash) {
            throw "Staged plugin hash mismatch before dump."
        }

        $runDirectory = $stockData
        $arguments = @("-D:$stockData", $pluginFileName)
        Write-Host "[INFO] Staged plugin: $stagedPluginPath"
    }

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        Push-Location -LiteralPath $runDirectory
        try {
            $dumpOutput = & $dumpExe @arguments 2>&1
            $exitCode = $LASTEXITCODE
        } finally {
            Pop-Location
        }
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
} finally {
    if ($StageInStockData -and (Test-Path -LiteralPath $stagedPluginPath)) {
        $currentHash = (Get-FileHash -LiteralPath $stagedPluginPath -Algorithm SHA256).Hash
        if ($sourceHash -and $currentHash -eq $sourceHash) {
            Remove-Item -LiteralPath $stagedPluginPath -Force
            Write-Host "[INFO] Removed staged plugin: $stagedPluginPath"
        } else {
            Write-Host "[WARNING] Staged plugin was not removed because its hash changed: $stagedPluginPath"
        }
    }
}
$dumpLines = $dumpOutput | ForEach-Object { $_.ToString() }
$dumpLines | Set-Content -LiteralPath $dumpPath -Encoding UTF8

if ($exitCode -ne 0 -or ($dumpLines | Select-String -Pattern "Unexpected Error|Exception:" -Quiet)) {
    if ($exitCode -ne 0) {
        Write-Host "[ERROR] SSEDump64 exited with code $exitCode."
    } else {
        Write-Host "[ERROR] SSEDump64 reported an unexpected error."
    }
    Write-Host "[ERROR] Partial output was written to: $dumpPath"
    if (-not $StageInStockData) {
        Write-Host "[ERROR] If the error is master resolution, retry with -StageInStockData."
    }
    if (Test-Path -LiteralPath $exceptionLog -PathType Leaf) {
        Write-Host "[ERROR] Last SSEDump64 exception log lines:"
        Get-Content -LiteralPath $exceptionLog -Tail 40 | ForEach-Object { Write-Host $_ }
    }
    throw "SSEDump64 failed. Use SSEEdit64 GUI inspection as the authoritative fallback."
}

if (-not (Test-Path -LiteralPath $dumpPath -PathType Leaf)) {
    throw "Dump file was not created: $dumpPath"
}

if ($Filter) {
    $safeFilter = Convert-ToSafeFilePart $Filter
    $matchesPath = Join-Path $outputDir ("{0}.{1}.matches.txt" -f (Convert-ToSafeFilePart $pluginBaseName), $safeFilter)
    $lines = Get-Content -LiteralPath $dumpPath
    $matchIndexes = New-Object System.Collections.Generic.SortedSet[int]

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -like "*$Filter*") {
            $start = [Math]::Max(0, $i - 3)
            $end = [Math]::Min($lines.Count - 1, $i + 3)
            for ($j = $start; $j -le $end; $j++) {
                [void]$matchIndexes.Add($j)
            }
        }
    }

    if ($matchIndexes.Count -eq 0) {
        "No matches for filter: $Filter" | Set-Content -LiteralPath $matchesPath -Encoding UTF8
        Write-Host "[INFO] No matches for filter '$Filter'."
    } else {
        $result = foreach ($index in $matchIndexes) {
            "{0,8}: {1}" -f ($index + 1), $lines[$index]
        }
        $result | Set-Content -LiteralPath $matchesPath -Encoding UTF8
        Write-Host "[SUCCESS] Wrote matches: $matchesPath"
    }
}

$dumpInfo = Get-Item -LiteralPath $dumpPath
Write-Host "[SUCCESS] Wrote dump: $dumpPath ($($dumpInfo.Length) bytes)"
