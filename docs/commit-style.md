--- Iron Soul Commit Style ---
==============================

This guide documents the commit-message style already used in Iron Soul. It is Conventional Commit-inspired, but tuned for this repo's history and workflow.


--- Subject Format ---
----------------------

Use one of these subject shapes:

```text
type(scope): summary
type: summary
type(scope)!: summary
type!: summary
```

- `type` names the kind of change.
- `scope` is optional, but preferred when the touched area is clear.
- `!` marks a breaking change or a migration that meaningfully changes persisted behavior, public configuration, or runtime expectations.
- `summary` should be a concise present-tense phrase with no trailing period.


--- Commit Bodies ---
---------------------

Use the shortest commit message that fully explains the change. A subject-only commit is correct when the subject says enough; a body is expected when the change is substantial, cross-system, risky, or hard to infer from the subject.

Commits often need a body when they touch:

- Core Papyrus scripts such as `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, `IronSoulNative.psc`, `IronSoulOnDying.psc`, `IronSoulPlayerAlias.psc`, or `_DS_DN_Draugnarok.psc`.
- SKSE plugin source under `dev/projects/ironsoul/src`.
- Persistence, INI keys, Papyrus/native contracts, death flow, tier progression, journal/data storage, or generated runtime outputs.

Subject-only commits are fine for simple Papyrus or plugin fixes where the subject says enough. They are also fine for straightforward docs, asset moves, UI/audio refreshes, and narrow housekeeping. Compiled output needs source context and should not be committed by itself unless the user explicitly requests a generated-output-only repair.

When a body is useful, prefer this shape:

- Put one blank line between the subject and body.
- Use bullets, usually 3-8.
- Use more bullets only when the change genuinely justifies it.
- Start each bullet with a verb and explain behavior, contracts, migration risk, or verification-relevant output.


--- Core Script Grouping ---
----------------------------

Default to one commit per core Papyrus source file. Do not bundle `IronSoulController.psc`, `IronSoulConsoleCommands.psc`, or `IronSoulNative.psc` together just because they are all Papyrus.

Group a core script with another file only when the companion is part of the same change:

- `IronSoulConsoleCommands.psc` may travel with `mod/SKSE/customconsole/IronSoulConsoleCommands.yaml`.
- `IronSoulNative.psc` may travel with matching SKSE plugin native bindings.
- A new imported subsystem, such as Draugnarok, may group its related scripts together.

Keep matching compiled `.pex` outputs with the `.psc` source commit that required the compile. Do not make standalone Papyrus compiled-output commits when no Papyrus source changed.


--- Native Output Grouping ---
------------------------------

Keep `mod/SKSE/plugins/ironsoul.dll` with the `dev/projects/ironsoul/src` source commit that required the rebuild. Native output should normally travel with the source change that produced it, not as a separate build-only commit.

Use a standalone `build(native): update SKSE plugin binary` commit only when the user explicitly asks for a DLL-only refresh or generated-output-only repair. If a commit only normalizes DLL path casing, use `chore(native)` and include the rebuilt DLL bytes in that same casing commit.


--- Types ---
-------------

Use the type that best describes the main reason for the commit.

| Type | Use For |
|---|---|
| `feat` | New behavior, gameplay capability, UI surface, asset set, or public-facing option. |
| `fix` | Bug fixes, corrections, and small behavior repairs. |
| `refactor` | Internal restructuring without intended user-facing behavior changes. |
| `docs` | README, Nexus copy, contributor notes, or repo documentation. |
| `style` | Formatting-only changes that do not alter behavior. |
| `chore` | Repository maintenance, sync commits, cleanup, ignores, placeholders, and non-feature asset upkeep. |
| `build` | Build outputs, compiled artifacts, or build-system related refreshes that are intentionally committed. |


--- Scopes ---
--------------

Scopes name the subsystem or asset area touched by the commit. Keep scopes lowercase and reuse existing names when they fit.

Common scopes from recent history:

```text
controller
config
console
scripts
papyrus
plugin
skse
skse-plugin
native
ui
interface
assets
audio
esp
nexus
tools
dsr
journal
```

Leave the scope off when the change is naturally repo-wide or too small to name cleanly, such as `feat: add initial README.md`.


--- Practical Guidance ---
--------------------------

- Use lowercase `type` and `scope`.
- Keep summaries concise, present-tense, and without a trailing period.
- Prefer a scope when the touched area is clear.
- Split unrelated changes into separate commits.
- Bundle committed Papyrus `.pex` refreshes with the `.psc` source changes that produced them.
- Avoid `build(papyrus)` for standalone compiled-script refreshes unless the user explicitly requests an exceptional generated-output-only repair.
- Bundle committed native DLL refreshes with the `dev/projects/ironsoul/src` source changes that produced them.
- Avoid standalone `build(native)` commits unless the user explicitly requests a DLL-only refresh or generated-output-only repair.
- Use `chore(plugin)` when syncing a plugin file with existing changes.
- Use `feat(esp)` when ESP record changes add or expose new behavior.
- Use `docs(nexus)` for Nexus listing or permission copy, and `docs` without a scope for repo-facing documentation.


--- Examples ---
----------------

Good examples from this repository:

```text
fix(interface): correct gold dragon soul revive limit
feat(controller)!: migrate controller to SKSE plugin datastore; overhaul Character Journal; modernize persistence and runtime
docs(nexus): update description and add Draugnarok permission
chore(plugin): sync Iron Soul ESP with latest changes
style(scripts): normalize Papyrus event script formatting
```

A substantial controller commit can use a body like this because the change touches many systems:

```text
feat(controller): overhaul soul tier progression

- Implement preset locking and positive INI feature toggles in the controller
- Remap canonical soul tiers to Defiant, Iron, Silver, Gold, Ebon, Platinum, Devour, and CHIM
- Add Devour tier support across progression, luck caps, menus, SFX, dynamic UI, and true-death handling
- Rework Defiant Soul into a tracked 20-death mode with stored base tier, fatigue stages, reset flow, and terminal handling
- Centralize tier resolution for Soul Feats, resets, true death, load catch-up, and console-driven state changes
- Replace single SoulBonus syncing with separate soul bonus and soul fatigue spell presentation paths
- Add total death tracking, preset state, console-entered tier flags, and current/historical character data cleanup helpers
- Rebaseline dragon soul tracking on load and optionally notify lifetime dragon soul increases
- Update death, respawn, Dragon Soul Revive, load notification, Soul Feat, Defiant reset, and CHIM transition flows
```

A simple change should stay short:

```text
docs: add commit style guide
```
