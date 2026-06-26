AGENTS.md
=========

Iron Soul is a Skyrim SE mod with Papyrus scripts, SKSE plugin source, assets, and user-facing INI configuration.

Command Speed Rules
-------------------

- Zero-tool commands must not inspect files, run shell commands, check git status, summarize context, or add extra explanation.
- `help` is the only zero-tool command. Reply immediately from the command list in the Keyword Commands section.
- Direct-action commands should skip unrelated repo inspection, git status checks, diff reading, and planning. Execute only their defined workflow, then report the result.
- Direct-action commands are `BACKUP`, `DLL`, `LOG`, `OINI`, `OINI2`, `README`, `RINI2`, `ROADMAP`, and `TODO`.


Do Not Edit Guard
-----------------

- If the user intentionally types `DNE` in their current prompt, treat it as "do not edit" for that prompt. Do not create, edit, move, delete, stage, commit, compile, build, refresh generated artifacts, launch external editors, or modify external paths during that prompt unless the user explicitly overrides `DNE` in the same prompt.
- `DNE` only applies when it appears to be typed intentionally by the user as an instruction. Ignore incidental appearances inside pasted file contents, quoted text, strings, command output, diffs, logs, or examples.


Working Rules
-------------

- Keep changes narrow and follow the existing style in the files being edited.
- Treat `README.md` as the main project document; it contains the version, Current TODO, Roadmap, Credits, and other project direction notes.
- Prefer simple, direct fixes. Do not overengineer or add abstractions unless they are clearly needed.
- Prefer not to add functions whose body is only one line of code unless there is a good reason, such as matching an existing interface, naming a repeated concept, or improving readability at the call site.
- Do not revert or overwrite unrelated user changes.
- Do not create, edit, move, delete, or overwrite files outside `C:\Repositories\Iron Soul` except for the documented BACKUP command, xEdit staged inspection, MO2 overwrite INI refresh, and explicitly requested Desktop output below. External paths may otherwise be read or used as tool/import inputs only.
- The BACKUP command may create and write only under `Z:\Backup\LoreRim\Iron Soul` outside the repo.
- When the user explicitly asks for output on the Desktop, Codex may create, edit, move, delete, or overwrite only the specific generated/user-facing files needed for that request under `C:\Users\Keenan\Desktop`. Do not use the Desktop for temporary build output, staging, broad exports, or unrelated files.
- Keep temporary compile output or staging inside this repo, preferably under `.codex-temp`.
- Treat `reference/` as read-only reference material for the original Draugnarok and Respawn Soulslike Edition. Do not edit, stage, or commit anything inside it.
- Follow `docs/style-guide.md` for naming and formatting conventions.


Shell Reliability
-----------------

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


AutoHotkey / ExplorerFix Rules
------------------------------

- AutoHotkey v2 scripts must be run with `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`.
- Use `/ErrorStdOut /Validate` before starting or testing background AHK scripts.
- For helper-mode tests, use `/ErrorStdOut` so syntax and runtime failures appear in the terminal instead of GUI popups.
- Do not use compact comma assignments before by-ref calls like `WinGetPos`; initialize each variable on its own line.
- Avoid writing AHK backtick escape strings such as ``"`n"`` through PowerShell double-quoted content. Prefer AHK `Chr(10)` and `Chr(13)` where practical.
- If an AHK script uses a Local AppData runtime/helper copy, refresh and validate that copy after source edits.
- When stopping ExplorerFix, kill only AutoHotkey processes whose command line contains `ExplorerFix.ahk` or `ExplorerFixSnapshotRuntime.ahk`.
- Never use `taskkill /t` when restarting Explorer; it can kill Explorer child processes such as `NEMESIS.exe`.
- Background hotkey scripts that defend against Explorer hangs must not call `Shell.Application.Windows` in the resident hotkey path; use a short-lived helper process with a timeout.


SWF / Flash UI
--------------

- JPEXS Flash Decompiler lives at `C:\Google Drive\Apps\JPEXS Flash Decompiler\ffdec.exe`.
- Use JPEXS Flash Decompiler to inspect, decompile, export, import, or modify SWF files when working on Flash UI assets.
- Prefer `C:\Google Drive\Apps\JPEXS Flash Decompiler\ffdec-cli.exe` for terminal inspection. `ffdec.exe` is the GUI launcher and may not print useful CLI help.
- Useful read-only inspection commands:
  - `ffdec-cli.exe -help`
  - `ffdec-cli.exe -header <swf>`
  - `ffdec-cli.exe -dumpSWF <swf>`
  - `ffdec-cli.exe -onerror ignore -export script,text,symbolClass <outdir> <swf>`
  - `ffdec-cli.exe -onerror ignore -swf2xml <swf> <outfile.xml>`
  - `ffdec-cli.exe -selectid <id> -format shape:svg -export shape <outdir> <swf>`
