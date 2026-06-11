[CmdletBinding(SupportsShouldProcess = $true)]
param()

$ErrorActionPreference = "Stop"

$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$destinationRoot = [System.IO.Path]::GetFullPath("Z:\Backup\LoreRim\Iron Soul")
$backupNamePattern = '^Iron Soul Backup (?<index>\d+) - \d{1,2}-\d{1,2}-\d{4}$'

function Get-FullPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Assert-DirectoryExists([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label not found: $Path"
    }
}

function Assert-PathExists([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label not found: $Path"
    }
}

function Test-PathInside([string]$Path, [string]$Root) {
    $fullPath = Get-FullPath $Path
    $fullRoot = (Get-FullPath $Root).TrimEnd('\') + '\'
    return $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-BackupPathsAreSafe([string]$SourceRoot, [string]$BackupRoot) {
    if ($SourceRoot.Equals($BackupRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Backup destination root must not be the repo root: $BackupRoot"
    }

    if (Test-PathInside $BackupRoot $SourceRoot) {
        throw "Backup destination root must not be inside the repo: $BackupRoot"
    }

    if (Test-PathInside $SourceRoot $BackupRoot) {
        throw "Repo root must not be inside the backup destination root: $SourceRoot"
    }
}

function Get-NextBackupIndex([string]$BackupRoot) {
    $highestIndex = 0

    if (Test-Path -LiteralPath $BackupRoot -PathType Container) {
        foreach ($directory in Get-ChildItem -LiteralPath $BackupRoot -Directory -Force) {
            if ($directory.Name -match $backupNamePattern) {
                $index = [int64]$Matches["index"]
                if ($index -gt $highestIndex) {
                    $highestIndex = $index
                }
            }
        }
    }

    return $highestIndex + 1
}

function Get-BackupDateStamp() {
    return (Get-Date).ToString("M-d-yyyy", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-BackupFolderName([int64]$Index, [string]$DateStamp) {
    return "Iron Soul Backup $Index - $DateStamp"
}

function New-BackupPlan([string]$BackupRoot) {
    $dateStamp = Get-BackupDateStamp
    $index = Get-NextBackupIndex $BackupRoot

    while ($true) {
        $name = Get-BackupFolderName $index $dateStamp
        $path = Join-Path $BackupRoot $name

        if (-not (Test-Path -LiteralPath $path)) {
            return [pscustomobject]@{
                Index = $index
                Name = $name
                Path = $path
            }
        }

        $index++
    }
}

function ConvertFrom-RobocopySummaryLine([string]$Line) {
    if ($Line -notmatch '^\s*(?<label>Dirs|Files|Bytes)\s*:\s*(?<values>.+)$') {
        return $null
    }

    $values = @($Matches["values"] -split '\s{2,}' | Where-Object { $_.Trim().Length -gt 0 })
    if ($values.Count -lt 6) {
        return $null
    }

    return [pscustomobject]@{
        Label = $Matches["label"]
        Total = $values[0].Trim()
        Copied = $values[1].Trim()
        Skipped = $values[2].Trim()
        Mismatch = $values[3].Trim()
        Failed = $values[4].Trim()
        Extras = $values[5].Trim()
    }
}

function Get-RobocopySummary([string[]]$Output) {
    $summary = [ordered]@{}

    foreach ($line in $Output) {
        $row = ConvertFrom-RobocopySummaryLine $line
        if ($null -ne $row) {
            $summary[$row.Label] = $row
        }
    }

    return [pscustomobject]@{
        Dirs = $summary["Dirs"]
        Files = $summary["Files"]
        Bytes = $summary["Bytes"]
    }
}

function Format-RobocopySummaryRow($Row) {
    if ($null -eq $Row) {
        return $null
    }

    $summary = "total $($Row.Total), copied $($Row.Copied), skipped $($Row.Skipped), failed $($Row.Failed)"
    if (($Row.Mismatch -ne "0") -or ($Row.Extras -ne "0")) {
        $summary += ", mismatch $($Row.Mismatch), extras $($Row.Extras)"
    }

    return $summary
}

function Write-RobocopySummary($Summary) {
    if (($null -eq $Summary) -or (($null -eq $Summary.Dirs) -and ($null -eq $Summary.Files) -and ($null -eq $Summary.Bytes))) {
        Write-Host "[SUCCESS] robocopy completed; summary was not available."
        return
    }

    Write-Host "[SUCCESS] Robocopy summary:"

    $dirs = Format-RobocopySummaryRow $Summary.Dirs
    if ($null -ne $dirs) {
        Write-Host "[SUCCESS]   Dirs: $dirs"
    }

    $files = Format-RobocopySummaryRow $Summary.Files
    if ($null -ne $files) {
        Write-Host "[SUCCESS]   Files: $files"
    }

    if ($null -ne $Summary.Bytes) {
        Write-Host "[SUCCESS]   Bytes: total $($Summary.Bytes.Total), copied $($Summary.Bytes.Copied)"
    }
}

function Invoke-RobocopyBackup([string]$SourceRoot, [string]$BackupPath) {
    $robocopy = Get-Command "robocopy.exe" -ErrorAction SilentlyContinue
    if ($null -eq $robocopy) {
        throw "robocopy.exe was not found."
    }

    $arguments = @(
        $SourceRoot
        $BackupPath
        "/E"
        "/COPY:DAT"
        "/DCOPY:DAT"
        "/XJ"
        "/R:2"
        "/W:1"
        "/MT:16"
        "/NP"
        "/NFL"
        "/NDL"
    )

    $output = @(& $robocopy.Source @arguments)
    $exitCode = $LASTEXITCODE
    $summary = Get-RobocopySummary $output

    if ($exitCode -ge 8) {
        throw "robocopy failed with exit code $exitCode. Partial backup folder left untouched: $BackupPath"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Summary = $summary
    }
}

Assert-DirectoryExists $repo "repo root"
Assert-DirectoryExists (Join-Path $repo "tools") "tools directory"
Assert-PathExists (Join-Path $repo ".git") "repo metadata"
Assert-BackupPathsAreSafe $repo $destinationRoot

$plan = New-BackupPlan $destinationRoot

if (-not $PSCmdlet.ShouldProcess($plan.Path, "Create full Iron Soul repo backup from $repo")) {
    return
}

[System.IO.Directory]::CreateDirectory($destinationRoot) | Out-Null
if (Test-Path -LiteralPath $plan.Path) {
    $plan = New-BackupPlan $destinationRoot
}
New-Item -Path $plan.Path -ItemType Directory -ErrorAction Stop | Out-Null

Write-Host "[INFO] Source: $repo"
Write-Host "[INFO] Backup: $($plan.Path)"

$robocopyResult = Invoke-RobocopyBackup $repo $plan.Path

Write-Host "[SUCCESS] Backup created: $($plan.Path)"
Write-RobocopySummary $robocopyResult.Summary
