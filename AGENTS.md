# AGENTS.md

## Project Notes
Iron Soul is a Skyrim SE mod with Papyrus scripts, SKSE plugin source, assets, and user-facing INI configuration.

## Working Rules
- Keep changes narrow and follow the existing style in the files being edited.
- Prefer simple, direct fixes. Do not overengineer or add abstractions unless they are clearly needed.
- Do not revert or overwrite unrelated user changes.
- Do not rebuild `SKSE/Plugins/IronSoul.dll`; the user will handle SKSE plugin builds.

## Papyrus
- Papyrus source lives in `Source/Scripts`.
- Compiled scripts output to `Scripts`.
- When changing `.psc` files, compile the changed script with the Skyrim SE Papyrus compiler when available.

## Verification
- Run the smallest relevant check for the files changed.
- Mention any compile, build, or test step that could not be run.
