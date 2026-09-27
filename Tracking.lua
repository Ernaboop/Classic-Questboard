local _, ns = ...
local Tracking = {}
ns.Tracking = Tracking
local db, changed, resolve
local names, tagged, loot, gathering, merchant = {}, {}, nil, nil, nil
local pendingLoot = {}
local ACTIVE, READY, COMPLETED = "Active", "Ready to Turn In", "Completed"
local function Refresh() if changed then changed() end end
local function ItemID(link) return link and tonumber(link:match("item:(%d+)")) end
local function Count(id)
    local fn = C_Item and C_Item.GetItemCount or GetItemCount
    return fn and fn(id, false, false) or 0
end
local function ItemInfo(id)
    local fn = C_Item and C_Item.GetItemInfo or GetItemInfo
    if fn then return fn(id) end
end
local function InZone()
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local id = C_Map.GetBestMapForUnit("player")
        for _ = 1, 12 do
            if id == 37 then return true end -- Elwynn, including its child maps.
            local info = id and C_Map.GetMapInfo(id)
            if not info or not info.parentMapID or info.parentMapID == 0 then break end
            id = info.parentMapID
        end
    end
    return GetRealZoneText and GetRealZoneText() == "Elwynn Forest"
end
function Tracking.IsResting() return IsResting and not not IsResting() end
local function Working()
    local q = db and db.activeQuest
    return q and q.state == ACTIVE and q.tracking and q
end
local function Matches(list, name)
    for _, value in ipairs(list or {}) do if value == name then return true end end
    return false
end
local function Observe(unit)
    local guid = UnitGUID(unit)
    if guid then names[guid] = UnitName(unit) end
end
local function ResetTransient()
    names, tagged, loot, gathering, merchant = {}, {}, nil, nil, nil
    pendingLoot = {}
end
local function UpdateState(q)
    local amount = q.tracking.kind == "collect_sell" and q.progress.sold or q.progress.count
    if amount >= q.amount and q.state == ACTIVE then
        q.state = READY
        print('|cffffd27fWoW Forever:|r "' .. q.title .. '" is Ready to Turn In. Visit a rested location and open /cq.')
    end
    Refresh()
end
local function Normalize(q)
    if type(q) ~= "table" then return end
    q.tracking = resolve(q)
    q.state = q.state == READY and READY or ACTIVE
    q.progress = type(q.progress) == "table" and q.progress or {}
    for _, field in ipairs({"count", "collected", "sold"}) do
        q.progress[field] = math.max(0, math.min(q.amount, tonumber(q.progress[field]) or 0))
    end
    q.progress.held = type(q.progress.held) == "table" and q.progress.held or {}
    q.progress.seen = type(q.progress.seen) == "table" and q.progress.seen or {}
    q.progress.inventory = type(q.progress.inventory) == "table" and q.progress.inventory or {}
    for id, count in pairs(q.progress.held) do
        if type(id) ~= "number" or type(count) ~= "number" or count < 0 then q.progress.held[id] = nil end
    end
    -- Older quests have no progress; preserve their target and rolled amount.
    if q.tracking then
        local count = q.tracking.kind == "collect_sell" and q.progress.sold or q.progress.count
        q.state = count >= q.amount and READY or ACTIVE
    else
        q.state = ACTIVE
    end
end
function Tracking.Accept(q)
    if not db or db.activeQuest or not Tracking.IsResting() then return false end
    if not resolve(q) then return false end
    q.state, q.progress, q.acceptedAt = ACTIVE, {}, time()
    Normalize(q)
    db.activeQuest = q
    ResetTransient()
    return true
end
function Tracking.Abandon()
    if not db or not db.activeQuest then return false end
    db.activeQuest = nil
    ResetTransient()
    return true
end
function Tracking.TurnIn()
    local q = db and db.activeQuest
    if not q or q.state ~= READY or not Tracking.IsResting() then return false end
    q.state, q.completedAt = COMPLETED, time()
    db.completedQuests[#db.completedQuests + 1] = {
        id = q.id, title = q.title, zone = q.zone, amount = q.amount,
        state = COMPLETED, acceptedAt = q.acceptedAt, completedAt = q.completedAt,
    }
    while #db.completedQuests > 20 do table.remove(db.completedQuests, 1) end
    db.activeQuest = nil
    ResetTransient()
    print('|cffffd27fWoW Forever:|r Completed "' .. q.title .. '".')
    return true
