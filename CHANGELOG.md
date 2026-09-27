# Changelog

This project follows Semantic Versioning 2.0.0.

## [0.4.5] - 2026-09-27

### Fixed

- Anchored the minimap icon by its inner corners so it stays centered and contained as the UI scales.
- Moved quest abandonment onto the active quest card; its button now changes from “Accept Quest” to “Abandon Quest.”
- Added a visible gear icon to the Debug Mode toggle.
- Routed offer generation through the active generation level: the debug override when Debug Mode is on, and the capped player level otherwise. Changing the debug level refreshes offers immediately when no quest is active.

## [0.4.4] - 2026-09-27

### Fixed

- Disabled quest rerolls while a quest is active and replaced “Release Objective” with “Abandon Quest,” which clears the active quest and refreshes the offers.
- Moved the Debug Mode toggle into the Questboard header and restored the level selector and Quest Browser button to debug-only visibility.
- Reduced and centered the minimap icon within its circular button.
- Put the Quest Browser on a higher frame strata so it stays fully in front of the main Questboard.
- Made the Quest Browser show the nearest supported objective level band when the selected level has no direct matches, with the effective level in each section heading.

## [0.4.3] - 2026-09-27

### Added

- Added a top-left Debug Mode toggle and moved the shared quest-generation level override onto the main Questboard while Debug Mode is enabled.
- Replaced the in-board debug tree with a separate Quest Browser window featuring icon category tabs, level-filtered objective lists, amount ranges, Hunt subtype sections, and all Gather profession pools.
- Kept test quest generation and objective previews in the Quest Browser; closing it no longer changes Debug Mode.

## [0.4.2] - 2026-09-27

### Fixed

- Reset the previously saved lower-right minimap-button position once so existing characters receive the corrected upper-right default.
- Continue saving later user repositioning separately from that one-time position migration.

## [0.4.1] - 2026-09-27

### Fixed

- Centered the minimap button icon and border on the button frame.
- Moved the default minimap-button position to the upper-right to avoid the built-in tracking control.

## [0.4.0] - 2026-09-27

### Added

- Reorganized the debug browser into a scrollable, collapsible folder tree for generation level, category, gathering profession, objective, hunt subtype, amount range, and quest preview/test generation.
- Added selectable options within each expanded generator folder while preserving debug selections when folders are collapsed and reopened.
- Added a draggable minimap button that opens the Questboard; existing slash commands remain available.

## [0.3.1] - 2026-09-27

### Changed

- Cap normal Elwynn quest generation at the zone maximum level of 12 so overleveled characters continue to receive eligible objectives.
- Add a debug generation-level override and a generated test-quest preview that does not modify the character level, saved offers, or active quest.

## [0.3.0] - 2026-09-27

### Added

- Expanded the Elwynn Forest objective pools across early, mid, and late zone progression for Kill, Collect & Sell, Hunt, and each gathering profession.
- Added per-objective player-level eligibility and level-aware category, branch, and objective selection.
- Added level testing to the debug browser, including the selected test level and each objective's eligible level range.

### Changed

- Kept rare hunts at exactly one target and limited elite targets to one or a small group according to the target.
- Preserved known-profession gating, three distinct quest offers, reroll behavior, and active-quest snapshots while regenerating stale offers for the expanded data.
- Display an unavailable card when no objective is eligible for the current character level.

## [0.2.2] - 2026-09-27

### Changed

- Replaced fixed amount choices with per-objective minimum and maximum values.
- Randomly generate an integer amount inside each objective's inclusive range.
- Updated the debug browser to browse valid amounts in the selected range.
- Kept rare hunt targets fixed at exactly one.

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
