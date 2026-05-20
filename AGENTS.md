=================
--- AGENTS.md ---
=================

Iron Soul is a Skyrim SE mod with Papyrus scripts, SKSE plugin source, assets, and user-facing INI configuration.

--- Working Rules ---
=====================

- Keep changes narrow and follow the existing style in the files being edited.
- Prefer simple, direct fixes. Do not overengineer or add abstractions unless they are clearly needed.
- Do not revert or overwrite unrelated user changes.
- Do not create, edit, move, delete, or overwrite files outside `C:\Repositories\Iron Soul`. External paths may be read or used as tool/import inputs only.
- Keep temporary compile output or staging inside this repo, preferably under `.codex-temp`.
- Do not rebuild `SKSE/plugins/ironsoul.dll`; the user will handle SKSE plugin builds.
- Follow `_docs/style-guide.md` for naming and formatting conventions.


--- Shell Reliability ---
=========================

- The shell may start in `C:\` even when the workspace root is provided.
- Treat `C:\Repositories\Iron Soul` as the canonical repo root for this project.
- Prefer explicit absolute repo paths, or use `git -C "C:\Repositories\Iron Soul"` for git commands.
- Before broad searches or recursive commands, verify the current location with `Get-Location` or target the repo root explicitly.
- Do not assume relative paths resolve from the repo root unless the command sets location itself.
- If a command unexpectedly lands in `C:\`, stop and rerun it with an explicit repo path.

Example:

```powershell
$repo = "C:\Repositories\Iron Soul"
Set-Location -LiteralPath $repo
```


--- xEdit / ESP Inspection ---
==============================

- xEdit lives at `G:\Modding\LoreRim\Tools\xEdit`.
- Use `G:\Modding\LoreRim\Tools\xEdit\SSEEdit64.exe` when ESP inspection is needed.
- Skyrim SE stock Data for xEdit master resolution is `G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`.
- Do not use `G:\Modding\LoreRim\Update\Stock Game\Data` for xEdit; that path is only the Papyrus source/flags area.
- Prefer the SSEEdit64 GUI for authoritative ESP record inspection. Load only the relevant plugin(s) and required masters, then wait for `Background Loader: finished` before drawing conclusions.
- Use EditorID/FormID search and the record tree to inspect records. Report the record signature, FormID, EditorID, and important field paths/values.
- Do not rely on Papyrus source alone when ESP or Story Manager wiring determines behavior.
- ESP/ESM/ESL files are view-only for Codex. Do not edit, save, compact, clean, or otherwise modify plugin files in xEdit.
- When closing xEdit, if any save prompt appears for a plugin, choose not to save.
- Do not run QuickAutoClean or save plugin backups unless the user explicitly asks for plugin edits/cleaning.
- `G:\Modding\LoreRim\Tools\xEdit\SSEDump64.exe` may be used as an optional read-only helper.
- If using SSEDump64, pass `-D:G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`; if it fails to resolve masters, check `G:\Modding\LoreRim\Tools\xEdit\SSEDump64Exception.log` and fall back to SSEEdit64 GUI inspection.


--- Papyrus ---
===============

- Iron Soul Papyrus source lives in `Source/Scripts`.
- Compiled scripts output to `Scripts`.
- Core source scripts include `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, `IronSoulNative.psc`, `IronSoulOnDying.psc`, `IronSoulPlayerAlias.psc`, and `_DS_DN_Draugnarok.psc`.
- Additional Draugnarok quest/location source scripts also live in `Source/Scripts`.
- SKSE sources must appear before stock sources in the import list.
- PapyrusUtil sources are required for helpers such as `StorageUtil` and `JsonUtil`.
- When changing `.psc` files, compile the changed script with the Skyrim SE Papyrus compiler when available.
- Compile to `.codex-temp\PapyrusCompile` first.
- If the compile succeeds and the expected `.pex` exists, replace the matching file in `Scripts`.
- If compilation fails, leave the existing `.pex` untouched and report the compiler errors.
- When adding, removing, or renaming functions in `Source/Scripts/IronSoulController.psc`, update that script's table of contents.

Papyrus compiler paths:

```text
Compiler: G:\Modding\LoreRim\Tools\Papyrus Compiler\PapyrusCompiler.exe
Flags:    G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg
Imports:  C:\Repositories\Iron Soul\Source\Scripts
          G:\Modding\LoreRim\Mod Organizer\mods\Skyrim Script Extender (SKSE64)\Scripts\Source
          G:\Modding\LoreRim\Mod Organizer\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Scripts\Source
          G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts
```

If SKSE imports are missing or ordered after stock sources, functions such as `GetINIFloat`, `GetName`, `RegisterForKey`, `UnregisterForKey`, `RegisterForModEvent`, and `UnregisterForModEvent` may fail to resolve.


--- Papyrus Compile Example ---
===============================

```powershell
$repo = "C:\Repositories\Iron Soul"
$script = "IronSoulController.psc"
$compiler = "G:\Modding\LoreRim\Tools\Papyrus Compiler\PapyrusCompiler.exe"
$flags = "G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg"
$skse = "G:\Modding\LoreRim\Mod Organizer\mods\Skyrim Script Extender (SKSE64)\Scripts\Source"
$papyrusUtil = "G:\Modding\LoreRim\Mod Organizer\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Scripts\Source"
$stock = "G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts"
$imports = "$repo\Source\Scripts;$skse;$papyrusUtil;$stock"
$out = Join-Path $repo ".codex-temp\PapyrusCompile"
$pexName = [IO.Path]::ChangeExtension($script, ".pex")

New-Item -ItemType Directory -Force -Path $out | Out-Null
Remove-Item -LiteralPath (Join-Path $out $pexName) -Force -ErrorAction SilentlyContinue

Push-Location -LiteralPath (Join-Path $repo "Source\Scripts")
& $compiler $script "-f=$flags" "-i=$imports" "-o=$out"
$exitCode = $LASTEXITCODE
Pop-Location

$compiledPex = Join-Path $out $pexName
if ($exitCode -eq 0 -and (Test-Path -LiteralPath $compiledPex)) {
    Move-Item -LiteralPath $compiledPex -Destination (Join-Path $repo "Scripts\$pexName") -Force
} else {
    throw "Papyrus compile failed; existing Scripts PEX was left untouched."
}
```


--- INI Configuration ---
=========================

- When adding, removing, or renaming public INI keys, update `SKSE/plugins/ironsoul.ini`.
- Also update the native allowlist in `source/plugin/config.cpp`.
- Also update the public `gini` listing in `Source/Scripts/IronSoulConsoleCommands.psc`.
- Do not rebuild `SKSE/plugins/ironsoul.dll`; the user will handle SKSE plugin builds.


--- Verification ---
====================

- Run the smallest relevant check for the files changed.
- Mention any compile, build, or test step that could not be run.