end
function Tracking.ProgressText(q)
    if not q.tracking then return "Tracking unavailable for this legacy objective. You may abandon it." end
    local p = q.progress
    if q.tracking.kind == "collect_sell" then
        return q.state .. "\nCollected: " .. p.collected .. "/" .. q.amount .. "   Sold: " .. p.sold .. "/" .. q.amount
    end
    return q.state .. "\nProgress: " .. p.count .. "/" .. q.amount
end
local function Combat()
    local q = Working()
    if not q then return end
    local _, event, _, source, sourceName, _, _, dest, destName = CombatLogGetCurrentEventInfo()
    if source and sourceName then names[source] = sourceName end
    if dest and destName then names[dest] = destName end
    if q.tracking.kind ~= "kill" or not dest or not InZone() then return end
    if (source == UnitGUID("player") or source == UnitGUID("pet"))
        and (event:find("_DAMAGE$") or event == "SPELL_INSTAKILL")
        and Matches(q.tracking.targets, destName) then
        tagged[dest] = GetTime()
    end
    if (event == "UNIT_DIED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL")
        and tagged[dest] and GetTime() - tagged[dest] < 300 and not q.progress.seen[dest]
        and Matches(q.tracking.targets, destName) then
        q.progress.seen[dest], tagged[dest] = true, nil
        q.progress.count = math.min(q.amount, q.progress.count + 1)
        UpdateState(q)
    end
end
local professionSpells = {herbalism = 2366, mining = 2575, skinning = 8613, fishing = 7620}
local function SpellName(id)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        return info and info.name
    end
    if GetSpellInfo then return GetSpellInfo(id) end
end
local function Cast(event, unit, castGUID, spellID)
    local q = Working()
    if not q or not q.tracking.profession or unit ~= "player" or not InZone() then return end
    local profession = q.tracking.profession
    local spellName, expected = SpellName(spellID), SpellName(professionSpells[profession])
    if not spellName or not expected or spellName ~= expected then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" or (profession == "fishing" and event == "UNIT_SPELLCAST_CHANNEL_START") then
        gathering = {profession = profession, expires = GetTime() + (profession == "fishing" and 35 or 10)}
        Observe("target")
        Observe("mouseover")
    end
end
local function EligibleSources(q, slot, context)
    if not GetLootSourceInfo then return {} end
    local result, spec = {}, q.tracking
    local sources = {GetLootSourceInfo(slot)}
    for i = 1, #sources, 2 do
        local guid, quantity = sources[i], sources[i + 1]
        if type(guid) == "string" and type(quantity) == "number" then
            local creature = guid:match("^Creature%-") ~= nil
            local object = guid:match("^GameObject%-") ~= nil
            local allowed = spec.kind == "collect_sell" and creature and Matches(spec.targets, names[guid])
            if spec.profession and context and context.profession == spec.profession and context.expires >= GetTime() then
                allowed = (spec.profession == "skinning" and creature and (not spec.targets or Matches(spec.targets, names[guid])))
                    or (spec.profession ~= "skinning" and object)
            end
            if allowed then result[#result + 1] = {guid = guid, quantity = quantity} end
        end
    end
    return result
end
local function CaptureLoot()
    local q = Working()
    if not q or q.tracking.kind == "kill" or not InZone() then return end
    Observe("target")
    Observe("mouseover")
    if not loot then
        loot = {quest = q, slots = {}, baseline = {}, credited = {}, receipts = {}, gathering = gathering}
        gathering = nil -- One successful gathering action authorizes one loot window.
    end
    for slot = 1, GetNumLootItems() do
        local id = ItemID(GetLootSlotLink(slot))
        if id and not loot.slots[slot] then
            local sources = EligibleSources(q, slot, loot.gathering)
            if #sources > 0 and (not q.tracking.itemID or id == q.tracking.itemID) then
                loot.slots[slot] = {id = id, sources = sources}
                loot.baseline[id] = loot.baseline[id] or Count(id)
                -- Request item data now; sale value is checked again on receipt.
                ItemInfo(id)
            end
        end
    end
end
local function SettleLoot(session)
    local q = Working()
    if not session or not q or session.quest ~= q then return end
    for _, entry in pairs(session.slots) do
        if entry.cleared and not entry.done then
            local _, _, _, _, _, _, _, _, _, _, price = ItemInfo(entry.id)
            if q.tracking.kind ~= "collect_sell" or (price and price > 0) then
                local available = math.min(session.receipts[entry.id] or 0,
                    math.max(0, Count(entry.id) - session.baseline[entry.id] - (session.credited[entry.id] or 0)))
                for _, source in ipairs(entry.sources) do
                    local received = math.min(available, source.quantity)
                    if received > 0 then
                        if q.tracking.kind == "collect_sell" then
                            q.progress.collected = math.min(q.amount, q.progress.collected + received)
                            q.progress.held[entry.id] = (q.progress.held[entry.id] or 0) + received
                            q.progress.inventory[entry.id] = Count(entry.id)
                        elseif q.tracking.kind == "nodes" then
                            if not q.progress.seen[source.guid] then
                                q.progress.seen[source.guid] = true
                                q.progress.count = math.min(q.amount, q.progress.count + 1)
                            end
                        else
                            q.progress.count = math.min(q.amount, q.progress.count + received)
                        end
                        source.quantity = source.quantity - received
                        available = available - received
                        session.credited[entry.id] = (session.credited[entry.id] or 0) + received
                        session.receipts[entry.id] = session.receipts[entry.id] - received
                        UpdateState(q)
                    end
                end
                local remaining = 0
                for _, source in ipairs(entry.sources) do remaining = remaining + source.quantity end
                entry.done = remaining == 0
            end
        end
    end
end
local function LootPattern(format)
    if not format then return nil end
    return "^" .. format:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
        :gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)") .. "$"
