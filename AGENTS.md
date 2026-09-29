# Classic Questboard

## Project scope

This repository contains the Classic Questboard roleplay questboard addon. Keep the addon compatible with the WoW Classic client targeted by the Interface value in Classic Questboard.toc. The slash command is /cq.

## Semantic versioning

- Treat the Version field in Classic Questboard.toc as the single authoritative release version. Use Semantic Versioning 2.0.0 with an alpha suffix during Alpha, for example `0.13.2-alpha`; derive the current version from the TOC rather than recording it again here.
- Keep the first component at 0 throughout Alpha; use 1.0.0 for the full release, or another first-component change only when the user explicitly requests it.
- Increase the second component for major feature updates such as a new zone. Increase the third component for bug fixes and minor updates. The user may explicitly specify a different version.
- Use SemVer prerelease identifiers such as `0.13.2-alpha` in the TOC; do not include the word `Alpha` outside the prerelease suffix in that metadata field.
- The Questboard reads the TOC version at runtime and presents an alpha release as `Alpha v0.13.2`. Never hardcode a second version in Lua.
- Version each completed change set, including documentation-only changes. Increment only once per completed change set, not for individual file edits or intermediate fixes. The user's versioning convention above takes precedence over generic feature/patch rules for this project.
- Add a matching release entry to CHANGELOG.md whenever the TOC version changes.
- Update the TOC version and matching changelog/history entries for each release. Run `python scripts/check_release.py`; it checks these records and, when given `--tag`, the annotated release tag against the TOC.
- Publish alpha releases using annotated tags named `v<TOC version>`, such as `v0.13.2-alpha`. The GitHub release workflow packages them as `ClassicQuestboard-v0.13.2-alpha.zip`. CurseForge project 1715617 should be set to **Package tagged commits** so its GitHub webhook builds only those same tagged versions rather than hash-named commit builds.
- Keep the in-game Help → Recent Updates history in Data/UpdateHistory.lua aligned with every CHANGELOG.md release. Write its summaries in plain language and add each new release there.

## Git workflow

- After completing and validating each change set, commit its changes to the local Git repository without waiting for another request. This includes documentation and version updates. An explicit user instruction not to commit overrides this default.
- Review the diff and run checks appropriate to the changes before committing. Stage only files belonging to the completed change set; do not include unrelated user changes.
- Include the release version and a concise description in the commit message. Report the commit hash and validation results to the user. Do not push unless explicitly requested.

## Change guidance

- Keep quest content in Data/Zones, Data/QuestGivers.lua, and Data/FlavourText.lua. Register every zone through Data/Database.lua using the common schema documented in DATA_FORMAT.md. Do not add per-zone generation, tracking, browser, or editor branches.
- Data/Database.lua owns validation and SavedVariables overrides. DatabaseEditor.lua uses that same schema and must never mutate built-in content. Preserve stable IDs and snapshots of previously generated and accepted quests.
- Preserve character saved data in WoWForeverDB when changing the data format; handle older or malformed saved values safely.
- The installation directory and manifest are `Classic Questboard/Classic Questboard.toc`. Keep legacy `WoWForever` frame, binding, and SavedVariables identifiers stable for compatibility; use Classic Questboard for user-facing branding. Preserve earlier addon names only in migration notes and historical changelog entries.
- Keep generated quests grounded in locations, creatures, and items that exist in the targeted game client. Clearly label any objective the addon does not mechanically track.
- Keep addon metadata and the file list in Classic Questboard.toc in sync with the project.

- Tracking.lua owns gameplay events, saved progress, rest-area checks, and quest lifecycle transitions. Questboard.lua owns generation and board/browser UI; Windows.lua owns nesting and placement. Secondary windows may open on either side or below their parent according to available space and overlap.
- Run tests/run.py with Lua 5.1 via lupa, including database_spec.lua and the original content manifest check, when changing the content schema, overrides, generation, editor, or tracking.
