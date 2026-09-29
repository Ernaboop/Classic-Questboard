local count = 0
local function check(value, message) assert(value, message); count = count + 1 end
local function newDatabase()
    local ns = {}
    for _, source in ipairs(data_sources) do assert(loadstring(source))('test', ns) end
    return ns.Database
end
local D = newDatabase()
local saved = {}
check(D:Initialize(saved), 'all built-in content validates')
local base = D:GetBase()
check(#D:List('zones') == 4 and #D:List('objectives') == 208, 'all four zones and Mining work orders validate')
check(#D:List('questGivers') == 42 and #D:List('flavourText') == 48, 'all tagged givers and flavour validate')
for _, objective in pairs(base.objectives) do
    check(base.zones[objective.zone] and objective.minAmount and objective.maxAmount, 'every objective uses shared schema')
end
local ordersByZone, orderCount = {}, 0
for _, npc in pairs(base.questGivers) do
    check(type(npc.tags) == 'table' and #npc.tags >= 1 and npc.categories == nil and npc.vendor == nil,
        'every NPC has tags and no legacy category/vendor fields')
    for _, tag in ipairs(npc.tags) do check(D.npcTags[tag], 'each NPC tag is registered') end
end
for _, objective in pairs(base.objectives) do
    check(type(objective.requiredNPCTags) == 'table' and #objective.requiredNPCTags > 0,
        'every objective states its required NPC tags')
    if objective.category == 'supply' then
        check(D.HasTags({tags = objective.requiredNPCTags}, {'vendor'}), 'Supply requires a vendor tag')
    end
    if objective.trackingKind == 'mining_workorder' then
        orderCount = orderCount + 1
        ordersByZone[objective.zone] = (ordersByZone[objective.zone] or 0) + 1
        check(objective.profession == 'mining' and objective.oreItemID and objective.smeltSpellID
            and objective.minAmount <= objective.maxAmount, 'Mining work order has ore, bars, and amount range')
        if objective.handoff == 'sale' then
            check(D.HasTags({tags = objective.requiredNPCTags}, {'blacksmith', 'vendor'}),
                'bar-sale order requires a blacksmith merchant')
        end
    end
end
check(orderCount == 8 and ordersByZone.elwynn == 1 and ordersByZone.dun_morogh == 2
    and ordersByZone.westfall == 2 and ordersByZone.darkshore == 3,
    'all four zones have their planned Mining work-order pools')
local function reject(edit, description)
    local candidate = D.Copy(base)
    edit(candidate.objectives.kobold_vermin, candidate)
    local ok, errors = D:Validate(candidate)
    check(not ok and #errors > 0, description)
    check(errors[1].message:find(' / ', 1, true), 'diagnostics identify the entry context')
end
reject(function(o) o.id = nil end, 'missing ID')
reject(function(o) o.name = '' end, 'missing name')
reject(function(o) o.category = 'unknown' end, 'unknown category')
reject(function(o) o.zone = 'unknown' end, 'unknown zone')
reject(function(o) o.targets = nil end, 'missing tracking identifier')
reject(function(o) o.targets = {0 / 0} end, 'invalid array numbers do not crash validation')
reject(function(o) o.minPlayerLevel = 9 end, 'inverted levels')
reject(function(o) o.maxPlayerLevel = 99 end, 'levels beyond zone')
reject(function(o) o.minAmount = 99 end, 'inverted amounts')
reject(function(o) o.profession = 'alchemy' end, 'wrong profession and category field')
reject(function(o) o.itemID = 123 end, 'item identifier on Kill rejected')
reject(function(o) o.requiredNPCTags = {'imaginary_role'} end, 'unknown NPC tag rejected')
reject(function(o) o.requiredNPCTags = {'blacksmith', 'vendor'} end, 'unavailable NPC tag combination rejected')
reject(function(o, c) c.questGivers = {} end, 'Supply needs zone vendors')
reject(function(o, c) c.zones.elwynn = false end, 'malformed referenced zone does not crash')
reject(function(o, c) c.flavourText.kobold_vermin = {id = o.id, category = 'kill', text = 'Duplicate'} end, 'cross-kind duplicate IDs')
check(not D:Validate({zones = false}), 'malformed collections rejected')
local rare = D:Get('objectives', 'narg_the_taskmaster')
-- Locate by classification rather than relying on another fixed content ID.
for _, entry in pairs(base.objectives) do if entry.classification == 'rare' then rare = D.Copy(entry); break end end
rare.maxAmount = 2
check(not D:Save('objectives', rare), 'rare count stays exactly one')
local edit = D:Get('objectives', 'kobold_vermin')
edit.name, edit.minAmount, edit.maxAmount = 'Edited vermin', 2, 3
check(D:Save('objectives', edit), 'objective override saves')
check(D:Get('objectives', edit.id).minAmount == 2 and D:GetBase().objectives[edit.id].minAmount == 8, 'base remains untouched')
check(not D:Save('objectives', edit, true), 'duplicate custom ID rejected')
edit.id, edit.name = 'custom_vermin', 'Custom vermin'
check(D:Save('objectives', edit, true), 'custom objective saved')
check(D:Delete('objectives', 'kobold_vermin'), 'builtin objective disabled')
check(not D:Get('objectives', 'kobold_vermin') and saved.databaseOverrides.objectives.kobold_vermin.disabled, 'tombstone used')
local giver = D:Get('questGivers', 'npc_295')
giver.name = 'Edited giver'
check(D:Save('questGivers', giver), 'giver override saves')
local flavour = D:List('flavourText')[1]
flavour.text = 'Edited flavour'
check(D:Save('flavourText', flavour), 'flavour override saves')
local customFlavour = D.Copy(flavour); customFlavour.id = 'custom_flavour'
check(D:Save('flavourText', customFlavour, true), 'new flavour saves')
D = newDatabase()
check(D:Initialize(saved), 'overrides survive reload')
check(D:Get('objectives', 'custom_vermin').minAmount == 2 and not D:Get('objectives', 'kobold_vermin'), 'custom addition and disable survive')
check(D:Get('questGivers', giver.id).name == giver.name and D:Get('flavourText', flavour.id).text == flavour.text, 'giver and flavour survive')
check(D:GetBase().objectives.kobold_vermin.minAmount == 8, 'reload does not alter base')
local broken = {databaseOverrides = {version = 1, objectives = {custom = {entry = {id = 'custom'}}}}}
check(not D:Initialize(broken), 'invalid saved edit reported safely')
check(broken.databaseOverrideBackup.objectives.custom and #D:List('objectives') == 208, 'broken edits backed up and base restored')
local duplicate = newDatabase()
check(not duplicate:RegisterObjective(base.objectives.kobold_vermin), 'registration duplicate rejected')
check(not duplicate:Initialize({}), 'registration error reported at load')

local function registerTestZone(db)
    db:RegisterZone({id = 'test_zone', name = 'Test Zone', minLevel = 1, maxLevel = 12, mapIDs = {999999},
        objectives = {{id = 'test_kill', name = 'Test creature', category = 'kill', level = '1',
            minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 2, maxAmount = 2,
            location = 'Test location', npcID = 999999, requiredNPCTags = {'questgiver'}}},
        questGivers = {{id = 'test_giver', name = 'Test giver', npcID = 999998, zone = 'test_zone',
            faction = 'Alliance', location = 'Test inn', tags = {'questgiver'}}},
        flavourText = {{id = 'test_story', category = 'kill', text = 'Test story.'}},
    })
end
local addon, board = TestEnvironment.load(nil, registerTestZone)
D = addon.Database
check(#D.zoneOrder == 5 and #D.errors == 0, 'new zone registered solely through data')
TestEnvironment.select(board.zoneDropdown, 'Test Zone')
local q = addon.GenerateQuestForLevel(6, false, nil, 'kill')
check(q and q.objectiveId == 'test_kill' and q.zoneMapIDs[1] == 999999 and q.tracking.npcID == 999999, 'new zone generator and tracking identifiers')
local foundStory, pickedValidStory = false, false
for _, story in ipairs(D:GetFlavours('test_zone', 'kill')) do
    if story == 'Test story.' then foundStory = true end
    if story == q.flavorText then pickedValidStory = true end
end
check(q.source == 'Test giver' and foundStory and pickedValidStory, 'new zone giver and flavour')
TestEnvironment.zone('Test Zone')
check(addon.Tracking.Accept(q), 'new zone accepts normally')
local mob = {guid = 'Creature-0-1-0-0-999997-wrong', name = 'Test creature', dead = false,
    controlled = false, denied = false, inCombat = true, tagger = 'player'}
TestEnvironment.unit('target', mob)
addon.Tracking.OnEvent('PLAYER_TARGET_CHANGED')
mob.dead = true; addon.Tracking.OnEvent('UNIT_DIED', mob.guid)
check(q.progress.count == 0, 'matching name with wrong NPC ID gives no credit')
mob = {guid = 'Creature-0-1-0-0-999999-right', name = 'Localized creature name', dead = false,
    controlled = false, denied = false, inCombat = true, tagger = 'player'}
TestEnvironment.unit('target', mob)
addon.Tracking.OnEvent('PLAYER_TARGET_CHANGED')
check(q.progress.count == 0, 'NPC ID match still requires death')
mob.dead = true; addon.Tracking.OnEvent('UNIT_DIED', mob.guid)
check(q.progress.count == 1, 'matching NPC ID counts tagged death with localized name')
local originalText, originalAmount = q.objective, q.amount
local changed = D:Get('objectives', 'test_kill')
changed.name, changed.minAmount, changed.maxAmount = 'Changed creature', 5, 5
check(D:Save('objectives', changed), 'editing source while active succeeds')
check(q.amount == originalAmount and q.objective == originalText and q.progress.count == 1, 'active snapshot and progress preserved')
check(addon.GenerateQuestForLevel(6, false, nil, 'kill').amount == 5, 'new generation reads merged override')
WoWForeverDebugModeButton.scripts.OnClick()
board.debugButton.scripts.OnClick()
local browser = WoWForeverQuestBrowser
local found = false
for _, row in ipairs(browser.objectiveRows) do if row:IsShown() and row.title.text == 'Changed creature' then found = true end end
check(found, 'Quest Browser reads merged data')
board.options.scripts.OnClick()
WoWForeverOptions.databaseEditor.scripts.OnClick()
local E, ui = addon.DatabaseEditor, addon.DatabaseEditor.frame
check(ui:IsShown() and ui.point[2] == WoWForeverOptions and ui.point[3] == 'BOTTOMLEFT', 'editor opens below Options')
E.Select('objectives', 'test_kill')
ui.fields.name:SetText('Unsaved name'); E.Cancel()
check(ui.fields.name.text == 'Changed creature', 'Cancel discards form edits')
ui.fields.minAmount:SetText('bad')
check(not E.Save() and D:Get('objectives', 'test_kill').minAmount == 5, 'GUI rejects invalid number atomically')
E.Cancel(); ui.fields.name:SetText('GUI name')
check(E.Save() and D:Get('objectives', 'test_kill').name == 'GUI name', 'GUI saves through shared validation')
E.RequestDelete()
check(D:Get('objectives', 'test_kill') and ui.confirmation:IsShown(), 'Delete waits for confirmation')
ui.confirmation.cancel.scripts.OnClick()
check(D:Get('objectives', 'test_kill'), 'delete cancellation keeps entry')
E.RequestDelete(); ui.confirmation.confirm.scripts.OnClick()
check(not D:Get('objectives', 'test_kill') and WoWForeverDB.activeQuest == q, 'deletion preserves active quest')
check(not addon.GenerateQuestForLevel(6, false, nil, 'kill'), 'disabled objective excluded from generator')
E.New()
ui.fields.id:SetText('gui_custom'); ui.fields.name:SetText('GUI custom objective')
ui.fields.level:SetText('1'); ui.fields.location:SetText('Test location'); ui.fields.npcID:SetText('999999')
ui.fields.requiredNPCTags:SetText('questgiver')
TestEnvironment.select(ui.fields.zone, 'Test Zone')
check(E.Save() and D:Get('objectives', 'gui_custom'), 'GUI Add stores complete new objective')
TestEnvironment.select(ui.zoneFilter, 'Test Zone')
TestEnvironment.select(ui.categoryFilter, 'Kill')
local visibleRows = 0
for _, row in ipairs(ui.rows) do
    if row:IsShown() then visibleRows = visibleRows + 1; check(row.text:find('test_kill') or row.text:find('gui_custom'), 'filters isolate selected zone/category') end
end
check(visibleRows == 2, 'list shows custom entry and disabled builtin')
check(D:Delete('objectives', 'gui_custom'), 'custom objective can be disabled')
check(D:Delete('questGivers', 'test_giver') and D:Delete('flavourText', 'test_story'), 'remove test zone dependencies')
check(D:Delete('zones', 'test_zone'), 'zone can be disabled while an accepted snapshot exists')
check(WoWForeverDB.activeQuest == q and D.zones.test_zone, 'archived zone remains accessible for active quest')
local reloaded = D.Copy(WoWForeverDB)
addon, board = TestEnvironment.load(reloaded, registerTestZone)
check(WoWForeverDB.activeQuest.amount == originalAmount and WoWForeverDB.activeQuest.progress.count == 1,
    'active snapshot survives reload after deleting source')
TestEnvironment.zone('Test Zone')
addon.Tracking.DebugAddProgress(true)
check(WoWForeverDB.activeQuest.state == 'Ready to Turn In', 'deleted source quest can still finish tracking')
-- Use the real card action: an empty edited pool must not block hand-in.
local card
for _, frame in ipairs(TestEnvironment.frames) do
    if frame.parent == board and rawget(frame, 'button') and rawget(frame, 'heading')
        and frame.heading.text == 'Test creature' then card = frame end
end
check(card ~= nil, 'active card remains visible after disabling its zone')
card.button.scripts.OnClick()
check(not WoWForeverDB.activeQuest, 'deleted source quest can still turn in through its card')
check(WoWForeverDB.statistics.handedIn == 1, 'statistics retained by database refactor')
TestEnvironment.load({activeQuest = true, zoneOffers = {unknown = 42}})
check(not WoWForeverDB.activeQuest, 'malformed legacy saved values repaired')

-- Westfall content, browser independence, and the old Supply identifier.
addon, board = TestEnvironment.load(nil)
D = addon.Database
TestEnvironment.level(12)
TestEnvironment.zone('Westfall')
TestEnvironment.professions({182, 186, 393, 356})
TestEnvironment.select(board.zoneDropdown, 'Westfall')
local counts = {kill = 0, supply = 0, hunt = 0, gather = 0}
for _, objective in ipairs(D:List('objectives')) do
    if objective.zone == 'westfall' then counts[objective.category] = counts[objective.category] + 1 end
end
check(counts.kill == 20 and counts.supply == 11 and counts.hunt == 7 and counts.gather == 14,
    'Westfall has balanced categories and two Mining work orders')
check(#WoWForeverDB.displayedQuests == 3 and WoWForeverDB.selectedZone == 'westfall', 'Westfall fills three live cards')
local seen = {}
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(not seen[offer.selectionId] and offer.zoneId == 'westfall', 'Westfall generated cards are unique and local')
    seen[offer.selectionId] = true
end
local kill = addon.GenerateQuestForLevel(12, false, nil, 'kill')
check(kill and kill.categoryName == 'Kill' and kill.tracking.targets, 'Westfall Kill generation uses registered data')
check(addon.Tracking.Accept(kill), 'Westfall kill can be accepted')
local enemy = {guid = 'Creature-0-1-0-0-454-westfall', name = kill.tracking.targets[1], dead = false,
    controlled = false, denied = false, inCombat = true, tagger = 'player'}
TestEnvironment.unit('target', enemy)
addon.Tracking.OnEvent('PLAYER_TARGET_CHANGED')
enemy.dead = true; addon.Tracking.OnEvent('UNIT_DIED', enemy.guid)
check(kill.progress.count == 1, 'tagged Westfall kill counts in Westfall')
addon.Tracking.Abandon()
local supply = addon.GenerateQuestForLevel(12, false, nil, 'supply')
check(supply and supply.categoryName == 'Supply' and supply.tracking.kind == 'supply'
    and supply.tracking.vendorID == supply.questGiverID, 'Westfall Supply selects its assigned friendly vendor')
check(addon.Tracking.Accept(supply), 'Westfall Supply accepts with vendor locked in')
local gather = addon.GenerateQuestForLevel(15, false, nil, 'gather')
check(gather and gather.professionId and gather.zoneId == 'westfall', 'Westfall Gather honours known professions')
local hunt = addon.GenerateQuestForLevel(18, false, nil, 'hunt')
check(hunt and hunt.amount == 1 and hunt.tracking.npcID, 'Westfall rare Hunt requires exactly one verified NPC')
WoWForeverDebugModeButton.scripts.OnClick()
board.debugButton.scripts.OnClick()
browser = WoWForeverQuestBrowser
for index, expected in ipairs({20, 11, 7, 14}) do
    local tab = browser.tabs[index]
    check(tab.objectiveCount == expected and tab.label.text:find('|cff999999(' .. expected .. ')', 1, true),
        'browser tab shows grey all-level Westfall objective count')
end
local mainLevel = board.debugLevelText.text
local offers = WoWForeverDB.displayedQuests
TestEnvironment.select(browser.zoneDropdown, 'Elwynn Forest')
check(WoWForeverDB.selectedZone == 'westfall' and browser.zoneDropdown.text == 'Elwynn Forest'
    and board.debugLevelText.text == mainLevel and WoWForeverDB.displayedQuests == offers,
    'browser zone changes without changing board zone, generation level, or cards')
local elwynnGatherCount = 0
for _, objective in ipairs(D:List('objectives')) do
    if objective.zone == 'elwynn' and objective.category == 'gather' then elwynnGatherCount = elwynnGatherCount + 1 end
end
check(browser.tabs[4].objectiveCount == elwynnGatherCount and elwynnGatherCount == 14,
    'browser category count refreshes when zone changes')
local initialBrowserLevel = browser.levelLabel.text
browser.levelDown.scripts.OnClick()
check(browser.levelLabel.text ~= initialBrowserLevel and board.debugLevelText.text == mainLevel
    and WoWForeverDB.displayedQuests == offers, 'browser level changes without affecting live generation')
local browserLevelText = browser.levelLabel.text
board.debugLevelUp.scripts.OnClick()
check(board.debugLevelText.text ~= mainLevel and browser.levelLabel.text == browserLevelText,
    'main debug level changes without affecting browser level')
TestEnvironment.select(board.zoneDropdown, 'Dun Morogh')
check(browser.zoneDropdown.text == 'Elwynn Forest' and browser.levelLabel.text == browserLevelText,
    'main zone changes do not move browser zone or level')
browser.testButton.scripts.OnClick()
local previewTitle = browser.preview.text:match('^Test quest: (.-) —')
local fromBrowserZone = false
for _, entry in ipairs(D:List('objectives')) do
    if entry.zone == 'elwynn' and entry.name == previewTitle then fromBrowserZone = true; break end
end
check(fromBrowserZone, 'browser test generation uses its own selected zone and level')
board.help.scripts.OnClick()
local helpText = WoWForeverHelp.message.text
check(helpText and helpText:find('|cff43bff7Spinkler|r', 1, true)
    and helpText:find('Please check back after the next turn-in.', 1, true),
    'Help keeps its original message and colours Spinkler blue')

local legacy = D.Copy(WoWForeverDB)
legacy.activeQuest = D.Copy(supply)
legacy.activeQuest.categoryName = 'Collect & Sell'
legacy.activeQuest.kind = 'Collect & Sell'
legacy.activeQuest.tracking.kind = 'collect_sell'
legacy.activeQuest.objectiveSnapshot.category = 'collect_sell'
legacy.statistics.acceptedByCategory['Collect & Sell'] = 4
legacy.statistics.completedByCategory['Collect & Sell'] = 2
legacy.statistics.abandonedByCategory['Collect & Sell'] = 3
local objective = D:Get('objectives', supply.objectiveId); objective.category = 'collect_sell'
local giver = D:Get('questGivers', supply.questGiverEntryID)
giver.categories, giver.vendor = {'collect_sell'}, true
giver.tags = nil
objective.requiredNPCTags = nil
local story
for _, entry in ipairs(D:List('flavourText')) do if entry.category == 'supply' then story = entry; break end end
story.category = 'collect_sell'
legacy.databaseOverrides.objectives = {}
legacy.databaseOverrides.questGivers = {}
legacy.databaseOverrides.flavourText = {}
legacy.databaseOverrides.objectives[objective.id] = {entry = objective}
legacy.databaseOverrides.questGivers[giver.id] = {entry = giver}
legacy.databaseOverrides.flavourText[story.id] = {entry = story}
addon, board = TestEnvironment.load(legacy)
D = addon.Database
local migratedGiver = D:Get('questGivers', giver.id)
local hasSupply = false
for _, id in ipairs(migratedGiver.tags) do if id == 'vendor' then hasSupply = true end end
check(#D.errors == 0 and D:Get('objectives', objective.id).category == 'supply'
    and hasSupply
    and D:Get('flavourText', story.id).category == 'supply',
    'old editor overrides migrate before shared validation')
check(WoWForeverDB.activeQuest.categoryName == 'Supply' and WoWForeverDB.activeQuest.tracking.kind == 'supply'
    and WoWForeverDB.activeQuest.tracking.vendorID == supply.questGiverID,
    'old active Supply quest keeps its assigned vendor')
check(WoWForeverDB.statistics.acceptedByCategory.Supply == 5
    and WoWForeverDB.statistics.completedByCategory.Supply == 2
    and WoWForeverDB.statistics.abandonedByCategory.Supply == 3
    and WoWForeverDB.statistics.acceptedByCategory['Collect & Sell'] == nil,
    'old statistics merge into Supply without losing counts')
check(WoWForeverDB.databaseOverrides.objectives[objective.id].entry.category == 'supply',
    'saved override is rewritten to the stable new identifier')
-- Darkshore uses the same data-driven generation and tracking path.
addon, board = TestEnvironment.load(nil)
D = addon.Database
TestEnvironment.zone('Darkshore')
TestEnvironment.level(16)
TestEnvironment.professions({182, 186, 393, 356})
TestEnvironment.select(board.zoneDropdown, 'Darkshore')
local darkCounts = {kill = 0, supply = 0, hunt = 0, gather = 0}
local darkProfessions = {herbalism = 0, mining = 0, skinning = 0, fishing = 0}
for _, entry in ipairs(D:List('objectives')) do
    if entry.zone == 'darkshore' then
        darkCounts[entry.category] = darkCounts[entry.category] + 1
        if entry.profession then darkProfessions[entry.profession] = darkProfessions[entry.profession] + 1 end
        check(entry.minPlayerLevel < entry.maxPlayerLevel and entry.minAmount <= entry.maxAmount,
            'Darkshore objective has a usable multi-level band and amount range')
        if entry.category == 'hunt' then
            check(entry.minAmount == 1 and entry.maxAmount == 1
                and entry.minPlayerLevel == tonumber(entry.level) - 2,
                'Darkshore rare Hunt is one kill and unlocks two levels early')
        end
    end
end
check(darkCounts.kill == 20 and darkCounts.supply == 11 and darkCounts.hunt == 7
    and darkCounts.gather == 15, 'Darkshore has balanced objectives and three Mining work orders')
check(darkProfessions.herbalism == 4 and darkProfessions.mining == 6
    and darkProfessions.skinning == 3 and darkProfessions.fishing == 2,
    'Darkshore covers all four gathering professions')
check(#WoWForeverDB.displayedQuests == 3 and WoWForeverDB.selectedZone == 'darkshore',
    'Darkshore fills three cards through the registered zone dropdown')
local darkSeen = {}
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(offer.zoneId == 'darkshore' and not darkSeen[offer.selectionId],
        'Darkshore cards stay local and do not duplicate objectives')
    darkSeen[offer.selectionId] = true
end
for _, testLevel in ipairs({10, 16, 22}) do
    local excluded, found = {}, 0
    for _ = 1, 60 do
        local offer = addon.GenerateQuestForLevel(testLevel, false, excluded)
        if not offer then break end
        check(offer.zoneId == 'darkshore' and offer.minPlayerLevel <= testLevel
            and offer.maxPlayerLevel >= testLevel and not excluded[offer.selectionId],
            'Darkshore level filtering uses each objective player band')
        excluded[offer.selectionId] = true
        found = found + 1
    end
    check(found >= 3, 'Darkshore has three or more objectives at early, middle, and late levels')
end
local darkKill = addon.GenerateQuestForLevel(16, false, nil, 'kill')
check(darkKill and addon.Tracking.Accept(darkKill), 'Darkshore Kill accepts through normal tracking')
local darkEnemy = {guid = 'Creature-0-1-0-0-2207-darkshore', name = darkKill.tracking.targets[1],
    dead = false, controlled = false, denied = false, inCombat = true, tagger = 'player'}
TestEnvironment.unit('target', darkEnemy)
addon.Tracking.OnEvent('PLAYER_TARGET_CHANGED')
darkEnemy.dead = true; addon.Tracking.OnEvent('UNIT_DIED', darkEnemy.guid)
check(darkKill.progress.count == 1, 'tagged Darkshore kill advances the active quest')
addon.Tracking.Abandon()
local darkSupply = addon.GenerateQuestForLevel(16, false, nil, 'supply')
check(darkSupply and darkSupply.tracking.vendorID == darkSupply.questGiverID
    and darkSupply.tracking.kind == 'supply', 'Darkshore Supply locks to an actual assigned merchant')
TestEnvironment.professions({})
check(not addon.GenerateQuestForLevel(16, false, nil, 'gather'),
    'Darkshore Gather still requires a learned profession')
TestEnvironment.professions({182, 186, 393, 356})
local darkGather = addon.GenerateQuestForLevel(16, false, nil, 'gather')
check(darkGather and darkGather.professionId and darkGather.zoneId == 'darkshore',
    'Darkshore learned profession generates local resources')
local darkHunt = addon.GenerateQuestForLevel(16, false, nil, 'hunt')
check(darkHunt and darkHunt.amount == 1 and darkHunt.tracking.npcID,
    'Darkshore named rare uses one tracked creature ID')
WoWForeverDebugModeButton.scripts.OnClick()
board.debugButton.scripts.OnClick()
local darkBrowser = WoWForeverQuestBrowser
check(darkBrowser.zoneDropdown.text == 'Darkshore', 'Quest Browser opens on the registered Darkshore zone')
for index, expected in ipairs({20, 11, 7, 15}) do
    check(darkBrowser.tabs[index].objectiveCount == expected,
        'Quest Browser tab counts Darkshore objectives in each category')
end
TestEnvironment.select(darkBrowser.zoneDropdown, 'Elwynn Forest')
check(darkBrowser.zoneDropdown.text == 'Elwynn Forest' and WoWForeverDB.selectedZone == 'darkshore'
    and darkBrowser.tabs[4].objectiveCount == 14,
    'Quest Browser can inspect another zone without changing the Darkshore board')

-- The optional PvP notice is a fourth card, not one of the three zone offers.
addon, board = TestEnvironment.load(nil)
local originalOffers = WoWForeverDB.displayedQuests
TestEnvironment.flag(true)
local pvpCard
for _, frame in ipairs(TestEnvironment.frames) do
    if frame.parent == board and rawget(frame, 'heading') and frame.heading.text == 'Honorable Combat' then
        pvpCard = frame; break
    end
end
check(pvpCard and pvpCard:IsShown() and board:GetWidth() == 1108
    and WoWForeverDB.displayedQuests == originalOffers,
    'PvP flag reveals an independent card beside unchanged zone offers')
local pvpOffer = WoWForeverDB.pvpQuest
pvpCard.button.scripts.OnClick()
check(WoWForeverDB.activeQuest == pvpOffer and pvpOffer.tracking.kind == 'pvp_honor',
    'PvP card accepts through the normal one-active-quest flow')
for _ = 1, pvpOffer.amount do
    TestEnvironment.honorKill()
    addon.Tracking.OnEvent('PLAYER_PVP_KILLS_CHANGED', 'player')
end
check(pvpOffer.state == 'Ready to Turn In' and pvpCard.button.text == 'Turn In Quest',
    'honorable kill credit makes the PvP card ready')
pvpCard.button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and WoWForeverDB.pvpQuest ~= pvpOffer
    and WoWForeverDB.displayedQuests == originalOffers,
    'PvP turn-in replaces only its own card')
local pvpStatistics = addon.Tracking.GetStatistics()
check(pvpStatistics.acceptedByCategory.PvP == 1
    and pvpStatistics.completedByCategory.PvP == 1,
    'accepted and handed-in PvP quests appear in their own statistics category')
pvpCard.button.scripts.OnClick()
TestEnvironment.flag(false)
check(not pvpCard:IsShown() and board:GetWidth() == 840 and board.pvpAbandon:IsShown(),
    'unflagging hides the card but leaves an abandon action for the active PvP quest')
board.pvpAbandon.scripts.OnClick()
WoWForeverAbandonDialog.confirm.scripts.OnClick()
check(not WoWForeverDB.activeQuest and WoWForeverDB.pvpQuest
    and WoWForeverDB.displayedQuests == originalOffers,
    'abandoning hidden PvP quest keeps the normal three offers')
check(addon.Tracking.GetStatistics().abandonedByCategory.PvP == 1,
    'abandoned PvP quests appear in their own statistics category')
addon, board = TestEnvironment.load(nil)
TestEnvironment.professions({186}, {1})
TestEnvironment.select(board.zoneDropdown, 'Westfall')
local function workOrderPool()
    local excluded, result = {}, {}
    for _ = 1, 80 do
        local offer = addon.GenerateQuestForLevel(18, false, excluded, 'gather')
        if not offer then break end
        excluded[offer.selectionId] = true
        if offer.tracking.kind == 'mining_workorder' then result[offer.objectiveId] = offer end
    end
    return result
end
local lowSkill = workOrderPool()
check(lowSkill.wf_copper_bar_workorder and not lowSkill.wf_tin_bar_workorder,
    'Tin work order stays hidden below Mining skill 65')
TestEnvironment.professions({186}, {65})
local highSkill = workOrderPool()
check(highSkill.wf_copper_bar_workorder and highSkill.wf_tin_bar_workorder,
    'Tin work order appears once Mining skill reaches 65')
print('PASS: ' .. count .. ' database, override, editor and new-zone assertions (Lua 5.1)')
