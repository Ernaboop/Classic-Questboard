# Dun Morogh data — Alpha 0.7.0

Checked against Wowhead's Forever database on 2026-09-28. NPC names, levels, classifications, and zone membership were read from the public Forever tooltip endpoint (`https://nether.wowhead.com/forever/tooltip/npc/ID`); the linked NPC pages provide locations. Amount ranges and player eligibility bands are our balancing choices.

Dun Morogh contributes **49** objectives versus Elwynn Forest's **51**. The existing category → objective → amount-range structure and relative category weights are unchanged.

| Category | Objectives |
| --- | ---: |
| Kill | 20 |
| Collect & Sell | 11 |
| Hunt | 7 (6 rares, 1 elite) |
| Herbalism | 3 |
| Mining | 3 |
| Skinning | 3 |
| Fishing | 2 |

## Creatures

| Target / Forever source | Creature level | Category | Eligible player levels |
| --- | --- | --- | --- |
| [Ragged Young Wolf](https://www.wowhead.com/forever/npc=705) | 1 | Kill | 1–3 |
| [Rockjaw Trogg](https://www.wowhead.com/forever/npc=707) | 1-2 | Kill | 1–3 |
| [Burly Rockjaw Trogg](https://www.wowhead.com/forever/npc=724) | 2 | Kill | 1–3 |
| [Small Crag Boar](https://www.wowhead.com/forever/npc=708) | 3 | Kill | 2–4 |
| [Frostmane Troll Whelp](https://www.wowhead.com/forever/npc=706) | 3-4 | Kill | 2–4 |
| [Frostmane Novice](https://www.wowhead.com/forever/npc=946) | 3-4 | Kill | 2–4 |
| [Rockjaw Raider](https://www.wowhead.com/forever/npc=1718) | 3-4 | Kill | 2–5 |
| [Crag Boar](https://www.wowhead.com/forever/npc=1125) | 5-6 | Kill | 4–7 |
| [Large Crag Boar](https://www.wowhead.com/forever/npc=1126) | 6-7 | Kill | 5–8 |
| [Young Black Bear](https://www.wowhead.com/forever/npc=1128) | 5-6 | Kill | 4–7 |
| [Young Wendigo](https://www.wowhead.com/forever/npc=1134) | 5-6 | Kill | 4–7 |
| [Wendigo](https://www.wowhead.com/forever/npc=1135) | 6-7 | Kill | 5–8 |
| [Elder Crag Boar](https://www.wowhead.com/forever/npc=1127) | 7-8 | Kill | 6–9 |
| [Ice Claw Bear](https://www.wowhead.com/forever/npc=1196) | 7-8 | Kill | 6–10 |
| [Winter Wolf](https://www.wowhead.com/forever/npc=1131) | 7-8 | Kill | 6–10 |
| [Rockjaw Skullthumper](https://www.wowhead.com/forever/npc=1115) | 8-9 | Kill | 7–10 |
| [Rockjaw Ambusher](https://www.wowhead.com/forever/npc=1116) | 9-10 | Kill | 8–10 |
| [Rockjaw Bonesnapper](https://www.wowhead.com/forever/npc=1117) | 9-10 | Kill | 8–10 |
| [Frostmane Snowstrider](https://www.wowhead.com/forever/npc=1121) | 8-9 | Kill | 7–10 |
| [Leper Gnome](https://www.wowhead.com/forever/npc=1211) | 8-10 | Kill | 7–10 |
| [Edan the Howler](https://www.wowhead.com/forever/npc=1137) | 9 | Hunt — Rare | 7–10 |
| [Timber](https://www.wowhead.com/forever/npc=1132) | 10 | Hunt — Rare | 8–10 |
| [Great Father Arctikus](https://www.wowhead.com/forever/npc=1260) | 11 | Hunt — Rare | 9–12 |
| [Gibblewilt](https://www.wowhead.com/forever/npc=8503) | 11 | Hunt — Rare | 9–12 |
| [Hammerspine](https://www.wowhead.com/forever/npc=1119) | 12 | Hunt — Rare | 10–12 |
| [Bjarn](https://www.wowhead.com/forever/npc=1130) | 12 | Hunt — Rare | 10–12 |
| [Vagash](https://www.wowhead.com/forever/npc=1388) | 11 | Hunt — Elite | 9–12 |

Rare hunts require exactly one kill. Vagash also requires one; no repeat-kill task for a single named elite. Hunt unlocks two levels below target level. Young Wendigo and Wendigo are listed as **Normal** in the checked Forever data, so they are Kill objectives rather than being assumed elite.

Collect & Sell uses eleven source-specific vendor-loot commissions: Coldridge troggs, Troll Whelps, Frostmane Novices, Rockjaw Raiders, Kharanos boars, Young Black Bears, Grizzled Den wendigos, Iceflow wolves, quarry troggs, Frostmane Hold trolls, and surface Leper Gnomes. These use any verified vendor-value drops from the specified creatures, followed by actual sale; no fabricated quest items or assumed guaranteed drops. Additional source creatures checked: [Starving Winter Wolf (1133)](https://www.wowhead.com/forever/npc=1133), [Frostmane Headhunter (1123)](https://www.wowhead.com/forever/npc=1123), and [Frostmane Hideskinner (1122)](https://www.wowhead.com/forever/npc=1122).

## Resources

The following Forever object/item pages include Dun Morogh in their gathering/fishing locations:

- [Peacebloom](https://www.wowhead.com/forever/object=1618/peacebloom), [Silverleaf](https://www.wowhead.com/forever/object=1617/silverleaf), [Earthroot](https://www.wowhead.com/forever/object=1619/earthroot): 4–8, 4–8, and 3–5 respectively.
- [Copper Vein](https://www.wowhead.com/forever/object=1731/copper-vein): Copper Ore (2770), Rough Stone (2835), and a distinct-vein task. Ranges 5–9 ore, 5–9 stone, or 3–5 veins.
- Ruined Leather Scraps (2934): 4–8 from low-level skinnable beasts. Light Leather (2318): 3–5 from Crag/Large/Elder Crag Boars or 3–5 from Winter/Starving Winter Wolves and Ice Claw Bears. Named leather tasks enforce those exact corpse names.
- [Raw Brilliant Smallfish](https://www.wowhead.com/forever/item=6291/raw-brilliant-smallfish) and [Raw Longjaw Mud Snapper](https://www.wowhead.com/forever/item=6289/raw-longjaw-mud-snapper): 5–9 and 4–8 respectively, from Iceflow Lake's open water.

Only learned gathering professions enter normal rolls. The browser can inspect unlearned professions as before. Mageroyal and Bristle Whisker Catfish were not copied from Elwynn without confirmed Dun Morogh availability.

## Zone handling and limits

The board dropdown chooses which zone's saved notices to display, not the player's physical location. Generation supports starting-zone progression through level 12 in both zones, with each category/profession falling back to its own highest band. This curated cap is not a claim that every NPC in the geographic zone is level 12 or below; dungeon and other high-level content is deliberately excluded.

Tracking always checks the active quest's zone. Dun Morogh uses Classic UI map 1426 (as reported in the Forever resource map data), with map 48 also recognized; Elwynn retains map 37 and also recognizes Classic map 1429. Child maps are followed through their parent hierarchy. Zone text is the fallback.

Tests cover generation at levels 1–12, profession eligibility, three distinct cards, outleveled fallback, saved boards/reload migration, cross-zone tracking, loot/gathering, and individual-slot turn-in. Live spawn availability, drop rates, client event ordering, localization, and visual layout still require in-game checks. Forever beta data may change.

