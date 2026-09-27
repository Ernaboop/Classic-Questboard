# Changelog

This project follows Semantic Versioning 2.0.0.

## [0.6.3] - 2026-09-28

### Added

- Debug Mode has a left-card category selector: Any category, Kill, Collect & Sell, Hunt, or Gather. Click to cycle and use Reroll Quests to apply. The other cards roll normally; level, profession, and duplicate-objective rules remain enforced.
- Left-card turn-in replacements honor the selected category when a unique eligible objective is available. If none exists, a chat message explains the normal replacement. An impossible forced reroll instead keeps all existing offers and explains why.
- Selection is session-only, inactive outside Debug Mode, and never changes accepted quests or existing offers by itself.

## [0.6.2] - 2026-09-27

### Changed

- AGENTS.md now requires an iterative patch-version increment for each completed change set, synchronized release labels, and a local Git commit after appropriate validation.

## [0.6.1] - 2026-09-27

### Fixed

- Category fallback now compares the selected generation level against each category's own ceiling, including debug levels and normal levels at or below Elwynn's level-12 cap. Kill, Collect & Sell, and learned Skinning remain eligible at levels 11 and 12 instead of requiring the actual character to exceed level 12.
- The same filtering applies to manual rerolls and single-slot replacements. Saved offers and active quests are preserved; use Reroll Quests to refresh existing offers.

## [0.6.0] - 2026-09-27

### Added

- Configurable Classic Questboard toggle in WoW Key Bindings, with no default key.
- Options cog beside Close with a persistent, enabled-by-default abandon confirmation setting.
- Abandon confirmation with Cancel and a "Don't show this again" checkbox, saved only after confirmation.
- Debug-only +1 Progress for active Kill quests, using normal Ready to Turn In logic and capped at the required amount.
- Matching mob tooltips show active objective progress and Ready to Turn In state, refreshing while hovered.

### Changed

- Abandoning resets only the accepted quest's progress; all three generated offers stay in place.
- Successful turn-in replaces only the completed slot, preserving the other two offers and excluding duplicate objectives.
- Debug toggles and generation-level changes no longer regenerate offers. Use Reroll Quests to apply the new generation settings to all three cards.

## [0.5.3] - 2026-09-27

### Changed

- Outleveled players now receive objectives from each eligible category's own highest available level band. Kill, Collect & Sell, Hunt, and each learned gathering profession fall back independently instead of requiring objectives at Elwynn's absolute level cap.
- Debug Mode now bypasses rest-area requirements for quest acceptance and manual turn-in while preserving all other quest-state and completion checks.
- Added a restrained blue glow around the Debug Mode icon while the mode is enabled; it disappears immediately when disabled.

## [0.5.2] - 2026-09-27

### Fixed

- Restored Kill/Hunt acceptance and automatic progress using Azeroth Fieldbook's watched-creature evidence approach. The tracker never registers or reads the combat log.
- Require a recent living target/mouseover observation, a readable death signal, and explicit tag eligibility for the same creature GUID. Player-controlled or tap-denied creatures are rejected; secret/unknown evidence waits briefly without guessing.
- Support standalone Forever UNIT_DIED/PARTY_KILL notifications and a 0.2-second watched-unit death poll, including pet kills without PARTY_KILL.
- Preserve saved progress and GUID deduplication. Transient evidence is bounded, expires, and clears on reset, abandonment, and world transitions.
- Expanded regression coverage for early party-kill events, delayed/secret eligibility, expired evidence, pet kills, aliases, corpse-only observations, and reloads. Added Fieldbook's MIT attribution.

## [0.5.1] - 2026-09-27

### Fixed

- Removed unconditional combat-log event registration, which triggers Blizzard's protected-action popup on restricted clients. Forever and Midnight never request that event; legacy clients additionally honor the public restriction predicate.
- Preserved existing Kill/Hunt progress and visibly paused unsupported tracking. New Kill/Hunt acceptance is disabled when the client cannot support it; ready quests can still be handed in.
- Kept collection, sale, gathering, rest-area controls, and saved quest state active. Secret unit names, GUIDs, spell IDs, and loot-chat messages are ignored rather than inspected.
- Extended regression tests to simulate forbidden event registration instead of assuming every event is available.

## [0.5.0] - 2026-09-27

### Added

- Accepted quests persist their progress through Active, Ready to Turn In, and Completed states. Hand-in is manual from the active quest card.
- Accepting and handing in quests requires WoW's rest-area state. Controls and the rest-area explanation update when that state changes.
- Added matching player/pet-assisted kill and Hunt tracking, corpse-loot collection and vendor-sale tracking, and profession-specific gathering for the existing Elwynn objectives.
- Copper Vein Prospecting counts different looted vein sources; other gathering objectives count received item quantities.
- Retained the latest 20 completed quests per character and added a last-completed notice.
- Added Lua 5.1 event and UI regression tests.

### Changed

- Existing accepted quests retain their target and amount during migration; pre-tracking quests begin with zero progress. Unaccepted offers refresh once for the new schema.
- Active cards display progress. Ready cards offer Turn In Quest and an on-card Abandon Quest action.
- Switching Debug Mode preserves active offers and recorded progress. Rest restrictions also apply in Debug Mode.
- Kept the existing Elwynn objective pools and amount ranges; no new zone data or reward systems were introduced.

## [0.4.6] - 2026-09-27

### Fixed

- Rebuilt the minimap button with a restored 20px icon, circular texture mask, and correctly anchored traditional round border.
- Corrected dragging coordinates for minimap UI scale and prevented drag release from opening the Questboard.

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
