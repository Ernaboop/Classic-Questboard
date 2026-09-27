local interfaceVersion, restrictedCombat = 11507, false
function GetBuildInfo() return "test", "1", "date", interfaceVersion end
C_CombatLog = {IsCombatLogRestricted = function() return restrictedCombat end}
local passed = 0
local function check(value, message)
    assert(value, message)
    passed = passed + 1
end
local clock, timers, resting, zone, bags, money, buybacks, lootItems, combat, level
local units, hooks, frames = {}, {}, {}
local function object(name, parent)
    local o = {scripts = {}, registered = {}, shown = true, parent = parent, name = name, width = 32, height = 32}
    setmetatable(o, {__index = function(_, key) return function() end end})
    function o:SetScript(k, fn) self.scripts[k] = fn end
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
    function o:Hide() self.shown = false end
    function o:IsShown() return self.shown end
    function o:SetFrameLevel(v) self.frameLevel = v end
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
UISpecialFrames, SlashCmdList, GameTooltip = {}, {}, object()
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
function GetProfessions() return nil end
function GetProfessionInfo() return nil end
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
    saved = {}
    T.Initialize(saved, function(q) return q.tracking end, function() end)
    T.OnEvent('PLAYER_ENTERING_WORLD')
end
local function quest(spec, amount)
    return {id = 'test', title = 'Test', zone = 'Elwynn Forest', amount = amount or 2, tracking = spec}
end
local function hit(guid, name, source, event)
    combat = {clock, event or 'SWING_DAMAGE', false, source or 'Player-1', 'Tester', 0, 0, guid, name, 0, 0}
    T.OnEvent('COMBAT_LOG_EVENT_UNFILTERED')
end
local function die(guid, name) hit(guid, name, 'Other', 'UNIT_DIED') end
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
check(#WoWForeverDB.displayedQuests == 3 and #cs == 3, 'three offers and three cards')
local seen = {}
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(not seen[offer.selectionId], 'unique objective offers'); seen[offer.selectionId] = true
end
resting = false; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
check(not cs[1].button.enabled and board.note.text:find('Visit an inn'), 'outside-rest UI explains and disables acceptance')
cs[1].button.scripts.OnClick(); check(not WoWForeverDB.activeQuest, 'callback also guards rest restriction')
resting = true; realNS.Tracking.OnEvent('PLAYER_UPDATE_RESTING')
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
WoWForeverDebugModeButton.scripts.OnClick(); board.debugLevelDown.scripts.OnClick()
for _, offer in ipairs(WoWForeverDB.displayedQuests) do
    check(offer.minPlayerLevel <= 5 and offer.maxPlayerLevel >= 5, 'debug level feeds actual generator')
end
cs[1].button.scripts.OnClick()
local persistent = WoWForeverDB.activeQuest
persistent.progress.count = 1
local persistentOffers = WoWForeverDB.displayedQuests
WoWForeverDebugModeButton.scripts.OnClick()
check(WoWForeverDB.activeQuest == persistent and persistent.progress.count == 1 and WoWForeverDB.displayedQuests == persistentOffers,
    'toggling debug preserves active progress and offers')
local function clone(t)
    if type(t) ~= 'table' then return t end
    local out = {}; for key, value in pairs(t) do out[key] = clone(value) end; return out
end
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
    check(kept.progress.count == 2 and kept.amount == 4 and t.ProgressText(kept):find('unavailable'), 'restricted active kills retain progress and explain pause')
    t.OnEvent('COMBAT_LOG_EVENT_UNFILTERED')
    check(kept.progress.count == 2, 'restricted combat payload never read')
    resting = true; t.Abandon()
    check(not t.Accept(kept), 'untrackable new kill quests cannot be accepted')
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
print('PASS: ' .. passed .. ' tracking and UI assertions (Lua 5.1)')
