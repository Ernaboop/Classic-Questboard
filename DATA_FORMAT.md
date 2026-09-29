# Classic Questboard data format

## Files and load order

```text
Classic Questboard/
├─ Data/
│  ├─ Database.lua          # schema, registration, validation, overrides
│  ├─ QuestGivers.lua       # friendly NPCs and verified vendors
│  ├─ FlavourText.lua       # category/profession story alternatives
│  ├─ UpdateHistory.lua     # player-facing summaries of every release
│  └─ Zones/
│     ├─ ElwynnForest.lua
│     ├─ DunMorogh.lua
│     ├─ Westfall.lua
│     └─ Darkshore.lua
├─ DatabaseEditor.lua      # form fields read the shared schema
├─ Questboard.lua          # generation and main/browser UI
├─ Tracking.lua            # gameplay evidence and quest lifecycle
├─ Windows.lua             # nesting, placement, stacking
└─ Classic Questboard.toc   # explicit client file load list
```

WoW loads files listed in the TOC; it cannot discover arbitrary new files on disk.
Add a new zone file after `Data\Database.lua` and before `Tracking.lua` in the TOC.
No edits to generation, tracking, the zone dropdown, browser, or editor are needed.
Reload the client UI after source edits. In-game edits take effect immediately for
new generation; use Reroll to replace existing notices when no quest is active.

## Registration and stable IDs

Every data file starts with `local _, ns = ...` and uses `ns.Database`.
`RegisterZone` accepts metadata plus optional `objectives`, `questGivers`, and
`flavourText` arrays. Nested entries inherit their containing zone ID. Separate
`RegisterObjective`, `RegisterQuestGiver`, and `RegisterFlavour` calls require a
`zone` field, except flavour may omit it to apply to all zones.

IDs are unique across **all** entry types: letters, digits, underscores and hyphens.
Keep existing IDs unchanged (`elwynn`, `dun_morogh`, `kobold_vermin`, etc.). Renaming
a display name is safe; changing an ID creates a different entry. Editor IDs are
locked after the entry is saved.

## Standard schema

The authoritative field definitions are `Database.schema` in `Data/Database.lua`.
Unknown fields and fields on the wrong category are rejected.

| Entry | Required fields | Optional fields |
|---|---|---|
| Zone | `id`, `name`, `minLevel`, `maxLevel`, `mapIDs` | `order`; registration arrays listed above |
| Objective | `id`, `name`, `zone`, `category`, `level`, `minPlayerLevel`, `maxPlayerLevel`, `minAmount`, `maxAmount`, `location`, `requiredNPCTags` | Category-specific fields below |
| NPC | `id`, `name`, `npcID`, `zone`, `location`, `faction`, `tags` | Multiple tags may be combined |
| Flavour text | `id`, `category`, `text` | `zone`, `profession` (Gather only) |

`category` uses `kill`, `supply`, `hunt`, or `gather`. The former `collect_sell`
ID and "Collect & Sell" label in 0.9.0 saves are migrated on load. `profession` uses
`herbalism`, `mining`, `skinning`, or `fishing`. `faction` is `Alliance`, `Horde`,
or `Neutral`; verify the NPC's friendliness in the targeted client before adding it.
`tags` and `requiredNPCTags` are arrays of role tags. Every NPC needs at least one tag; an objective may require several, and its assigned NPC must have all of them. The current tags are `vendor`, `blacksmith`, `innkeeper`, `guard`, `questgiver`, `collector`, `farmer`, `fisherman`, `trainer`, `quartermaster`, `engineer`, `scout`, and `resident`. Add new tags to `Database.npcTags` before using them. Old saved `categories` and `vendor` fields are converted on load. `mapIDs` is an array of zone map IDs;
tracking walks parent maps for interiors and also supports zone-name matching.

`level` is a display string (for example `"5-6"` or `"Mining 1"`). Eligibility uses
the numeric `minPlayerLevel` and `maxPlayerLevel`, inclusively, inside the zone's
range. Hunt's two-level early allowance is already represented in those values;
do not subtract it again. Existing overlevel category fallback is unchanged.
Profession gating checks whether the character knows the profession, as before;
the skill label does not introduce a skill-rank gate by itself. An optional `minProfessionSkill` does gate a Gather objective when the client reports the learned skill.

