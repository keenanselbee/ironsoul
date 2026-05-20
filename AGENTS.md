=================
--- AGENTS.md ---
=================

Iron Soul is a Skyrim SE mod with Papyrus scripts, SKSE plugin source, assets, and user-facing INI configuration.

--- Working Rules ---
=====================

- Keep changes narrow and follow the existing style in the files being edited.
- Prefer simple, direct fixes. Do not overengineer or add abstractions unless they are clearly needed.
- Do not revert or overwrite unrelated user changes.
- Do not create, edit, move, delete, or overwrite files outside `C:\Repositories\Iron Soul` except for the documented SKSE plugin build automation, xEdit staged inspection, and MO2 overwrite INI refresh below. External paths may otherwise be read or used as tool/import inputs only.
- Keep temporary compile output or staging inside this repo, preferably under `.codex-temp`.
- Treat `_reference/` as read-only reference material for the original Draugnarok and Respawn Soulslike Edition. Do not edit, stage, or commit anything inside it.
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
- Use `_tools/dump-esp-records.ps1` for first-pass read-only ESP dumps and text searches when possible.
- Prefer the SSEEdit64 GUI for authoritative ESP record inspection. Load only the relevant plugin(s) and required masters, then wait for `Background Loader: finished` before drawing conclusions.
- Use EditorID/FormID search and the record tree to inspect records. Report the record signature, FormID, EditorID, and important field paths/values.
- Do not rely on Papyrus source alone when ESP or Story Manager wiring determines behavior.
- ESP/ESM/ESL files are view-only for Codex. Do not edit, save, compact, clean, or otherwise modify plugin files in xEdit.
- When closing xEdit, if any save prompt appears for a plugin, choose not to save.
- Do not run QuickAutoClean or save plugin backups unless the user explicitly asks for plugin edits/cleaning.
- `G:\Modding\LoreRim\Tools\xEdit\SSEDump64.exe` may be used as an optional read-only helper.
- Prefer `_tools/dump-esp-records.ps1 -StageInStockData` when using SSEDump64 against repo plugins, because SSEDump resolves masters reliably when the target plugin is temporarily staged beside the Stock Game Data masters.
- The staged dump helper may temporarily copy a repo ESP/ESM/ESL into `G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`, run SSEDump, and remove only the hash-matching staged copy afterward. It must refuse to overwrite an existing plugin with the same name.
- If using SSEDump64 directly, pass `-D:G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`; if it fails to resolve masters, check `G:\Modding\LoreRim\Tools\xEdit\SSEDump64Exception.log` and fall back to SSEEdit64 GUI inspection.


--- Papyrus ---
===============

- Iron Soul Papyrus source lives in `Source/Scripts`.
- Compiled scripts output to `Scripts`.
- Core source scripts include `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, `IronSoulNative.psc`, `IronSoulOnDying.psc`, `IronSoulPlayerAlias.psc`, and `_DS_DN_Draugnarok.psc`.
- Additional Draugnarok quest/location source scripts also live in `Source/Scripts`.
- SKSE sources must appear before stock sources in the import list.
- PapyrusUtil sources are required for helpers such as `StorageUtil` and `JsonUtil`.
- When changing `.psc` files, compile the changed script with `_tools/compile-papyrus.ps1` when available.
- Default compile mode writes only to `.codex-temp\PapyrusCompile`.
- Use `_tools/compile-papyrus.ps1 <ScriptName.psc> -RefreshRepoPex` only when the compiled repo `Scripts\<ScriptName>.pex` should be refreshed.
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


--- Papyrus Compile Automation ---
==================================

```powershell
_tools\compile-papyrus.ps1 IronSoulController.psc
_tools\compile-papyrus.ps1 IronSoulController.psc IronSoulConsoleCommands.psc -RefreshRepoPex
```


--- SKSE Plugin Build Automation ---
====================================

- Codex may run `_tools/build-skse-plugin.ps1` when the user explicitly requests SKSE plugin build verification or DLL refresh.
- Before proposing or performing external project edits, warn exactly: `WARNING: THIS WILL MODIFY THE EXTERNAL BUILD PROJECT`.
- The script mirrors `Source/Plugin/**/*.cpp` and `Source/Plugin/**/*.h` to `G:\Modding\LoreRim\Dev\projects\ironsoul\src`, then builds with `G:\Modding\LoreRim\Dev\tools\xmake\xmake.exe`.
- Default mode is verify-only. Verify-only builds must not update `SKSE/plugins/ironsoul.dll`.
- DLL refresh is allowed only when explicitly requested, by running `_tools/build-skse-plugin.ps1 -RefreshRepoDll`.
- DLL refresh must copy only the successful release output from `G:\Modding\LoreRim\Dev\projects\ironsoul\build\windows\x64\release\IronSoul.dll` to `SKSE/plugins/ironsoul.dll`.
- Do not copy debug DLLs or any external build output other than the release DLL.
- Do not stage or commit the DLL from inside the script. If the repo DLL changes, commit it separately as `build(native): update SKSE plugin binary`.


--- MO2 Overwrite INI Refresh ---
=================================

- Codex may run `_tools/refresh-overwrite-ini.ps1` when `SKSE/plugins/ironsoul.ini` changes or when the user explicitly asks to refresh the LoreRim+ Overwrite INI.
- The script overwrites `G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini` from the repo INI, then forces these debug settings:

```ini
EnableDebug = 1
EnableLogging = 1
EnableLogNotifications = 1
LogLevel = 3
```

- Do not manually edit the LoreRim+ Overwrite INI. Update the repo INI, then run the refresh tool.
- If the refresh tool fails, leave the external overwrite INI untouched except for any partial write the tool already performed, and report the error.


--- INI Configuration ---
=========================

- When adding, removing, or renaming public INI keys, update `SKSE/plugins/ironsoul.ini`.
- Also update the native allowlist in `source/plugin/config.cpp`.
- Also update the public `gini` listing in `Source/Scripts/IronSoulConsoleCommands.psc`.
- After changing `SKSE/plugins/ironsoul.ini`, run `_tools/refresh-overwrite-ini.ps1` to refresh the LoreRim+ Overwrite INI with debug logging enabled.


--- Verification ---
====================

- Run the smallest relevant check for the files changed.
- Mention any compile, build, or test step that could not be run.
