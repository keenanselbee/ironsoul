--- Iron Soul Style Guide ---
=============================

This guide defines the naming and formatting conventions for Iron Soul. Follow the local style of the file you are editing first, then use these rules for new work or unclear cases.

--- Core Style ---
------------------

- Keep changes narrow, direct, and consistent with nearby code or docs.
- Prefer readable names over abbreviations for new systems.
- Use ASCII text unless a file already uses a broader character set or the content needs a specific symbol.
- Keep the repo's ceremonial divider-header identity, adapted to each file type.
- Do not mass-rename legacy files just to match this guide. Treat renames as deliberate migrations.


--- Header Formatting ---
-------------------------

Use divider headers across the repo. Match the header style to the file type and the weight of the section.

Markdown:

- Keep Markdown prose and lists in normal Markdown instead of wrapping divider sections in `text` fences just to preserve their source layout.
- Use one Markdown file header with the `--- Name ---` title line, a hard break, and an escaped visible `=` ruler.
- End the Markdown file-header title line with a backslash hard break so Markdown keeps the escaped `=` ruler on the next rendered line without trailing whitespace.
- Use the `--- Name ---` title line with a `-` Setext underline for every Markdown section after the file header.
- The first Markdown section after opening prose uses one blank line before the header.
- Later Markdown sections use exactly two blank lines before the header.
- Fenced examples and Papyrus/C++/INI comment dividers are exempt from Markdown spacing rules.

Markdown file header:

```md
--- Iron Soul: Dead God's Dream ---
===================================
```

The file-header title line above intentionally ends with Markdown's backslash hard break, and the `=` ruler is escaped so it stays visible.

Markdown section:

```md
--- Current TODO ---
--------------------
```

Use `=` divider comments for major implementation sections outside Markdown.

Adapt the comment prefix to the file type:

Papyrus:

```papyrus
; --- Section Name ---
; ====================
```

C++:

```cpp
// --- Section Name ---
// ====================
```

INI:

```ini
; --- Section Name ---
; ====================
```

Keep short local labels simple when a full divider would add noise:

```papyrus
; Logging
; Runtime / Polling
```


--- Naming By Layer ---
-----------------------

| Area | Convention | Example |
|---|---|---|
| Special root docs | Uppercase conventional names | `README.md`, `AGENTS.md`, `LICENSE`, `CHANGELOG.md` |
| Repo docs | lower-kebab | `docs/style-guide.md`, `docs/heart-shards-roadmap.md` |
| Repo tools | lower-kebab | `tools/compile-papyrus.ps1` |
| Internal repo buckets | Top-level lowercase folders | `docs`, `tools`, `assets`, `reference` |
| Papyrus scripts | PascalCase, no dashes | `IronSoulDraugnarokMain.psc` |
| Quest fragments | `IronSoul_QF_*` | `IronSoul_QF_DraugnarokMain.psc` |
| EditorIDs | `IronSoul_*` | `IronSoul_Draugnarok_MainQuest` |
| INI sections | PascalCase | `[Draugnarok]`, `[HeartShards]` |
| INI keys | PascalCase | `DraugnarokSystem`, `HeartShardSystem` |
| SKSE plugin files | lowercase | `ironsoul.ini`, `ironsoul.dll` |
| Public titles | Title Case | `Iron Soul: Dead God's Dream` |

Use lower-kebab for repo-owned docs, tools, and assets when the file is not consumed directly by Skyrim, Papyrus, SKSE, the CK, xEdit, or another tool with stricter expectations.

Do not use dashes in Papyrus script names, Papyrus identifiers, quest fragment names, EditorIDs, aliases, properties, globals, or CK-facing identifiers.


--- Papyrus ---
---------------

- Use PascalCase for script names, functions, and public-facing helper names.
- Keep script names and file names identical: `Scriptname IronSoulExample` belongs in `IronSoulExample.psc`.
- Use the existing controller section style for major blocks and update the table of contents when adding, removing, or renaming controller functions.
- Keep explanatory comments short and practical. Use bullets for policy blocks, persistence models, and failure-mode notes.
- Preserve existing generated quest-fragment structure unless intentionally migrating it.
- Do not rename fragment functions such as `Fragment_0` unless the owning quest fragment data is regenerated and verified.

Recommended new Draugnarok-style names:

```text
IronSoulDraugnarokMain.psc
IronSoulDraugnarokGlobals.psc
IronSoulDraugnarokKillHandler.psc
IronSoul_QF_DraugnarokMain.psc
IronSoul_QF_DraugnarokCapitalRaidWhiterun.psc
```


--- C++ / SKSE Plugin ---
-------------------------

- Follow the existing C++ style in the touched file.
- Use `IronSoul::` namespaces for plugin code.
- Use `PascalCase` for functions and types when matching the existing plugin style.
- Use `g_` prefixes for file-static global state where the surrounding file already does.
- Use lowercase file names with no dashes for Iron Soul C++ source/header files, e.g. `config.cpp`, `datastore.h`, and `papyrusbindings.cpp`.
- Keep comments concise and behavior-focused.
- Use divider headers for larger C++ sections when the file grows enough to need navigation.

Example:

```cpp
// --- Config Parsing ---
// ======================
```


--- INI Configuration ---
-------------------------

- Use PascalCase for section names and keys.
- Keep comments directly above the setting they explain.
- Describe valid ranges, default behavior, and disabled values where useful.
- Use `0 = Off` and compact enumerations for mode keys.
- When adding, removing, or renaming public INI keys, update the shipped INI, native allowlist, and console `gini` listing together.

Example:

```ini
[Draugnarok]

; Enable the Draugnarok system.
DraugnarokSystem = 1
```


--- README And Documentation ---
--------------------------------

- Keep the README's ceremonial banner and Markdown file-header style.
- Use Markdown section dividers from this guide in Markdown docs.
- Use concise prose first, then short one-level bullet lists.
- Keep roadmap names in Title Case: `Heart Shards`, `Return of the Dead God`, `War of the Barrows`.
- Prefer public-facing clarity over implementation detail in README prose.
- Use lower-kebab filenames for additional docs under `docs`.
- Avoid nested bullets unless the extra hierarchy prevents confusion.
- Keep commit-message and commit-grouping policy in `docs/commit-style.md`.
