# Changelog

This project follows Semantic Versioning 2.0.0.

## [0.13.2] - 2026-09-29

### Fixed

- Extra windows choose the clearer side of their parent or continue below it when there is room, staying full-sized and visible near screen edges.
- Closing the Questboard or another addon window also closes every window opened from it.

### Changed

- The in-game version comes from addon metadata. Release tags are checked against that same version, and GitHub release archives include it in their names.

## [0.13.1] - 2026-09-29

### Fixed

- PvP quests now advance from the actual increase in honorable kills, including delayed or combined counter updates. A PvP event alone cannot grant progress.
- Selling qualifying items to the assigned vendor no longer loses credit when a purchase or repair offsets the money earned, or when buyback evidence arrives shortly after the bag changes.
- Mining work orders can track a matching smelt cast and resulting bar when the client lacks the crafted-result event. Orders stay unavailable if neither smelting signal is supported; crafted-result data with a recipe ID must match the requested smelt.

## [0.13.0] - 2026-09-29

### Added

- NPC role tags now determine which friendly local can offer each objective. Every existing NPC has at least one tag, and Supply still selects a real merchant through the vendor tag.
- Eight Mining work orders across Elwynn Forest, Dun Morogh, Westfall, and Darkshore. These track ore mined, bars smelted, and, where a blacksmith merchant is available, bars sold to that assigned NPC. Amounts come from each objective's own range.
- An optional fourth PvP notice appears to the right while the player is PvP flagged. It asks for 1–5 honorable enemy-player kills and uses the normal active, ready, and turn-in flow. The board returns to its usual width when the flag ends.
- The compact in-game changelog now scrolls through every release in player-friendly language.

### Changed

- Removed the separate vendor flag/list in favor of reusable NPC tags and objective-required tag combinations. Existing saved database edits using old giver fields migrate on load.

## [0.12.0] - 2026-09-29

### Added

- Darkshore as a registered zone with 20 Kill, 11 Supply, 7 Hunt, and 12 profession-gated Gather objectives (50 total), plus Auberdine quest givers, friendly merchant vendors, and original local flavour text.

### Changed

- Broadened narrowly defined Elwynn Forest and Dun Morogh player eligibility bands so ordinary objectives remain available for several nearby levels. Creature levels, amounts, targets, and the two-level-early Hunt unlocks stay the same.

## [0.11.3] - 2026-09-29

### Fixed

- Secondary windows remain at a readable size and slide fully on screen when there is not enough space beside or below the Questboard.

## [0.11.2] - 2026-09-28

### Added

- A Changelog button in Help opens a toggleable window with the three newest updates in plain language. Closing Help also closes its changelog window.

## [0.11.1] - 2026-09-28

### Changed

- Renamed the installation folder, TOC manifest, and visible addon branding from Classic Questbook to Classic Questboard, including the Questboard windows, options, keybinding label, chat messages, tooltip text, and current documentation.
- Kept the existing SavedVariables and keybinding identifiers so quest progress and assigned keys remain compatible. Updated the saved-file migration instructions for the new folder name.

## [0.11.0] - 2026-09-28

### Added

- Westfall as a registered zone with 20 Kill, 11 Supply, 7 Hunt, and 12 Gather objectives (50 total), plus local quest givers, verified friendly vendors, and original Westfall flavour text.
- An independent Quest Browser zone dropdown and preview level. The category tabs show all objective counts for the browser's selected zone.
- A blue thank-you to Spinkler in Help for Alpha and Pre-Alpha testing and help, while retaining the existing Help message.

### Changed

- Renamed Collect & Sell to Supply throughout the current addon, data, statistics, editor, browser, debug controls, and tests. Existing saved quests, statistics, and database overrides migrate to the new identifier while keeping vendor-specific sale tracking.
- Quest Browser preview generation uses its own selected zone and level without changing the main board's selected zone or debug generation level.

## [0.10.0] - 2026-09-28

### Added

- A common, documented database schema with readable zone, objective, quest giver, and flavour files. All 100 objectives, 25 givers, and 28 flavour lines are preserved from 0.9.0.
- An Options → Database Editor window with Zones, Objectives, Quest Givers, Vendors, and Flavour Text tabs; zone/category/profession filters; editable fields; Add, Save, Cancel, and confirmed Delete actions.
- Per-character SavedVariables overrides for edits, custom entries, and disabled built-in entries. Shared validation reports the affected zone, category, ID, and name; invalid saved overrides are backed up before falling back to validated built-in data.
- DATA_FORMAT.md documents the schema, tracking identifiers, examples for every objective type, override format, and a blank zone template.
- Database/editor integration tests and a data-only test zone, alongside the original tracking/UI regression suite and 0.9.0 objective manifest.

