local interfaceVersion, restrictedCombat = 11507, false
function GetBuildInfo() return "test", "1", "date", interfaceVersion end
C_CombatLog = {IsCombatLogRestricted = function() return restrictedCombat end}
local passed = 0
local function check(value, message)
    assert(value, message)
    passed = passed + 1
end
local clock, timers, resting, zone, bags, money, buybacks, lootItems, combat, level, faction
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
    function o:GetText() return self.text end
    function o:GetEffectiveScale() return 1 end
    function o:SetPoint(...) self.point = {...} end
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
local menuEntries = {}
function UIDropDownMenu_SetWidth(frame, width) frame:SetWidth(width) end
function UIDropDownMenu_SetText(frame, text) frame.text = text end
function UIDropDownMenu_Initialize(frame, initialize) frame.initialize = initialize end
function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_AddButton(info) menuEntries[#menuEntries + 1] = info end
function CloseDropDownMenus() UIDROPDOWNMENU_OPEN_MENU = nil end
local function selectCategory(frame, label)
    menuEntries = {}; UIDROPDOWNMENU_OPEN_MENU = frame
    frame.initialize(frame, 1)
    check(#menuEntries == 5, 'dropdown exposes all five categories')
    for _, info in ipairs(menuEntries) do
        if info.text == label then
            info.func()
            check(frame.text == 'Left card: ' .. label and not UIDROPDOWNMENU_OPEN_MENU, 'dropdown selection updates label and closes menu')
            return
        end
    end
    error('Missing category: ' .. label)
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
function UnitFactionGroup() return faction end
function UnitExists(unit) return units[unit] ~= nil end
function UnitIsDead(unit) return units[unit] and units[unit].dead end
function UnitPlayerControlled(unit) return units[unit] and units[unit].controlled end
function UnitIsTapDenied(unit) return units[unit] and units[unit].denied end
function UnitAffectingCombat(unit) return units[unit] and units[unit].inCombat end
function UnitThreatSituation(actor, unit)
    local mob = units[unit]
    return mob and mob.tagger == actor and 0 or nil
end
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
local windowNS = {}
assert(loadstring(windows_source))('Classic Questbook', windowNS)
local wm = windowNS.Windows
local parentWindow, childWindow, nestedWindow = object(), object(), object()
parentWindow:SetFrameLevel(20); childWindow:SetSize(400, 200); nestedWindow:SetSize(300, 200)
function parentWindow:GetRight() return 1850 end
function parentWindow:GetLeft() return 1010 end
wm.Register(parentWindow); wm.Register(childWindow, parentWindow); wm.Register(nestedWindow, childWindow)
nestedWindow:Hide()
wm.Open(childWindow, parentWindow)
check(childWindow.point[1] == 'TOPRIGHT' and childWindow.point[3] == 'TOPLEFT', 'screen edge places child on available left side')
wm.Open(nestedWindow, childWindow)
wm.Raise(childWindow)
check(nestedWindow:GetFrameLevel() > childWindow:GetFrameLevel() and parentWindow:GetFrameLevel() == 20,
    'raising parent keeps nested child above it and main below both')
wm.Open(childWindow, nestedWindow)
check(wm.entries[childWindow].parent == parentWindow, 'window manager rejects nesting cycles')
assert(loadstring(tracking_source))('Classic Questbook', ns)
local T = ns.Tracking
local saved
local function fresh()
    clock, timers, resting, zone, bags, money, buybacks, lootItems, level, faction = 0, {}, true, 'Elwynn Forest', {}, 100, {}, {}, 6, 'Alliance'
    units = {player = {guid = 'Player-1', name = 'Tester'}, pet = {guid = 'Pet-1', name = 'Pet'},
        npc = {guid = 'Creature-0-1-0-0-295-123', name = 'Innkeeper Farley'}}
    professionSlots, professionLines = {}, {}
    saved = {}
    T.Initialize(saved, function(q) return q.tracking end, function() end)
    T.OnEvent('PLAYER_ENTERING_WORLD')
end
local function quest(spec, amount)
    if spec.kind == 'collect_sell' and not spec.vendorID then spec.vendorID = 295 end
    return {id = 'test', title = 'Test', zone = 'Elwynn Forest', amount = amount or 2, tracking = spec}
end
local function killGUID(guid) return 'Creature-0-1-0-0-40-' .. guid:gsub('%W', '') end
local function hit(guid, name, source)
    units.target = {guid = killGUID(guid), name = name, dead = false, controlled = false,
        denied = source == 'Stranger', inCombat = true,
        tagger = source == 'Pet-1' and 'pet' or source == 'Player-party' and 'party1'
            or (source == 'Stranger' or source == 'Unrelated') and 'outsider'
            or source == 'NPC' and 'npc' or 'player'}
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
units.npc = {guid = 'Creature-0-1-0-0-66-321', name = 'Innkeeper Farley'}
T.OnEvent('MERCHANT_SHOW'); bags[2672] = 1; money = money + 10; buybacks = {{id = 2672, quantity = 1}}
T.OnEvent('BAG_UPDATE_DELAYED'); T.OnEvent('MERCHANT_CLOSED'); advance(1)
check(q.progress.sold == 0 and q.progress.held[2672] == 1 and q.state == 'Active',
    'selling to a different vendor never counts, even when the shown name matches')
units.npc = nil
T.OnEvent('MERCHANT_SHOW'); T.OnEvent('MERCHANT_CLOSED'); advance(1)
check(q.progress.sold == 0, 'missing interacting NPC identity fails closed')
lootStart(2672, 1, 'Creature-wolf-new', 'Young Wolf'); receive(2672, 1)
units.npc = {guid = 'Creature-0-1-0-0-295-456', name = 'Innkeeper Farley'}
buybacks = {}
T.OnEvent('MERCHANT_SHOW'); bags[2672] = 0; money = money + 20
buybacks = {{id = 2672, quantity = 2}}
T.OnEvent('BAG_UPDATE_DELAYED'); T.OnEvent('MERCHANT_CLOSED'); advance(1)
check(q.progress.sold == 2 and q.state == 'Ready to Turn In', 'selling replacement gathered items to the assigned vendor counts')

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
assert(loadstring(tracking_source))('Classic Questbook', realNS)
assert(loadstring(windows_source))('Classic Questbook', realNS)
assert(loadstring(board_source))('Classic Questbook', realNS)
-- Fixed-seed distribution checks cover both category weighting and the shared
-- Gather weight, independently of the number of learned professions.
local function categorySample(slots, lines)
    professionSlots, professionLines = slots, lines
    math.randomseed(609)
    local counts = {Kill = 0, ['Collect & Sell'] = 0, Gather = 0, Hunt = 0}
    for _ = 1, 8000 do
        local offer = realNS.GenerateQuestForLevel(12, false)
        counts[offer.categoryName] = counts[offer.categoryName] + 1
    end
    return counts
end
local oneProfession = categorySample({1}, {[1] = 182})
local allProfessions = categorySample({1, 2, 3, 4}, {[1] = 182, [2] = 186, [3] = 393, [4] = 356})
for name, weight in pairs({Kill = 0.40, ['Collect & Sell'] = 0.30, Gather = 0.25, Hunt = 0.05}) do
    check(math.abs(oneProfession[name] / 8000 - weight) < 0.025, 'weighted category frequency: ' .. name)
    check(math.abs(allProfessions[name] / 8000 - weight) < 0.025, 'additional professions preserve category weight: ' .. name)
end
local noProfessions = categorySample({}, {})
check(noProfessions.Gather == 0, 'weighted generation excludes unlearned gathering')
check(math.abs(noProfessions.Hunt / 8000 - 5 / 75) < 0.025, 'Hunt remains rare after eligibility renormalization')
check(noProfessions.Kill > noProfessions['Collect & Sell'] and noProfessions['Collect & Sell'] > noProfessions.Hunt,
    'weighted category ordering favors ordinary quests')
math.randomseed(1)
local outleveledSeen = {}
local function huntPoolAt(playerLevel)
    local excluded, found = {}, {}
    for _ = 1, 20 do
        local offer = realNS.GenerateQuestForLevel(playerLevel, false, excluded, 'hunt')
        if not offer then return found end
        found[offer.objectiveId] = offer
        excluded[offer.selectionId] = true
    end
    error('Hunt pool enumeration failed to terminate')
end
for id, unlock in pairs({mine_spider = 5, mother_fang = 5, narg = 8, morgaine = 8,
    hogger = 9, fedfennel = 10, gruff_swiftbite = 10}) do
    check(not huntPoolAt(unlock - 1)[id], 'Hunt not available before two-level lead: ' .. id)
    local offer = huntPoolAt(unlock)[id]
    check(offer and offer.minPlayerLevel == unlock, 'Hunt unlocks at two-level lead: ' .. id)
    check(not offer.objective:find('level'), 'Hunt descriptions continue to omit levels')
    if offer.branchId == 'rare' then check(offer.amount == 1, 'rare Hunt amount remains one') end
end
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
    if frame.registered.ADDON_LOADED then frame.scripts.OnEvent(frame, 'ADDON_LOADED', 'Classic Questbook') end
end
SlashCmdList.WOWFOREVERQUESTBOARD('')
local board = WoWForeverQuestboard
local function cards()
    local result = {}
    for _, frame in ipairs(frames) do if frame.parent == board and rawget(frame, 'heading') then result[#result + 1] = frame end end
    return result
end
local cs = cards()
check(cs[1].progress.text == '' and not rawget(cs[1], 'prompt'),
    'unaccepted quest cards omit the roleplay prompt while keeping a progress field')
board.statistics.scripts.OnClick()
local statsWindow = WoWForeverStatistics
check(statsWindow:IsShown() and statsWindow.values.accepted.text == '0', 'statistics window opens with starting totals')
local acceptedSection, handedSection, abandonedSection = statsWindow.sections.accepted, statsWindow.sections.handedIn, statsWindow.sections.abandoned
acceptedSection.expand.scripts.OnClick()
handedSection.expand.scripts.OnClick()
abandonedSection.expand.scripts.OnClick()
check(acceptedSection.categories:IsShown() and handedSection.categories:IsShown() and abandonedSection.categories:IsShown(),
    'each statistic expands independently')
check(acceptedSection.point[5] > handedSection.point[5] and handedSection.point[5] > abandonedSection.point[5],
    'expanded statistics stack underneath their own headers')
handedSection.expand.scripts.OnClick()
check(not handedSection.categories:IsShown() and acceptedSection.categories:IsShown() and abandonedSection.categories:IsShown(),
    'collapsing one statistic preserves other expanded sections')
acceptedSection.expand.scripts.OnClick(); abandonedSection.expand.scripts.OnClick()
board.statistics.scripts.OnClick()
check(not statsWindow:IsShown(), 'statistics button toggles window closed')
board.help.scripts.OnClick()
check(WoWForeverHelp:IsShown(), 'help button opens help window')
board.help.scripts.OnClick()
check(not WoWForeverHelp:IsShown(), 'help button closes help window')
board.options.scripts.OnClick()
check(WoWForeverOptions:IsShown(), 'options button opens options')
check(WoWForeverOptions.point[2] == board and WoWForeverOptions.point[3] == 'TOPRIGHT', 'secondary opens beside main window')
board.help.scripts.OnClick()
check(WoWForeverHelp.point[2] == WoWForeverOptions, 'nested window opens beside previous window')
check(WoWForeverHelp:GetFrameLevel() > WoWForeverOptions:GetFrameLevel(), 'nested window stacks above parent')
board.help.scripts.OnClick()
board.options.scripts.OnClick()
check(not WoWForeverOptions:IsShown(), 'options button closes options')
-- Exercise the actual debug selector and Reroll button at the zone cap.
WoWForeverDebugModeButton.scripts.OnClick()
board.debugButton.scripts.OnClick()
check(WoWForeverQuestBrowser:IsShown(), 'browser button opens browser')
local browser = WoWForeverQuestBrowser
local function visibleObjectives()
    local count = 0
    for _, row in ipairs(browser.objectiveRows) do if row:IsShown() then count = count + 1 end end
    return count
end
local filteredCount = visibleObjectives()
local keptBrowserOffers = WoWForeverDB.displayedQuests
browser.allLevels:SetChecked(true); browser.allLevels.scripts.OnClick()
check(visibleObjectives() > filteredCount, 'show all levels expands current zone objective list')
check(WoWForeverDB.displayedQuests == keptBrowserOffers, 'browser level toggle never changes offers')
for _, tab in ipairs(browser.tabs) do
    tab.scripts.OnClick()
    check(visibleObjectives() > 0, 'all-level browser supports each category tab')
end
browser.tabs[1].scripts.OnClick()
browser.allLevels:SetChecked(false); browser.allLevels.scripts.OnClick()
check(visibleObjectives() == filteredCount, 'turning off all levels restores selected level filter')
board.debugButton.scripts.OnClick()
check(not WoWForeverQuestBrowser:IsShown(), 'browser button closes browser')
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
local otherCategories = {}
for _, expected in ipairs({'Kill', 'Collect & Sell', 'Hunt'}) do
    local previous = WoWForeverDB.displayedQuests
    selectCategory(board.debugCategory, expected)
    check(WoWForeverDB.displayedQuests == previous, 'category selection leaves existing offers unchanged')
    for _ = 1, 20 do
        board.reroll.scripts.OnClick()
        local offers = WoWForeverDB.displayedQuests
        check(offers[1].categoryName == expected, 'forced category applies to left card')
        check(offers[1].selectionId ~= offers[2].selectionId and offers[1].selectionId ~= offers[3].selectionId
            and offers[2].selectionId ~= offers[3].selectionId, 'forced rerolls preserve uniqueness')
        otherCategories[offers[2].categoryName] = true
        otherCategories[offers[3].categoryName] = true
    end
end
check(otherCategories.Kill and otherCategories['Collect & Sell'] and otherCategories.Hunt, 'other slots retain normal category selection')
selectCategory(board.debugCategory, 'Gather') -- no profession
local beforeUnavailable = WoWForeverDB.displayedQuests
board.reroll.scripts.OnClick()
check(WoWForeverDB.displayedQuests == beforeUnavailable, 'unavailable forced category preserves offers')
professionSlots, professionLines = {1}, {[1] = 393}
board.reroll.scripts.OnClick()
check(WoWForeverDB.displayedQuests[1].professionId == 'skinning', 'forced Gather respects learned professions and category ceiling')
professionSlots, professionLines = {}, {}
WoWForeverDebugModeButton.scripts.OnClick()
board.reroll.scripts.OnClick()
check(not board.debugCategory.shown and #WoWForeverDB.displayedQuests == 3, 'debug-off generation ignores forced Gather')
WoWForeverDebugModeButton.scripts.OnClick()
selectCategory(board.debugCategory, 'Any category')
check(board.debugCategory.text == 'Left card: Any category', 'dropdown restores unrestricted generation')
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
local abandonedBeforeCancel = WoWForeverDB.statistics.abandoned
dialog.skip:SetChecked(true); dialog.cancel.scripts.OnClick()
check(WoWForeverDB.activeQuest == pending and WoWForeverDB.settings.showAbandonConfirmation,
    'cancel preserves active quest and does not save opt-out')
check(WoWForeverDB.statistics.abandoned == abandonedBeforeCancel, 'cancel does not count abandonment')
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
check(statsWindow.values.handedIn.text == '1' and statsWindow.sections.handedIn.categoryValues[active.categoryName].text == '1',
    'statistics total and category refresh after successful turn-in')
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
assert(loadstring(tracking_source))('Classic Questbook', reloadNS)
assert(loadstring(windows_source))('Classic Questbook', reloadNS)
assert(loadstring(board_source))('Classic Questbook', reloadNS)
for _, frame in ipairs(frames) do
    if frame.registered.ADDON_LOADED then frame.scripts.OnEvent(frame, 'ADDON_LOADED', 'Classic Questbook') end
end
check(WoWForeverDB.activeQuest.id == persistent.id and WoWForeverDB.activeQuest.amount == persistent.amount
    and WoWForeverDB.activeQuest.progress.count == 1, 'real saved-state migration preserves identity, amount, and progress')
SlashCmdList.WOWFOREVERQUESTBOARD('')
local reloadedCard
for _, frame in ipairs(frames) do
    if frame.parent == WoWForeverQuestboard and rawget(frame, 'heading') and frame.heading.text == persistent.title then reloadedCard = frame end
end
check(reloadedCard and reloadedCard.progress.text:find('Active'), 'reloaded active card renders authoritative saved state')
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
local editBoard = WoWForeverQuestboard
local originalID, originalOther = debugKill.id, WoWForeverDB.displayedQuests[1]
editBoard.debugAmount:SetText('25'); editBoard.debugAmountApply.scripts.OnClick()
check(debugKill.amount == 25 and debugKill.objective:find('25') and debugKill.id == originalID,
    'amount editor updates objective text without changing quest identity')
check(WoWForeverDB.displayedQuests[1] == originalOther, 'amount edit preserves other offers')
editBoard.debugAmount:SetText('0'); editBoard.debugAmountApply.scripts.OnClick()
check(debugKill.amount == 25, 'invalid amount rejected by UI')
WoWForeverQuestboard.debugProgress.scripts.OnClick()
check(debugKill.progress.count == 1, 'debug button reaches tracking increment logic')
WoWForeverDebugModeButton.scripts.OnClick()
WoWForeverQuestboard.debugProgress.scripts.OnClick()
check(not WoWForeverQuestboard.debugProgress.shown and debugKill.progress.count == 1, 'hidden debug control cannot increment')
reloadedCards[2].button.scripts.OnClick() -- confirmation remains disabled
WoWForeverDebugModeButton.scripts.OnClick()
selectCategory(WoWForeverQuestboard.debugCategory, 'Kill')
WoWForeverQuestboard.reroll.scripts.OnClick()
reloadedCards[1].button.scripts.OnClick()
local forcedActive = WoWForeverDB.activeQuest
local keptRight = {WoWForeverDB.displayedQuests[2], WoWForeverDB.displayedQuests[3]}
selectCategory(WoWForeverQuestboard.debugCategory, 'Collect & Sell')
check(WoWForeverDB.activeQuest == forcedActive and forcedActive.categoryName == 'Kill', 'changing forced category preserves active quest')
forcedActive.state = 'Ready to Turn In'
reloadedCards[1].button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and WoWForeverDB.displayedQuests[1].categoryName == 'Collect & Sell',
    'left-slot replacement uses selected forced category')
check(WoWForeverDB.displayedQuests[2] == keptRight[1] and WoWForeverDB.displayedQuests[3] == keptRight[2],
    'forced replacement leaves other slots unchanged')
reloadedCards[1].button.scripts.OnClick()
WoWForeverDB.activeQuest.state = 'Ready to Turn In'
selectCategory(WoWForeverQuestboard.debugCategory, 'Gather')
reloadedCards[1].button.scripts.OnClick()
check(not WoWForeverDB.activeQuest and #WoWForeverDB.displayedQuests == 3,
    'unavailable forced replacement does not block turn-in')
-- Debug increment is limited to Kill category and uses the normal ready state.
fresh(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 2); q.categoryName = 'Kill'; T.Accept(q)
check(not T.DebugAddProgress(false) and q.progress.count == 0, 'debug increment denied with mode off')
check(T.DebugAddProgress(true) and q.progress.count == 1, 'debug increment adds one kill')
check(T.DebugAddProgress(true) and q.state == 'Ready to Turn In' and saved.activeQuest == q,
    'debug completion becomes ready without auto turn-in')
check(not T.DebugAddProgress(true) and q.progress.count == 2, 'debug count cannot exceed objective amount')
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
check(T.DebugAddProgress(true) and q.progress.count == 1, 'debug increment supports Hunt')
T.Abandon(); q = quest({kind = 'gather', profession = 'mining', itemID = 2770}); q.categoryName = 'Gather'; T.Accept(q)
check(T.DebugAddProgress(true) and q.progress.count == 1, 'debug increment supports gathering')
for _, spec in ipairs({
    {kind = 'gather', profession = 'herbalism', itemID = 2447},
    {kind = 'gather', profession = 'skinning', itemID = 2318},
    {kind = 'gather', profession = 'fishing', itemID = 6291},
    {kind = 'nodes', profession = 'mining', itemID = 2770},
}) do
    T.Abandon(); q = quest(spec, 2); T.Accept(q)
    check(T.DebugAddProgress(true) and q.progress.count == 1, 'debug increments gathering or node progress')
    check(T.DebugAddProgress(true) and q.state == 'Ready to Turn In', 'debug gathering/node reaches ready state')
    check(not T.DebugAddProgress(true) and q.progress.count == 2, 'debug gathering/node count is capped')
end
T.Abandon(); q = quest({kind = 'collect_sell', targets = {'Young Wolf'}, itemID = 2672}, 2); T.Accept(q)
check(T.DebugAddProgress(true) and q.progress.collected == 1 and q.progress.sold == 0, 'debug collect increments collection first')
check(T.DebugAddProgress(true) and q.progress.collected == 2 and q.state == 'Active', 'full collection still requires selling')
check(T.DebugAddProgress(true) and q.progress.sold == 1 and q.state == 'Active', 'debug then advances selling')
check(T.DebugAddProgress(true) and q.progress.sold == 2 and q.state == 'Ready to Turn In' and saved.activeQuest == q,
    'debug sale completion is ready without auto turn-in')
check(not T.DebugAddProgress(true) and q.progress.collected == 2 and q.progress.sold == 2, 'debug collection and sales stay capped')
check(T.DebugSetAmount(true, 5, q) and q.state == 'Active' and q.progress.sold == 2, 'raising target reactivates ready collection quest')
check(T.DebugSetAmount(true, 1, q) and q.state == 'Ready to Turn In' and q.progress.sold == 2,
    'lowering target preserves earned collection and sale progress')
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(q.amount == 1 and q.progress.collected == 2 and q.progress.sold == 2 and q.state == 'Ready to Turn In',
    'edited amount and excess progress survive reload normalization')
for _, value in ipairs({'', 'oops', 0, -1, 1.5, 1001, math.huge}) do
    check(not T.DebugSetAmount(true, value, q) and q.amount == 1, 'invalid required amounts are rejected')
end
check(not T.DebugSetAmount(false, 10, q) and q.amount == 1, 'amount changes require debug mode')
check(not T.DebugSetAmount(true, 10, {}) and q.amount == 1, 'stale amount editor cannot modify a different quest')
T.Abandon(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 5); T.Accept(q)
T.DebugAddProgress(true); T.DebugAddProgress(true)
check(T.DebugSetAmount(true, 1, q) and q.state == 'Ready to Turn In' and q.progress.count == 2, 'lowering kill amount marks ready and preserves kills')
check(T.DebugSetAmount(true, 4, q) and q.state == 'Active' and q.progress.count == 2, 'raising kill amount reactivates without resetting progress')
T.Abandon(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 2); q.categoryName = 'Kill'; T.Accept(q)
assert(loadstring(tooltip_source))('Classic Questbook', ns)
tooltipUnit = 'mouseover'; GameTooltip:Show()
GameTooltip.scripts.OnTooltipCleared(GameTooltip); tooltipLines = {}
GameTooltip.scripts.OnTooltipSetUnit(GameTooltip)
check(#tooltipLines == 1 and tooltipLines[1].text:find('0/2'), 'tooltip hook adds current quest progress')
T.DebugAddProgress(true); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(#tooltipLines == 1 and tooltipLines[1].text:find('1/2'), 'hovered tooltip updates without duplicate lines')
T.DebugAddProgress(true); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(tooltipLines[1].text:find('Ready to Turn In'), 'hovered tooltip reflects completion')
T.Abandon(); GameTooltip.scripts.OnUpdate(GameTooltip, 0.2)
check(tooltipLines[1].text == '', 'abandon removes tooltip progress')
-- Client restrictions must be modeled: a protected registration is not a Lua
-- exception that an addon should try to catch after triggering the popup.
for _, build in ipairs({16001, 120000, 11507}) do
    interfaceVersion = build
    restrictedCombat = build == 11507 -- Also honor the public restriction predicate.
    local restrictedNS = {}
    assert(loadstring(tracking_source))('Classic Questbook', restrictedNS)
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
units.target = {guid = killGUID('untagged'), name = 'Kobold Miner', dead = false,
    controlled = false, denied = false, inCombat = false}
T.OnEvent('PLAYER_TARGET_CHANGED')
units.target.dead = true; T.PollKills(); T.OnEvent('UNIT_DIED', killGUID('untagged'))
check(q.progress.count == 0, 'an untapped target dying does not grant quest credit')
hit('foreign', 'Kobold Miner', 'Stranger'); die('foreign', 'Kobold Miner')
check(q.progress.count == 0, 'another player tapping the mob denies quest credit')
hit('stillalive', 'Kobold Miner')
T.OnEvent('PARTY_KILL', 'Player-1', killGUID('stillalive'))
check(q.progress.count == 0, 'a kill notification without confirmed death does not grant credit')
hit('soloeligible', 'Kobold Miner'); die('soloeligible', 'Kobold Miner')
check(q.progress.count == 1, 'a tagged mob dying grants solo credit')
units.party1 = {guid = 'Player-party', name = 'Party Member'}
hit('partyeligible', 'Kobold Miner', 'Player-party'); T.OnEvent('PARTY_KILL', 'Player-party', killGUID('partyeligible'))
units.target = nil; T.OnEvent('UNIT_DIED', killGUID('partyeligible'))
check(q.progress.count == 2, 'a tagged mob killed by a party member grants credit after death')
hit('partyTagOtherFinisher', 'Kobold Miner', 'Player-party')
-- A party member's tap belongs to the group even if no PARTY_KILL reaches
-- this client (or an outsider lands the finishing blow).
die('partyTagOtherFinisher', 'Kobold Miner')
check(q.progress.count == 3, 'eligible party tap and confirmed death count without PARTY_KILL')
hit('resetbeforedeath', 'Kobold Miner'); units.target.inCombat = false; T.PollKills()
units.target.dead = true; T.PollKills()
check(q.progress.count == 3, 'a mob that resets before dying loses earlier tap evidence')
hit('contested', 'Kobold Miner'); units.target.denied = true; T.PollKills()
units.target.dead = true; units.target.denied = false; T.PollKills()
check(q.progress.count == 3, 'a contested mob cannot gain credit when its corpse becomes readable')
hit('npcfight', 'Kobold Miner', 'NPC'); units.target.dead = true; T.PollKills()
check(q.progress.count == 3, 'a mob fighting an NPC with no party threat does not grant credit')
hit('unrelatedplayer', 'Kobold Miner', 'Unrelated'); units.target.dead = true; T.PollKills()
check(q.progress.count == 3, 'another player fighting a not-denied target still lacks party-tag evidence')
local secretThreat = {}
local originalThreat = UnitThreatSituation
UnitThreatSituation = function() return secretThreat end
issecretvalue = function(value) return value == secretThreat end
hit('secretthreat', 'Kobold Miner'); units.target.dead = true; T.PollKills()
check(q.progress.count == 3, 'secret threat data cannot prove a group tag')
UnitThreatSituation = originalThreat; issecretvalue = nil
local hiddenTap = {}; issecretvalue = function(value) return value == hiddenTap end
units.target = {guid = killGUID('secretlive'), name = 'Kobold Miner', dead = false,
    controlled = false, denied = hiddenTap, inCombat = true}
T.OnEvent('PLAYER_TARGET_CHANGED')
units.target.dead = true; units.target.denied = false; T.PollKills()
check(q.progress.count == 3, 'secret live tap evidence cannot become a credited kill after death')
issecretvalue = nil

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
fresh(); q = quest({kind = 'kill', targets = {'Kobold Miner'}}); q.categoryName = 'Kill'
resting = false
check(not T.Accept(q) and saved.statistics.accepted == 0, 'failed acceptance does not count')
resting = true; T.Accept(q)
check(saved.statistics.accepted == 1 and not T.Accept(q) and saved.statistics.accepted == 1, 'acceptance counts exactly once')
T.DebugAddProgress(true); T.DebugAddProgress(true)
check(saved.statistics.handedIn == 0, 'ready state does not count as handed in')
resting = false
check(not T.TurnIn() and saved.statistics.handedIn == 0, 'failed turn-in does not count')
T.Abandon()
check(saved.statistics.abandoned == 1 and saved.statistics.completedByCategory.Kill == 0, 'abandoning ready quest does not count completion')
check(not T.Abandon() and saved.statistics.abandoned == 1, 'repeated abandonment does not count')
check(saved.statistics.acceptedByCategory.Kill == 1 and saved.statistics.abandonedByCategory.Kill == 1,
    'successful acceptance and abandonment count by category exactly once')
resting = true
for _, category in ipairs({'Kill', 'Collect & Sell', 'Hunt', 'Gather'}) do
    q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 1); q.categoryName = category
    T.Accept(q); T.DebugAddProgress(true); T.TurnIn()
    check(saved.statistics.completedByCategory[category] == 1, 'completion category counted: ' .. category)
    check(saved.statistics.acceptedByCategory[category] >= 1, 'acceptance category counted: ' .. category)
end
for _ = 1, 24 do
    q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 1); q.categoryName = 'Kill'
    T.Accept(q); T.DebugAddProgress(true); T.TurnIn()
end
check(saved.statistics.handedIn == 28 and saved.statistics.completedByCategory.Kill == 25 and #saved.completedQuests == 20,
    'statistics persist independently of recent completion history limit')
local statsSnapshot = T.GetStatistics()
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(saved.statistics.accepted == 29 and saved.statistics.abandoned == 1 and saved.statistics.handedIn == 28,
    'statistics survive initialization without recounting history')
statsSnapshot.completedByCategory.Kill = 0
check(saved.statistics.completedByCategory.Kill == 25, 'statistics snapshots do not expose mutable saved counters')
saved.statistics = {accepted = -2, handedIn = math.huge, abandoned = 'bad', completedByCategory = {Kill = -1, Hunt = '3'}}
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(saved.statistics.accepted == 0 and saved.statistics.handedIn == 0 and saved.statistics.abandoned == 0
    and saved.statistics.completedByCategory.Kill == 0 and saved.statistics.completedByCategory.Hunt == 3,
    'malformed statistics repaired safely')
saved.statistics = {accepted = 20, handedIn = 5, abandoned = 10, completedByCategory = {Kill = 5}}
T.Initialize(saved, function(v) return v.tracking end, function() end)
check(saved.statistics.accepted == 20 and saved.statistics.abandoned == 10
    and saved.statistics.completedByCategory.Kill == 5 and saved.statistics.acceptedByCategory.Kill == 0,
    'upgrade preserves old totals and completion categories without inventing historical category counts')
for _, category in ipairs({'Kill', 'Collect & Sell', 'Hunt', 'Gather'}) do
    q = quest({kind = 'kill', targets = {'Kobold Miner'}}, 1); q.categoryName = category
    T.Accept(q); T.Abandon()
    check(saved.statistics.acceptedByCategory[category] == 1 and saved.statistics.abandonedByCategory[category] == 1,
        'new category counters track accepted and abandoned: ' .. category)
end
-- Multi-zone generation, saved boards, and real tracking share the same data.
do
    fresh()
    local function loadZoneBoard(data)
        WoWForeverDB = data
        local addon = {}
        assert(loadstring(tracking_source))('Classic Questbook', addon)
        assert(loadstring(windows_source))('Classic Questbook', addon)
        assert(loadstring(board_source))('Classic Questbook', addon)
        for _, frame in ipairs(frames) do
            if frame.registered.ADDON_LOADED then frame.scripts.OnEvent(frame, 'ADDON_LOADED', 'Classic Questbook') end
        end
        SlashCmdList.WOWFOREVERQUESTBOARD('')
        return addon, WoWForeverQuestboard
    end
    local addon, ui = loadZoneBoard(nil)
    local function chooseZone(name)
        menuEntries = {}
        local dropdown = ui.zoneDropdown
        dropdown.initialize(dropdown, 1)
        check(#menuEntries == 2, 'zone dropdown lists both supported zones')
        for _, entry in ipairs(menuEntries) do
            if entry.text == name then entry.func(); check(dropdown.text == name, 'zone selection updates label'); return end
        end
        error('missing zone ' .. name)
    end
    local function uiCards()
        local result = {}
        for _, frame in ipairs(frames) do
            if frame.parent == ui and rawget(frame, 'heading') then result[#result + 1] = frame end
        end
        return result
    end
    local elwynnOffers = WoWForeverDB.displayedQuests
    local verifiedGivers = {
        elwynn = {[240]=true,[197]=true,[823]=true,[261]=true,[241]=true,[295]=true,[244]=true,[251]=true,[514]=true,
            [66]=true,[1250]=true,[152]=true},
        dun_morogh = {[658]=true,[713]=true,[786]=true,[714]=true,[1252]=true,[1265]=true,[1247]=true,[1267]=true,
            [1378]=true,[1269]=true,[829]=true,[1691]=true,[1692]=true},
    }
    local verifiedVendors = {
        elwynn = {[295]=true,[66]=true,[1250]=true,[152]=true},
        dun_morogh = {[1247]=true,[829]=true,[1691]=true,[1692]=true},
    }
    local function checkNarrative(offer)
        check(verifiedGivers[offer.zoneId][offer.questGiverID] and offer.questGiverFaction == 'Alliance',
            'quest giver is verified in the zone and friendly to Alliance')
        check(type(offer.flavorText) == 'string' and #offer.flavorText > 40
            and offer.description:find(offer.flavorText, 1, true)
            and offer.description:find(offer.questGiverLocation, 1, true),
            'quest carries a specific saved flavour line and giver location')
        if offer.categoryName == 'Collect & Sell' then
            check(verifiedVendors[offer.zoneId][offer.questGiverID]
                and offer.tracking.vendorID == offer.questGiverID
                and offer.objective:find(offer.source, 1, true),
                'Collect & Sell names and tracks only its assigned local vendor')
        end
    end
    for _, offer in ipairs(elwynnOffers) do checkNarrative(offer) end
    chooseZone('Dun Morogh')
    local dunOffers = WoWForeverDB.displayedQuests
    check(#dunOffers == 3 and dunOffers ~= elwynnOffers, 'first visit generates a separate Dun Morogh board')
    for _, offer in ipairs(dunOffers) do
        check(offer.zone == 'Dun Morogh', 'Dun Morogh board contains only local objectives')
        checkNarrative(offer)
    end
    chooseZone('Elwynn Forest')
    check(WoWForeverDB.displayedQuests == elwynnOffers, 'switching back preserves all Elwynn offers')
    chooseZone('Dun Morogh')
    check(WoWForeverDB.displayedQuests == dunOffers, 'switching back preserves all Dun Morogh offers')
    local pool, counts = {}, {Kill = 0, ['Collect & Sell'] = 0, Hunt = 0, Gather = 0}
    local miningFlavors, miningGivers = {}, {}
    professionSlots, professionLines = {1, 2, 3, 4}, {[1] = 182, [2] = 186, [3] = 393, [4] = 356}
    for testLevel = 1, 12 do
        local excluded, reachedEnd = {}, false
        for _ = 1, 80 do
            local offer = addon.GenerateQuestForLevel(testLevel, false, excluded)
            if not offer then reachedEnd = true; break end
            check(offer.zoneId == 'dun_morogh' and offer.zone == 'Dun Morogh', 'all generated data belongs to selected zone')
            checkNarrative(offer)
            if offer.professionId == 'mining' then
                miningFlavors[offer.flavorText], miningGivers[offer.questGiverID] = true, true
            end
            check(not excluded[offer.selectionId] and addon.Tracking.CanTrack(offer), 'Dun Morogh objectives unique and trackable')
            check(offer.amount >= 1 and offer.minPlayerLevel <= testLevel, 'objective eligibility never advances low-level characters')
            excluded[offer.selectionId] = true
            if not pool[offer.objectiveId] then counts[offer.categoryName] = counts[offer.categoryName] + 1 end
            pool[offer.objectiveId] = offer
            if offer.categoryName == 'Hunt' then
                check(not offer.objective:lower():find('rare') and not offer.objective:lower():find('elite'), 'Hunt objective omits classification')
                check(offer.amount == 1 and not offer.objective:find('1'), 'single-target Hunt has no amount in description')
                check(offer.minPlayerLevel == tonumber(offer.level) - 2, 'Dun Morogh Hunt unlocks two levels early')
            end
        end
        check(reachedEnd, 'Dun Morogh pool enumeration terminates without duplicates')
    end
    check(counts.Kill == 20 and counts['Collect & Sell'] == 11 and counts.Hunt == 7 and counts.Gather == 11,
        'Dun Morogh has 49 objectives across every category')
    local flavorCount, giverCount = 0, 0
    for _ in pairs(miningFlavors) do flavorCount = flavorCount + 1 end
    for _ in pairs(miningGivers) do giverCount = giverCount + 1 end
    check(flavorCount > 1 and giverCount > 1, 'mining notices vary both flavour and local giver')
    check(pool.dm_copper_vein_prospecting.tracking.kind == 'nodes'
        and pool.dm_copper_vein_prospecting.objective:find('Dun Morogh'), 'Dun Morogh prospecting counts nodes and names correct zone')
    check(pool.dm_boar_leather.tracking.targets[1] == 'Crag Boar', 'skinning uses Dun Morogh creature sources')
    local cappedCategories, cappedProfessions, excluded = {}, {}, {}
    for _ = 1, 80 do
        local offer = addon.GenerateQuestForLevel(12, true, excluded)
        if not offer then break end
        excluded[offer.selectionId] = true
        cappedCategories[offer.categoryName] = true
        if offer.professionId then cappedProfessions[offer.professionId] = true end
    end
    check(cappedCategories.Kill and cappedCategories['Collect & Sell'] and cappedCategories.Hunt and cappedCategories.Gather,
        'outleveled Dun Morogh keeps all category ceilings')
    for _, profession in ipairs({'herbalism', 'mining', 'skinning', 'fishing'}) do
        check(cappedProfessions[profession], 'outleveled Dun Morogh retains learned profession ' .. profession)
    end
    professionSlots, professionLines = {}, {}
    check(not addon.GenerateQuestForLevel(12, true, nil, 'gather'), 'Dun Morogh preserves profession gating')
    faction = 'Horde'
    check(not addon.GenerateQuestForLevel(12, true), 'Alliance-zone notices do not assign hostile NPCs to Horde characters')
    faction = 'Alliance'
    level = 60
    for _ = 1, 20 do
        ui.reroll.scripts.OnClick()
        local seen = {}
        check(#WoWForeverDB.displayedQuests == 3, 'overleveled Dun Morogh still fills three cards')
        for _, offer in ipairs(WoWForeverDB.displayedQuests) do
            check(not seen[offer.selectionId] and offer.minPlayerLevel <= 12, 'three Dun Morogh cards remain unique and capped')
            seen[offer.selectionId] = true
        end
    end
    WoWForeverDebugModeButton.scripts.OnClick()
    for _ = 1, 12 do ui.debugLevelDown.scripts.OnClick() end
    ui.reroll.scripts.OnClick()
    for _, offer in ipairs(WoWForeverDB.displayedQuests) do
        check(offer.minPlayerLevel <= 1 and offer.maxPlayerLevel >= 1, 'Dun Morogh debug override drives rolled eligibility')
    end
    ui.debugButton.scripts.OnClick()
    local browser = WoWForeverQuestBrowser
    browser.allLevels:SetChecked(true); browser.allLevels.scripts.OnClick()
    local n = 0
    for _, row in ipairs(browser.objectiveRows) do if row:IsShown() then n = n + 1 end end
    check(n == 20 and browser.levelLabel.text:find('Dun Morogh'), 'all-level browser shows selected zone and all 20 Kill objectives')
    local firstRow = browser.objectiveRows[1]
    check(firstRow.amount.text:find('Level %d+–%d+') and not firstRow.amount.text:find('%('),
        'Quest Browser row displays eligible character level range instead of amount')
    firstRow.scripts.OnEnter(firstRow)
    local amountTooltip = false
    for i = math.max(1, #tooltipLines - 4), #tooltipLines do
        if tooltipLines[i].text:find('Amount range:', 1, true) then amountTooltip = true end
    end
    check(amountTooltip, 'Quest Browser hover shows objective amount range')
    firstRow.scripts.OnClick()
    check(browser.preview.text:find('Amount range', 1, true), 'Quest Browser click preview shows amount range')
    chooseZone('Elwynn Forest')
    check(browser.preview.text == '' and browser.levelLabel.text:find('Elwynn Forest'), 'zone switch refreshes browser and clears stale preview')
    chooseZone('Dun Morogh')
    local active = pool.dm_crag_boar
    WoWForeverDB.displayedQuests[2] = active
    uiCards()[2].button.scripts.OnClick()
    check(WoWForeverDB.activeQuest == active, 'Dun Morogh quest accepts through card')
    local keptDun = WoWForeverDB.displayedQuests
    chooseZone('Elwynn Forest')
    check(WoWForeverDB.activeQuest == active and not ui.reroll.enabled and ui.note.text:find('Dun Morogh'),
        'browsing another zone preserves active quest, locks reroll and explains how to return')
    uiCards()[1].button.scripts.OnClick()
    check(WoWForeverDB.activeQuest == active, 'cannot accept a second quest in another zone')
    local previousT = T; T = addon.Tracking
    zone = 'Elwynn Forest'; hit('dmwrongzone', 'Crag Boar'); die('dmwrongzone', 'Crag Boar')
    check(active.progress.count == 0, 'Dun Morogh kill cannot be credited in Elwynn')
    zone = 'Dun Morogh'; hit('dmrightzone', 'Crag Boar'); die('dmrightzone', 'Crag Boar')
    check(active.progress.count == 1, 'active Dun Morogh quest tracks while Elwynn board is selected')
    C_Map = {GetBestMapForUnit = function() return 9999 end,
        GetMapInfo = function(id) return {parentMapID = id == 9999 and 1426 or 0} end}
    zone = 'localized zone'; hit('dmchildmap', 'Crag Boar'); die('dmchildmap', 'Crag Boar')
    check(active.progress.count == 2, 'Classic Dun Morogh child map ancestry counts without English zone text')
    C_Map = nil
    local preserved = clone(WoWForeverDB)
    local savedGiver, savedFlavor = preserved.activeQuest.questGiverID, preserved.activeQuest.flavorText
    addon, ui = loadZoneBoard(preserved); T = addon.Tracking
    check(WoWForeverDB.selectedZone == 'elwynn' and WoWForeverDB.activeQuest.progress.count == 2,
        'reload retains selected zone and active quest in another zone')
    check(WoWForeverDB.activeQuest.questGiverID == savedGiver and WoWForeverDB.activeQuest.flavorText == savedFlavor,
        'reload keeps the accepted quest giver and flavour text')
    chooseZone('Dun Morogh')
    active = WoWForeverDB.activeQuest
    check(WoWForeverDB.displayedQuests[2] == active and active.tracking.targets[1] == 'Crag Boar',
        'reload restores authoritative active card and its Dun Morogh tracking spec')
    local untouched = {WoWForeverDB.displayedQuests[1], WoWForeverDB.displayedQuests[3]}
    while T.DebugAddProgress(true) do end
    resting = true
    uiCards()[2].button.scripts.OnClick()
    check(not WoWForeverDB.activeQuest and WoWForeverDB.displayedQuests[2] ~= active
        and WoWForeverDB.displayedQuests[2].zone == 'Dun Morogh', 'turn-in replaces only the finished slot in its zone')
    check(WoWForeverDB.displayedQuests[1] == untouched[1] and WoWForeverDB.displayedQuests[3] == untouched[2],
        'Dun Morogh turn-in preserves the other two cards')
    chooseZone('Elwynn Forest')
    for i = 1, 3 do check(WoWForeverDB.displayedQuests[i].id == elwynnOffers[i].id, 'Dun Morogh turn-in leaves Elwynn board unchanged') end
    zone = 'Dun Morogh'
    local collection = pool.dm_coldridge_trogg_spoils
    check(T.Accept(collection), 'Dun Morogh collection resolver works with another board selected')
    lootStart(2672, 1, 'Creature-dmtroggwrong', 'Kobold Miner'); receive(2672, 1)
    check(collection.progress.collected == 0, 'Dun Morogh collection rejects Elwynn source')
    lootStart(2672, 1, 'Creature-dmtrogg', 'Rockjaw Trogg'); receive(2672, 1)
    check(collection.progress.collected == 1, 'Dun Morogh collection credits its named source')
    T.Abandon()
    for _, test in ipairs({
        {'dm_peacebloom', 2366, 'GameObject-dmherb', 'Peacebloom'},
        {'dm_copper_ore', 2575, 'GameObject-dmcopper', 'Copper Vein'},
        {'dm_copper_vein_prospecting', 2575, 'GameObject-dmnode', 'Copper Vein'},
        {'dm_boar_leather', 8613, 'Creature-dmboar', 'Crag Boar'},
        {'dm_longjaw_mud_snapper', 7620, 'GameObject-dmfish', 'Fishing Bobber'},
    }) do
        local offer = pool[test[1]]
        check(T.Accept(offer), 'Dun Morogh gathering resolver: ' .. test[1])
        T.OnEvent(test[2] == 7620 and 'UNIT_SPELLCAST_CHANNEL_START' or 'UNIT_SPELLCAST_SUCCEEDED', 'player', 'cast', test[2])
        lootStart(offer.tracking.itemID, 1, test[3], test[4]); receive(offer.tracking.itemID, 1)
        check(offer.progress.count == 1, 'Dun Morogh gathering credits verified source: ' .. test[1])
        T.Abandon()
    end
    -- A legacy board upgrades without rerolling, even with malformed new settings.
    local legacy = {generatorDataVersion = '0.5.0', displayedQuests = clone(elwynnOffers),
        selectedZone = 'invalid', zoneOffers = 'bad'}
    for _, offer in ipairs(legacy.displayedQuests) do
        offer.questGiverID, offer.questGiverFaction, offer.questGiverLocation, offer.flavorText = nil, nil, nil, nil
        offer.description, offer.source = 'Mining supplies are needed.', 'A gathering commission'
    end
    addon, ui = loadZoneBoard(legacy)
    check(WoWForeverDB.selectedZone == 'elwynn' and WoWForeverDB.zoneOffers.elwynn == legacy.displayedQuests,
        'legacy offers migrate and invalid zone settings are repaired')
    for i = 1, 3 do
        check(legacy.displayedQuests[i].id == elwynnOffers[i].id and legacy.displayedQuests[i].amount == elwynnOffers[i].amount,
            'migration keeps old generated IDs and amounts')
        checkNarrative(legacy.displayedQuests[i])
    end
    -- Hunt wording is shared by both zones, including multiple-target elites.
    local hunt = addon.GenerateQuestForLevel(5, false, nil, 'hunt')
    for _ = 1, 100 do
        if hunt.objectiveId == 'mine_spider' then break end
        hunt = addon.GenerateQuestForLevel(5, false, nil, 'hunt')
    end
    check(hunt.objectiveId == 'mine_spider' and hunt.objective:find(tostring(hunt.amount))
        and not hunt.objective:lower():find('elite'), 'multi-target Hunt retains count but omits elite wording')
    local oldSaleQuest = clone(pool.dm_coldridge_trogg_spoils)
    oldSaleQuest.questGiverID, oldSaleQuest.questGiverLocation = 1265, 'Amberstill Ranch'
    oldSaleQuest.source, oldSaleQuest.flavorText = 'Rudra Amberstill', 'The market shelves are bare.'
    oldSaleQuest.tracking.vendorID = nil
    oldSaleQuest.state, oldSaleQuest.progress = 'Active', {count = 0, collected = 1, sold = 0, held = {}, inventory = {}, seen = {}}
    local previousAmount, previousObjectiveID = oldSaleQuest.amount, oldSaleQuest.objectiveId
    addon, ui = loadZoneBoard({generatorDataVersion = '0.5.0', selectedZone = 'dun_morogh',
        activeQuest = oldSaleQuest, displayedQuests = {oldSaleQuest}})
    local migratedSale = WoWForeverDB.activeQuest
    check(migratedSale.amount == previousAmount and migratedSale.objectiveId == previousObjectiveID
        and migratedSale.progress.collected == 1 and verifiedVendors.dun_morogh[migratedSale.questGiverID]
        and migratedSale.tracking.vendorID == migratedSale.questGiverID
        and migratedSale.objective:find(migratedSale.source, 1, true),
        'accepted old Collect & Sell quest gains a real vendor without losing amount or progress')
    WoWForeverDB.statistics.accepted, WoWForeverDB.statistics.handedIn, WoWForeverDB.statistics.abandoned = 7, 3, 2
    WoWForeverDB.statistics.acceptedByCategory.Kill = 4
    WoWForeverDB.statistics.completedByCategory.Hunt = 2
    WoWForeverDB.statistics.abandonedByCategory.Gather = 1
    ui.statistics.scripts.OnClick()
    local statsUI = WoWForeverStatistics
    check(not statsUI.reset:IsShown(), 'reset stats is hidden outside Debug Mode')
    statsUI.reset.scripts.OnClick()
    check(WoWForeverDB.statistics.accepted == 7, 'hidden reset handler cannot clear statistics outside Debug Mode')
    WoWForeverDebugModeButton.scripts.OnClick()
    check(statsUI.reset:IsShown(), 'reset stats appears when Debug Mode is enabled')
    statsUI.reset.scripts.OnClick()
    local cleared = addon.Tracking.GetStatistics()
    check(cleared.accepted == 0 and cleared.handedIn == 0 and cleared.abandoned == 0
        and cleared.acceptedByCategory.Kill == 0 and cleared.completedByCategory.Hunt == 0
        and cleared.abandonedByCategory.Gather == 0 and statsUI.values.accepted.text == '0',
        'debug reset clears all totals and category breakdowns immediately')
    WoWForeverDebugModeButton.scripts.OnClick()
    check(not statsUI.reset:IsShown(), 'reset stats hides immediately when Debug Mode is disabled')
    T = previousT
end
print('PASS: ' .. passed .. ' tracking and UI assertions (Lua 5.1)')
