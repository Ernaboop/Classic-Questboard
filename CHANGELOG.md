# Changelog

This project follows Semantic Versioning 2.0.0.

## [0.2.1] - 2026-09-27

### Fixed

- Fixed questboard button callbacks calling Refresh as a missing global by forward-declaring the local function.

## [0.2.0] - 2026-09-27

### Added

- Added Elwynn Forest quest generation through category, objective, and curated amount layers.
- Added Kill, Collect & Sell, Hunt, and profession-aware Gather categories.
- Added separate Gather objectives for Herbalism, Mining, Skinning, and Fishing.
- Added a debug browser to inspect each generator layer and preview a selected objective.
- Added /cq debug and /cqdebug access to the debug browser.

### Changed

- Updated the questboard display version to Alpha V0.2 (0.2.0).
- Kept rare hunt objectives fixed at one rare target; elite hunt counts use small curated amounts.
- Saved accepted generated quests as character-specific snapshots.

### Known limitations

- Quest progress and completion are not mechanically tracked yet.
- Collect & Sell counts vendor-value drops generically; it does not select or monitor exact loot items.
- Profession detection depends on the client reporting the standard profession skill line IDs.