### Changed

- Generation, tracking map lookup, zone selection, and the Quest Browser consume registered data. Future zones need a data file and TOC load entry, without zone-specific logic.
- Generated quests retain their objective, tracking, giver/story, and zone snapshots when database entries change or are disabled. Existing saved quests migrate without rerolling or losing progress and statistics.
- Secondary windows continue below the previous window instead of opening to its left across the main Questboard. Nested windows fit the remaining screen space where possible.

## [0.9.0] - 2026-09-28

### Changed

- Collect & Sell quests are now offered only by friendly, verified merchants in the selected zone. The card names the exact merchant and location where the collected items must be sold.
- Sales count only when the merchant window belongs to that quest's assigned NPC. Existing sale evidence checks still apply; selling to another vendor consumes the eligible items without advancing the quest. Previously generated Collect & Sell notices are assigned a real vendor in place, preserving objective, amount, and progress.
- Quest Browser objective rows now show eligible character level ranges. Hovering or clicking reveals the objective's amount range.
- Quest cards no longer show the roleplay prompt. Active quest progress remains visible, with more room for the objective text.

## [0.8.0] - 2026-09-28

### Added

- Elwynn Forest and Dun Morogh each have a verified pool of local Alliance-friendly NPC quest givers, assigned by quest category. Generated notices now show a named giver and their location. See QUEST_GIVERS.md for the roster and sources.
- Each quest category has four original flavour-text alternatives. Gathering has separate alternatives for Herbalism, Mining, Skinning, and Fishing; the bland supply-request line is replaced.
- A Reset Stats button appears on the Statistics page only in Debug Mode. It clears accepted, handed-in, and abandoned totals and each category breakdown.

### Changed

- Giver and flavour text are saved with each offer and accepted quest, so they do not change on reload or UI refresh. Existing notices gain a giver and new story in place, without rerolling their objectives, amounts, or progress.
- Generation requires a friendly NPC for the player's faction in the selected zone. The two current zones have verified Alliance giver pools only; a Horde character is shown an explanatory empty-board message rather than a hostile giver.

## [0.7.1] - 2026-09-28

### Fixed

- Kill and Hunt progress now requires a matching creature observed alive, in combat, with a permitted tap and public threat evidence from the player, a party member, or one of their pets, followed by a confirmed death. Seeing an untapped creature die no longer grants credit merely because its corpse reports tap-not-denied.
- Rejected/secret tap evidence never grants credit, and a living creature that resets loses prior tag evidence. A valid party tap can still count when the death is confirmed without a `PARTY_KILL` event.
- Added regressions for solo/party/pet taps, missing death, untapped and contested kills, NPC/outsider fights, reset, secret tap/threat data, and corpse state.

## [0.7.0] - 2026-09-28

### Added

- Dun Morogh has 49 objectives: 20 Kill, 11 Collect & Sell, 7 Hunt (6 rare targets and Vagash), and 11 Gather (3 Herbalism, 3 Mining, 3 Skinning, 2 Fishing). Targets/resources were checked against Forever data; see ZONE_DATA.md.
- A top-centre zone dropdown switches between Elwynn Forest and Dun Morogh. Each zone keeps its own three offers between switches and sessions. The first visit generates a board; revisiting does not reroll it.
- Quest Browser, all-level browsing, test generation, level override, and forced-category testing use the selected zone. Both curated starting-zone pools cap generation at 12 and retain independent category/profession ceiling fallback.

### Changed

- Tracking and saved-objective resolution use the accepted quest's zone, independent of the board currently being browsed. Classic map IDs and child maps are supported alongside zone-name fallback.
- Existing Elwynn offers, accepted quests, progress, statistics, and settings migrate without rerolling. One active quest remains the global limit; other-zone cards and reroll stay unavailable until it is abandoned or handed in. A notice identifies the active quest's zone.
- Successful turn-in replaces only the completed slot; offers in the other zone remain unchanged.
- Hunt objective descriptions omit the count when only one target is required and no longer describe targets as rare/elite. Multiple-target Hunts still show their count. Subtype data, eligibility, rarity rules, and tracking remain intact; existing Hunt card text is refreshed too.
- Release advances to Alpha 0.7.0, retaining the pre-1.0 version series.

