local _, ns = ...
local Tracking = {}
ns.Tracking = Tracking
local db, changed, resolve
local function Public(value) return not (issecretvalue and issecretvalue(value)) end
local function Read(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok and Public(value) then return value end
end
local names, loot, gathering, merchant, smelt = {}, nil, nil, nil, nil
local craftEventAvailable, smeltStartAvailable, pvpEventAvailable = false, false, false
local killEvidence = {}
local pendingLoot = {}
local ACTIVE, READY, COMPLETED = "Active", "Ready to Turn In", "Completed"
local statisticCategories = {Kill = true, ["Supply"] = true, Hunt = true, Gather = true, PvP = true}
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
    local quest = db and db.activeQuest
    local zoneName = quest and quest.zone
    local zone = ns.Database and quest and ns.Database.zones[quest.zoneId]
    local mapIDs = {}
    for _, id in ipairs(quest and quest.zoneMapIDs or zone and zone.mapIDs or {}) do mapIDs[id] = true end
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local id = C_Map.GetBestMapForUnit("player")
        for _ = 1, 12 do
            if mapIDs[id] then return true end -- Classic/Forever maps and child maps.
            local info = id and C_Map.GetMapInfo(id)
            if not info or not info.parentMapID or info.parentMapID == 0 then break end
            id = info.parentMapID
        end
    end
    return GetRealZoneText and GetRealZoneText() == zoneName
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
local function NPCID(guid)
    if not Public(guid) or type(guid) ~= "string" then return nil end
    return tonumber(guid:match("^Creature%-[^%-]+%-[^%-]+%-[^%-]+%-[^%-]+%-(%d+)%-"))
end
local function TargetMatches(spec, name, guid)
    if spec.npcID or spec.npcIDs then
        local id = NPCID(guid)
        return id ~= nil and (id == spec.npcID or Matches(spec.npcIDs, id))
    end
    return Matches(spec.targets, name)
end
local function Observe(unit)
    if not Public(unit) then return end
    local guid, name = UnitGUID(unit), UnitName(unit)
    if Public(guid) and Public(name) and type(guid) == "string" and type(name) == "string" then
        names[guid] = name
    end
end
local function ResetTransient()
    names, loot, gathering, merchant, smelt = {}, nil, nil, nil, nil
    killEvidence = {}
    pendingLoot = {}
end
local function HonorableTotal(preferred)
    -- Lifetime honorable kills do not reset when a session ends. Fall back to
    -- the session counter on clients that do not expose lifetime statistics.
    local sources = {{"lifetime", GetPVPLifetimeStats}, {"session", GetPVPSessionStats}}
    for _, source in ipairs(sources) do
        if not preferred or source[1] == preferred then
            local value = Read(source[2])
            if type(value) == "number" and value >= 0 and value == math.floor(value) then
                return value, source[1]
            end
        end
    end
end
local function UpdateState(q)
    local amount = q.tracking.kind == "supply" and q.progress.sold
        or q.tracking.kind == "mining_workorder" and (q.tracking.handoff == "sale" and q.progress.sold or q.progress.smelted)
        or q.progress.count
    if amount >= q.amount and q.state == ACTIVE then
        q.state = READY
        print('|cffffd27fClassic Questboard:|r "' .. q.title .. '" is Ready to Turn In. Visit a rested location and open /cq.')
    end
    Refresh()
end
local function Normalize(q)
    if type(q) ~= "table" then return end
    q.tracking = resolve(q)
    q.state = q.state == READY and READY or ACTIVE
    q.progress = type(q.progress) == "table" and q.progress or {}
    for _, field in ipairs({"count", "collected", "sold", "mined", "smelted"}) do
        -- Debug target reductions must not discard previously earned progress.
        q.progress[field] = math.max(0, math.min(1000, tonumber(q.progress[field]) or 0))
    end
    q.progress.held = type(q.progress.held) == "table" and q.progress.held or {}
    q.progress.seen = type(q.progress.seen) == "table" and q.progress.seen or {}
    q.progress.inventory = type(q.progress.inventory) == "table" and q.progress.inventory or {}
    for id, count in pairs(q.progress.held) do
        if type(id) ~= "number" or type(count) ~= "number" or count < 0 then q.progress.held[id] = nil end
    end
    -- Older quests have no progress; preserve their target and rolled amount.
    if q.tracking then
        local count = q.tracking.kind == "supply" and q.progress.sold
            or q.tracking.kind == "mining_workorder" and (q.tracking.handoff == "sale" and q.progress.sold or q.progress.smelted)
            or q.progress.count
        q.state = count >= q.amount and READY or ACTIVE
        if q.tracking.kind == "pvp_honor" then
            local total, source = HonorableTotal()
            if total and (q.progress.honorSource ~= source or type(q.progress.honorBaseline) ~= "number"
                or total < q.progress.honorBaseline) then
                q.progress.honorBaseline, q.progress.honorSource = total, source
            end
        end
    else
        q.state = ACTIVE
    end
end
function Tracking.CanTrack(q)
    local spec = resolve and resolve(q) or q.tracking
    if not spec then return false end
    if spec.kind == "pvp_honor" then return pvpEventAvailable and HonorableTotal() ~= nil end
    if spec.kind == "mining_workorder" then return craftEventAvailable or smeltStartAvailable end
    return true
end
function Tracking.Accept(q, bypassLocation)
    if not db or db.activeQuest or (not bypassLocation and not Tracking.IsResting()) then return false end
    if not Tracking.CanTrack(q) then return false end
    q.state, q.progress, q.acceptedAt = ACTIVE, {}, time()
    Normalize(q)
    db.activeQuest = q
    db.statistics.accepted = db.statistics.accepted + 1
    if statisticCategories[q.categoryName] then
        db.statistics.acceptedByCategory[q.categoryName] = db.statistics.acceptedByCategory[q.categoryName] + 1
    end
    ResetTransient()
    return true
end
function Tracking.Abandon()
    if not db or not db.activeQuest then return false end
    db.statistics.abandoned = db.statistics.abandoned + 1
    local q = db.activeQuest
    if statisticCategories[q.categoryName] then
        db.statistics.abandonedByCategory[q.categoryName] = db.statistics.abandonedByCategory[q.categoryName] + 1
    end
    q.state, q.progress, q.acceptedAt, q.completedAt = nil, nil, nil, nil
    db.activeQuest = nil
    ResetTransient()
    return true
end
function Tracking.TurnIn(bypassLocation)
    local q = db and db.activeQuest
    if not q or q.state ~= READY or (not bypassLocation and not Tracking.IsResting()) then return false end
    db.statistics.handedIn = db.statistics.handedIn + 1
    if statisticCategories[q.categoryName] then
        local counts = db.statistics.completedByCategory
        counts[q.categoryName] = counts[q.categoryName] + 1
    end
    q.state, q.completedAt = COMPLETED, time()
    db.completedQuests[#db.completedQuests + 1] = {
        id = q.id, title = q.title, zone = q.zone, amount = q.amount,
        state = COMPLETED, acceptedAt = q.acceptedAt, completedAt = q.completedAt,
    }
    while #db.completedQuests > 20 do table.remove(db.completedQuests, 1) end
    db.activeQuest = nil
    ResetTransient()
    print('|cffffd27fClassic Questboard:|r Completed "' .. q.title .. '".')
    return true
end
function Tracking.GetStatistics()
    local stats = db and db.statistics or {}
    local result = {accepted = stats.accepted or 0, handedIn = stats.handedIn or 0, abandoned = stats.abandoned or 0}
    for _, field in ipairs({"acceptedByCategory", "completedByCategory", "abandonedByCategory"}) do
        result[field] = {}
        for category in pairs(statisticCategories) do
            result[field][category] = stats[field] and stats[field][category] or 0
        end
    end
    return result
end

function Tracking.DebugResetStatistics(enabled)
    if not enabled or not db then return false end
    for _, key in ipairs({"accepted", "handedIn", "abandoned"}) do db.statistics[key] = 0 end
    for _, field in ipairs({"acceptedByCategory", "completedByCategory", "abandonedByCategory"}) do
        db.statistics[field] = {}
        for category in pairs(statisticCategories) do db.statistics[field][category] = 0 end
    end
    Refresh()
    return true
end

function Tracking.ProgressText(q)
    if not q.tracking then return "Tracking unavailable for this legacy objective. You may abandon it." end
    local p = q.progress
    if q.tracking.kind == "supply" then
        return q.state .. "\nCollected: " .. p.collected .. "/" .. q.amount .. "   Sold: " .. p.sold .. "/" .. q.amount
    end
    if q.tracking.kind == "mining_workorder" then
        local result = q.state .. "\nMined: " .. p.mined .. "/" .. q.amount .. "   Smelted: " .. p.smelted .. "/" .. q.amount
        if q.tracking.handoff == "sale" then result = result .. "   Sold: " .. p.sold .. "/" .. q.amount end
        return result
    end
    return q.state .. "\nProgress: " .. p.count .. "/" .. q.amount
end
function Tracking.DebugAddProgress(enabled)
    local q = Working()
    if not enabled or not q then return false end
    if q.tracking.kind == "supply" then
        local field = q.progress.collected < q.amount and "collected" or "sold"
        q.progress[field] = math.min(q.amount, q.progress[field] + 1)
    elseif q.tracking.kind == "mining_workorder" then
        local p = q.progress
        if p.mined < q.amount then p.mined = p.mined + 1
        elseif p.smelted < q.amount then p.smelted = p.smelted + 1
        elseif q.tracking.handoff == "sale" then p.sold = math.min(q.amount, p.sold + 1)
        else return false end
    elseif q.tracking.kind == "kill" or q.tracking.kind == "gather" or q.tracking.kind == "nodes" or q.tracking.kind == "pvp_honor" then
        q.progress.count = math.min(q.amount, q.progress.count + 1)
    else
        return false
    end
    UpdateState(q)
    return true
end

function Tracking.DebugSetAmount(enabled, amount, expected)
    local q = db and db.activeQuest
    amount = tonumber(amount)
    if not enabled or not q or q ~= expected or not q.tracking
        or (q.state ~= ACTIVE and q.state ~= READY)
        or not amount or amount ~= amount or amount < 1 or amount > 1000 or amount ~= math.floor(amount) then
        return false
    end
    q.amount = amount
    local count = q.tracking.kind == "supply" and q.progress.sold
        or q.tracking.kind == "mining_workorder" and (q.tracking.handoff == "sale" and q.progress.sold or q.progress.smelted)
        or q.progress.count
    if count < amount then q.state = ACTIVE end
    UpdateState(q)
    return true
end

function Tracking.TooltipText(unit)
    local q = db and db.activeQuest
    if not q or not q.tracking or not Public(unit) or type(unit) ~= "string" then return nil end
    if q.tracking.kind == "mining_workorder" then return nil end
    local name = Read(UnitName, unit)
    if type(name) ~= "string" or Read(UnitPlayerControlled, unit) ~= false then return nil end
    if not TargetMatches(q.tracking, name, Read(UnitGUID, unit)) then return nil end
    local p = q.progress
    local action = q.tracking.kind == "kill" and "Kill " or "Collect from "
    local count = q.tracking.kind == "supply" and p.collected or p.count
    return "Classic Questboard: " .. action .. name .. " " .. count .. "/" .. q.amount
        .. (q.state == READY and " (Ready to Turn In)" or "")
end
-- Adapted from Azeroth Fieldbook's BestiaryJournal living-observation,
-- terminal eligibility, expiry and GUID-deduplication approach. No combat log.
local function CreatureGUID(guid)
    return Public(guid) and type(guid) == "string" and #guid <= 128
        and guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-%d+%-%w+$") ~= nil
end
local function PruneKills(at)
    for guid, entry in pairs(killEvidence) do
        if at < entry.seenAt or at > (entry.deadline or entry.seenAt + 120) then killEvidence[guid] = nil end
    end
end
local function ClearTerminal(entry)
    entry.dead, entry.eligible, entry.rejected, entry.deadline, entry.tagged = nil, nil, nil, nil, nil
end
local threatActors = {"player", "pet", "party1", "partypet1", "party2", "partypet2",
    "party3", "partypet3", "party4", "partypet4"}
local function GroupHasThreat(unit)
    if type(UnitThreatSituation) ~= "function" then return false end
    for _, actor in ipairs(threatActors) do
        if Read(UnitExists, actor) == true then
            -- Zero is valid: it means this party unit is on the mob's threat
            -- list without being its primary target. Nil/secret is no proof.
            local threat = Read(UnitThreatSituation, actor, unit)
            if type(threat) == "number" and threat >= 0 and threat <= 3 then return true end
        end
    end
    return false
end
local function SampleEligibility(entry, unit, guid, livingCombat)
    if Read(UnitGUID, unit) ~= guid then return end
    local exists, controlled, denied = Read(UnitExists, unit), Read(UnitPlayerControlled, unit), Read(UnitIsTapDenied, unit)
    if Read(UnitGUID, unit) ~= guid then return end
    if controlled == true or denied == true then
        entry.rejected, entry.eligible = true, nil
    elseif exists == true and controlled == false and denied == false then
        if livingCombat then
            entry.tagged = true
        else
            entry.eligible = true
        end
    end
end
local function CompleteKill(q, guid, entry)
    if not entry.dead or entry.tagged ~= true or entry.eligible ~= true or entry.rejected or q.progress.seen[guid] then return end
    if not InZone() then return end
    -- Consume evidence before callbacks and persist the GUID across reloads.
    killEvidence[guid], q.progress.seen[guid] = nil, true
    q.progress.count = math.min(q.amount, q.progress.count + 1)
    UpdateState(q)
end
local function ObserveKill(unit)
    local q = Working()
    if not q or q.tracking.kind ~= "kill" or not InZone() then return end
    local guid, at = Read(UnitGUID, unit), Read(GetTime)
    if not CreatureGUID(guid) or type(at) ~= "number" or q.progress.seen[guid] then return end
    PruneKills(at)
    local dead = Read(UnitIsDead, unit)
    if Read(UnitGUID, unit) ~= guid then return end
    local entry = killEvidence[guid]
    if dead == false then
        local name = Read(UnitName, unit)
        if not TargetMatches(q.tracking, name, guid) or Read(UnitGUID, unit) ~= guid then return end
        if not entry then
            local count, oldestGUID, oldestAt = 0, nil, math.huge
            for key, value in pairs(killEvidence) do
                count = count + 1
                if value.seenAt < oldestAt then oldestGUID, oldestAt = key, value.seenAt end
            end
            if count >= 64 then killEvidence[oldestGUID] = nil end
            entry = {}; killEvidence[guid] = entry
        end
        entry.seenAt = at
        if Read(UnitAffectingCombat, unit) == true then
            -- An untapped, idle mob also reports tap-not-denied. Only remember
            -- the party's permitted tap while this mob is alive and engaged.
            if GroupHasThreat(unit) then SampleEligibility(entry, unit, guid, true) end
        else
            ClearTerminal(entry) -- The mob reset; previous tap/death evidence is stale.
        end
        return
    end
    if dead ~= true or not entry then return end
    entry.dead, entry.deadline = true, entry.deadline or at + 10
    SampleEligibility(entry, unit, guid)
    CompleteKill(q, guid, entry)
end
local function DeathEvent(event, guid)
    local q = Working()
    if not q or q.tracking.kind ~= "kill" or not CreatureGUID(guid) or not InZone() then return end
    local at = Read(GetTime)
    if type(at) ~= "number" then return end
    PruneKills(at)
    local entry = killEvidence[guid]
    if not entry or q.progress.seen[guid] then return end
    entry.deadline = entry.deadline or at + 10
    -- PARTY_KILL can precede a readable death: it samples eligibility only.
    if event == "UNIT_DIED" then entry.dead = true end
    for _, unit in ipairs({"target", "mouseover"}) do SampleEligibility(entry, unit, guid) end
    CompleteKill(q, guid, entry)
end
function Tracking.PollKills()
    ObserveKill("target")
    ObserveKill("mouseover")
end
local function HonorKill(unit)
    local q = Working()
    if not q or q.tracking.kind ~= "pvp_honor" or unit ~= "player" then return end
    local function ReconcileHonor()
        if Working() ~= q then return end
        local total, source = HonorableTotal(q.progress.honorSource)
        if not total then return end
        local previous = q.progress.honorBaseline
        if q.progress.honorSource ~= source or type(previous) ~= "number" or total < previous then
            q.progress.honorBaseline, q.progress.honorSource = total, source
            return
        end
        if total > previous then
            q.progress.honorBaseline = total
            q.progress.count = math.min(q.amount, q.progress.count + total - previous)
            UpdateState(q)
        end
    end
    ReconcileHonor()
    -- The PvP counter can update after its event. A delayed read also handles
    -- several kills being merged into one statistics change.
    C_Timer.After(1, ReconcileHonor)
end
local function HealthEvent(unit)
    if not Public(unit) or type(unit) ~= "string" then return end
    for _, watched in ipairs({"target", "mouseover"}) do
        if unit == watched or Read(UnitIsUnit, unit, watched) == true then ObserveKill(watched) end
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
    if not Public(unit) or not Public(spellID) then return end
    local q = Working()
    if not q or not q.tracking.profession or unit ~= "player" or not InZone() then return end
    local profession = q.tracking.profession
    local spellName, expected = SpellName(spellID), SpellName(professionSpells[profession])
    if not Public(spellName) or not Public(expected) or not spellName or not expected or spellName ~= expected then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" or (profession == "fishing" and event == "UNIT_SPELLCAST_CHANNEL_START") then
        gathering = {profession = profession, expires = GetTime() + (profession == "fishing" and 35 or 10)}
        Observe("target")
        Observe("mouseover")
    end
end
local function CreditSmelt(q, quantity)
    local p = q.progress
    local credited = math.min(quantity, q.amount - p.smelted, p.mined - p.smelted)
    if credited <= 0 then return 0 end
    p.smelted = p.smelted + credited
    if q.tracking.handoff == "sale" then
        local itemID = q.tracking.itemID
        p.held[itemID] = (p.held[itemID] or 0) + credited
        p.inventory[itemID] = Count(itemID)
    end
    UpdateState(q)
    return credited
end
local function Crafted(result)
    local q = Working()
    if not q or q.tracking.kind ~= "mining_workorder" or type(result) ~= "table" then return end
    local itemID = result.itemID
    if not Public(itemID) or not Public(result.quantity) then return end
    local quantity = tonumber(result.quantity)
    if itemID ~= q.tracking.itemID then return end
    local recipeID = result.recipeID or result.spellID
    if recipeID and not Public(recipeID) then return end
    if recipeID and recipeID ~= q.tracking.smeltSpellID then return end
    if not quantity or quantity < 1 or quantity ~= math.floor(quantity) then return end
    if smelt and smelt.quest == q and smelt.credited then smelt = nil; return end
    CreditSmelt(q, quantity)
    if smelt and smelt.quest == q then smelt = nil end -- The result supersedes bag-delta fallback.
end
local function ReconcileSmelt()
    local q = Working()
    if not smelt or not smelt.succeeded or not q or smelt.quest ~= q then return end
    if GetTime() > smelt.expires then smelt = nil; return end
    if not smelt.credited and Count(q.tracking.itemID) > smelt.baseline then
        local credited = CreditSmelt(q, 1) -- Current work orders produce one bar per cast.
        if credited > 0 then smelt.credited = true end
    end
end
local function ObserveSmelt(event, unit, spellID)
    local q = Working()
    if not q or q.tracking.kind ~= "mining_workorder"
        or not Public(unit) or not Public(spellID) or unit ~= "player"
        or spellID ~= q.tracking.smeltSpellID then return end
    if event == "UNIT_SPELLCAST_START" then
        smelt = {quest = q, baseline = Count(q.tracking.itemID), expires = GetTime() + 15}
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and smelt and smelt.quest == q then
        smelt.succeeded = true
        ReconcileSmelt()
        C_Timer.After(0.3, ReconcileSmelt)
        C_Timer.After(1, ReconcileSmelt)
    end
end
local function EligibleSources(q, slot, context)
    if not GetLootSourceInfo then return {} end
    local result, spec = {}, q.tracking
    local sources = {GetLootSourceInfo(slot)}
    for i = 1, #sources, 2 do
        local guid, quantity = sources[i], sources[i + 1]
        if Public(guid) and Public(quantity) and type(guid) == "string" and type(quantity) == "number" then
            local creature = guid:match("^Creature%-") ~= nil
            local object = guid:match("^GameObject%-") ~= nil
            local allowed = spec.kind == "supply" and creature and TargetMatches(spec, names[guid], guid)
            if spec.profession and context and context.profession == spec.profession and context.expires >= GetTime() then
                allowed = (spec.profession == "skinning" and creature and
                    (not (spec.targets or spec.npcID or spec.npcIDs) or TargetMatches(spec, names[guid], guid)))
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
            local wanted = q.tracking.kind == "mining_workorder" and q.tracking.oreItemID or q.tracking.itemID
            if #sources > 0 and (not wanted or id == wanted) then
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
            if q.tracking.kind ~= "supply" or (price and price > 0) then
                local available = math.min(session.receipts[entry.id] or 0,
                    math.max(0, Count(entry.id) - session.baseline[entry.id] - (session.credited[entry.id] or 0)))
                for _, source in ipairs(entry.sources) do
                    local received = math.min(available, source.quantity)
                    if received > 0 then
                        if q.tracking.kind == "supply" then
                            q.progress.collected = math.max(q.progress.collected, math.min(q.amount, q.progress.collected + received))
                            q.progress.held[entry.id] = (q.progress.held[entry.id] or 0) + received
                            q.progress.inventory[entry.id] = Count(entry.id)
                        elseif q.tracking.kind == "mining_workorder" then
                            q.progress.mined = math.min(q.amount, q.progress.mined + received)
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
    if not Public(message) or type(message) ~= "string" then return end
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
local function InteractingMerchantID()
    return NPCID(Read(UnitGUID, "npc"))
end
local function StartMerchant()
    local q = Working()
    if not q or (q.tracking.kind ~= "supply"
        and not (q.tracking.kind == "mining_workorder" and q.tracking.handoff == "sale")) then return end
    if not q.tracking.vendorID or InteractingMerchantID() ~= q.tracking.vendorID then
        merchant = nil
        return
    end
    merchant = {quest = q, counts = {}, buyback = Buyback(), slots = BagSlots(), intents = {},
        pendingLoss = {}, pendingBuyback = {}}
    for id in pairs(q.progress.held) do merchant.counts[id] = Count(id) end
end
local function SettleMerchant(session)
    local q = Working()
    if not session or session ~= merchant or not q or session.quest ~= q then return end
    local merchant = session
    local now = Buyback()
    for id, previous in pairs(merchant.counts) do
        local current = Count(id)
        local lost = math.max(0, previous - current)
        local newBuyback = math.max(0, (now[id] or 0) - (merchant.buyback[id] or 0))
        -- A full buyback list can replace an identical stack without changing
        -- its totals. Also require an observed sell action in that case.
        if merchant.intents[id] then newBuyback = math.max(newBuyback, now[id] or 0) end
        merchant.pendingLoss[id] = (merchant.pendingLoss[id] or 0) + lost
        merchant.pendingBuyback[id] = (merchant.pendingBuyback[id] or 0) + newBuyback
        local _, _, _, _, _, _, _, _, _, _, price = ItemInfo(id)
        if price and price > 0 then
            local sold = math.min(merchant.pendingLoss[id], merchant.pendingBuyback[id], q.progress.held[id] or 0)
            merchant.pendingLoss[id] = merchant.pendingLoss[id] - sold
            merchant.pendingBuyback[id] = merchant.pendingBuyback[id] - sold
            q.progress.sold = math.min(q.amount, q.progress.sold + sold)
            q.progress.held[id] = math.max(0, (q.progress.held[id] or 0) - sold)
            if sold > 0 then UpdateState(q) end
        end
        merchant.counts[id] = current
        q.progress.inventory[id] = current
    end
    merchant.buyback = now
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
    if q and (q.tracking.kind == "supply" or
        (q.tracking.kind == "mining_workorder" and q.tracking.handoff == "sale")) then
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
local function RegisterOptional(event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then return false end
    return pcall(events.RegisterEvent, events, event)
end
function Tracking.Initialize(saved, resolver, callback)
    db, resolve, changed = saved, resolver, callback
    db.statistics = type(db.statistics) == "table" and db.statistics or {}
    for _, key in ipairs({"accepted", "handedIn", "abandoned"}) do
        local value = tonumber(db.statistics[key])
        db.statistics[key] = value and value == value and value >= 0 and value < math.huge and math.floor(value) or 0
    end
    for _, field in ipairs({"acceptedByCategory", "completedByCategory", "abandonedByCategory"}) do
        db.statistics[field] = type(db.statistics[field]) == "table" and db.statistics[field] or {}
        for category in pairs(statisticCategories) do
            local value = tonumber(db.statistics[field][category])
            db.statistics[field][category] = value and value == value and value >= 0 and value < math.huge and math.floor(value) or 0
        end
    end
    db.completedQuests = type(db.completedQuests) == "table" and db.completedQuests or {}
    if db.activeQuest then
        Normalize(db.activeQuest)
        if db.activeQuest.tracking and db.activeQuest.tracking.kind == "pvp_honor" then
            local total, source = HonorableTotal()
            if total then
                db.activeQuest.progress.honorBaseline = total
                db.activeQuest.progress.honorSource = source
            end
        end
    end
    for _, event in ipairs({"PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD",
        "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "LOOT_READY", "LOOT_OPENED", "LOOT_SLOT_CLEARED", "LOOT_CLOSED",
        "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "BAG_UPDATE_DELAYED", "MERCHANT_SHOW", "MERCHANT_CLOSED",
        "MERCHANT_UPDATE", "PLAYER_MONEY", "GET_ITEM_INFO_RECEIVED", "CHAT_MSG_LOOT", "UNIT_HEALTH", "PLAYER_REGEN_ENABLED"}) do
        events:RegisterEvent(event)
    end
    -- These events are optional on older clients. A missing craft-result event
    -- uses a matching smelt cast plus a resulting bag increase instead.
    RegisterOptional("PARTY_KILL")
    RegisterOptional("UNIT_DIED")
    craftEventAvailable = RegisterOptional("TRADE_SKILL_ITEM_CRAFTED_RESULT")
    smeltStartAvailable = RegisterOptional("UNIT_SPELLCAST_START")
    pvpEventAvailable = RegisterOptional("PLAYER_PVP_KILLS_CHANGED")
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
    elseif event == "UNIT_DIED" then DeathEvent(event, ...)
    elseif event == "PARTY_KILL" then local _, victim = ...; DeathEvent(event, victim)
    elseif event == "PLAYER_PVP_KILLS_CHANGED" then HonorKill(...)
    elseif event == "UNIT_HEALTH" then HealthEvent(...)
    elseif event == "PLAYER_REGEN_ENABLED" then Tracking.PollKills()
    elseif event == "PLAYER_UPDATE_RESTING" then Refresh()
    elseif event == "PLAYER_ENTERING_WORLD" then ResetTransient(); ReconcileHeld(); Refresh()
    elseif event == "PLAYER_TARGET_CHANGED" then Observe("target"); ObserveKill("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then Observe("mouseover"); ObserveKill("mouseover")
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        ObserveSmelt(event, unit, spellID)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then Cast(event, ...) end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then Cast(event, ...)
    elseif event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then Crafted(...)
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
        C_Timer.After(1, function()
            SettleMerchant(session)
            if merchant == session then
                merchant = nil
                ReconcileHeld()
            end
        end)
    elseif event == "MERCHANT_UPDATE" or event == "PLAYER_MONEY" then ScheduleMerchant(merchant)
    elseif event == "BAG_UPDATE_DELAYED" or event == "GET_ITEM_INFO_RECEIVED" then
        ReconcileSmelt()
        SettleLoot(loot)
        for i = #pendingLoot, 1, -1 do
            if pendingLoot[i].expires < GetTime() then table.remove(pendingLoot, i)
            else SettleLoot(pendingLoot[i]) end
        end
        if merchant then ScheduleMerchant(merchant) else ReconcileHeld() end
    end
end
events:SetScript("OnEvent", function(_, event, ...) Tracking.OnEvent(event, ...) end)

local scanElapsed = 0
events:SetScript("OnUpdate", function(_, elapsed)
    local q = Working()
    if not q or q.tracking.kind ~= "kill" then scanElapsed = 0; return end
    scanElapsed = scanElapsed + elapsed
    if scanElapsed < 0.2 then return end
    scanElapsed = 0
    Tracking.PollKills()
end)