Amounts are inclusive integer ranges from 1 to 1000, with minimum ≤ maximum.
Rare Hunts must use 1–1. Keep elite counts suitably small.

| Category | Tracking fields |
|---|---|
| Kill | `npcID`, `npcIDs`, or `targets` (exact creature-name array) |
| Hunt | Same targets as Kill, plus `classification = "rare"` or `"elite"` |
| Supply | Creature identifiers above; `lootMode = "item"` with `itemID`, or `"any_vendor_item"`; optional `item` display name and `vendorID` |
| Gather | `profession`, `itemID`, `trackingKind = "gather"`; Mining may use `"nodes"` or `"mining_workorder"`; Skinning may restrict creature identifiers |

`target` is an optional display label, not a tracking identifier. NPC IDs, when
present, take precedence over names. Existing name-based targets are preserved;
no unverified NPC IDs were invented during the refactor. Numeric IDs allow new
content to avoid name/localization ambiguity. The shared `npcID`/`npcIDs` fields
refer to creatures; Gather uses `itemID` plus existing gathering evidence.

Supply objectives require `requiredNPCTags = {"vendor"}` (or a larger set including `vendor`). Generation chooses a matching friendly NPC in the same zone; optional `vendorID` pins one NPC ID. The chosen merchant is saved on the quest, and only sales to that NPC count.

Mining work orders use `trackingKind = "mining_workorder"`, `oreItemID`, `oreName`, `itemID` for the resulting bar, and `smeltSpellID`. Their `minAmount`/`maxAmount` roll the required quantity. The tracker requires ore mined from a matching local node, then bars created by smelting. `handoff = "sale"` adds a final sale to the assigned NPC, so its `requiredNPCTags` must include both `blacksmith` and `vendor`. Non-sale work orders can use another suitable collector. Skill 65 Tin work orders set `minProfessionSkill = 65`.

## Elwynn example: zone and Kill objective

This is an excerpt of the real schema/data; do not register its IDs a second time.

```lua
local _, ns = ...
ns.Database:RegisterZone({
    id = "elwynn", name = "Elwynn Forest",
    minLevel = 1, maxLevel = 12, order = 1,
    mapIDs = {37, 1429},
    objectives = {
        {
            id = "kobold_vermin", name = "Kobold Vermin",
            category = "kill", requiredNPCTags = {"questgiver"}, level = "1-2",
            minPlayerLevel = 1, maxPlayerLevel = 3,
            minAmount = 8, maxAmount = 12,
            location = "Northshire Valley",
            targets = {"Kobold Vermin"},
        },
    },
})
```

## Objective examples

These complete example entries show each type. The `example_` IDs are illustrative
and are not installed content. Check balancing/location data before adding them.
Place entries in a zone's `objectives` array (zone inherited), or pass each to
`RegisterObjective` with `zone = "elwynn"`.