## [0.6.13] - 2026-09-28

### Added

- Accepted, handed-in, and abandoned statistics each have independent plus/minus controls. Category breakdowns expand directly underneath their own header and move subsequent sections down.
- Added persistent accepted/abandoned category counters. Existing totals and completion breakdowns are preserved; earlier events without category records appear under Earlier / unclassified.
- Quest Browser has a Show all levels checkbox for the current Elwynn data pool across every category tab. This is inspection-only; normal generation, test generation, and profession gating remain unchanged.

## [0.6.12] - 2026-09-28

### Added

- Statistics button opens a toggleable, nested Statistics window with quests accepted, handed in, and abandoned.
- A plus/minus expansion beside quests handed in shows successful completions by Kill, Collect & Sell, Hunt, and Gather category, saved per character.
- Per-character counters persist across sessions and update only on successful lifecycle actions. Cancelled confirmations, denied actions, ready-state transitions, and reloads do not add counts.
- Totals begin when this feature is installed, include Debug Mode actions, and are independent of the limited recent-completion history.

## [0.6.11] - 2026-09-28

### Changed

- Hunt objectives unlock two levels below the target's minimum listed level. Mine Spider and Mother Fang now unlock at player level 5; Narg/Morgaine at 8, Hogger at 9, and Fedfennel/Gruff at 10 already followed this rule.
- Existing upper bands, Hunt category weight, rare/elite amounts, and hidden level descriptions are preserved. Reroll to refresh existing offers.

## [0.6.10] - 2026-09-28

### Changed

- Removed target levels from Hunt objective descriptions and the level/skill line on Hunt quest cards, including existing saved offers. Debug browser eligibility details remain available.
- Hunt level data, eligibility filtering, category weights, tracking, and rare/elite amounts are unchanged.

## [0.6.9] - 2026-09-28

### Changed

- Weighted category generation: Kill 40, Collect & Sell 30, Gather 25, Hunt 5. These are percentages when all categories are eligible; otherwise weights are redistributed among eligible categories. Hunt is the rarest category.
- Gather uses a single shared category weight before choosing a learned eligible profession, so additional professions do not increase Gather's overall odds.
- Rerolls and replacements retain eligibility and objective uniqueness. Debug forced categories override the weighted choice for the left card; existing offers are not automatically replaced.

## [0.6.8] - 2026-09-28

### Added

- Debug Mode can edit the active quest's required amount (whole numbers 1–1000) using an amount field and Apply button. Updates objective text and readiness without rerolling, losing progress, or changing quest identity; applies to all tracked types. Raising a ready quest's target can make it Active again. Generated rare hunts still default to one.
- Added a Help window via the question-mark button beside Options, with a quest-themed placeholder joke.

### Changed

- Options, Help, and Quest Browser buttons now toggle their respective windows open and closed. The existing minimap and keybind toggles are preserved.
- Added shared window management with logical nesting, opening beside the previous visible window, left-side placement when the right side is full, screen clamping, and nested frame ordering. The main Questboard remains underneath secondary windows.

## [0.6.7] - 2026-09-28

### Changed

- Debug Mode now uses a magnifying-glass inspection icon to distinguish it from the Options cog. Existing toggle behavior, tooltip, and active glow are preserved.

## [0.6.6] - 2026-09-28

### Changed

- Set the addon-list icon to the same map texture used by the minimap button.

## [0.6.5] - 2026-09-28

### Changed

- Renamed the addon and installation folder to Classic Questbook, with a matching Classic Questbook.toc manifest.
- Updated window, options, keybinding, minimap, chat, and mob-tooltip branding. Slash commands remain /cq and /cqdebug.
- Retained the internal WoWForeverDB and binding identifiers for compatibility. Existing installations must copy their saved-variable files to the new addon filename; see TRACKING.md.

## [0.6.4] - 2026-09-28

### Changed

- Replaced the Debug Mode left-card category cycling button with a standard WoW dropdown. All five choices are directly selectable, the current selection is checked, and existing generation behavior is preserved.
- Debug +1 Progress now supports every tracked quest type, including Hunt, all gathering professions, node objectives, and Collect & Sell. Collection advances before selling; counts stay capped and completion still requires manual turn-in. This test control does not create items or perform real sales.

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