- Keep JPEXS exports under `.codex-temp` unless the user explicitly asks to preserve them.
- For SWF comparisons, start with header/hash/size checks, then compare exported symbol maps, text files, script hashes, tag counts, and targeted XML or SVG for changed character IDs.
- Full-frame exports can look nearly blank for transparent/menu-component SWFs. If that happens, export the changed shape or sprite by ID instead of relying on the whole-frame PNG.
- Treat FFDec XML as an inspection format, not a stable source format, unless the task is explicitly to round-trip XML with the same FFDec version.
- External SWFs may be opened or used as read-only references. Modify only repo-local SWFs unless the user explicitly asks for an external write and the external-path rules in this file allow it.
- When editing SWFs, prefer working on a repo-local copy or temporary staging copy, then copy only the intended finished SWF into `mod\interface` or `assets\interface`.

xEdit / ESP Inspection
----------------------

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


Papyrus
-------

- Iron Soul Papyrus source lives in `mod/source/scripts`.
- Compiled scripts output to `mod/scripts`.
- Core source scripts include `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, `IronSoulNative.psc`, `IronSoulOnDying.psc`, `IronSoulPlayerAlias.psc`, and `_DS_DN_Draugnarok.psc`.
- Additional Draugnarok quest/location source scripts also live in `mod/source/scripts`.
- SKSE sources must appear before stock sources in the import list.
- PapyrusUtil sources are required for helpers such as `StorageUtil` and `JsonUtil`.
- Controller-owned quest components must use a local `HasCoreRuntime()` helper for required wiring checks. `IronSoulController.LoadConfig()` remains the user-facing wiring gate; feature availability helpers such as Respawn runtime availability must call `HasCoreRuntime()` but stay semantically separate. When adding new controller-owned dependency dereferences, update the local runtime guard and compile the changed script.
- Follow `docs/style-guide.md` for Papyrus verb-prefix, predicate, logging-wrapper, persistence-key, runtime-field, and CK-facing naming conventions. Do not mass-rename legacy symbols just to satisfy the guide.
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


Papyrus Compile Automation
--------------------------

```powershell
tools\compile-papyrus.ps1 IronSoulController.psc
tools\compile-papyrus.ps1 IronSoulController.psc IronSoulConsoleCommands.psc -RefreshRepoPex
```


SKSE Plugin Build Automation
----------------------------

- Codex may run `tools/build-skse-plugin.ps1` when the user explicitly requests SKSE plugin build verification or DLL refresh, or when Codex has changed `dev/projects/ironsoul/src` source and needs final build verification/output sync.
- Iron Soul SKSE plugin source lives in `dev/projects/ironsoul/src`.
- The script builds the repo-local project in `dev/projects/ironsoul` with `dev/tools/xmake/xmake.exe` and uses local xmake state under `dev/.xmake`.
- Run `tools/build-skse-plugin.ps1` with escalated permissions by default so xmake uses the normal Windows user context for the local `dev/.xmake` repository cache. This avoids Git `dubious ownership` or `safe.directory` failures caused by sandbox/user-context ownership mismatches.
- If xmake still fails with a Git `dubious ownership` or `safe.directory` check inside `dev/.xmake`, report the failure. Do not change global Git `safe.directory` settings or delete the xmake cache unless the user explicitly asks.
- For completed SKSE plugin source changes, run `tools/build-skse-plugin.ps1 -RefreshRepoDll` by default after a successful build so `mod/SKSE/plugins/ironsoul.dll` matches the source change. Use verify-only only for WIP checks or when the user explicitly asks not to refresh the repo DLL.
- Verify-only builds must not update `mod/SKSE/plugins/ironsoul.dll`.
- Refresh builds increment the SKSE plugin version in `dev/projects/ironsoul/xmake.lua` and the matching runtime log version in `dev/projects/ironsoul/src/plugin.h` before compiling. Stage those version bumps with the refreshed DLL.
- DLL refresh must copy only the successful release output from `dev/projects/ironsoul/build/windows/x64/release/IronSoul.dll` to `mod/SKSE/plugins/ironsoul.dll`.
- Do not copy debug DLLs or any build output other than the release DLL.
- Do not stage or commit the DLL from inside the script. When `dev/projects/ironsoul/src` source changed, stage `mod/SKSE/plugins/ironsoul.dll` with the same source commit that produced it. Use a standalone `build(native): update SKSE plugin binary` commit only for an explicitly requested DLL-only refresh or generated-output repair.


MO2 Overwrite INI Refresh
-------------------------

- Codex may run `tools/refresh-overwrite-ini.ps1` when `mod/SKSE/plugins/ironsoul.ini` changes or when the user explicitly asks to refresh the LoreRim+ Overwrite INI.
- The script overwrites `G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini` from the repo INI, then forces these testing/debug settings:

```ini
Anticheat = 0
EnableDebug = 1
EnableLogging = 1
EnableLogNotifications = 1
LogLevel = 3
```

- Do not manually edit the LoreRim+ Overwrite INI. Update the repo INI, then run the refresh tool.
- If the refresh tool fails, leave the external overwrite INI untouched except for any partial write the tool already performed, and report the error.


INI Configuration
-----------------

- When adding, removing, or renaming public INI keys, update `mod/SKSE/plugins/ironsoul.ini`.
- Also update the native allowlist in `dev/projects/ironsoul/src/config.cpp`.
- Also update the public `gini` listing in `mod/source/scripts/IronSoulConsoleCommands.psc`.
- After changing `mod/SKSE/plugins/ironsoul.ini`, run `tools/refresh-overwrite-ini.ps1` to refresh the LoreRim+ Overwrite INI with debug logging enabled.
- When adding, removing, or renaming any optional INI key that may be omitted from the shipped INI, update the centralized hidden optional INI settings list in `mod/source/scripts/IronSoulConfig.psc`; do not create partial hidden optional INI lists in owner components.
- Individual sound-effect toggles such as `HeartstoneAbsorbSFX` are hidden optional INI settings and must not be added to the shipped `mod/SKSE/plugins/ironsoul.ini`. The shipped `[Sound]` section should contain only `MusicVolumeOverride` and the global `SFX` toggle unless the user explicitly asks to expose another public sound key.


Keyword Commands
----------------

Codex chat messages may trigger repo-specific keyword commands.

- A keyword command triggers only when the entire user message, after trimming whitespace, is exactly one command word, except for the parameterized commands listed below.
- Parameterized keyword commands are `ROADMAP: <instruction>`, `TODO: <instruction>`, and `XEDIT: <question>`, which may include free-form text after the colon.
- `help` is the only lowercase command. All other commands are uppercase.
- If an unknown uppercase single-word command is received, reply with `Unknown command. Type help.`
- Commands must still follow all safety, staging, compile, build, xEdit, and external-path rules in this file.
- Commands that modify external paths, refresh compiled artifacts, launch GUI tools, or create commits must explain the intended action and wait for explicit confirmation when the command definition says confirmation is required.

`help` prints this command list quickly, alphabetically, with one short line per command:

```text
AUDIT   Audit the last few substantial chat changes end to end without editing.
BACKUP  Copy the full repo contents to a numbered backup folder.
COMMIT   Execute the latest DIFF commit proposal.
COMPILE  Compile all Papyrus source scripts and refresh only changed repo .pex files.
DIFF     Show changed files and propose intelligent commit splits.
DLL      Build and refresh mod/SKSE/plugins/ironsoul.dll.
IMPLEMENT Execute the latest SUGGEST implementation proposal.
LOG      Build logs\ironsoul.0.log, summarize it, then open it in VS Code.
MSG      Generate a commit message for the currently staged files.
OINI     Open the repo INI in VS Code.
OINI2    Open the LoreRim+ Overwrite INI in VS Code for inspection.
README  Open README.md and suggest focused README updates.
RINI2    Refresh the LoreRim+ Overwrite INI from the repo INI.
ROADMAP  Update README Roadmap, or apply a ROADMAP: instruction.
STATUS   Assess project direction and repo health, then recommend next work.
SUGGEST  Suggest the smartest minimal implementation course without editing, or advocate a larger rework if it makes more sense.
TODO     Update README Current TODO, or apply a TODO: instruction.
XEDIT    Summarize the main plugin, or answer an XEDIT: question from a fresh ESP dump.
```

Command behavior:

- `AUDIT`: Run a read-only audit of the last few substantial changes made in the current chat. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. Use the available chat context to identify the change set, then inspect relevant git status, diffs, and affected files to verify the work end to end against the user's requests. Check for behavioral regressions, missed call sites, stale docs/config, missing generated artifacts, unsafe file operations, and verification gaps. Report findings first in severity order with file/line references where possible; if no issues are found, say that clearly and list any residual risk or checks not run.
- `BACKUP`: Treat the `BACKUP` command itself as the explicit user request to run `tools/backup-repo.ps1`; do not ask for another chat confirmation. The script copies the full contents of `C:\Repositories\Iron Soul`, including hidden files and folders such as `.git`, to a new numbered backup folder under `Z:\Backup\LoreRim\Iron Soul`. It creates `Z:\Backup\LoreRim\Iron Soul` if it is missing, finds existing backup folders matching `Iron Soul Backup N - M-D-YYYY`, uses the global highest existing `N` plus one, defaults to `1` when none exist, and formats the command execution date as `M-D-YYYY` with no zero padding, for example `5-5-2026`. It creates `Iron Soul Backup <index> - <date>`, incrementing the index again if that exact folder already exists, then copies every root item from the repo with hidden items included. Report the created backup path, or report any failure and leave any partial backup folder untouched.
- `COMMIT`: Treat the `COMMIT` command as confirmation to execute the latest commit proposal produced by `DIFF`. Before staging, verify the worktree still matches that proposal. If no current `DIFF` proposal exists, or if the worktree changed since the proposal, run the `DIFF` behavior and stop instead of committing. When executing, stage only the proposed files for each commit, run `git diff --cached --check` before each commit, use the proposed messages, and finish with commit hashes and final status.
- `COMPILE`: Enumerate every `.psc` file under `mod/source/scripts`, then compile all of them with `tools/compile-papyrus.ps1` to `.codex-temp\PapyrusCompile` first. Do not use `-RefreshRepoPex` for this command because that switch copies every successful target. If compilation succeeds, compare each generated `.pex` against `mod/scripts\<ScriptName>.pex` with SHA-256 hashes, then copy only missing or different repo `.pex` files. Leave existing repo `.pex` files untouched for failed scripts and report copied, unchanged, and failed scripts.
- `DIFF`: Report current git status, diff stats, and important changed files without modifying the worktree. Then propose an intelligent commit plan with commit groups, file lists, and commit messages that follow `docs/commit-style.md`. Use multiple commits when changes are independently revertible. Write detailed bullet-list commit bodies for complex, cross-system, risky, or hard-to-infer changes, especially scripts, native source, public config, persistence, generated outputs, and user-facing text. Use discretion for simple commits: when the subject fully explains a narrow docs, asset, formatting, or housekeeping change, propose a subject-only message with no body. If the user has asked to ignore specific files for the current plan, leave those files out of the proposed commits and list them separately as intentionally unplanned. Group `mod/SKSE/plugins/ironsoul.dll` with the matching `dev/projects/ironsoul/src` source commit when native source changes exist; propose a standalone `build(native)` commit only for an explicit DLL-only refresh. State that `COMMIT` will execute this proposal if the worktree is unchanged.
- `DLL`: Treat the `DLL` command itself as the explicit user request to refresh the repo DLL. State that `mod/SKSE/plugins/ironsoul.dll` will be refreshed on success, then run `tools/build-skse-plugin.ps1 -RefreshRepoDll` without asking for another chat confirmation.
- `IMPLEMENT`: Treat the `IMPLEMENT` command as confirmation to execute the latest `SUGGEST` proposal or the latest explicit implementation plan proposed in chat. Before editing, verify the current request, repo context, and worktree still match that proposal; if no current proposal exists, or if the context has changed enough that the proposal may be stale, run `SUGGEST` behavior and stop instead of editing. When executing, make the narrow proposed code/file changes, run the relevant verification, refresh generated artifacts when project rules require it, and report changed files and checks. Do not stage or commit unless the user separately asks.
- `LOG`: Run `tools/build-ironsoul-log.bat`, then summarize `logs\ironsoul.0.log`. Open the generated log in VS Code with `code --reuse-window "C:\Repositories\Iron Soul\logs\ironsoul.0.log"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "C:\Repositories\Iron Soul\logs\ironsoul.0.log"`.
- `MSG`: Read only the currently staged files and staged diff needed to understand them, then generate a commit message in chat that follows `docs/commit-style.md`. Do not edit files, stage, commit, inspect unstaged changes, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. If no files are staged, say so and stop.
- `OINI`: Open `C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini` in VS Code. Use `code --reuse-window "C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "C:\Repositories\Iron Soul\mod\SKSE\plugins\ironsoul.ini"`.
- `OINI2`: Open `G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini` in VS Code for inspection only. Use `code --reuse-window "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "G:\Modding\LoreRim\Mod Organizer\mods\[NoDelete] LoreRim+ Overwrite\SKSE\Plugins\ironsoul.ini"`. Do not manually edit the overwrite INI.
- `README`: Open `C:\Repositories\Iron Soul\README.md` in VS Code with `code --reuse-window "C:\Repositories\Iron Soul\README.md"`. If `code` is unavailable, use `& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --reuse-window "C:\Repositories\Iron Soul\README.md"`. Then quickly read `README.md` and, if useful, run a narrow `git -C "C:\Repositories\Iron Soul" status --short` check. Use recent chat history and obvious repo status to suggest concise README changes in chat. Do not edit files, stage, commit, inspect broad diffs, refresh generated artifacts, build, or compile.
- `RINI2`: Run `tools/refresh-overwrite-ini.ps1` to refresh the LoreRim+ Overwrite INI with debug logging enabled. Report any failure.
- `ROADMAP`: Treat `ROADMAP` as `ROADMAP: update`. Update the `README.md` Roadmap section from the recent current-chat project history. Keep the edit narrow: read `README.md`, use available chat context, avoid unrelated repo inspection, and edit only the Roadmap section unless the user's ROADMAP instruction clearly names another README section. Preserve still-relevant long-term direction, remove or revise stale items, add concise bullets for important newly discovered future work, and keep the section strategic rather than an implementation checklist. Do not stage, commit, compile, build, refresh generated artifacts, or launch external editors. Report the changed roadmap bullets.
- `ROADMAP: <instruction>`: Treat the text after the colon as a brief instruction for updating the `README.md` Roadmap section. `ROADMAP: update` follows the same behavior as `ROADMAP`. `ROADMAP: add <idea>` adds a concise bullet to the Roadmap section unless the instruction names another section. Other instructions such as remove, revise, prioritize, move, or split should make the narrow corresponding edit. Do not use this command for code changes.
- `STATUS`: Run a read-only project direction and health check. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files. Read `README.md` first; its Current TODO and ROADMAP sections are the primary direction source. Also read any separate `ROADMAP*` or `TODO*` files if they exist, plus meaningful repo TODO/FIXME markers. Check expected repo structure, key automation scripts, and required external tools/paths from this file for missing or broken pieces. Treat git as background context only: mention uncommitted changes, unpushed commits, or recent commits only when they affect project health, block likely next work, or explain current direction. Report project direction, health issues, risks, and the most likely next work in priority order.
- `SUGGEST`: Run a read-only assessment of the current request or active problem and recommend the smartest minimal implementation course. Do not edit files, stage, commit, refresh generated artifacts, build, compile, launch GUI tools, or open files in external editors. Inspect only the repo context needed to avoid guessing. Recommend the best next action, likely files or systems involved, the smallest safe implementation shape, key risks, and the verification that should be run before committing.
- `TODO`: Treat `TODO` as `TODO: update`. Update the `README.md` Current TODO section from the recent current-chat project history. Keep the edit narrow: read `README.md`, use available chat context, avoid unrelated repo inspection, and edit only the Current TODO section unless the user's TODO instruction clearly names another README todo/roadmap section. Preserve still-relevant work, remove or revise stale items, add concise bullets for important newly discovered work, and keep the section practical rather than exhaustive. Do not stage, commit, compile, build, refresh generated artifacts, or launch external editors. Report the changed TODO bullets.
- `TODO: <instruction>`: Treat the text after the colon as a brief instruction for updating `README.md` todos. `TODO: update` follows the same behavior as `TODO`. `TODO: add <idea>` adds a concise bullet to the Current TODO section unless the instruction names another section. Other instructions such as remove, revise, prioritize, or split should make the narrow corresponding edit. Do not use this command for code changes.
- `XEDIT`: Run `tools/dump-esp-records.ps1 "Iron Soul - Dead God's Dream.esp" -StageInStockData`, summarize the plugin's major records and wiring from the dump, then suggest likely next changes. Do not edit or save plugin files.
- `XEDIT: <question>`: Treat the text after the colon as the inspection question. Dump `Iron Soul - Dead God's Dream.esp` with `-StageInStockData` by default, or dump another repo `.esp`, `.esm`, or `.esl` only if the question clearly names it. Search the dump for relevant terms, answer with record signature, FormID, EditorID, and important field paths/values where possible, and say when SSEEdit64 GUI inspection is needed for confidence. Do not edit or save plugin files.


Verification
------------

- Run the smallest relevant check for the files changed.
- Mention any compile, build, or test step that could not be run.
