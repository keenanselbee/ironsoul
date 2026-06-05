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

    & $robocopy.Source @arguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -ge 8) {
        throw "robocopy failed with exit code $exitCode. Partial backup folder left untouched: $BackupPath"
    }

    return $exitCode
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

$robocopyExitCode = Invoke-RobocopyBackup $repo $plan.Path

Write-Host "[SUCCESS] Backup created: $($plan.Path)"
Write-Host "[SUCCESS] robocopy exit code: $robocopyExitCode"
