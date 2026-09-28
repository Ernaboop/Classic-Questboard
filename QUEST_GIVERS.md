# Quest givers — Alpha 0.13.0

These are narrative attributions for Classic Questboard notices. Players accept and turn in quests at the Questboard in a rested area; they do not need to interact with these NPCs. The flavour text is original addon writing, not in-game NPC dialogue.

The NPC names, faction affiliations, and zone membership were checked against Wowhead's Forever NPC data on 2026-09-28 and 2026-09-29. Each row links to its Forever record. Each NPC has the source tags shown below. Objectives request one or more tags; the generator assigns a friendly NPC that has every requested tag. The four supported zones have Alliance-friendly giver pools. Westfall also includes two neutral NPCs. Normal faction eligibility still applies.

| Elwynn Forest NPC | Location | NPC tags |
| --- | --- | --- |
| [Marshal Dughan](https://www.wowhead.com/forever/npc=240) | Goldshire | questgiver, guard |
| [Marshal McBride](https://www.wowhead.com/forever/npc=197) | Northshire Abbey | questgiver, guard |
| [Deputy Willem](https://www.wowhead.com/forever/npc=823) | Northshire Valley | questgiver, guard |
| [Guard Thomas](https://www.wowhead.com/forever/npc=261) | Eastvale road | questgiver, guard |
| [Remy "Two Times"](https://www.wowhead.com/forever/npc=241) | Goldshire | questgiver, scout |
| [Innkeeper Farley](https://www.wowhead.com/forever/npc=295) | Goldshire | vendor, collector, innkeeper |
| [Ma Stonefield](https://www.wowhead.com/forever/npc=244) | Stonefield Farm | collector, farmer |
| [Maybell Maclure](https://www.wowhead.com/forever/npc=251) | Maclure Vineyards | collector, farmer |
| [Smith Argus](https://www.wowhead.com/forever/npc=514) | Goldshire | collector, blacksmith, trainer |
| [Tharynn Bouden](https://www.wowhead.com/forever/npc=66) | Goldshire | vendor |
| [Drake Lindgren](https://www.wowhead.com/forever/npc=1250) | Eastvale Logging Camp | vendor |
| [Brother Danil](https://www.wowhead.com/forever/npc=152) | Northshire Abbey | vendor |

| Dun Morogh NPC | Location | NPC tags |
| --- | --- | --- |
| [Sten Stoutarm](https://www.wowhead.com/forever/npc=658) | Coldridge Valley | questgiver, guard |
| [Balir Frosthammer](https://www.wowhead.com/forever/npc=713) | Coldridge Valley | questgiver, guard |
| [Grelin Whitebeard](https://www.wowhead.com/forever/npc=786) | Coldridge Valley | questgiver, resident |
| [Talin Keeneye](https://www.wowhead.com/forever/npc=714) | Coldridge Valley | questgiver, scout |
| [Senir Whitebeard](https://www.wowhead.com/forever/npc=1252) | Kharanos | questgiver, scout |
| [Rudra Amberstill](https://www.wowhead.com/forever/npc=1265) | Amberstill Ranch | questgiver, guard |
| [Innkeeper Belm](https://www.wowhead.com/forever/npc=1247) | Kharanos | vendor, collector, innkeeper |
| [Ragnar Thunderbrew](https://www.wowhead.com/forever/npc=1267) | Kharanos | collector, resident |
| [Pilot Bellowfiz](https://www.wowhead.com/forever/npc=1378) | Steelgrill's Depot | collector, engineer |
| [Razzle Sprysprocket](https://www.wowhead.com/forever/npc=1269) | Steelgrill's Depot | collector, engineer |
| [Adlin Pridedrift](https://www.wowhead.com/forever/npc=829) | Coldridge Valley | vendor |
| [Kreg Bilmn](https://www.wowhead.com/forever/npc=1691) | Kharanos | vendor |
| [Golorn Frostbeard](https://www.wowhead.com/forever/npc=1692) | South of Kharanos | vendor |
| [Thrawn Boltar](https://www.wowhead.com/forever/npc=1690) | Kharanos | vendor, blacksmith, collector |

| Westfall NPC | Location | NPC tags |
| --- | --- | --- |
| [Gryan Stoutmantle](https://www.wowhead.com/forever/npc=234) | Sentinel Hill | questgiver, guard |
| [Captain Grayson](https://www.wowhead.com/forever/npc=392) | Westfall Lighthouse | questgiver, scout |
| [Farmer Saldean](https://www.wowhead.com/forever/npc=233) | Saldean's Farm | questgiver, collector, vendor, farmer |
| [Innkeeper Heather](https://www.wowhead.com/forever/npc=8931) | Sentinel Hill | collector, vendor, innkeeper |
| [Quartermaster Lewis](https://www.wowhead.com/forever/npc=491) | Sentinel Hill | vendor, quartermaster |
| [William MacGregor](https://www.wowhead.com/forever/npc=1668) | Sentinel Hill | vendor |
| [Defias Profiteer](https://www.wowhead.com/forever/npc=1669) | Moonbrook | vendor |

| Darkshore NPC | Location | NPC tags |
| --- | --- | --- |
| [Cerellean Whiteclaw](https://www.wowhead.com/forever/npc=3644) | Auberdine docks | questgiver, resident |
| [Thundris Windweaver](https://www.wowhead.com/forever/npc=3649) | Auberdine | questgiver, collector, resident |
| [Barithras Moonshade](https://www.wowhead.com/forever/npc=3583) | Auberdine | questgiver, resident |
| [Sentinel Glynda Nal'Shea](https://www.wowhead.com/forever/npc=2930) | Auberdine | questgiver, guard |
| [Innkeeper Shaussiy](https://www.wowhead.com/forever/npc=6737) | Auberdine inn | collector, innkeeper |
| [Dalmond](https://www.wowhead.com/forever/npc=4182) | Auberdine | vendor, collector |
| [Gorbold Steelhand](https://www.wowhead.com/forever/npc=6301) | Auberdine | vendor, collector |
| [Laird](https://www.wowhead.com/forever/npc=4200) | Auberdine inn | vendor, collector, fisherman |
| [Elisa Steelhand](https://www.wowhead.com/forever/npc=6300) | Auberdine forge | vendor, blacksmith, collector |

Innkeeper Shaussiy does not open a merchant inventory in the checked client records, so she is not assigned Supply tasks. Dalmond, Gorbold, Laird, and Elisa are actual merchant vendors; a Supply task remains locked to its assigned vendor.

Each category has four possible flavour lines. Gather uses separate four-line pools for Herbalism, Mining, Skinning, and Fishing. An offer saves its chosen NPC and line, so neither changes when a quest is accepted, refreshed, or restored after login.

Supply uses only NPCs with a merchant inventory. The addon checks the interacting NPC's creature ID when the merchant window opens; only sales to the notice's named vendor can advance its sale step. If the client does not expose that NPC identity, the sale does not receive quest credit.

NPC tag catalog: `vendor`, `blacksmith`, `innkeeper`, `guard`, `questgiver`, `collector`, `farmer`, `fisherman`, `trainer`, `quartermaster`, `engineer`, `scout`, and `resident`. A Supply objective requires `vendor`; a bar handoff requires both `blacksmith` and `vendor`. The NPC list has no separate vendor flag.
