=============================
--- Iron Soul Style Guide ---
=============================

This guide defines the naming and formatting conventions for Iron Soul. Follow the local style of the file you are editing first, then use these rules for new work or unclear cases.

--- Core Style ---
==================

- Keep changes narrow, direct, and consistent with nearby code or docs.
- Prefer readable names over abbreviations for new systems.
- Use ASCII text unless a file already uses a broader character set or the content needs a specific symbol.
- Keep the repo's ceremonial divider-header identity, adapted to each file type.
- Do not mass-rename legacy files just to match this guide. Treat renames as deliberate migrations.


--- Header Formatting ---
=========================

Use divider headers across the repo. Match the weight of the header to the scope of the section.

Markdown major-section spacing:

- Document title banners stay at the top of the file with no leading blank lines.
- The first major section after opening prose uses one blank line before the header.
- Later major sections use exactly two blank lines before the header.
- This applies only to real Markdown `--- Name ---` plus `====` sections outside fenced code blocks.
- Minor sections with `----` underlines, fenced examples, and Papyrus/C++/INI comment dividers are exempt.

Document title banner:

```md
=============================
--- Iron Soul Style Guide ---
=============================
```

Use this once at the top of major standalone docs, such as `_docs/style-guide.md`. The title line is wrapped above and below with `=` lines.

Major section header:

```md
--- Header Formatting ---
=========================
```

Use this for major document sections and major implementation sections.

Minor section header:

```md
--- Naming By Layer ---
-----------------------
```

Use this for table-of-contents groups, minor doc sections, or second-level sections.

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
=======================

| Area | Convention | Example |
|---|---|---|
| Special root docs | Uppercase conventional names | `README.md`, `AGENTS.md`, `LICENSE`, `CHANGELOG.md` |
| Repo docs | lower-kebab | `_docs/style-guide.md`, `_docs/heart-shards-roadmap.md` |
| Repo tools | lower-kebab | `_tools/compile-papyrus.ps1` |
| Internal repo buckets | Existing underscore folders | `_docs`, `_tools`, `_assets`, `_nexus` |
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
===============

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
=========================

- Follow the existing C++ style in the touched file.
- Use `IronSoul::` namespaces for plugin code.
- Use `PascalCase` for functions and types when matching the existing plugin style.
- Use `g_` prefixes for file-static global state where the surrounding file already does.
- Use lowercase file names with no dashes for Iron Soul C++ source/header files, e.g. `config.cpp`, `datastore.h`, and `papyrusbindings.cpp`.
- External copied API headers may keep upstream casing, e.g. `PrismaUI_API.h`.
- Keep comments concise and behavior-focused.
- Use divider headers for larger C++ sections when the file grows enough to need navigation.

Example:

```cpp
// --- Config Parsing ---
// ======================
```


--- INI Configuration ---
=========================

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
================================

- Keep the README's ceremonial banner and divider-header style.
- Use concise prose first, then short one-level bullet lists.
- Keep roadmap names in Title Case: `Heart Shards`, `Return of the Dead God`, `War of the Barrows`.
- Prefer public-facing clarity over implementation detail in README prose.
- Use lower-kebab filenames for additional docs under `_docs`.
- Avoid nested bullets unless the extra hierarchy prevents confusion.
- Keep commit-message and commit-grouping policy in `_docs/commit-style.md`.