end
local function LootReceipt(message)
    local q = Working()
    if not q then return end
    local link, quantity
    local multiple = LootPattern(LOOT_ITEM_SELF_MULTIPLE)
    if multiple then link, quantity = message:match(multiple) end
    if not link then
        local single = LootPattern(LOOT_ITEM_SELF)
        if single then link = message:match(single); quantity = 1 end
    end
    local id = ItemID(link)
    if not id then return end -- Other players, trades, purchases and quest rewards.
    local function Apply(session)
        if not session or session.quest ~= q then return false end
        for _, entry in pairs(session.slots) do
            if entry.id == id and not entry.done then
                session.receipts[id] = (session.receipts[id] or 0) + (tonumber(quantity) or 1)
                SettleLoot(session)
                return true
            end
        end
        return false
    end
    if loot then Apply(loot); return end
    for i = #pendingLoot, 1, -1 do
        if pendingLoot[i].expires >= GetTime() and Apply(pendingLoot[i]) then return end
    end
end
local function Buyback()
    local result = {}
    for slot = 1, GetNumBuybackItems() do
        local id = ItemID(GetBuybackItemLink(slot))
        local _, _, price, quantity = GetBuybackItemInfo(slot)
        if id and quantity then result[id] = (result[id] or 0) + quantity end
    end
    return result
end
local function BagSlots()
    local slots = {}
    local size = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
    local link = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
    if size and link then
        for bag = 0, NUM_BAG_SLOTS or 4 do
            for slot = 1, size(bag) do slots[bag .. ":" .. slot] = ItemID(link(bag, slot)) end
        end
    end
    return slots
end
local function StartMerchant()
    local q = Working()
    if not q or q.tracking.kind ~= "collect_sell" then return end
    merchant = {quest = q, counts = {}, buyback = Buyback(), money = GetMoney(), slots = BagSlots(), intents = {}}
    for id in pairs(q.progress.held) do merchant.counts[id] = Count(id) end
end
local function SettleMerchant(session)
    local q = Working()
    if not session or not q or session.quest ~= q then return end
    local merchant = session
    local now, money = Buyback(), GetMoney()
    local budget = math.max(0, money - merchant.money)
    for id, previous in pairs(merchant.counts) do
        local current = Count(id)
        local lost = math.max(0, previous - current)
        local newBuyback = math.max(0, (now[id] or 0) - (merchant.buyback[id] or 0))
        -- A full buyback list can replace an identical stack without changing
        -- its totals. Also require an observed sell action in that case.
        if merchant.intents[id] then newBuyback = math.max(newBuyback, now[id] or 0) end
        local _, _, _, _, _, _, _, _, _, _, price = ItemInfo(id)
        if lost > 0 then
            local sold = 0
            if price and price > 0 then
                sold = math.min(lost, newBuyback, q.progress.held[id] or 0, math.floor(budget / price))
                budget = budget - sold * price
            end
            q.progress.sold = math.min(q.amount, q.progress.sold + sold)
            q.progress.held[id] = math.max(0, (q.progress.held[id] or 0) - lost)
            UpdateState(q)
        end
        merchant.counts[id] = current
        q.progress.inventory[id] = current
    end
    merchant.buyback, merchant.money = now, money
    merchant.slots, merchant.intents = BagSlots(), {}
