# Classic Questboard tracking

## Forever compatibility

Alpha 0.5.3 keeps the automatic Kill/Hunt tracking restored in 0.5.2 using the public watched-creature approach adapted from Azeroth Fieldbook. No combat-log event is registered or read, on any client. Kill/Hunt offers can be accepted again; existing active progress is preserved.

Watch the quest target while it is alive by targeting or mousing over it. A kill requires a recent living, in-combat observation of that same creature GUID with readable tap eligibility (`UnitExists == true`, `UnitPlayerControlled == false`, `UnitIsTapDenied == false`) **and** public `UnitThreatSituation` evidence that the player, a party member, or one of their pets is on that mob's threat list. The mob must then have a confirmed death and readable eligibility at the terminal observation. An idle, untapped target's eventual corpse cannot establish an earlier tag; neither can a mob fighting an NPC or unrelated player without group threat. A standalone `UNIT_DIED` event or a watched corpse can confirm death. `PARTY_KILL` only samples eligibility and is not proof of death by itself; a valid party tap can still count without that event if death is confirmed separately. Polling every 0.2 seconds handles pet kills and clients without standalone GUID events.

Only publicly readable values are used. Unknown or secret evidence never grants credit. Living observations expire after 120 seconds; pending death evidence expires after 10 seconds. At most 64 creatures are remembered at once. Each credited GUID is saved with the active quest to prevent duplicates across reloads. Reloading clears unfinished observations, so newly encountered corpses do not count. Killing a creature that was never observed alive with readable group threat and a permitted tap, or losing all readable tap/death evidence, can miss credit. Threat data may be unavailable or secret on some client states, in which case the addon deliberately withholds credit rather than guessing. The public API reports tap denial and threat, not the individual who first tagged; an in-game check is needed to confirm exact client group-tap behavior.

See THIRD_PARTY_NOTICES.md for attribution and license.

## Player flow

### Rename and saved quests

The addon folder and manifest are now `Classic Questboard/Classic Questboard.toc`. Fully restart WoW after replacing an older installation. While WoW is closed, copy each character's `WTF/Account/.../SavedVariables/Classic Questbook.lua` to `Classic Questboard.lua` in the same directory (and copy the `.lua.bak` backup similarly). For installations dating back to WoWForever, use `WoWForever.lua` if there is no Classic Questbook save. Preserve the originals and do not overwrite an existing Classic Questboard save. The internal `WoWForeverDB` variable and keybinding IDs deliberately retain their old names to preserve progress and assigned keys.

Open `/cq`, click the minimap button, or assign Toggle Classic Questboard in WoW's Key Bindings settings (no default key). The board offers three quests from the selected registered zone, including Elwynn Forest, Dun Morogh, and Westfall.

Eligible categories use relative weights: Kill 40, Supply 30, Gather 25, Hunt 5. Gather has one shared weight regardless of learned profession count. Unavailable categories are excluded and remaining weights are normalized. These are per-roll odds, not guaranteed proportions on a three-card board. Debug's forced left-card category overrides that card's random category choice.

Accept one quest in an inn, city, or other area where WoW reports `IsResting()`. Progress continues with the board closed and outside rest areas, but kills and collection/gathering must occur in Elwynn Forest, including child maps such as Northshire.

Reaching the required count changes the quest to **Ready to Turn In** and prints a chat notice. Return to any rested location, open the board, and click **Turn In Quest**. Nothing automatically hands in a quest. The latest 20 completions are saved per character. This release awards no rewards.

Abandon is available on the active card anywhere. A ready quest has a smaller Abandon Quest button on that same card. Abandoning asks for confirmation and clears progress while preserving all three offers. The popup's opt-out is saved only when confirmed. The cog beside Close opens Options, where confirmation can be re-enabled. Settings are saved per character.

Turning in replaces only the completed slot using current generation settings and excludes objectives already on the other two cards. The completed objective is also excluded when alternatives exist. Only Reroll Quests regenerates the entire board; it is disabled while a quest is active or ready. Debug level/mode changes apply to the next reroll or replacement.

Debug Mode's +1 Progress control supports every active tracked quest type. Kill, Hunt, gathering, and node objectives gain one count. Supply advances collection until full, then selling. Counts are capped and use normal Ready to Turn In logic, requiring a manual turn-in. Debug increments do not create inventory items or perform actual sales. Matching creature tooltips display progress, updating while hovered and showing Ready to Turn In when finished.

The Debug Mode left-card category dropdown offers Any category, Kill, Supply, Hunt, and Gather directly. Choose a category, then use Reroll Quests. The selection also applies to left-slot turn-in replacements when eligible objectives exist, without changing active quests or the other two slots. Normal eligibility rules remain enforced.

Debug Mode also exposes Required amount at the bottom of the board. Enter a whole number from 1 to 1000 and click Apply (or press Enter). This edits only the accepted quest and refreshes its objective text and readiness. Earned progress is preserved, including across reloads; lowering the target may show progress above the new requirement. Raising it can return a ready quest to Active. No quest is handed in automatically.

Options, Help (the question-mark button), and Quest Browser toggle open/closed. Secondary windows open beside the previous visible window with support for nested windows; they use the left side when needed and remain clamped to the screen.

Statistics opens a toggleable window with per-character totals for quests accepted, handed in, and abandoned. Each statistic has its own +/− button, expanding its Kill, Supply, Hunt, and Gather counts directly underneath. Sections expand independently and push later sections down. Totals include successful Debug Mode actions and persist independently of recent-completion history. Failed actions, cancelled abandonment, ready-state changes, and reloads do not increment totals. Existing totals without category records are listed under Earlier / unclassified rather than guessed or discarded.

