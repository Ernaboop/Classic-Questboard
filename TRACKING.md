# Alpha 0.6.12 tracking

## Forever compatibility

Alpha 0.5.3 keeps the automatic Kill/Hunt tracking restored in 0.5.2 using the public watched-creature approach adapted from Azeroth Fieldbook. No combat-log event is registered or read, on any client. Kill/Hunt offers can be accepted again; existing active progress is preserved.

Watch the quest target while it is alive by targeting or mousing over it. A death requires a recent living observation of that same creature GUID and readable eligibility (`UnitExists == true`, `UnitPlayerControlled == false`, `UnitIsTapDenied == false`) at death/kill notification time. A standalone `UNIT_DIED` event or a watched corpse can confirm death. `PARTY_KILL` only starts pending evidence and samples eligibility; it is not enough by itself. Polling every 0.2 seconds handles pet kills and clients without standalone GUID events.

Only publicly readable values are used. Unknown or secret evidence never grants credit. Living observations expire after 120 seconds; pending death evidence expires after 10 seconds. At most 64 creatures are remembered at once. Each credited GUID is saved with the active quest to prevent duplicates across reloads. Reloading clears unfinished observations, so newly encountered corpses do not count. Killing a creature that was never observed alive, or losing all readable tag/death evidence, can miss credit.

See THIRD_PARTY_NOTICES.md for attribution and license.

## Player flow

### Rename from WoWForever

The addon folder and manifest are now `Classic Questbook/Classic Questbook.toc`. Fully restart WoW after renaming the folder. For other installations, while WoW is closed, copy each character's `WTF/Account/.../SavedVariables/WoWForever.lua` to `Classic Questbook.lua` in the same directory (and copy the `.lua.bak` backup similarly). Preserve the originals and do not overwrite existing Classic Questbook saves. The internal `WoWForeverDB` variable and keybinding IDs deliberately retain their old names to preserve data and assigned keys.

Open `/cq`, click the minimap button, or assign Toggle Classic Questbook in WoW's Key Bindings settings (no default key). The board offers three quests from the existing Elwynn Forest pool, including when opened in a city. Other zones do not yet have objective data.

Eligible categories use relative weights: Kill 40, Collect & Sell 30, Gather 25, Hunt 5. Gather has one shared weight regardless of learned profession count. Unavailable categories are excluded and remaining weights are normalized. These are per-roll odds, not guaranteed proportions on a three-card board. Debug's forced left-card category overrides that card's random category choice.

Accept one quest in an inn, city, or other area where WoW reports `IsResting()`. Progress continues with the board closed and outside rest areas, but kills and collection/gathering must occur in Elwynn Forest, including child maps such as Northshire.

Reaching the required count changes the quest to **Ready to Turn In** and prints a chat notice. Return to any rested location, open the board, and click **Turn In Quest**. Nothing automatically hands in a quest. The latest 20 completions are saved per character. This release awards no rewards.

Abandon is available on the active card anywhere. A ready quest has a smaller Abandon Quest button on that same card. Abandoning asks for confirmation and clears progress while preserving all three offers. The popup's opt-out is saved only when confirmed. The cog beside Close opens Options, where confirmation can be re-enabled. Settings are saved per character.

Turning in replaces only the completed slot using current generation settings and excludes objectives already on the other two cards. The completed objective is also excluded when alternatives exist. Only Reroll Quests regenerates the entire board; it is disabled while a quest is active or ready. Debug level/mode changes apply to the next reroll or replacement.

Debug Mode's +1 Progress control supports every active tracked quest type. Kill, Hunt, gathering, and node objectives gain one count. Collect & Sell advances collection until full, then selling. Counts are capped and use normal Ready to Turn In logic, requiring a manual turn-in. Debug increments do not create inventory items or perform actual sales. Matching creature tooltips display progress, updating while hovered and showing Ready to Turn In when finished.

The Debug Mode left-card category dropdown offers Any category, Kill, Collect & Sell, Hunt, and Gather directly. Choose a category, then use Reroll Quests. The selection also applies to left-slot turn-in replacements when eligible objectives exist, without changing active quests or the other two slots. Normal eligibility rules remain enforced.

Debug Mode also exposes Required amount at the bottom of the board. Enter a whole number from 1 to 1000 and click Apply (or press Enter). This edits only the accepted quest and refreshes its objective text and readiness. Earned progress is preserved, including across reloads; lowering the target may show progress above the new requirement. Raising it can return a ready quest to Active. No quest is handed in automatically.

