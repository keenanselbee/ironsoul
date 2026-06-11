$script:IronSoulRepo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$script:IronSoulSourceDir = Join-Path $script:IronSoulRepo "mod\source\scripts"
$script:IronSoulNativeAliases = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@("native", "skse", "plugin"),
    [System.StringComparer]::OrdinalIgnoreCase
)

Set-Location -LiteralPath $script:IronSoulRepo

function ConvertTo-IronSoulCompileAlias {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    $name = [System.IO.Path]::GetFileName($Target.Trim())
    if ([string]::IsNullOrWhiteSpace($name)) {
        throw "Compile target is empty."
    }

    if ($name.EndsWith(".psc", [System.StringComparison]::OrdinalIgnoreCase)) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($name)
    }

    if ($name.StartsWith("IronSoul", [System.StringComparison]::OrdinalIgnoreCase)) {
        $name = $name.Substring("IronSoul".Length)
    }

    return $name.ToLowerInvariant()
}

function Get-IronSoulCompileAliasMap {
    if (-not (Test-Path -LiteralPath $script:IronSoulSourceDir -PathType Container)) {
        throw "Papyrus source directory not found: $script:IronSoulSourceDir"
    }

    $aliases = @{}
    Get-ChildItem -LiteralPath $script:IronSoulSourceDir -Filter "IronSoul*.psc" |
        Sort-Object Name |
        ForEach-Object {
            $alias = ConvertTo-IronSoulCompileAlias $_.Name
            if ($aliases.ContainsKey($alias)) {
                throw "Duplicate compile alias '$alias' for $($aliases[$alias]) and $($_.Name)."
            }

            $aliases[$alias] = $_.Name
        }

    return $aliases
}

function Show-IronSoulCompileUsage {
    $aliases = Get-IronSoulCompileAliasMap
    $papyrusAliases = $aliases.Keys | Sort-Object

    Write-Host "Usage:"
    Write-Host "  compile ui sunderhearts config    Refresh repo PEX files"
    Write-Host "  compile death -Temp               Compile to .codex-temp only"
    Write-Host "  compile native                    Build and refresh the repo SKSE DLL"
    Write-Host "  compile native -VerifyOnly        Build the SKSE DLL without repo refresh"
    Write-Host ""
    Write-Host "Native aliases: native, skse, plugin"
    Write-Host "Papyrus aliases: $($papyrusAliases -join ', ')"
    Write-Host "Papyrus note: use IronSoulNative or IronSoulNative.psc to compile that script."
}

function backup {
    [CmdletBinding()]
    param(
        [switch]$WhatIf
    )

    $backupScript = Join-Path $script:IronSoulRepo "tools\backup-repo.ps1"
    if ($WhatIf) {
        & $backupScript -WhatIf
    } else {
        & $backupScript
    }
}

function compile {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Targets,

        [switch]$Temp,
        [switch]$VerifyOnly
    )

    if (-not $Targets -or $Targets.Count -eq 0) {
        Show-IronSoulCompileUsage
        return
    }

    $nativeTargets = @($Targets | Where-Object { $script:IronSoulNativeAliases.Contains($_.Trim()) })
    if ($nativeTargets.Count -gt 0) {
        if ($Targets.Count -ne 1) {
            throw "Native compile aliases must be used alone. Use 'compile native', 'compile skse', or 'compile plugin'."
        }
        if ($Temp) {
            throw "-Temp is only valid for Papyrus compiles. Use 'compile native -VerifyOnly' for a native build without DLL refresh."
        }

        $buildScript = Join-Path $script:IronSoulRepo "tools\build-skse-plugin.ps1"
        if ($VerifyOnly) {
            & $buildScript -VerifyOnly
        } else {
            & $buildScript -RefreshRepoDll
        }
        return
    }

    if ($VerifyOnly) {
        throw "-VerifyOnly is only valid for native plugin builds. Use -Temp for a Papyrus compile without repo PEX refresh."
    }

    $aliases = Get-IronSoulCompileAliasMap
    $scripts = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($target in $Targets) {
        $alias = ConvertTo-IronSoulCompileAlias $target
        if (-not $aliases.ContainsKey($alias)) {
            Show-IronSoulCompileUsage
            throw "Unknown Papyrus compile alias '$target'."
        }

        $scriptName = $aliases[$alias]
        if ($seen.Add($scriptName)) {
            $scripts.Add($scriptName)
        }
    }

    $compileScript = Join-Path $script:IronSoulRepo "tools\compile-papyrus.ps1"
    if ($Temp) {
        & $compileScript -Scripts $scripts.ToArray()
    } else {
        & $compileScript -Scripts $scripts.ToArray() -RefreshRepoPex
    }
}
