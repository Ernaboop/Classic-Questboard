local interfaceVersion, restrictedCombat = 11507, false
function GetBuildInfo() return "test", "1", "date", interfaceVersion end
C_CombatLog = {IsCombatLogRestricted = function() return restrictedCombat end}
local passed = 0
local function check(value, message)
    assert(value, message)
    passed = passed + 1
end
local clock, timers, resting, zone, bags, money, buybacks, lootItems, combat, level
local professionSlots, professionLines = {}, {}
local units, hooks, frames = {}, {}, {}
local function object(name, parent)
    local o = {scripts = {}, registered = {}, shown = true, parent = parent, name = name, width = 32, height = 32}
    setmetatable(o, {__index = function(_, key) return function() end end})
    function o:SetScript(k, fn) self.scripts[k] = fn end
    function o:HookScript(k, fn)
        local before = self.scripts[k]
        self.scripts[k] = function(...) if before then before(...) end; fn(...) end
    end
    function o:HasScript() return true end
    function o:GetName() return self.name end
    function o:SetChecked(v) self.checked = not not v end
    function o:GetChecked() return self.checked end
    function o:RegisterEvent(e)
        if e == 'COMBAT_LOG_EVENT_UNFILTERED' and (restrictedCombat or interfaceVersion == 16001 or interfaceVersion >= 120000) then
            error('ADDON_ACTION_FORBIDDEN: forbidden combat-log registration')
        end
        self.registered[e] = true
    end
    function o:UnregisterEvent(e) self.registered[e] = nil end
    function o:SetText(text) self.text = text end
    function o:SetSize(w, h) self.width, self.height = w, h end
    function o:SetHeight(h) self.height = h end
    function o:SetWidth(w) self.width = w end
    function o:GetWidth() return self.width end
    function o:GetHeight() return self.height end
    function o:SetEnabled(v) self.enabled = not not v end
    function o:SetShown(v) self.shown = not not v end
    function o:Show() self.shown = true end
    function o:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
    function o:IsShown() return self.shown end
    function o:SetFrameLevel(v) self.frameLevel = v end
    function o:SetAlpha(v) self.alpha = v end
    function o:SetVertexColor(...) self.vertexColor = {...} end
    function o:GetFrameLevel() return rawget(self, 'frameLevel') or 1 end
    function o:CreateTexture() return object(nil, self) end
    function o:CreateMaskTexture() return object(nil, self) end
    function o:CreateFontString() return object(nil, self) end
    return o
