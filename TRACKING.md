# Alpha 0.5.3 tracking

## Forever compatibility

Alpha 0.5.3 keeps the automatic Kill/Hunt tracking restored in 0.5.2 using the public watched-creature approach adapted from Azeroth Fieldbook. No combat-log event is registered or read, on any client. Kill/Hunt offers can be accepted again; existing active progress is preserved.

Watch the quest target while it is alive by targeting or mousing over it. A death requires a recent living observation of that same creature GUID and readable eligibility (`UnitExists == true`, `UnitPlayerControlled == false`, `UnitIsTapDenied == false`) at death/kill notification time. A standalone `UNIT_DIED` event or a watched corpse can confirm death. `PARTY_KILL` only starts pending evidence and samples eligibility; it is not enough by itself. Polling every 0.2 seconds handles pet kills and clients without standalone GUID events.

Only publicly readable values are used. Unknown or secret evidence never grants credit. Living observations expire after 120 seconds; pending death evidence expires after 10 seconds. At most 64 creatures are remembered at once. Each credited GUID is saved with the active quest to prevent duplicates across reloads. Reloading clears unfinished observations, so newly encountered corpses do not count. Killing a creature that was never observed alive, or losing all readable tag/death evidence, can miss credit.

See THIRD_PARTY_NOTICES.md for attribution and license.

## Player flow

Open `/cq` or click the minimap button. The board offers three quests from the existing Elwynn Forest pool, including when opened in a city. Other zones do not yet have objective data.

Accept one quest in an inn, city, or other area where WoW reports `IsResting()`. Progress continues with the board closed and outside rest areas, but kills and collection/gathering must occur in Elwynn Forest, including child maps such as Northshire.

Reaching the required count changes the quest to **Ready to Turn In** and prints a chat notice. Return to any rested location, open the board, and click **Turn In Quest**. Nothing automatically hands in a quest. The latest 20 completions are saved per character. This release awards no rewards.

Abandon is available on the active card anywhere. A ready quest has a smaller Abandon Quest button on that same card. Reroll is disabled while a quest is active or ready.

## What earns progress

- **Kill / Hunt:** a matching creature observed alive must have a confirmed death and readable player/group tag eligibility. Pet kills can count without an attacker event. Tap-denied kills, player-controlled creatures, and duplicate death notifications do not count. Rare target amounts remain one.
- **Collect & Sell:** obtain the specified item, or vendor-value loot for generic spoils, from one of the objective's named creatures. Then sell qualifying quantities to a vendor. Sales require matching bag loss, buyback data, and money received. Existing inventory, purchases, trades, bank transfers, item destruction, and quest rewards do not earn collection credit. Removing eligible items from carried bags removes their remaining sale eligibility; buying them back does not restore it.
- **Herbalism / Mining / Skinning / Fishing:** a gathering action (or fishing channel) must precede the loot, with the correct item ID and creature/object source. The player's own loot message, a cleared loot slot, and an inventory gain confirm receipt. Boar and eastern-beast leather objectives also check the corpse's name.
- **Copper Vein Prospecting:** loot ore from the required number of different vein sources. Several ore from one vein count as one vein.

The accepted quest and progress are saved in `WoWForeverDB`. Existing accepted quests acquire tracking without changing their objective or amount. Pre-0.5.0 quests start at zero because those versions did not record progress. Unknown legacy objective IDs remain visible and can be abandoned. Debug levels never reset active progress. While Debug Mode is enabled, only the accept and turn-in location checks are bypassed; progress, state, tracking, and completion checks remain unchanged.

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
6. Change the debug generation level without an active quest. Outside a rest area, accept and turn in a completed quest while Debug Mode is active. Disable Debug Mode and verify those actions require a rest area again. Confirm the active quest remains stable while toggling the mode.

API events were checked against Blizzard's extracted [Classic loot documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua) and [merchant documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/MerchantFrameDocumentation.lua).
