# Alpha 0.5.1 tracking

## Forever compatibility

Forever restricts combat-log event registration. Version 0.5.1 does not request it on Forever or Midnight. Automatic Kill/Hunt tracking is therefore unavailable on these clients: the cards explain the limitation and cannot be newly accepted. Existing active Kill/Hunt quests retain their progress and can be abandoned; already-ready quests can still be handed in. The generator's pools are preserved, so some displayed offers may be unavailable until an alternative supported kill-credit system is implemented.

Collection and gathering continue using public loot, inventory, and profession events. When corpse identities are secret or unavailable, source-specific loot cannot be credited. No attempt is made to read restricted combat data or bypass the client's protection. On supported legacy clients, automatic kill tracking remains enabled.

The blocked-event restriction is documented in [Blizzard's extracted combat-log API definitions](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/CombatLogDocumentation.lua).

## Player flow

Open `/cq` or click the minimap button. The board offers three quests from the existing Elwynn Forest pool, including when opened in a city. Other zones do not yet have objective data.

Accept one quest in an inn, city, or other area where WoW reports `IsResting()`. Progress continues with the board closed and outside rest areas, but kills and collection/gathering must occur in Elwynn Forest, including child maps such as Northshire.

Reaching the required count changes the quest to **Ready to Turn In** and prints a chat notice. Return to any rested location, open the board, and click **Turn In Quest**. Nothing automatically hands in a quest. The latest 20 completions are saved per character. This release awards no rewards.

Abandon is available on the active card anywhere. A ready quest has a smaller Abandon Quest button on that same card. Reroll is disabled while a quest is active or ready.

## What earns progress

- **Kill / Hunt (supported legacy clients only):** the matching named creature must die after the player or their pet damages it. Nearby strangers' kills and duplicate death events do not count. Rare target amounts remain one.
- **Collect & Sell:** obtain the specified item, or vendor-value loot for generic spoils, from one of the objective's named creatures. Then sell qualifying quantities to a vendor. Sales require matching bag loss, buyback data, and money received. Existing inventory, purchases, trades, bank transfers, item destruction, and quest rewards do not earn collection credit. Removing eligible items from carried bags removes their remaining sale eligibility; buying them back does not restore it.
- **Herbalism / Mining / Skinning / Fishing:** a gathering action (or fishing channel) must precede the loot, with the correct item ID and creature/object source. The player's own loot message, a cleared loot slot, and an inventory gain confirm receipt. Boar and eastern-beast leather objectives also check the corpse's name.
- **Copper Vein Prospecting:** loot ore from the required number of different vein sources. Several ore from one vein count as one vein.

The accepted quest and progress are saved in `WoWForeverDB`. Existing accepted quests acquire tracking without changing their objective or amount. Pre-0.5.0 quests start at zero because those versions did not record progress. Unknown legacy objective IDs remain visible and can be abandoned. Debug levels never reset active progress or bypass rest requirements.

## Limits and client verification

The current creature definitions use English names from the existing generator. Items use numeric IDs. Non-English creature names are not yet localized. Location hints such as Fargodeep Mine remain guidance: tracking enforces Elwynn membership and the exact target, not a radius around each landmark.

Tracking requires positive loot/sale evidence. Deferred group-roll awards, loot systems without normal loot-window/source events, or sales combined with a repair/purchase that hides the net money gain may be missed rather than credited speculatively. Individual vendor sales and normal loot/autoloot are the intended first client test paths. World data remains subject to Forever beta changes.

Run tests with Python and `lupa` installed: `python tests/run.py`. The runner compiles both Lua files and executes event/UI regressions under Lua 5.1 with mocked WoW APIs. It does not verify live event ordering or visual layout.

In-game smoke test:

1. Outside rest, verify accept and turn-in are disabled and explained. Enter an inn and verify the controls update.
2. Accept a Kill quest. Try a wrong target, then matching targets with player and pet damage. Close the board while progressing. Reload midway and verify the same quest and count return.
3. Finish outdoors. Confirm Ready to Turn In persists without completion, then return to rest and manually hand in once.
4. Test normal loot/autoloot for each learned gathering profession, a full-bag failure, and unrelated purchased items. Multiple ore from one vein should count once for prospecting.
5. Collect qualifying spoils and sell individual stacks. Verify destruction, banking, and purchased replacements do not count as sales. Test an identical-stack sale when buyback is full.
6. Change the debug generation level without an active quest, accept a generated quest, then toggle Debug Mode. Verify the active quest stays stable and rest restrictions still apply.

API events were checked against Blizzard's extracted [Classic loot documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua) and [merchant documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/MerchantFrameDocumentation.lua).
