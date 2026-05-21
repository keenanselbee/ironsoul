--- Iron Soul xEdit Workflow ---
================================

This workflow keeps ESP/ESM/ESL inspection useful while keeping binary plugin saves under user control.


--- Read-Only Inspection ---
----------------------------

Use `_tools/dump-esp-records.ps1` for first-pass read-only dumps and text searches:

```powershell
_tools\dump-esp-records.ps1 "Iron Soul - Dead God's Dream.esp"
_tools\dump-esp-records.ps1 "Iron Soul - Dead God's Dream.esp" -StageInStockData
_tools\dump-esp-records.ps1 "Iron Soul - Dead God's Dream.esp" -Filter "IronSoul_Draugnarok"
_tools\dump-esp-records.ps1 "Draugnarok.esp" -Filter "00012345" -StageInStockData
```

The helper writes output under `.codex-temp\xedit` and must not modify plugin files.
Use `-StageInStockData` when SSEDump needs the repo plugin temporarily copied beside the Stock Game Data masters. The helper refuses to overwrite an existing plugin with the same name, runs the dump, then removes only the hash-matching staged copy.

Use `SSEEdit64.exe` for authoritative inspection when dump output is incomplete, hard to search, or master resolution fails. Load only the relevant plugin and required masters, wait for `Background Loader: finished`, and close without saving.


--- Edit Handoff ---
--------------------

Codex should propose simple plugin changes as an exact edit checklist:

```text
Plugin:
Record:
Signature:
FormID:
EditorID:
Field path:
Current value:
Proposed value:
Reason:
Verification:
```

The user performs and saves ESP edits in xEdit. Codex may verify the saved plugin afterward with read-only dump output or guided GUI inspection.


--- Safety Rules ---
--------------------

- Treat ESP/ESM/ESL files as view-only for Codex.
- Do not save, compact, clean, QuickAutoClean, or create plugin backups unless the user explicitly requests that exact operation.
- If xEdit shows a save prompt during inspection, choose not to save.
- Commit ESP changes separately from source/script/build-output changes.
- Use `feat(esp)` for feature-bearing record changes and `fix(esp)` for record corrections.
