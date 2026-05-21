--- AGENTS.md ---
=================

Iron Soul is a Skyrim SE mod with Papyrus scripts, SKSE plugin source, assets, and user-facing INI configuration.

--- Command Speed Rules ---
---------------------------

- Zero-tool commands must not inspect files, run shell commands, check git status, summarize context, or add extra explanation.
- `help` is the only zero-tool command. Reply immediately from the command list in the Keyword Commands section.
- Direct-action commands should skip unrelated repo inspection, git status checks, diff reading, and planning. Execute only their defined workflow, then report the result.
- Direct-action commands are `DLL`, `LOG`, `OINI`, `OINI2`, and `RINI2`.


--- Working Rules ---
---------------------

- Keep changes narrow and follow the existing style in the files being edited.
- Prefer simple, direct fixes. Do not overengineer or add abstractions unless they are clearly needed.
- Do not revert or overwrite unrelated user changes.
- Do not create, edit, move, delete, or overwrite files outside `C:\Repositories\Iron Soul` except for the documented xEdit staged inspection and MO2 overwrite INI refresh below. External paths may otherwise be read or used as tool/import inputs only.
- Keep temporary compile output or staging inside this repo, preferably under `.codex-temp`.
- Treat `reference/` as read-only reference material for the original Draugnarok and Respawn Soulslike Edition. Do not edit, stage, or commit anything inside it.
- Follow `docs/style-guide.md` for naming and formatting conventions.


--- Shell Reliability ---
-------------------------

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
------------------------------

- xEdit lives at `G:\Modding\LoreRim\Tools\xEdit`.
- Use `G:\Modding\LoreRim\Tools\xEdit\SSEEdit64.exe` when ESP inspection is needed.
- Skyrim SE stock Data for xEdit master resolution is `G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`.
- Do not use `G:\Modding\LoreRim\Update\Stock Game\Data` for xEdit; that path is only the Papyrus source/flags area.
- Use `tools/dump-esp-records.ps1` for first-pass read-only ESP dumps and text searches when possible.
- Prefer the SSEEdit64 GUI for authoritative ESP record inspection. Load only the relevant plugin(s) and required masters, then wait for `Background Loader: finished` before drawing conclusions.
- Use EditorID/FormID search and the record tree to inspect records. Report the record signature, FormID, EditorID, and important field paths/values.
- Do not rely on Papyrus source alone when ESP or Story Manager wiring determines behavior.
- ESP/ESM/ESL files are view-only for Codex. Do not edit, save, compact, clean, or otherwise modify plugin files in xEdit.
- When closing xEdit, if any save prompt appears for a plugin, choose not to save.
- Do not run QuickAutoClean or save plugin backups unless the user explicitly asks for plugin edits/cleaning.
- `G:\Modding\LoreRim\Tools\xEdit\SSEDump64.exe` may be used as an optional read-only helper.
- Prefer `tools/dump-esp-records.ps1 -StageInStockData` when using SSEDump64 against repo plugins, because SSEDump resolves masters reliably when the target plugin is temporarily staged beside the Stock Game Data masters.
- The staged dump helper may temporarily copy a repo ESP/ESM/ESL into `G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`, run SSEDump, and remove only the hash-matching staged copy afterward. It must refuse to overwrite an existing plugin with the same name.
- If using SSEDump64 directly, pass `-D:G:\Modding\LoreRim\Mod Organizer\Stock Game\Data`; if it fails to resolve masters, check `G:\Modding\LoreRim\Tools\xEdit\SSEDump64Exception.log` and fall back to SSEEdit64 GUI inspection.


--- Papyrus ---
---------------

- Iron Soul Papyrus source lives in `mod/source/scripts`.
- Compiled scripts output to `mod/scripts`.
- Core source scripts include `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, `IronSoulNative.psc`, `IronSoulOnDying.psc`, `IronSoulPlayerAlias.psc`, and `_DS_DN_Draugnarok.psc`.
- Additional Draugnarok quest/location source scripts also live in `mod/source/scripts`.
- SKSE sources must appear before stock sources in the import list.
- PapyrusUtil sources are required for helpers such as `StorageUtil` and `JsonUtil`.
- When changing `.psc` files, compile the changed script with `tools/compile-papyrus.ps1` when available.
- Default compile mode writes only to `.codex-temp\PapyrusCompile`.
- Use `tools/compile-papyrus.ps1 <ScriptName.psc> -RefreshRepoPex` only when the compiled repo `mod\scripts\<ScriptName>.pex` should be refreshed.
- If compilation fails, leave the existing `.pex` untouched and report the compiler errors.
- When adding, removing, or renaming functions in `mod/source/scripts/IronSoulController.psc`, update that script's table of contents.

Papyrus compiler paths:

```text
Compiler: G:\Modding\LoreRim\Tools\Papyrus Compiler\PapyrusCompiler.exe
Flags:    G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg
Imports:  C:\Repositories\Iron Soul\mod\source\scripts
          G:\Modding\LoreRim\Mod Organizer\mods\Skyrim Script Extender (SKSE64)\Scripts\Source
          G:\Modding\LoreRim\Mod Organizer\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Scripts\Source
          G:\Modding\LoreRim\Update\Stock Game\Data\Source\Scripts