```lua
-- Hunt: target once; elite entries use classification = "elite".
{
    id = "example_narg", name = "Narg the Taskmaster", category = "hunt",
    classification = "rare", requiredNPCTags = {"questgiver"}, level = "10",
    minPlayerLevel = 8, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1,
    location = "Fargodeep Mine", targets = {"Narg the Taskmaster"},
},
-- Collect item from a known creature, then sell to the assigned merchant.
{
    id = "example_boar_meat", name = "Boar Meat Delivery", category = "supply",
    requiredNPCTags = {"vendor"},
    level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7,
    minAmount = 3, maxAmount = 5, location = "Stonefield and Maclure farms",
    targets = {"Stonetusk Boar"}, lootMode = "item",
    itemID = 769, item = "Chunk of Boar Meat", vendorID = 295,
},
-- Herbalism: count verified gathered items.
{
    id = "example_peacebloom", name = "Peacebloom", category = "gather",
    profession = "herbalism", requiredNPCTags = {"collector"}, level = "Herbalism 1",
    minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8,
    location = "throughout Elwynn Forest", itemID = 2447, trackingKind = "gather",
},
-- Mining: count ore; use trackingKind = "nodes" to count distinct looted nodes.
{
    id = "example_copper", name = "Copper Ore", category = "gather",
    profession = "mining", requiredNPCTags = {"collector"}, level = "Mining 1",
    minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9,
    location = "Copper Veins throughout Elwynn Forest", itemID = 2770,
    trackingKind = "gather",
},
-- Mining work order: mine ore, smelt bars, then sell to a blacksmith vendor.
{
    id = "example_copper_bars", name = "Copper Bars for the Forge",
    category = "gather", profession = "mining", requiredNPCTags = {"blacksmith", "vendor"},
    level = "Mining 1", minPlayerLevel = 5, maxPlayerLevel = 12,
    minAmount = 3, maxAmount = 5, location = "Copper Veins throughout Dun Morogh",
    target = "Copper Bar", oreItemID = 2770, oreName = "Copper Ore",
    itemID = 2840, smeltSpellID = 2657,
    trackingKind = "mining_workorder", handoff = "sale",
},
-- Skinning: optionally restrict which beasts supply the leather.
{
    id = "example_leather", name = "Light Leather from Boars", category = "gather",
    profession = "skinning", requiredNPCTags = {"collector"}, level = "Skinning 1",
    minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 3, maxAmount = 5,
    location = "Stonefield and Maclure farms", targets = {"Stonetusk Boar"},
    itemID = 2318, trackingKind = "gather",
},
-- Fishing: only matching fishing loot counts.
{
    id = "example_smallfish", name = "Raw Brilliant Smallfish", category = "gather",
    profession = "fishing", requiredNPCTags = {"collector"}, level = "Fishing 1",
    minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 5, maxAmount = 9,
    location = "lakes and rivers", itemID = 6291, trackingKind = "gather",
},
```

## Givers, vendors, and flavour

These examples refer to existing NPCs, so edit the existing entries instead of
duplicating them. Friendly vendors are a filtered view of quest givers, not a
second independent table.

```lua
local _, ns = ...
ns.Database:RegisterQuestGiver({
    id = "npc_240", name = "Marshal Dughan", npcID = 240,
    zone = "elwynn", location = "Goldshire", faction = "Alliance",
    tags = {"questgiver", "guard"},
})
ns.Database:RegisterQuestGiver({
    id = "npc_295", name = "Innkeeper Farley", npcID = 295,
    zone = "elwynn", location = "Lion's Pride Inn", faction = "Alliance",
    tags = {"vendor", "collector", "innkeeper"},
})
ns.Database:RegisterFlavour({
    id = "example_mining_story", category = "gather", profession = "mining",
    zone = "elwynn", -- Omit zone to share this line with every zone.
    text = "The forge has gone quiet, and the smith is blaming everyone but his empty ore bin.",
})
```

## Blank new-zone template

Copy to `Data/Zones/YourZone.lua`. Replace placeholder metadata with verified
client values; the template is deliberately not registered while placeholders
remain. Add at least one objective and a compatible friendly giver before testing
generation. Empty zones are valid but cannot offer quests.

```lua
local _, ns = ...
-- Remove this guard once all placeholder values below are replaced.
if true then return end
ns.Database:RegisterZone({
    id = "your_zone", name = "Your Zone",
    minLevel = 1, maxLevel = 12, order = 3,
    mapIDs = {0}, -- Replace with verified positive zone map ID(s).
    objectives = {
        -- Copy a complete objective example; give it a permanent unique ID.
    },
    questGivers = {
        -- Same giver schema above; omit zone here to inherit this zone's ID.
    },
    flavourText = {
        -- {id = "your_zone_kill_story", category = "kill", text = "..."},
    },
})
```

Steps: fill metadata → add verified objectives/givers → add optional stories →
remove guard → add TOC line → reload → select zone in the dropdown → inspect the
Quest Browser at relevant levels and professions → generate and track a test quest.

## SavedVariables and migration

`WoWForeverDB` remains the per-character saved variable. Overrides have version 1:

```lua
WoWForeverDB.databaseOverrides = {
    version = 1,
    zones = {},
    objectives = {
        kobold_vermin = {disabled = true},
        custom_vermin = {entry = {
            id = "custom_vermin", name = "My Vermin Patrol", zone = "elwynn",
            category = "kill", requiredNPCTags = {"questgiver"}, level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3,
            minAmount = 4, maxAmount = 6, location = "Northshire Valley",
            targets = {"Kobold Vermin"},
        }},
    },
    questGivers = {},
    flavourText = {},
}
```

