# Classic Questboard

## Project scope

This repository contains the Classic Questboard roleplay questboard addon. Keep the addon compatible with the WoW Classic client targeted by the Interface value in Classic Questboard.toc. The slash command is /cq.

## Semantic versioning

- Treat the Version field in Classic Questboard.toc as the authoritative release version and always use Semantic Versioning 2.0.0: MAJOR.MINOR.PATCH.
- The current release is 0.12.0. Keep the first component at 0 throughout Alpha; use 1.0.0 for the full release, or another first-component change only when the user explicitly requests it.
- Increase the second component for major feature updates such as a new zone. Increase the third component for bug fixes and minor updates. The Westfall/Supply update is 0.11.0; follow-up fixes or small changes become 0.11.1, 0.11.2, and so on. The user may explicitly specify a different version.
- Use SemVer prerelease identifiers such as 0.2.0-alpha.1 when a prerelease version is needed. Do not put labels such as Alpha into the TOC version field.
- Keep user-facing labels, such as the version shown in the questboard window, consistent with the TOC release. A display label may be friendlier (for example, Alpha V0.1) but must not replace the SemVer release value.
- Version each completed change set, including documentation-only changes. Increment only once per completed change set, not for individual file edits or intermediate fixes. The user's versioning convention above takes precedence over generic feature/patch rules for this project.
- Add a matching release entry to CHANGELOG.md whenever the TOC version changes.
- Update the TOC version, in-window Alpha label, and current release note in this file together for every versioned change set.
- Keep the in-game Help → Changelog list in Questboard.lua aligned with the newest three CHANGELOG.md releases. Write its summaries in plain language and update it whenever a release entry is added.

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

- Tracking.lua owns gameplay events, saved progress, rest-area checks, and quest lifecycle transitions. Questboard.lua owns generation and board/browser UI; Windows.lua owns nesting and placement. Secondary windows continue downward rather than falling back left over the main board.
- Run tests/run.py with Lua 5.1 via lupa, including database_spec.lua and the original content manifest check, when changing the content schema, overrides, generation, editor, or tracking.
