# Classic Questbook

## Project scope

This repository contains the Classic Questbook roleplay questboard addon. Keep the addon compatible with the WoW Classic client targeted by the Interface value in Classic Questbook.toc. The slash command is /cq.

## Semantic versioning

- Treat the Version field in Classic Questbook.toc as the authoritative release version and always use Semantic Versioning 2.0.0: MAJOR.MINOR.PATCH.
- The current release is 0.9.0. While the major version is zero, minor releases may introduce incompatible changes; patch releases are for compatible fixes.
- Increase the major version for incompatible public behavior or saved-data changes once the project reaches 1.0.0; increase the minor version for compatible features; increase the patch version for compatible fixes.
- Use SemVer prerelease identifiers such as 0.2.0-alpha.1 when a prerelease version is needed. Do not put labels such as Alpha into the TOC version field.
- Keep user-facing labels, such as the version shown in the questboard window, consistent with the TOC release. A display label may be friendlier (for example, Alpha V0.1) but must not replace the SemVer release value.
- Version each completed change set, including documentation-only changes. Use the PATCH component after MINOR as the iterative version number: for example, 0.6.1 -> 0.6.2 -> 0.6.3. Increment it once per completed change set, not for individual file edits or intermediate fixes. When Semantic Versioning requires a new minor or major release, reset the lower components to zero instead. Follow an explicitly requested version when supplied by the user.
- Add a matching release entry to CHANGELOG.md whenever the TOC version changes.
- Update the TOC version, in-window Alpha label, and current release note in this file together for every versioned change set.

## Git workflow

- After completing and validating each change set, commit its changes to the local Git repository without waiting for another request. This includes documentation and version updates. An explicit user instruction not to commit overrides this default.
- Review the diff and run checks appropriate to the changes before committing. Stage only files belonging to the completed change set; do not include unrelated user changes.
- Include the release version and a concise description in the commit message. Report the commit hash and validation results to the user. Do not push unless explicitly requested.

## Change guidance

- Keep quest definitions and questboard behavior in Questboard.lua unless a clear need justifies splitting the addon into more files.
- Preserve character saved data in WoWForeverDB when changing the data format; handle older or malformed saved values safely.
- The installation directory and manifest are `Classic Questbook/Classic Questbook.toc`. Keep legacy internal frame, binding, and WoWForeverDB identifiers stable for compatibility; use Classic Questbook for user-facing branding.
- Keep generated quests grounded in locations, creatures, and items that exist in the targeted game client. Clearly label any objective the addon does not mechanically track.
- Keep addon metadata and the file list in Classic Questbook.toc in sync with the project.

- Tracking.lua owns gameplay events, saved progress, rest-area checks, and quest lifecycle transitions. Keep generation definitions and UI in Questboard.lua.