Options, Help (the question-mark button), and Quest Browser toggle open/closed. Secondary windows open beside the previous visible window with support for nested windows; they use the left side when needed and remain clamped to the screen.

Statistics opens a toggleable window with per-character totals for quests accepted, handed in, and abandoned. Use the + beside Quests handed in to expand completion counts for Kill, Collect & Sell, Hunt, and Gather; use − to collapse. Totals start when statistics are installed, include successful Debug Mode actions, and persist independently of recent-completion history. Failed actions, cancelled abandonment, ready-state changes, and reloads do not increment totals. Earlier activity cannot be reconstructed reliably and is not backfilled.

## What earns progress

- **Kill / Hunt:** a matching creature observed alive must have a confirmed death and readable player/group tag eligibility. Pet kills can count without an attacker event. Tap-denied kills, player-controlled creatures, and duplicate death notifications do not count. Rare target amounts remain one.
- **Collect & Sell:** obtain the specified item, or vendor-value loot for generic spoils, from one of the objective's named creatures. Then sell qualifying quantities to a vendor. Sales require matching bag loss, buyback data, and money received. Existing inventory, purchases, trades, bank transfers, item destruction, and quest rewards do not earn collection credit. Removing eligible items from carried bags removes their remaining sale eligibility; buying them back does not restore it.
- **Herbalism / Mining / Skinning / Fishing:** a gathering action (or fishing channel) must precede the loot, with the correct item ID and creature/object source. The player's own loot message, a cleared loot slot, and an inventory gain confirm receipt. Boar and eastern-beast leather objectives also check the corpse's name.
- **Copper Vein Prospecting:** loot ore from the required number of different vein sources. Several ore from one vein count as one vein.

The accepted quest and progress are saved in `WoWForeverDB`. Existing accepted quests acquire tracking without changing their objective or amount. Pre-0.5.0 quests start at zero because those versions did not record progress. Unknown legacy objective IDs remain visible and can be abandoned. Debug levels never reset active progress. While Debug Mode is enabled, only the accept and turn-in location checks are bypassed; progress, state, tracking, and completion checks remain unchanged.

## Limits and client verification

The current creature definitions use English names from the existing generator. Items use numeric IDs. Non-English creature names are not yet localized. Location hints such as Fargodeep Mine remain guidance: tracking enforces Elwynn membership and the exact target, not a radius around each landmark.

Tracking requires positive loot/sale evidence. Deferred group-roll awards, loot systems without normal loot-window/source events, or sales combined with a repair/purchase that hides the net money gain may be missed rather than credited speculatively. Individual vendor sales and normal loot/autoloot are the intended first client test paths. World data remains subject to Forever beta changes.

Run tests with Python and `lupa` installed: `python tests/run.py`. The runner compiles all Lua files, parses the keybinding XML, and executes event/UI regressions under Lua 5.1 with mocked WoW APIs. It does not verify live event ordering or visual layout.

In-game smoke test:

1. Outside rest, verify accept and turn-in are disabled and explained. Enter an inn and verify the controls update.
2. Accept a Kill quest. Try a wrong target, then matching targets with player and pet damage. Close the board while progressing. Reload midway and verify the same quest and count return.
3. Finish outdoors. Confirm Ready to Turn In persists without completion, then return to rest and manually hand in once.
4. Test normal loot/autoloot for each learned gathering profession, a full-bag failure, and unrelated purchased items. Multiple ore from one vein should count once for prospecting.
5. Collect qualifying spoils and sell individual stacks. Verify destruction, banking, and purchased replacements do not count as sales. Test an identical-stack sale when buyback is full.
6. Change the debug generation level without an active quest. Outside a rest area, accept and turn in a completed quest while Debug Mode is active. Disable Debug Mode and verify those actions require a rest area again. Confirm the active quest remains stable while toggling the mode.
7. Bind a toggle key, test open/close, and open the Options cog. Cancel abandonment, then confirm with the opt-out checked; reload and verify the preference persists. Re-enable confirmation in Options.
8. Accept each card in turn. Abandon and verify all offers stay put; complete and hand in to verify only that slot changes. In Debug Mode, use +1 Progress on a Kill quest and hover a matching mob to check the updated tooltip and ready state.

API events were checked against Blizzard's extracted [Classic loot documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua) and [merchant documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/MerchantFrameDocumentation.lua).
