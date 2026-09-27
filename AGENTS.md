# WoW Forever Questboard

## Project scope

This repository contains the WoW Forever roleplay questboard addon. Keep the addon compatible with the WoW Classic client targeted by the Interface value in WoWForever.toc. The slash command is /cq.

## Semantic versioning

- Treat the Version field in WoWForever.toc as the authoritative release version and always use Semantic Versioning 2.0.0: MAJOR.MINOR.PATCH.
- The current release is 0.5.2. While the major version is zero, minor releases may introduce incompatible changes; patch releases are for compatible fixes.
- Increase the major version for incompatible public behavior or saved-data changes once the project reaches 1.0.0; increase the minor version for compatible features; increase the patch version for compatible fixes.
- Use SemVer prerelease identifiers such as 0.2.0-alpha.1 when a prerelease version is needed. Do not put labels such as Alpha into the TOC version field.
- Keep user-facing labels, such as the version shown in the questboard window, consistent with the TOC release. A display label may be friendlier (for example, Alpha V0.1) but must not replace the SemVer release value.
- Update the TOC version whenever a change is intended as a new release. Do not increment it for every edit automatically.
- Add a matching release entry to CHANGELOG.md whenever the TOC version changes.

## Change guidance

- Keep quest definitions and questboard behavior in Questboard.lua unless a clear need justifies splitting the addon into more files.
- Preserve character saved data in WoWForeverDB when changing the data format; handle older or malformed saved values safely.
- Keep generated quests grounded in locations, creatures, and items that exist in the targeted game client. Clearly label any objective the addon does not mechanically track.
- Keep addon metadata and the file list in WoWForever.toc in sync with the project.

- Tracking.lua owns gameplay events, saved progress, rest-area checks, and quest lifecycle transitions. Keep generation definitions and UI in Questboard.lua.
