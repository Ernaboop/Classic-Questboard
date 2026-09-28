# Quest givers — Alpha 0.12.0

These are narrative attributions for Classic Questboard notices. Players accept and turn in quests at the Questboard in a rested area; they do not need to interact with these NPCs. The flavour text is original addon writing, not in-game NPC dialogue.

The NPC names, faction affiliations, and zone membership were checked against Wowhead's Forever NPC data on 2026-09-28 and 2026-09-29. Each row links to its Forever record. Roles describe which addon categories may draw that NPC. The four supported zones have Alliance-friendly giver pools. Westfall also includes two neutral NPCs. Normal faction eligibility still applies.

| Elwynn Forest NPC | Location | Eligible categories |
| --- | --- | --- |
| [Marshal Dughan](https://www.wowhead.com/forever/npc=240) | Goldshire | Kill, Hunt |
| [Marshal McBride](https://www.wowhead.com/forever/npc=197) | Northshire Abbey | Kill, Hunt |
| [Deputy Willem](https://www.wowhead.com/forever/npc=823) | Northshire Valley | Kill, Hunt |
| [Guard Thomas](https://www.wowhead.com/forever/npc=261) | Eastvale road | Kill, Hunt |
| [Remy "Two Times"](https://www.wowhead.com/forever/npc=241) | Goldshire | Hunt |
| [Innkeeper Farley](https://www.wowhead.com/forever/npc=295) | Goldshire | Supply, Gather |
| [Ma Stonefield](https://www.wowhead.com/forever/npc=244) | Stonefield Farm | Gather |
| [Maybell Maclure](https://www.wowhead.com/forever/npc=251) | Maclure Vineyards | Gather |
| [Smith Argus](https://www.wowhead.com/forever/npc=514) | Goldshire | Gather |
| [Tharynn Bouden](https://www.wowhead.com/forever/npc=66) | Goldshire | Supply |
| [Drake Lindgren](https://www.wowhead.com/forever/npc=1250) | Eastvale Logging Camp | Supply |
| [Brother Danil](https://www.wowhead.com/forever/npc=152) | Northshire Abbey | Supply |

| Dun Morogh NPC | Location | Eligible categories |
| --- | --- | --- |
| [Sten Stoutarm](https://www.wowhead.com/forever/npc=658) | Coldridge Valley | Kill, Hunt |
| [Balir Frosthammer](https://www.wowhead.com/forever/npc=713) | Coldridge Valley | Kill, Hunt |
| [Grelin Whitebeard](https://www.wowhead.com/forever/npc=786) | Coldridge Valley | Kill, Hunt |
| [Talin Keeneye](https://www.wowhead.com/forever/npc=714) | Coldridge Valley | Kill, Hunt |
| [Senir Whitebeard](https://www.wowhead.com/forever/npc=1252) | Kharanos | Kill, Hunt |
| [Rudra Amberstill](https://www.wowhead.com/forever/npc=1265) | Amberstill Ranch | Kill, Hunt |
| [Innkeeper Belm](https://www.wowhead.com/forever/npc=1247) | Kharanos | Supply, Gather |
| [Ragnar Thunderbrew](https://www.wowhead.com/forever/npc=1267) | Kharanos | Gather |
| [Pilot Bellowfiz](https://www.wowhead.com/forever/npc=1378) | Steelgrill's Depot | Gather |
| [Razzle Sprysprocket](https://www.wowhead.com/forever/npc=1269) | Steelgrill's Depot | Gather |
| [Adlin Pridedrift](https://www.wowhead.com/forever/npc=829) | Coldridge Valley | Supply |
| [Kreg Bilmn](https://www.wowhead.com/forever/npc=1691) | Kharanos | Supply |
| [Golorn Frostbeard](https://www.wowhead.com/forever/npc=1692) | South of Kharanos | Supply |

| Westfall NPC | Location | Eligible categories |
| --- | --- | --- |
| [Gryan Stoutmantle](https://www.wowhead.com/forever/npc=234) | Sentinel Hill | Kill, Hunt |
| [Captain Grayson](https://www.wowhead.com/forever/npc=392) | Westfall Lighthouse | Kill, Hunt |
| [Farmer Saldean](https://www.wowhead.com/forever/npc=233) | Saldean's Farm | Kill, Gather, Supply |
| [Innkeeper Heather](https://www.wowhead.com/forever/npc=8931) | Sentinel Hill | Gather, Supply |
| [Quartermaster Lewis](https://www.wowhead.com/forever/npc=491) | Sentinel Hill | Supply |
| [William MacGregor](https://www.wowhead.com/forever/npc=1668) | Sentinel Hill | Supply |
| [Defias Profiteer](https://www.wowhead.com/forever/npc=1669) | Moonbrook | Supply |

| Darkshore NPC | Location | Eligible categories |
| --- | --- | --- |
| [Cerellean Whiteclaw](https://www.wowhead.com/forever/npc=3644) | Auberdine docks | Kill, Hunt |
| [Thundris Windweaver](https://www.wowhead.com/forever/npc=3649) | Auberdine | Kill, Hunt, Gather |
| [Barithras Moonshade](https://www.wowhead.com/forever/npc=3583) | Auberdine | Kill, Hunt |
| [Sentinel Glynda Nal'Shea](https://www.wowhead.com/forever/npc=2930) | Auberdine | Kill, Hunt |
| [Innkeeper Shaussiy](https://www.wowhead.com/forever/npc=6737) | Auberdine inn | Gather |
| [Dalmond](https://www.wowhead.com/forever/npc=4182) | Auberdine | Supply, Gather |
| [Gorbold Steelhand](https://www.wowhead.com/forever/npc=6301) | Auberdine | Supply, Gather |
| [Laird](https://www.wowhead.com/forever/npc=4200) | Auberdine inn | Supply, Gather |

Innkeeper Shaussiy does not open a merchant inventory in the checked client records, so she is not assigned Supply tasks. Dalmond, Gorbold, and Laird are actual merchant vendors; a Supply task remains locked to its assigned vendor.

Each category has four possible flavour lines. Gather uses separate four-line pools for Herbalism, Mining, Skinning, and Fishing. An offer saves its chosen NPC and line, so neither changes when a quest is accepted, refreshed, or restored after login.

Supply uses only NPCs with a merchant inventory. The addon checks the interacting NPC's creature ID when the merchant window opens; only sales to the notice's named vendor can advance its sale step. If the client does not expose that NPC identity, the sale does not receive quest credit.