An `entry` is a **complete replacement record**, not a partial field patch. Using
a built-in ID edits that record; a new unique ID adds a record. `disabled = true`
excludes it. Source tables stay intact. Full replacement makes saved behavior
predictable when built-in defaults change in future releases.

Generated offers and accepted quests are snapshots. Source edits only affect new
rolls. Objective, tracking, zone/map, giver, text, amount, and earned progress stay
stable across reloads. A deleted objective or zone does not strand its accepted
quest. Existing 0.9.0 saves gain snapshot metadata without a forced reroll.

Invalid saved overrides are copied to `WoWForeverDB.databaseOverrideBackup` and
the active layer falls back to validated source content, with diagnostics. Fix
the invalid record before restoring that backup. Invalid source records are
excluded and reported. Deleting a referenced zone or the last required vendor is
rejected; remove/reassign dependent records first. Editor changes persist when WoW
writes SavedVariables on logout or `/reload`, as with other addon settings.

## Database Editor layout

```text
Classic Questboard Options
  [Database Editor]
         ↓
┌ Classic Questboard Database Editor ─────────────────────── × ┐
│ [Zones] [Objectives] [Quest Givers] [Flavour Text]           │
│ [All zones ▼]       [All categories ▼] [All professions ▼] │
│ Entry list ↕        │ Selected entry's schema fields ↕    │
│ Name + stable ID    │ ID, name, zone, category...          │
│ [Disabled] entries  │ Category-specific tracking fields    │
│ [Add] [Save] [Delete] [Cancel]                             │
│ Validation / save status                                 │
└───────────────────────────────────────────────────────────┘
```

Select a row to edit. Add starts a new form. Save validates the entire merged
database before applying anything; Cancel restores the saved entry or discards a
new form. Delete opens a confirmation dialog. Select a disabled built-in record
and Save to restore it. Lists in editor text fields use semicolons; source files
use Lua arrays. Hover the window to read complete validation diagnostics if the
status area is too short. This editor accepts data, never executable Lua text.

The first secondary window can open beside the Questboard. Further windows open
below the previous window, including the editor and deletion confirmation. Frames
stay movable and fit available space where possible; visually check long window
chains at your preferred UI scale in the client.

## Review checks for 0.10.0

Verified on 2026-09-28 using the Lua 5.1 test runtime:

- 3,888 existing tracking and UI assertions passed.
- 183 database, override, editor, and data-only test-zone assertions passed.
- All 100 original objectives matched the saved 0.9.0 content manifest.
- TOC load order, Lua syntax, release labels, and whitespace checks passed.

The new checks cover validation, duplicate IDs, custom entries, source preservation,
reloads, GUI Save/Cancel/Add/Delete, filters, the merged Quest Browser and generator,
NPC-ID kill credit, and finishing an accepted quest after its source zone is disabled.
Existing tests cover party/tag credit, gather evidence, vendor-specific sales,
profession/level filtering, statistics, debug tools, and stable quest cards.

These are automated client simulations, not a live WoW playtest. After `/reload`,
check Options → Database Editor, nested window placement at your UI scale, and
one accept/track/hand-in cycle. The 0.10.0 review was completed before that release.

## Review checks for 0.11.0

The Westfall file registers 50 objectives in the shared schema: 20 Kill, 11 Supply, 7 Hunt, and 12 Gather. The Quest Browser has its own registered-zone dropdown and preview level; its category tabs show all-level counts for that selected zone. The main board's zone and debug generation level remain independent. The old `collect_sell` identifier and `Collect & Sell` label migrate in saved offers, active quests, statistics, and editor overrides before validation. Supply still requires the assigned vendor for a sale.

The complete Lua 5.1 simulation suite passes: 3,888 tracking/UI assertions and 260 database/override/editor/new-zone assertions, plus the 100-objective 0.9.0 content comparison. These checks do not replace a live client pass for window appearance, spawns, gathering, or merchant events. That release was reviewed before the current update.