end
local function ScheduleMerchant(session)
    if not session or session.pending then return end
    session.pending = true
    C_Timer.After(0.2, function()
        session.pending = false
        SettleMerchant(session)
    end)
end
local function SaleIntent(bag, slot)
    if not merchant then return end
    local id = merchant.slots[bag .. ":" .. slot]
    if id then merchant.intents[id] = true end
    ScheduleMerchant(merchant)
end
local function ReconcileHeld()
    local q = Working()
    if q and q.tracking.kind == "collect_sell" then
        for id, count in pairs(q.progress.held) do
            local current = Count(id)
            local previous = tonumber(q.progress.inventory[id]) or current
            local lost = math.max(0, previous - current)
            q.progress.held[id] = math.max(0, math.min(current, (tonumber(count) or 0) - lost))
            q.progress.inventory[id] = current
        end
    end
end
local events = CreateFrame("Frame")
function Tracking.Initialize(saved, resolver, callback)
    db, resolve, changed = saved, resolver, callback
    db.completedQuests = type(db.completedQuests) == "table" and db.completedQuests or {}
    if db.activeQuest then Normalize(db.activeQuest) end
    for _, event in ipairs({"COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD",
        "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "LOOT_READY", "LOOT_OPENED", "LOOT_SLOT_CLEARED", "LOOT_CLOSED",
        "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "BAG_UPDATE_DELAYED", "MERCHANT_SHOW", "MERCHANT_CLOSED",
        "MERCHANT_UPDATE", "PLAYER_MONEY", "GET_ITEM_INFO_RECEIVED", "CHAT_MSG_LOOT"}) do
        events:RegisterEvent(event)
    end
    if not Tracking.hooked and hooksecurefunc then
        if C_Container and C_Container.UseContainerItem then hooksecurefunc(C_Container, "UseContainerItem", SaleIntent) end
        if UseContainerItem then hooksecurefunc("UseContainerItem", SaleIntent) end
        Tracking.hooked = true
    end
end
-- Public event adapter permits deterministic tests without touching a character.
function Tracking.OnEvent(event, ...)
    if not db then return end
    if event == "CHAT_MSG_LOOT" then LootReceipt(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then Combat()
    elseif event == "PLAYER_UPDATE_RESTING" then Refresh()
    elseif event == "PLAYER_ENTERING_WORLD" then ResetTransient(); ReconcileHeld(); Refresh()
    elseif event == "PLAYER_TARGET_CHANGED" then Observe("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then Observe("mouseover")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_CHANNEL_START" then Cast(event, ...)
    elseif event == "LOOT_READY" or event == "LOOT_OPENED" then CaptureLoot()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        local session = loot
        if session and session.slots[slot] then
            session.slots[slot].cleared = true
            SettleLoot(session)
            C_Timer.After(0.2, function() SettleLoot(session) end)
        end
    elseif event == "LOOT_CLOSED" then
        local session = loot
        loot = nil
        if session then session.expires = GetTime() + 5; pendingLoot[#pendingLoot + 1] = session end
        C_Timer.After(0.2, function() SettleLoot(session) end)
        C_Timer.After(1, function() SettleLoot(session) end)
    elseif event == "MERCHANT_SHOW" then StartMerchant()
    elseif event == "MERCHANT_CLOSED" then
        local session = merchant
        C_Timer.After(0.2, function()
            SettleMerchant(session)
            if merchant == session then merchant = nil end
            ReconcileHeld()
        end)
    elseif event == "MERCHANT_UPDATE" or event == "PLAYER_MONEY" then ScheduleMerchant(merchant)
    elseif event == "BAG_UPDATE_DELAYED" or event == "GET_ITEM_INFO_RECEIVED" then
        SettleLoot(loot)
        for i = #pendingLoot, 1, -1 do
            if pendingLoot[i].expires < GetTime() then table.remove(pendingLoot, i)
            else SettleLoot(pendingLoot[i]) end
        end
        if merchant then ScheduleMerchant(merchant) else ReconcileHeld() end
    end
end
events:SetScript("OnEvent", function(_, event, ...) Tracking.OnEvent(event, ...) end)