end
function CreateFrame(_, name, parent)
    local o = object(name, parent)
    frames[#frames + 1] = o
    if name then _G[name] = o end
    return o
end
UIParent = object(); UIParent:SetSize(1920, 1080)
Minimap = object(); Minimap:SetSize(140, 140)
UISpecialFrames, SlashCmdList, GameTooltip = {}, {}, object('GameTooltip')
local tooltipLines, tooltipUnit = {}, nil
function GameTooltip:GetUnit() return nil, tooltipUnit end
function GameTooltip:NumLines() return #tooltipLines end
function GameTooltip:AddLine(value)
    local line = object(); line:SetText(value)
    tooltipLines[#tooltipLines + 1] = line
    _G['GameTooltipTextLeft' .. #tooltipLines] = line
end
C_Timer = {After = function(delay, fn) timers[#timers + 1] = {at = clock + delay, fn = fn} end}
local function advance(seconds)
    clock = clock + seconds
    local pending = timers; timers = {}
    for _, timer in ipairs(pending) do
        if timer.at <= clock then timer.fn() else timers[#timers + 1] = timer end
    end
end
function GetTime() return clock end
function time() return 100000 + clock end
function IsResting() return resting end
function GetRealZoneText() return zone end
function UnitGUID(unit) return units[unit] and units[unit].guid end
function UnitName(unit) return units[unit] and units[unit].name end
function UnitLevel() return level end
function UnitExists(unit) return units[unit] ~= nil end
function UnitIsDead(unit) return units[unit] and units[unit].dead end
function UnitPlayerControlled(unit) return units[unit] and units[unit].controlled end
function UnitIsTapDenied(unit) return units[unit] and units[unit].denied end
function UnitAffectingCombat(unit) return units[unit] and units[unit].inCombat end
function UnitIsUnit(a, b) return units[a] ~= nil and units[b] ~= nil and units[a].guid == units[b].guid end
function GetProfessions() return unpack(professionSlots) end
function GetProfessionInfo(index) return nil, nil, nil, nil, nil, nil, professionLines[index] end
function GetMoney() return money end
function CombatLogGetCurrentEventInfo() return unpack(combat, 1, 11) end
function GetNumLootItems() return #lootItems end
function GetLootSlotLink(slot) return lootItems[slot] and ('item:' .. lootItems[slot].id) end
function GetLootSourceInfo(slot) return lootItems[slot].guid, lootItems[slot].quantity end
function GetNumBuybackItems() return #buybacks end
function GetBuybackItemLink(slot) return 'item:' .. buybacks[slot].id end
function GetBuybackItemInfo(slot) return nil, 'loot', 10 * buybacks[slot].quantity, buybacks[slot].quantity end
C_Item = {
    GetItemCount = function(id) return bags[id] or 0 end,
    GetItemInfo = function(id) return 'item', nil, 1, 1, 1, nil, nil, nil, nil, nil, 10 end,
}
local spellNames = {[2366] = 'Herbalism', [2575] = 'Mining', [8613] = 'Skinning', [7620] = 'Fishing'}
C_Spell = {GetSpellInfo = function(id) return {name = spellNames[id]} end}
C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and 1 or 0 end,
    GetContainerItemLink = function() return 'item:2672' end,
    UseContainerItem = function(bag, slot) if hooks.UseContainerItem then hooks.UseContainerItem(bag, slot) end end,
}
function hooksecurefunc(t, key, fn)
    if type(t) == 'table' then hooks[key] = fn else hooks[t] = key end
end
LOOT_ITEM_SELF = "You receive loot: %s."
LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d."
local ns = {}
assert(loadstring(tracking_source))('WoWForever', ns)
local T = ns.Tracking
local saved
local function fresh()
    clock, timers, resting, zone, bags, money, buybacks, lootItems, level = 0, {}, true, 'Elwynn Forest', {}, 100, {}, {}, 6
    units = {player = {guid = 'Player-1', name = 'Tester'}, pet = {guid = 'Pet-1', name = 'Pet'}}
    professionSlots, professionLines = {}, {}
    saved = {}
    T.Initialize(saved, function(q) return q.tracking end, function() end)
    T.OnEvent('PLAYER_ENTERING_WORLD')
end
local function quest(spec, amount)
    return {id = 'test', title = 'Test', zone = 'Elwynn Forest', amount = amount or 2, tracking = spec}
end
local function killGUID(guid) return 'Creature-0-1-0-0-40-' .. guid:gsub('%W', '') end
local function hit(guid, name, source)
    units.target = {guid = killGUID(guid), name = name, dead = false, controlled = false,
        denied = source == 'Stranger', inCombat = true}
    T.OnEvent('PLAYER_TARGET_CHANGED')
end
local function die(guid, name)
    local id = killGUID(guid)
    if units.target and units.target.guid == id then units.target.dead = true end
    T.OnEvent('UNIT_DIED', id)
end
local function lootStart(id, quantity, guid, name)
    units.target = {guid = guid, name = name}
    lootItems = {{id = id, quantity = quantity, guid = guid}}
    T.OnEvent('LOOT_READY'); T.OnEvent('LOOT_OPENED')
end
local function receive(id, count)
    bags[id] = (bags[id] or 0) + count
    T.OnEvent('CHAT_MSG_LOOT', 'You receive loot: item:' .. id .. 'x' .. count .. '.')
    T.OnEvent('LOOT_SLOT_CLEARED', 1)
    T.OnEvent('BAG_UPDATE_DELAYED')
    T.OnEvent('LOOT_CLOSED'); lootItems = {}
    advance(1)
end
fresh()
local q = quest({kind = 'kill', targets = {'Kobold Miner'}})
resting = false
check(not T.Accept(q) and not saved.activeQuest, 'acceptance must require rest')
resting = true; check(T.Accept(q), 'accept in rest area')
resting = false
hit('Creature-1', 'Wolf'); die('Creature-1', 'Wolf')
hit('Creature-2', 'Kobold Miner', 'Stranger'); die('Creature-2', 'Kobold Miner')
check(q.progress.count == 0, 'unrelated and bystander kills excluded')
hit('Creature-3', 'Kobold Miner'); die('Creature-3', 'Kobold Miner'); die('Creature-3', 'Kobold Miner')
check(q.progress.count == 1, 'one kill counted once outside rest')
zone = 'Westfall'; hit('Creature-4', 'Kobold Miner'); die('Creature-4', 'Kobold Miner')
check(q.progress.count == 1, 'wrong-zone kills excluded')
zone = 'Elwynn Forest'; hit('Creature-5', 'Kobold Miner', 'Pet-1'); die('Creature-5', 'Kobold Miner')
check(q.state == 'Ready to Turn In' and saved.activeQuest == q and #saved.completedQuests == 0, 'ready never automatically completes')
check(not T.TurnIn(), 'turn-in outside rest denied')
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(q.state == 'Ready to Turn In' and q.progress.count == 2, 'ready/progress survive reload')
resting = true; check(T.TurnIn(), 'manual rested turn-in')
check(not saved.activeQuest and saved.completedQuests[1].state == 'Completed', 'completion retained and active cleared')
check(not T.TurnIn(), 'turn-in cannot be repeated')

fresh(); resting = false
q = quest({kind = 'kill', targets = {'Kobold Miner'}})
check(T.Accept(q, true), 'debug location override permits acceptance outside rest')
q.state = 'Ready to Turn In'; q.progress.count = q.amount
check(T.TurnIn(true), 'debug location override permits turn-in outside rest')
check(not saved.activeQuest and saved.completedQuests[1].state == 'Completed', 'debug location override preserves normal completion state')

fresh(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
bags[2672] = 10; T.OnEvent('BAG_UPDATE_DELAYED')
check(q.progress.collected == 0, 'existing or purchased inventory not credited')
lootStart(2672, 2, 'Creature-wrong', 'Kobold Miner'); receive(2672, 2)
check(q.progress.collected == 0, 'wrong corpse excluded')
lootStart(769, 2, 'Creature-wolf', 'Young Wolf'); receive(769, 2)
check(q.progress.collected == 0, 'wrong item excluded')
lootStart(2672, 2, 'Creature-wolf2', 'Young Wolf'); receive(2672, 2)
check(q.progress.collected == 2 and q.progress.sold == 0 and q.state == 'Active', 'collection requires later sale')
T.OnEvent('MERCHANT_SHOW'); bags[2672] = bags[2672] - 2
T.OnEvent('BAG_UPDATE_DELAYED') -- client can deliver bag changes before money/buyback
money = money + 20; buybacks = {{id = 2672, quantity = 2}}
T.OnEvent('MERCHANT_UPDATE'); T.OnEvent('MERCHANT_CLOSED'); advance(1)
check(q.progress.sold == 2 and q.state == 'Ready to Turn In', 'sale requires bag, buyback, and money evidence, including close race')

fresh(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
lootStart(2672, 2, 'Creature-wolf', 'Young Wolf'); receive(2672, 2)
T.OnEvent('MERCHANT_SHOW'); bags[2672] = 0; T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.sold == 0 and q.progress.held[2672] == 0, 'destroyed/traded items are not sales')
T.OnEvent('MERCHANT_CLOSED'); advance(1)
bags[2672] = 2; T.OnEvent('BAG_UPDATE_DELAYED'); T.OnEvent('MERCHANT_SHOW')
bags[2672] = 0; money = 120; buybacks = {{id = 2672, quantity = 2}}
T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.sold == 0, 'replacement purchased items do not regain eligible balance')

fresh(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
lootStart(2672, 2, 'Creature-wolf', 'Young Wolf'); receive(2672, 2)
buybacks = {{id = 2672, quantity = 2}}; T.OnEvent('MERCHANT_SHOW')
C_Container.UseContainerItem(0, 1); bags[2672] = 0; money = money + 20
T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.sold == 2, 'identical stack replacing a full buyback list still credits an observed sale')

for _, case in ipairs({{'herbalism', 2447, 2366}, {'mining', 2770, 2575}, {'skinning', 2318, 8613}, {'fishing', 6291, 7620}}) do
    fresh(); local profession, id, spell = unpack(case)
    q = quest({kind = 'gather', profession = profession, itemID = id}, 3); T.Accept(q)
    local guid = profession == 'skinning' and 'Creature-beast' or 'GameObject-node'
    lootStart(id, 3, guid, 'Wolf'); receive(id, 3)
    check(q.progress.count == 0, profession .. ': loot without gathering action excluded')
    T.OnEvent(profession == 'fishing' and 'UNIT_SPELLCAST_CHANNEL_START' or 'UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', spell)
    lootStart(id, 3, guid, 'Wolf'); receive(id, 3)
    check(q.progress.count == 3 and q.state == 'Ready to Turn In', profession .. ': matching gathered item counted')
end
fresh(); q = quest({kind = 'nodes', profession = 'mining', itemID = 2770}, 2); T.Accept(q)
for _, guid in ipairs({'GameObject-copper1', 'GameObject-copper1', 'GameObject-copper2'}) do
    T.OnEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', 2575)
    lootStart(2770, 4, guid); receive(2770, 4)
end
check(q.progress.count == 2, 'veins counted by distinct source, not ore stack size')
fresh(); q = quest({kind = 'kill', targets = {'Hogger'}}, 1); saved.activeQuest = q
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(q.state == 'Active' and q.progress.count == 0 and q.amount == 1, 'legacy active quest upgraded without changing amount')
T.Abandon(); die('Creature-old', 'Hogger')
check(not saved.activeQuest, 'abandoned quest no longer tracks')

fresh(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
lootStart(2672, 2, 'Creature-wolf', 'Young Wolf')
T.OnEvent('LOOT_SLOT_CLEARED', 1)
bags[2672] = 2
T.OnEvent('CHAT_MSG_LOOT', 'Someone receives loot: item:2672x2.')
T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.collected == 0, 'other-player receipt plus unrelated bag gain cannot count')
T.OnEvent('CHAT_MSG_LOOT', 'You receive loot: item:2672x2.')
T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.collected == 2 and q.progress.held[2672] == 2, 'self receipt confirms source-matched loot once')
T.OnEvent('LOOT_SLOT_CLEARED', 1); T.OnEvent('CHAT_MSG_LOOT', 'You receive loot: item:2672x2.')
T.OnEvent('BAG_UPDATE_DELAYED'); advance(1)
check(q.progress.held[2672] == 2, 'repeated receipt and cleared events cannot duplicate credit')

fresh(); q = quest({kind = 'gather', profession = 'herbalism', itemID = 2447}, 2); T.Accept(q)
T.OnEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', 2366)
lootStart(2447, 2, 'GameObject-herb'); T.OnEvent('LOOT_SLOT_CLEARED', 1); T.OnEvent('LOOT_CLOSED')
advance(1)
check(q.progress.count == 0, 'cleared slot without inventory receipt does not count')
bags[2447] = 2; T.OnEvent('CHAT_MSG_LOOT', 'You receive loot: item:2447x2.')
T.OnEvent('BAG_UPDATE_DELAYED')
check(q.progress.count == 2, 'delayed receipt after loot window closes is counted')

fresh(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
bags[2672] = 100
lootStart(2672, 2, 'Creature-wolf', 'Young Wolf'); receive(2672, 2)
bags[2672] = 100; T.OnEvent('BAG_UPDATE_DELAYED')
check(q.progress.held[2672] == 0, 'banking loses sale eligibility even with an existing stockpile')

-- Exercise real generator/UI wiring with mocked WoW frame APIs.
fresh(); local realNS = {}
assert(loadstring(tracking_source))('WoWForever', realNS)
assert(loadstring(board_source))('WoWForever', realNS)
local outleveledSeen = {}
for _ = 1, 1200 do
    local offer = realNS.GenerateQuestForLevel(12, true)
    outleveledSeen[offer.categoryName] = true
    if offer.categoryName == 'Kill' or offer.categoryName == 'Collect & Sell' then
        check(offer.maxPlayerLevel == 10, offer.categoryName .. ' uses its own highest level band')
    elseif offer.categoryName == 'Hunt' then
        check(offer.maxPlayerLevel == 12, 'Hunt uses its own highest level band')
    end
end
check(outleveledSeen.Kill and outleveledSeen['Collect & Sell'] and outleveledSeen.Hunt,
    'outleveled generation retains every non-profession category')
check(not outleveledSeen.Gather, 'unlearned gathering professions remain excluded when outleveled')
professionSlots, professionLines = {1}, {[1] = 182}
local sawHerbalism = false
for _ = 1, 1200 do
    local offer = realNS.GenerateQuestForLevel(12, true)
    if offer.professionId then
        check(offer.professionId == 'herbalism' and offer.maxPlayerLevel == 12,
            'learned gathering profession uses its own highest level band')
        sawHerbalism = true
    end
end
check(sawHerbalism, 'learned gathering profession contributes to outleveled generation')
professionSlots, professionLines = {}, {}
-- Enumerate the entire pool through exclusions: no chance-based coverage and
-- no outleveled flag, matching capped normal and debug generation paths.
local function enumeratePool(generationLevel)
    local excluded, categories, professions = {}, {}, {}
    for _ = 1, 100 do
        local offer = realNS.GenerateQuestForLevel(generationLevel, false, excluded)
        if not offer then return categories, professions end
        check(not excluded[offer.selectionId], 'enumeration respects objective exclusions')
        excluded[offer.selectionId] = true
        categories[offer.categoryName] = true
        if offer.professionId then professions[offer.professionId] = true end
        local ceiling = offer.categoryName == 'Kill' or offer.categoryName == 'Collect & Sell'
            or offer.professionId == 'skinning'
        if generationLevel >= 11 then
            check(offer.maxPlayerLevel == (ceiling and 10 or 12), 'fallback uses category highest pool at capped levels')
        else
            check(offer.minPlayerLevel <= generationLevel and offer.maxPlayerLevel >= generationLevel,
                'fallback never promotes low-level players into higher bands')
        end
    end
    error('pool enumeration did not terminate')
end
for _, generationLevel in ipairs({1, 6, 11, 12}) do
    local categories = enumeratePool(generationLevel)
    check(categories.Kill and categories['Collect & Sell'], 'normal/debug level retains lower-ceiling categories')
    check(not categories.Gather, 'category fallback preserves profession gating')
end
professionSlots, professionLines = {1, 2, 3, 4}, {[1] = 182, [2] = 186, [3] = 393, [4] = 356}
for _, generationLevel in ipairs({11, 12}) do
    local categories, professions = enumeratePool(generationLevel)
    check(categories.Kill and categories['Collect & Sell'] and categories.Hunt and categories.Gather,
        'each category contributes independently at zone cap')
    check(professions.herbalism and professions.mining and professions.skinning and professions.fishing,
        'each learned profession contributes even below zone cap')
end
professionSlots, professionLines = {}, {}
WoWForeverDB = nil
for _, frame in ipairs(frames) do
    if frame.registered.ADDON_LOADED then frame.scripts.OnEvent(frame, 'ADDON_LOADED', 'WoWForever') end
end
SlashCmdList.WOWFOREVERQUESTBOARD('')
local board = WoWForeverQuestboard
local function cards()
    local result = {}
    for _, frame in ipairs(frames) do if frame.parent == board and rawget(frame, 'heading') then result[#result + 1] = frame end end
    return result
end
local cs = cards()
-- Exercise the actual debug selector and Reroll button at the zone cap.
WoWForeverDebugModeButton.scripts.OnClick()
for _ = 1, 6 do board.debugLevelUp.scripts.OnClick() end
local debugCategories = {}
for _ = 1, 60 do
    board.reroll.scripts.OnClick()
    local ids = {}
    for _, offer in ipairs(WoWForeverDB.displayedQuests) do
        debugCategories[offer.categoryName] = true
        check(not ids[offer.selectionId], 'debug cap reroll has no duplicate objectives')
        ids[offer.selectionId] = true
    end
end
check(debugCategories.Kill and debugCategories['Collect & Sell'] and debugCategories.Hunt,
    'debug level 12 rerolls include lower-ceiling categories')
for _ = 1, 6 do board.debugLevelDown.scripts.OnClick() end
WoWForeverDebugModeButton.scripts.OnClick()
board.reroll.scripts.OnClick()
assert(loadstring(binding_source))()
check(not board:IsShown(), 'configured binding closes an open board')
assert(loadstring(binding_source))()
check(board:IsShown(), 'configured binding opens a closed board')
check(#WoWForeverDB.displayedQuests == 3 and #cs == 3, 'three offers and three cards')
local seen = {}
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(not seen[offer.selectionId], 'unique objective offers'); seen[offer.selectionId] = true
end
resting = false; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
check(not cs[1].button.enabled and board.note.text:find('Visit an inn'), 'outside-rest UI explains and disables acceptance')
cs[1].button.scripts.OnClick(); check(not WoWForeverDB.activeQuest, 'callback also guards rest restriction')
resting = true; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
-- Accept the middle card, cancel first, then confirm with a saved opt-out.
local beforeAbandon = {unpack(WoWForeverDB.displayedQuests)}
cs[2].button.scripts.OnClick()
local pending = WoWForeverDB.activeQuest
cs[2].button.scripts.OnClick()
local dialog = WoWForeverAbandonDialog
check(dialog:IsShown() and WoWForeverDB.activeQuest == pending, 'abandon waits for confirmation')
dialog.skip:SetChecked(true); dialog.cancel.scripts.OnClick()
check(WoWForeverDB.activeQuest == pending and WoWForeverDB.settings.showAbandonConfirmation,
    'cancel preserves active quest and does not save opt-out')
cs[2].button.scripts.OnClick(); dialog.skip:SetChecked(true); dialog.confirm.scripts.OnClick()
check(not WoWForeverDB.activeQuest and not WoWForeverDB.settings.showAbandonConfirmation,
    'confirmed opt-out is saved')
for i = 1, 3 do check(WoWForeverDB.displayedQuests[i] == beforeAbandon[i], 'abandon preserves every offer identity and slot') end
cs[2].button.scripts.OnClick(); cs[2].button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and not dialog:IsShown(), 'saved preference skips confirmation')
board.options.scripts.OnClick()
WoWForeverOptions.confirmation:SetChecked(true)
WoWForeverOptions.confirmation.scripts.OnClick(WoWForeverOptions.confirmation)
check(WoWForeverDB.settings.showAbandonConfirmation, 'options re-enables abandon confirmation')
cs[1].button.scripts.OnClick()
local active = WoWForeverDB.activeQuest
check(active and cs[1].button.text == 'Abandon Quest' and not board.reroll.enabled, 'acceptance starts tracking and locks reroll')
local originalOffers = WoWForeverDB.displayedQuests
board.reroll.scripts.OnClick(); check(WoWForeverDB.displayedQuests == originalOffers, 'reroll handler cannot replace active offers')
check(not cs[2].button.enabled, 'other cards unavailable')
active.state = 'Ready to Turn In'; active.progress.count = active.amount; active.progress.sold = active.amount
realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
check(cs[1].button.text == 'Turn In Quest' and cs[1].abandon.shown, 'ready card offers manual turn-in and abandonment')
resting = false; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING'); cs[1].button.scripts.OnClick()
check(WoWForeverDB.activeQuest == active, 'ready card cannot turn in outside rest')
resting = true; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING'); cs[1].button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and board.reroll.enabled and #WoWForeverDB.completedQuests == 1, 'manual turn-in returns to three selectable cards')
check(WoWForeverDB.displayedQuests == originalOffers and originalOffers[1] ~= active
    and originalOffers[2] == beforeAbandon[2] and originalOffers[3] == beforeAbandon[3],
    'turn-in replaces only completed slot and preserves other offer objects')
check(originalOffers[1].selectionId ~= originalOffers[2].selectionId
    and originalOffers[1].selectionId ~= originalOffers[3].selectionId, 'replacement excludes other displayed objectives')
WoWForeverDebugModeButton.scripts.OnClick(); board.debugLevelDown.scripts.OnClick()
check(WoWForeverDB.displayedQuests == originalOffers, 'debug mode and level changes never reroll existing offers')
board.reroll.scripts.OnClick()
check(WoWForeverDebugModeButton.active.shown and WoWForeverDebugModeButton.active.alpha <= 0.5,
    'debug icon shows a restrained active highlight')
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(offer.minPlayerLevel <= 5 and offer.maxPlayerLevel >= 5, 'debug level feeds actual generator')
end
resting = false; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
check(cs[1].button.enabled and board.note.text:find('Debug Mode'), 'debug UI bypasses acceptance location only')
cs[1].button.scripts.OnClick()
local persistent = WoWForeverDB.activeQuest
persistent.progress.count = 1
local persistentOffers = WoWForeverDB.displayedQuests
WoWForeverDebugModeButton.scripts.OnClick()
check(not WoWForeverDebugModeButton.active.shown, 'debug highlight clears immediately when disabled')
check(WoWForeverDB.activeQuest == persistent and persistent.progress.count == 1 and WoWForeverDB.displayedQuests == persistentOffers,
    'toggling debug preserves active progress and offers')
local function clone(t)
    if type(t) ~= 'table' then return t end
    local out = {}; for key, value in pairs(t) do out[key] = clone(value) end; return out
end
WoWForeverDB.settings.showAbandonConfirmation = false
WoWForeverDB = clone(WoWForeverDB) -- SavedVariables reload recreates independent tables.
local reloadNS = {}
assert(loadstring(tracking_source))('WoWForever', reloadNS)
assert(loadstring(board_source))('WoWForever', reloadNS)
for _, frame in ipairs(frames) do
    if frame.registered.ADDON_LOADED then frame.scripts.OnEvent(frame, 'ADDON_LOADED', 'WoWForever') end
end
check(WoWForeverDB.activeQuest.id == persistent.id and WoWForeverDB.activeQuest.amount == persistent.amount
    and WoWForeverDB.activeQuest.progress.count == 1, 'real saved-state migration preserves identity, amount, and progress')
SlashCmdList.WOWFOREVERQUESTBOARD('')
local reloadedCard
for _, frame in ipairs(frames) do
    if frame.parent == WoWForeverQuestboard and rawget(frame, 'heading') and frame.heading.text == persistent.title then reloadedCard = frame end
end
check(reloadedCard and reloadedCard.prompt.text:find('Active'), 'reloaded active card renders authoritative saved state')
check(not WoWForeverDB.settings.showAbandonConfirmation, 'disabled confirmation survives saved-variable reload')
-- All card positions, including separate active/offer tables after reload.
local reloadedCards = {}
for _, frame in ipairs(frames) do
    if frame.parent == WoWForeverQuestboard and rawget(frame, 'heading') then reloadedCards[#reloadedCards + 1] = frame end
end
reloadedCard.button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and not WoWForeverDB.displayedQuests[1].progress,
    'abandon after reload clears saved offer progress without replacing it')
resting = true; level = 6
for slot = 2, 3 do
    local keptOffers = {unpack(WoWForeverDB.displayedQuests)}
    reloadedCards[slot].button.scripts.OnClick()
    local selected = WoWForeverDB.activeQuest
    selected.state = 'Ready to Turn In'; selected.progress.count = selected.amount; selected.progress.sold = selected.amount
    reloadedCards[slot].button.scripts.OnClick()
    check(not WoWForeverDB.activeQuest and WoWForeverDB.displayedQuests[slot] ~= keptOffers[slot], 'turn-in replaces the selected non-first slot')
    for other = 1, 3 do
        if other ~= slot then check(WoWForeverDB.displayedQuests[other] == keptOffers[other], 'non-completed slot stays untouched') end
    end
end
WoWForeverDebugModeButton.scripts.OnClick()
local debugKill
for _ = 1, 100 do
    local candidate = reloadNS.GenerateQuestForLevel(1, false)
    if candidate.categoryName == 'Kill' then debugKill = candidate; break end
end
assert(debugKill)
WoWForeverDB.displayedQuests[2] = debugKill
reloadedCards[2].button.scripts.OnClick()
check(WoWForeverQuestboard.debugProgress.enabled and WoWForeverQuestboard.debugProgress.shown, 'debug Kill progress control is available')
WoWForeverQuestboard.debugProgress.scripts.OnClick()
check(debugKill.progress.count == 1, 'debug button reaches tracking increment logic')
WoWForeverDebugModeButton.scripts.OnClick()
WoWForeverQuestboard.debugProgress.scripts.OnClick()
check(not WoWForeverQuestboard.debugProgress.shown and debugKill.progress.count == 1, 'hidden debug control cannot increment')
-- Debug increment is limited to Kill category and uses the normal ready state.
fresh(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 2); q.categoryName = 'Kill'; T.Accept(q)
check(not T.DebugAddKillProgress(false) and q.progress.count == 0, 'debug increment denied with mode off')
check(T.DebugAddKillProgress(true) and q.progress.count == 1, 'debug increment adds one kill')
check(T.DebugAddKillProgress(true) and q.state == 'Ready to Turn In' and saved.activeQuest == q,
    'debug completion becomes ready without auto turn-in')
check(not T.DebugAddKillProgress(true) and q.progress.count == 2, 'debug count cannot exceed objective amount')
units.mouseover = {name = 'Kobold Miner', guid = killGUID('tooltip'), controlled = false}
check(T.TooltipText('mouseover'):find('2/2 %(Ready to Turn In%)'), 'matching tooltip shows ready progress')
units.mouseover.name = 'Wolf'; check(not T.TooltipText('mouseover'), 'unrelated tooltip has no quest line')
units.mouseover.name = 'Kobold Miner'; units.mouseover.controlled = true
check(not T.TooltipText('mouseover'), 'player-controlled unit does not receive mob progress')
units.mouseover.controlled = false
local hiddenName = {}; issecretvalue = function(v) return v == hiddenName end
units.mouseover.name = hiddenName; check(not T.TooltipText('mouseover'), 'secret tooltip name is ignored')
issecretvalue = nil; units.mouseover.name = 'Kobold Miner'
T.Abandon(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 2); q.categoryName = 'Hunt'; T.Accept(q)
check(not T.DebugAddKillProgress(true) and q.progress.count == 0, 'debug increment excludes Hunt')
T.Abandon(); q = quest({kind = 'gather', profession = 'mining', itemID = 2770}); q.categoryName = 'Gather'; T.Accept(q)
check(not T.DebugAddKillProgress(true), 'debug increment excludes gathering')
T.Abandon(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 2); q.categoryName = 'Kill'; T.Accept(q)
assert(loadstring(tooltip_source))('WoWForever', ns)
tooltipUnit = 'mouseover'; GameTooltip:Show()
GameTooltip.scripts.OnTooltipCleared(GameTooltip); tooltipLines = {}
GameTooltip.scripts.OnTooltipSetUnit(GameTooltip)
check(#tooltipLines == 1 and tooltipLines[1].text:find('0/2'), 'tooltip hook adds current quest progress')
T.DebugAddKillProgress(true); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(#tooltipLines == 1 and tooltipLines[1].text:find('1/2'), 'hovered tooltip updates without duplicate lines')
T.DebugAddKillProgress(true); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(tooltipLines[1].text:find('Ready to Turn In'), 'hovered tooltip reflects completion')
T.Abandon(); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(tooltipLines[1].text == '', 'abandon removes tooltip progress')
-- Client restrictions must be modeled: a protected registration is not a Lua
-- exception that an addon should try to catch after triggering the popup.
for _, build in ipairs({16001, 120000, 11507}) do
    interfaceVersion = build
    restrictedCombat = build == 11507 -- Also honor the public restriction predicate.
    local restrictedNS = {}
    assert(loadstring(tracking_source))('WoWForever', restrictedNS)
    local t = restrictedNS.Tracking
    local kept = quest({kind = 'kill', targets = {'Kobold Miner'}}, 4)
    kept.state, kept.progress = 'Active', {count = 2}
    local record = {activeQuest = kept}
    t.Initialize(record, function(v) return v.tracking end, function() end)
    check(not frames[#frames].registered.COMBAT_LOG_EVENT_UNFILTERED, 'restricted client never registers combat-log event')
    check(frames[#frames].registered.CHAT_MSG_LOOT and frames[#frames].registered.MERCHANT_SHOW, 'safe tracking events still register')
    check(kept.progress.count == 2 and kept.amount == 4 and t.CanTrack(kept), 'restricted active kills retain progress and are trackable')
    t.OnEvent('COMBAT_LOG_EVENT_UNFILTERED')
    check(kept.progress.count == 2, 'restricted combat payload never read')
    resting = true; t.Abandon()
    check(t.Accept(kept), 'kill quests can be accepted without combat-log access'); t.Abandon()
    check(t.Accept(quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2)), 'collection quests remain available')
    local secret = {}
    issecretvalue = function(value) return value == secret end
    units.target = {guid = secret, name = secret}
    t.OnEvent('PLAYER_TARGET_CHANGED')
    t.OnEvent('UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', secret)
    t.OnEvent('CHAT_MSG_LOOT', secret)
    check(record.activeQuest.progress.collected == 0, 'secret unit/spell/chat values are ignored')
    issecretvalue = nil
end
-- Fieldbook-style evidence: live observation + death + public tag eligibility.
fresh(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 20); T.Accept(q)
units.target = {guid = killGUID('corpse'), name = 'Kobold Miner', dead = true, controlled = false, denied = false}
T.PollKills(); die('corpse', 'Kobold Miner')
check(q.progress.count == 0, 'already-dead corpse never counts without a living observation')
hit('party', 'Kobold Miner')
T.OnEvent('PARTY_KILL', 'Party-attacker', killGUID('party'))
check(q.progress.count == 0, 'party kill alone is not proof of death')
units.target = nil; T.OnEvent('UNIT_DIED', killGUID('party'))
check(q.progress.count == 1, 'terminal eligibility survives target clearing before death event')
T.OnEvent('UNIT_DIED', killGUID('party')); check(q.progress.count == 1, 'duplicate standalone death is ignored')
hit('pet', 'Kobold Miner', 'Pet-1'); units.target.dead = true; T.PollKills()
check(q.progress.count == 2, 'pet-assisted death can count through polling without PARTY_KILL or UNIT_DIED')
hit('hidden', 'Kobold Miner'); units.target.dead = true
local secret = {}; issecretvalue = function(v) return v == secret end
units.target.denied = secret; T.PollKills(); T.OnEvent('UNIT_DIED', killGUID('hidden'))
check(q.progress.count == 2, 'hidden tap eligibility never grants credit')
units.target.denied = false; advance(1); T.PollKills()
check(q.progress.count == 3, 'readable eligibility arriving within pending window grants credit')
units.target.guid = secret; T.PollKills(); T.OnEvent('UNIT_DIED', secret)
check(q.progress.count == 3, 'hidden GUID is never inspected or credited')
issecretvalue = nil
hit('expired', 'Kobold Miner'); units.target.dead = true; units.target.denied = nil; T.PollKills()
advance(11); units.target.denied = false; T.PollKills()
check(q.progress.count == 3, 'pending evidence expires after ten seconds')
hit('stale', 'Kobold Miner'); units.target = nil; advance(121); T.OnEvent('UNIT_DIED', killGUID('stale'))
check(q.progress.count == 3, 'old living observation expires')
hit('controlled', 'Kobold Miner'); units.target.dead = true; units.target.controlled = true; T.PollKills()
units.target.controlled = false; T.PollKills()
check(q.progress.count == 3, 'player-controlled rejection is sticky for a death')
hit('reset', 'Kobold Miner'); T.OnEvent('PARTY_KILL', 'Attacker', killGUID('reset'))
units.target.inCombat = false; T.PollKills()
units.target = nil; T.OnEvent('UNIT_DIED', killGUID('reset'))
check(q.progress.count == 3, 'living reset clears earlier terminal eligibility')
hit('alias', 'Kobold Miner'); units.nameplate1 = units.target; units.target.dead = true
T.OnEvent('UNIT_HEALTH', 'nameplate1')
check(q.progress.count == 4, 'health event alias can confirm a watched target death')
hit('reload', 'Kobold Miner'); T.OnEvent('PLAYER_ENTERING_WORLD'); die('reload', 'Kobold Miner')
check(q.progress.count == 4, 'world transition clears transient living evidence')
hit('saved', 'Kobold Miner'); units.target.dead = true; T.PollKills()
T.Initialize(saved, function(v) return v.tracking end, function() end); T.OnEvent('PLAYER_ENTERING_WORLD')
hit('saved', 'Kobold Miner'); units.target.dead = true; T.PollKills()
check(q.progress.count == 5, 'saved GUID prevents duplicate kill credit after reload')
check(not frames[1].registered.COMBAT_LOG_EVENT_UNFILTERED, 'no kill tracker uses restricted combat-log registration')
print('PASS: ' .. passed .. ' tracking and UI assertions (Lua 5.1)')