```

If SKSE imports are missing or ordered after stock sources, functions such as `GetINIFloat`, `GetName`, `RegisterForKey`, `UnregisterForKey`, `RegisterForModEvent`, and `UnregisterForModEvent` may fail to resolve.


--- Papyrus Compile Automation ---
----------------------------------

```powershell
tools\compile-papyrus.ps1 IronSoulController.psc
tools\compile-papyrus.ps1 IronSoulController.psc IronSoulConsoleCommands.psc -RefreshRepoPex
```


--- SKSE Plugin Build Automation ---
------------------------------------

- Codex may run `tools/build-skse-plugin.ps1` when the user explicitly requests SKSE plugin build verification or DLL refresh, or when Codex has changed `dev/projects/ironsoul/src` source and needs final build verification/output sync.
- Iron Soul SKSE plugin source lives in `dev/projects/ironsoul/src`.
- The script builds the repo-local project in `dev/projects/ironsoul` with `dev/tools/xmake/xmake.exe` and uses local xmake state under `dev/.xmake`.
- For completed SKSE plugin source changes, run `tools/build-skse-plugin.ps1 -RefreshRepoDll` by default after a successful build so `mod/SKSE/plugins/ironsoul.dll` matches the source change. Use verify-only only for WIP checks or when the user explicitly asks not to refresh the repo DLL.
- Verify-only builds must not update `mod/SKSE/plugins/ironsoul.dll`.
- DLL refresh must copy only the successful release output from `dev/projects/ironsoul/build/windows/x64/release/IronSoul.dll` to `mod/SKSE/plugins/ironsoul.dll`.
- Do not copy debug DLLs or any build output other than the release DLL.
- Do not stage or commit the DLL from inside the script. When `dev/projects/ironsoul/src` source changed, stage `mod/SKSE/plugins/ironsoul.dll` with the same source commit that produced it. Use a standalone `build(native): update SKSE plugin binary` commit only for an explicitly requested DLL-only refresh or generated-output repair.


--- MO2 Overwrite INI Refresh ---
---------------------------------

- Codex may run `tools/refresh-overwrite-ini.ps1` when `mod/SKSE/plugins/ironsoul.ini` changes or when the user explicitly asks to refresh the LoreRim+ Overwrite INI.
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
-------------------------

- When adding, removing, or renaming public INI keys, update `mod/SKSE/plugins/ironsoul.ini`.
- Also update the native allowlist in `dev/projects/ironsoul/src/config.cpp`.
- Also update the public `gini` listing in `mod/source/scripts/IronSoulConsoleCommands.psc`.
- After changing `mod/SKSE/plugins/ironsoul.ini`, run `tools/refresh-overwrite-ini.ps1` to refresh the LoreRim+ Overwrite INI with debug logging enabled.


--- Keyword Commands ---
------------------------

Codex chat messages may trigger repo-specific keyword commands.

- A keyword command triggers only when the entire user message, after trimming whitespace, is exactly one command word.
- The only parameterized keyword command is `XEDIT: <question>`, which may include free-form question text after the colon.
- `help` is the only lowercase command. All other commands are uppercase.
- If an unknown uppercase single-word command is received, reply with `Unknown command. Type help.`
- Commands must still follow all safety, staging, compile, build, xEdit, and external-path rules in this file.
- Commands that modify external paths, refresh compiled artifacts, launch GUI tools, or create commits must explain the intended action and wait for explicit confirmation when the command definition says confirmation is required.

`help` prints this command list quickly, alphabetically, with one short line per command:

```text
AUDIT   Audit the last few substantial chat changes end to end without editing.
COMMIT   Execute the latest DIFF commit proposal.
COMPILE  Compile all Papyrus source scripts and refresh only changed repo .pex files.
DIFF     Show changed files and propose intelligent commit splits.
DLL      Build and refresh mod/SKSE/plugins/ironsoul.dll.
IMPLEMENT Execute the latest SUGGEST implementation proposal.
LOG      Build tools/ironsoul-combined.log, summarize it, then open it in VS Code.
MSG      Generate a commit message for the currently staged files.
OINI     Open the repo INI in VS Code.
OINI2    Open the LoreRim+ Overwrite INI in VS Code for inspection.
RINI2    Refresh the LoreRim+ Overwrite INI from the repo INI.
STATUS   Assess project direction and repo health, then recommend next work.
SUGGEST  Suggest the smartest minimal implementation course without editing.
XEDIT    Summarize the main plugin, or answer an XEDIT: question from a fresh ESP dump.
```

Command behavior:

- `AUDIT`: Run a read-only audit of the last few substantial changes made in the current chat. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. Use the available chat context to identify the change set, then inspect relevant git status, diffs, and affected files to verify the work end to end against the user's requests. Check for behavioral regressions, missed call sites, stale docs/config, missing generated artifacts, unsafe file operations, and verification gaps. Report findings first in severity order with file/line references where possible; if no issues are found, say that clearly and list any residual risk or checks not run.
- `COMMIT`: Treat the `COMMIT` command as confirmation to execute the latest commit proposal produced by `DIFF`. Before staging, verify the worktree still matches that proposal. If no current `DIFF` proposal exists, or if the worktree changed since the proposal, run the `DIFF` behavior and stop instead of committing. When executing, stage only the proposed files for each commit, run `git diff --cached --check` before each commit, use the proposed messages, and finish with commit hashes and final status.
- `COMPILE`: Enumerate every `.psc` file under `mod/source/scripts`, then compile all of them with `tools/compile-papyrus.ps1` to `.codex-temp\PapyrusCompile` first. Do not use `-RefreshRepoPex` for this command because that switch copies every successful target. If compilation succeeds, compare each generated `.pex` against `mod/scripts\<ScriptName>.pex` with SHA-256 hashes, then copy only missing or different repo `.pex` files. Leave existing repo `.pex` files untouched for failed scripts and report copied, unchanged, and failed scripts.
- `DIFF`: Report current git status, diff stats, and important changed files without modifying the worktree. Then propose an intelligent commit plan with commit groups, file lists, and commit messages. Use multiple commits when changes are independently revertible. Group `mod/SKSE/plugins/ironsoul.dll` with the matching `dev/projects/ironsoul/src` source commit when native source changes exist; propose a standalone `build(native)` commit only for an explicit DLL-only refresh. State that `COMMIT` will execute this proposal if the worktree is unchanged.
- `DLL`: Treat the `DLL` command itself as the explicit user request to refresh the repo DLL. State that `mod/SKSE/plugins/ironsoul.dll` will be refreshed on success, then run `tools/build-skse-plugin.ps1 -RefreshRepoDll` without asking for another chat confirmation.
- `IMPLEMENT`: Treat the `IMPLEMENT` command as confirmation to execute the latest `SUGGEST` proposal or the latest explicit implementation plan proposed in chat. Before editing, verify the current request, repo context, and worktree still match that proposal; if no current proposal exists, or if the context has changed enough that the proposal may be stale, run `SUGGEST` behavior and stop instead of editing. When executing, make the narrow proposed code/file changes, run the relevant verification, refresh generated artifacts when project rules require it, and report changed files and checks. Do not stage or commit unless the user separately asks.
- `LOG`: Run `tools/build-ironsoul-log.bat`, then summarize `tools/ironsoul-combined.log`. Open the generated log in VS Code with `code --reuse-window "C:\Repositories\Iron Soul\tools\ironsoul-combined.log"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "C:\Repositories\Iron Soul\tools\ironsoul-combined.log"`.
- `MSG`: Read only the currently staged files and staged diff needed to understand them, then generate a commit message in chat that follows `docs/commit-style.md`. Do not edit files, stage, commit, inspect unstaged changes, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. If no files are staged, say so and stop.
- `OINI`: Open `C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini` in VS Code. Use `code --reuse-window "C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini"`.
- `OINI2`: Open `G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini` in VS Code for inspection only. Use `code --reuse-window "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"`. Do not manually edit the overwrite INI.
- `RINI2`: Run `tools/refresh-overwrite-ini.ps1` to refresh the LoreRim+ Overwrite INI with debug logging enabled. Report any failure.
- `STATUS`: Run a read-only project direction and health check. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files. Read `README.md` first; its Current TODO and ROADMAP sections are the primary direction source. Also read any separate `ROADMAP*` or `TODO*` files if they exist, plus meaningful repo TODO/FIXME markers. Check expected repo structure, key automation scripts, and required external tools/paths from this file for missing or broken pieces. Treat git as background context only: mention uncommitted changes, unpushed commits, or recent commits only when they affect project health, block likely next work, or explain current direction. Report project direction, health issues, risks, and the most likely next work in priority order.
- `SUGGEST`: Run a read-only assessment of the current request or active problem and recommend the smartest minimal implementation course. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. Inspect only the repo context needed to avoid guessing. Recommend the best next action, likely files or systems involved, the smallest safe implementation shape, key risks, and the verification that should be run before committing.
- `XEDIT`: Run `tools/dump-esp-records.ps1 "Iron Soul - Dead God's Dream.esp" -StageInStockData`, summarize the plugin's major records and wiring from the dump, then suggest likely next changes. Do not edit or save plugin files.
- `XEDIT: <question>`: Treat the text after the colon as the inspection question. Dump `Iron Soul - Dead God's Dream.esp` with `-StageInStockData` by default, or dump another repo `.esp`, `.esm`, or `.esl` only if the question clearly names it. Search the dump for relevant terms, answer with record signature, FormID, EditorID, and important field paths/values where possible, and say when SSEEdit64 GUI inspection is needed for confidence. Do not edit or save plugin files.


--- Verification ---
--------------------

- Run the smallest relevant check for the files changed.
- Mention any compile, build, or test step that could not be run.