The top-centre zone dropdown selects Elwynn Forest or Dun Morogh for the board, browser, and generator. Each zone's three offers are saved separately. First-time selection generates offers; returning to a zone restores its existing offers. Reroll only changes the selected board, and successful hand-in replaces only its completed slot. Both curated pools support generation levels 1–12; each category/profession still falls back independently to its highest eligible band for overleveled characters.

Only one quest may be active across both zones. Switching boards leaves that quest and progress intact; return to its zone with the dropdown to view its card or hand it in. Existing Elwynn offers and active progress migrate unchanged. Debug amount edits and tracking resolve the accepted quest's own data even when another board is selected.

Quest Browser's Show all levels checkbox shows every objective in the selected zone's pool across all category tabs. Switching it off restores the selected level view. The toggle only changes browsing; it does not alter generated offers, generation level, or profession requirements. Hunt objective prose omits single-target counts and rare/elite labels; the browser retains the underlying subtype and eligibility data.

## What earns progress

- **Kill / Hunt:** a matching creature observed alive must have a confirmed death and readable player/group tag eligibility. Pet kills can count without an attacker event. Tap-denied kills, player-controlled creatures, and duplicate death notifications do not count. Rare target amounts remain one.
- **Supply:** obtain the specified item, or vendor-value loot for generic spoils, from one of the objective's named creatures. Then sell qualifying quantities to the assigned vendor. Sales require matching bag loss and buyback evidence; net money gain is not required because purchases and repairs can offset sale proceeds. Existing inventory, purchases, trades, bank transfers, item destruction, and quest rewards do not earn collection credit. Removing eligible items from carried bags removes their remaining sale eligibility; buying them back does not restore it.
- **Herbalism / Mining / Skinning / Fishing:** a gathering action (or fishing channel) must precede the loot, with the correct item ID and creature/object source. The player's own loot message, a cleared loot slot, and an inventory gain confirm receipt. Boar and eastern-beast leather objectives also check the corpse's name.
- **Copper Vein Prospecting:** loot ore from the required number of different vein sources. Several ore from one vein count as one vein.

The accepted quest and progress are saved in `WoWForeverDB`. Existing accepted quests acquire tracking without changing their objective or amount. Pre-0.5.0 quests start at zero because those versions did not record progress. Unknown legacy objective IDs remain visible and can be abandoned. Debug levels never reset active progress. While Debug Mode is enabled, only the accept and turn-in location checks are bypassed; progress, state, tracking, and completion checks remain unchanged.

## Limits and client verification

The current creature definitions use English names from the generator. Items use numeric IDs. Non-English creature names are not yet localized. Location hints such as Fargodeep Mine and Gol'Bolar Quarry remain guidance: tracking enforces the accepted quest's zone and exact target, not a radius around each landmark. Elwynn map IDs 1429/37 and Dun Morogh 1426/48 (including child maps) are recognized; English zone-name matching is the fallback. The selected board does not change these tracking restrictions.

Tracking requires positive loot/sale evidence. Deferred group-roll awards or loot systems without normal loot-window/source events may be missed rather than credited speculatively. Merchant item losses wait briefly for buyback evidence before being discarded. Individual vendor sales and normal loot/autoloot are the intended first client test paths. World data remains subject to Forever beta changes.

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
9. Switch zones with the top-centre dropdown and back; verify the original three offers return. Reload while browsing a different zone from the active quest and check both boards and active progress survive.
10. In Dun Morogh, test Crag Boar kills, Rockjaw spoils/sales, and every learned gathering profession. Confirm matching names/items in another zone do not count. Verify browser tabs and Show all levels switch to the selected zone, and the zone dropdown remains clear of the title and debug controls at your UI scale.
11. With a Kill or Hunt quest active, watch one target before engaging it. Confirm your own tag, a party member's tag, and a pet tag count after death. Confirm an idle target, an NPC-fought target, a grey/other-player tag, and a target that reset do not count. Repeat with the `PARTY_KILL` event unavailable or with the target cleared just before death to check the public threat/death fallback. If an eligible group kill is missed on the Forever client, inspect whether `UnitThreatSituation` is readable for player/party/pet while the mob is alive; the addon does not read restricted combat-log data.

API events were checked against Blizzard's extracted [Classic loot documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/LootDocumentation.lua) and [merchant documentation](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_APIDocumentationGenerated/MerchantFrameDocumentation.lua).

## Mining work orders and PvP card — Alpha 0.13.0

A Mining work order counts ore received from a local vein after a Mining action, then counts matching bars produced by smelting. Bar production cannot exceed the ore credited to that quest. Orders that name a blacksmith merchant require a final sale of those newly made bars to that exact NPC; matching bag loss and buyback evidence are required. Tin orders require Mining skill 65 to appear. Existing ore and bars, purchases, and sales to another vendor do not count. If the crafted-result event is missing or silent, a matching smelt cast followed by a bar appearing in the bag provides a fallback; unsupported work orders cannot be accepted.

A fourth card appears only while the player is PvP flagged. It is separate from the three saved zone notices and rolls an amount from 1 to 5. The player's PvP-kills event triggers a comparison against WoW's honorable-kill total; only positive honorable-kill increases advance it. Raw deaths and PvP events without an honorable-kill increase do not count. It shares the one-active-quest and manual rested turn-in rules. If the PvP flag ends while this quest is active, the card is hidden until the flag returns, but its progress stays saved.
