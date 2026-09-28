# Quest givers — Alpha 0.9.0

These are narrative attributions for Classic Questbook notices. Players accept and turn in quests at the Questboard in a rested area; they do not need to interact with these NPCs. The flavour text is original addon writing, not in-game NPC dialogue.

The NPC names, faction affiliations, and zone membership were checked against Wowhead's Forever NPC data on 2026-09-28. Each row links to its Forever record. Roles describe which addon categories may draw that NPC. Both supported zones have verified Alliance-friendly giver pools. No Horde-friendly local pool has been verified, so Horde characters receive no generated notices in these zones.

| Elwynn Forest NPC | Location | Eligible categories |
| --- | --- | --- |
| [Marshal Dughan](https://www.wowhead.com/forever/npc=240) | Goldshire | Kill, Hunt |
| [Marshal McBride](https://www.wowhead.com/forever/npc=197) | Northshire Abbey | Kill, Hunt |
| [Deputy Willem](https://www.wowhead.com/forever/npc=823) | Northshire Valley | Kill, Hunt |
| [Guard Thomas](https://www.wowhead.com/forever/npc=261) | Eastvale road | Kill, Hunt |
| [Remy "Two Times"](https://www.wowhead.com/forever/npc=241) | Goldshire | Hunt |
| [Innkeeper Farley](https://www.wowhead.com/forever/npc=295) | Goldshire | Collect & Sell, Gather |
| [Ma Stonefield](https://www.wowhead.com/forever/npc=244) | Stonefield Farm | Gather |
| [Maybell Maclure](https://www.wowhead.com/forever/npc=251) | Maclure Vineyards | Gather |
| [Smith Argus](https://www.wowhead.com/forever/npc=514) | Goldshire | Gather |
| [Tharynn Bouden](https://www.wowhead.com/forever/npc=66) | Goldshire | Collect & Sell |
| [Drake Lindgren](https://www.wowhead.com/forever/npc=1250) | Eastvale Logging Camp | Collect & Sell |
| [Brother Danil](https://www.wowhead.com/forever/npc=152) | Northshire Abbey | Collect & Sell |

| Dun Morogh NPC | Location | Eligible categories |
| --- | --- | --- |
| [Sten Stoutarm](https://www.wowhead.com/forever/npc=658) | Coldridge Valley | Kill, Hunt |
| [Balir Frosthammer](https://www.wowhead.com/forever/npc=713) | Coldridge Valley | Kill, Hunt |
| [Grelin Whitebeard](https://www.wowhead.com/forever/npc=786) | Coldridge Valley | Kill, Hunt |
| [Talin Keeneye](https://www.wowhead.com/forever/npc=714) | Coldridge Valley | Kill, Hunt |
| [Senir Whitebeard](https://www.wowhead.com/forever/npc=1252) | Kharanos | Kill, Hunt |
| [Rudra Amberstill](https://www.wowhead.com/forever/npc=1265) | Amberstill Ranch | Kill, Hunt |
| [Innkeeper Belm](https://www.wowhead.com/forever/npc=1247) | Kharanos | Collect & Sell, Gather |
| [Ragnar Thunderbrew](https://www.wowhead.com/forever/npc=1267) | Kharanos | Gather |
| [Pilot Bellowfiz](https://www.wowhead.com/forever/npc=1378) | Steelgrill's Depot | Gather |
| [Razzle Sprysprocket](https://www.wowhead.com/forever/npc=1269) | Steelgrill's Depot | Gather |
| [Adlin Pridedrift](https://www.wowhead.com/forever/npc=829) | Coldridge Valley | Collect & Sell |
| [Kreg Bilmn](https://www.wowhead.com/forever/npc=1691) | Kharanos | Collect & Sell |
| [Golorn Frostbeard](https://www.wowhead.com/forever/npc=1692) | South of Kharanos | Collect & Sell |

Each category has four possible flavour lines. Gather uses separate four-line pools for Herbalism, Mining, Skinning, and Fishing. An offer saves its chosen NPC and line, so neither changes when a quest is accepted, refreshed, or restored after login.

Collect & Sell uses only NPCs with a merchant inventory. The addon checks the interacting NPC's creature ID when the merchant window opens; only sales to the notice's named vendor can advance its sale step. If the client does not expose that NPC identity, the sale does not receive quest credit.
