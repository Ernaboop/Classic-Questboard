local _, ns = ...
local Database = {}
ns.Database = Database

local kinds = {"zones", "objectives", "questGivers", "flavourText"}
local base = {zones = {}, objectives = {}, questGivers = {}, flavourText = {}}
local registrationErrors = {}
local registrationOrder, registrationCount = {}, 0
local owner, entries
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end
Database.Copy = Copy

Database.categories = {kill = "Kill", supply = "Supply", hunt = "Hunt", gather = "Gather"}
Database.professions = {
    {id = "herbalism", name = "Herbalism", skillLine = 182},
    {id = "mining", name = "Mining", skillLine = 186},
    {id = "skinning", name = "Skinning", skillLine = 393},
    {id = "fishing", name = "Fishing", skillLine = 356},
}
local professions = {herbalism = true, mining = true, skinning = true, fishing = true}

-- NPC tags describe roles, not zones or quest categories. New tags belong here;
-- objective requirements may combine any number of tags (all must match).
Database.npcTags = {vendor = true, blacksmith = true, innkeeper = true, guard = true,
    questgiver = true, collector = true, farmer = true, fisherman = true,
    trainer = true, quartermaster = true, engineer = true, scout = true, resident = true}

-- Shared by validation, documentation and the editor. Lists use semicolons in
-- the GUI; source files always use normal Lua arrays.
Database.schema = {
    zones = {
        {key = "id", label = "Stable ID", type = "string", required = true},
        {key = "name", label = "Zone name", type = "string", required = true},
        {key = "minLevel", label = "Minimum level", type = "number", required = true},
        {key = "maxLevel", label = "Maximum level", type = "number", required = true},
        {key = "order", label = "Display order", type = "number"},
        {key = "mapIDs", label = "Map IDs (semicolon separated)", type = "numbers", required = true},
    },
    objectives = {
        {key = "id", label = "Stable ID", type = "string", required = true},
        {key = "name", label = "Objective name", type = "string", required = true},
        {key = "zone", label = "Zone", type = "choice", choices = "zones", required = true},
        {key = "category", label = "Category", type = "choice", choices = {"kill", "supply", "hunt", "gather"}, required = true},
        {key = "profession", label = "Profession", type = "choice", choices = {"herbalism", "mining", "skinning", "fishing"}, categories = {gather = true}},
        {key = "classification", label = "Hunt classification", type = "choice", choices = {"rare", "elite"}, categories = {hunt = true}},
        {key = "level", label = "Creature level / skill label", type = "string", required = true},
        {key = "minPlayerLevel", label = "First eligible player level", type = "number", required = true},
        {key = "maxPlayerLevel", label = "Last eligible player level", type = "number", required = true},
        {key = "minAmount", label = "Minimum amount", type = "number", required = true},
        {key = "maxAmount", label = "Maximum amount", type = "number", required = true},
        {key = "location", label = "Objective location", type = "string", required = true},
        {key = "target", label = "Target display label (optional)", type = "string"},
        {key = "targets", label = "Exact creature names (semicolon separated)", type = "strings"},
        {key = "npcID", label = "Creature NPC ID (optional)", type = "number"},
        {key = "npcIDs", label = "Creature NPC IDs (semicolon separated)", type = "numbers"},
        {key = "item", label = "Item display label", type = "string", categories = {supply = true}},
        {key = "itemID", label = "Item ID", type = "number", categories = {supply = true, gather = true}},
        {key = "lootMode", label = "Collected loot", type = "choice", choices = {"item", "any_vendor_item"}, categories = {supply = true}},
        {key = "vendorID", label = "Specific vendor NPC ID (optional)", type = "number", categories = {supply = true}},
        {key = "trackingKind", label = "Gather tracking", type = "choice", choices = {"gather", "nodes", "mining_workorder"}, categories = {gather = true}},
        {key = "requiredNPCTags", label = "Required NPC tags (all)", type = "strings", required = true},
        {key = "minProfessionSkill", label = "Minimum profession skill", type = "number", categories = {gather = true}},
        {key = "oreItemID", label = "Mined ore item ID", type = "number", categories = {gather = true}},
        {key = "oreName", label = "Mined ore name", type = "string", categories = {gather = true}},
        {key = "smeltSpellID", label = "Smelting spell ID", type = "number", categories = {gather = true}},
        {key = "handoff", label = "Final handoff", type = "choice", choices = {"sale"}, categories = {gather = true}},
    },
    questGivers = {
        {key = "id", label = "Stable ID", type = "string", required = true},
        {key = "name", label = "NPC name", type = "string", required = true},
        {key = "npcID", label = "NPC ID", type = "number", required = true},
        {key = "zone", label = "Zone", type = "choice", choices = "zones", required = true},
        {key = "location", label = "Location", type = "string", required = true},
        {key = "faction", label = "Friendly faction", type = "choice", choices = {"Alliance", "Horde", "Neutral"}, required = true},
        {key = "tags", label = "NPC tags (semicolon separated)", type = "strings", required = true},
    },
    flavourText = {
        {key = "id", label = "Stable ID", type = "string", required = true},
        {key = "category", label = "Category", type = "choice", choices = {"kill", "supply", "hunt", "gather"}, required = true},
        {key = "profession", label = "Profession (optional)", type = "choice", choices = {"herbalism", "mining", "skinning", "fishing"}, categories = {gather = true}},
        {key = "zone", label = "Zone (blank = all zones)", type = "choice", choices = "zones"},
        {key = "text", label = "Flavour text", type = "text", required = true},
    },
}

local function Nonempty(value) return type(value) == "string" and value:find("%S") ~= nil end
local function Integer(value) return type(value) == "number" and value == value and value >= 1 and value <= 10000000 and value == math.floor(value) end
local function Contains(list, value)
    for _, item in ipairs(list or {}) do if item == value then return true end end
    return false
end
function Database.HasTags(npc, required)
    if type(npc) ~= "table" or type(npc.tags) ~= "table" or type(required) ~= "table" then return false end
    for _, tag in ipairs(required or {}) do
        if not Contains(npc.tags, tag) then return false end
    end
    return true
end
local function Sorted(map)
    local result = {}
    for _, entry in pairs(map) do result[#result + 1] = entry end
    table.sort(result, function(a, b)
        local x, y = registrationOrder[a.id] or math.huge, registrationOrder[b.id] or math.huge
        if x ~= y then return x < y end
        return a.id < b.id
    end)
    return result
end

local function Error(errors, kind, entry, message)
    entry = type(entry) == "table" and entry or {}
    errors[#errors + 1] = {kind = kind, id = entry.id,
        message = "Zone " .. tostring(entry.zone or (kind == "zones" and entry.id) or "global")
            .. " / " .. tostring(entry.category or kind) .. " / " .. tostring(entry.id or "<missing ID>")
            .. " / " .. tostring(entry.name or entry.text or "<unnamed>") .. ": " .. message}
end
function Database:FormatErrors(errors)
    local lines = {}
    for _, issue in ipairs(errors or {}) do lines[#lines + 1] = issue.message end
    return table.concat(lines, "\n")
end

function Database:Register(kind, entry)
    if not base[kind] then error("Unknown database kind: " .. tostring(kind)) end
    if type(entry) ~= "table" or not Nonempty(entry.id) then
        Error(registrationErrors, kind, entry, "missing stable ID"); return false
    end
    for _, map in pairs(base) do
        if map[entry.id] then Error(registrationErrors, kind, entry, "duplicate ID"); return false end
    end
    base[kind][entry.id] = Copy(entry)
    registrationCount = registrationCount + 1
    registrationOrder[entry.id] = registrationCount
    return true
end
function Database:RegisterZone(zone)
    if type(zone) ~= "table" then return self:Register("zones", zone) end
    local metadata = Copy(zone)
    metadata.objectives, metadata.questGivers, metadata.flavourText = nil, nil, nil
    if not self:Register("zones", metadata) then return false end
    for field, kind in pairs({objectives = "objectives", questGivers = "questGivers", flavourText = "flavourText"}) do
        if zone[field] ~= nil and type(zone[field]) ~= "table" then
            Error(registrationErrors, "zones", zone, field .. " must be an array")
        else
            local count = 0
            for index in pairs(zone[field] or {}) do
                count = count + 1
                if not Integer(index) or index > #(zone[field] or {}) then
                    Error(registrationErrors, "zones", zone, field .. " must be a dense array")
                end
            end
            if count ~= #(zone[field] or {}) then Error(registrationErrors, "zones", zone, field .. " must be a dense array") end
            for _, child in ipairs(zone[field] or {}) do
                local entry = Copy(child)
                if type(entry) == "table" then entry.zone = entry.zone or zone.id end
                if type(entry) == "table" and entry.zone ~= zone.id then
                    Error(registrationErrors, kind, entry, "nested entry must use its containing zone")
                else self:Register(kind, entry) end
            end
        end
    end
    return true
end
function Database:RegisterQuestGiver(entry) return self:Register("questGivers", entry) end
function Database:RegisterFlavour(entry) return self:Register("flavourText", entry) end
function Database:RegisterObjective(entry) return self:Register("objectives", entry) end
function Database:GetBase() return Copy(base) end

function Database:Validate(candidate)
    local errors, ids = {}, {}
    if type(candidate) ~= "table" then
        Error(errors, "zones", {}, "database must be a table")
        return false, errors
    end
    for _, kind in ipairs(kinds) do
        if type(candidate[kind]) ~= "table" then
            Error(errors, kind, {}, "database collection must be a table")
        end
    end
    if #errors > 0 then return false, errors end
    for _, kind in ipairs(kinds) do
        for key, entry in pairs(candidate[kind] or {}) do
            local function Fail(message) Error(errors, kind, entry, message) end
            if type(entry) ~= "table" then
                Fail("entry must be a table")
            else
                if not Nonempty(entry.id) or not entry.id:match("^[%w_%-]+$") then Fail("missing or invalid stable ID") end
                if entry.id ~= key then Fail("entry ID must match its database key") end
                if Nonempty(entry.id) then
                    if ids[entry.id] then Fail("duplicate ID") end
                    ids[entry.id] = true
                end
                local allowed = {}
                for _, field in ipairs(self.schema[kind]) do
                    allowed[field.key] = true
                    local value = entry[field.key]
                    if field.required and value == nil then Fail("missing " .. field.key) end
                    if value ~= nil then
                        if field.categories and not field.categories[entry.category] then Fail(field.key .. " is not valid for this category") end
                        if field.type == "number" and not Integer(value) then Fail(field.key .. " must be a positive whole number")
                        elseif field.type == "boolean" and type(value) ~= "boolean" then Fail(field.key .. " must be true or false")
                        elseif (field.type == "string" or field.type == "text" or field.type == "choice") and not Nonempty(value) then Fail(field.key .. " cannot be blank")
                        elseif field.type == "choice" and type(field.choices) == "table" and not Contains(field.choices, value) then Fail("unknown " .. field.key .. ": " .. tostring(value))
                        elseif field.type == "strings" or field.type == "numbers" then
                            if type(value) ~= "table" or #value == 0 then Fail(field.key .. " must be a non-empty array")
                            else
                                local seen, count = {}, 0
                                for index, item in pairs(value) do
                                    count = count + 1
                                    if not Integer(index) or index > #value then Fail(field.key .. " must be an array") end
                                    if (field.type == "numbers" and not Integer(item)) or (field.type == "strings" and not Nonempty(item)) then Fail("invalid value in " .. field.key) end
                                    if type(item) == "string" or Integer(item) then
                                        if seen[item] then Fail("duplicate value in " .. field.key) end
                                        seen[item] = true
                                    end
                                end
                                if count ~= #value then Fail(field.key .. " must be a dense array") end
                            end
                        end
                    end
                end
                for field in pairs(entry) do if not allowed[field] then Fail("unknown field " .. tostring(field)) end end
                if entry.zone and not candidate.zones[entry.zone] then Fail("unknown zone " .. tostring(entry.zone)) end
                if entry.category and not self.categories[entry.category] then Fail("unknown category") end
                if entry.profession and not professions[entry.profession] then Fail("unknown profession") end
                local tags = entry.tags or entry.requiredNPCTags
                for _, tag in ipairs(type(tags) == "table" and tags or {}) do
                    if not self.npcTags[tag] then Fail("unknown NPC tag " .. tostring(tag)) end
                end
                if kind == "zones" and Integer(entry.minLevel) and Integer(entry.maxLevel) and entry.minLevel > entry.maxLevel then Fail("minimum level exceeds maximum") end
                if kind == "objectives" then
                    if Integer(entry.minPlayerLevel) and Integer(entry.maxPlayerLevel) and entry.minPlayerLevel > entry.maxPlayerLevel then Fail("invalid player level range") end
                    if Integer(entry.minAmount) and Integer(entry.maxAmount) and (entry.minAmount > entry.maxAmount or entry.maxAmount > 1000) then Fail("invalid amount range (1–1000)") end
                    local zone = candidate.zones[entry.zone]
                    if type(zone) == "table" and Integer(zone.minLevel) and Integer(zone.maxLevel) and Integer(entry.minPlayerLevel) and Integer(entry.maxPlayerLevel)
                        and (entry.minPlayerLevel < zone.minLevel or entry.maxPlayerLevel > zone.maxLevel) then Fail("player level range is outside the zone range") end
                    local hasTargets = type(entry.targets) == "table" and #entry.targets > 0 or Integer(entry.npcID) or type(entry.npcIDs) == "table" and #entry.npcIDs > 0
                    if entry.category ~= "gather" and not hasTargets then Fail("missing NPC ID(s) or exact target names") end
                    local giverFound = false
                    for _, giver in pairs(candidate.questGivers) do
                        if type(giver) == "table" and giver.zone == entry.zone
                            and self.HasTags(giver, entry.requiredNPCTags) then
                            if not entry.vendorID or giver.npcID == entry.vendorID then giverFound = true end
                        end
                    end
                    if not giverFound then Fail("no NPC in this zone has all required tags") end
                    if entry.category == "gather" then
                        if not professions[entry.profession] then Fail("Gather requires a profession") end
                        if not Integer(entry.itemID) then Fail("Gather requires an itemID") end
                        if entry.trackingKind ~= "gather" and entry.trackingKind ~= "nodes"
                            and entry.trackingKind ~= "mining_workorder" then Fail("Gather requires a supported trackingKind") end
                        if entry.trackingKind == "nodes" and entry.profession ~= "mining" then Fail("node counting requires Mining") end
                        if entry.trackingKind == "mining_workorder" then
                            if entry.profession ~= "mining" or not Integer(entry.oreItemID) or not Nonempty(entry.oreName)
                                or not Integer(entry.smeltSpellID) or not Integer(entry.itemID) then
                                Fail("Mining work orders require Mining, ore, smelt spell, and bar item IDs")
                            end
                            if entry.handoff == "sale" and not Contains(type(entry.requiredNPCTags) == "table" and entry.requiredNPCTags or {}, "vendor") then
                                Fail("sale handoff requires the vendor NPC tag")
                            end
                        elseif entry.oreItemID or entry.oreName or entry.smeltSpellID or entry.handoff then
                            Fail("ore, smelt, and handoff fields require a Mining work order")
                        end
                        if hasTargets and entry.profession ~= "skinning" then Fail("creature targets only apply to Skinning") end
                    elseif entry.category == "hunt" then
                        if entry.classification ~= "rare" and entry.classification ~= "elite" then Fail("Hunt requires rare or elite classification") end
                        if entry.classification == "rare" and (entry.minAmount ~= 1 or entry.maxAmount ~= 1) then Fail("rare Hunts must always require exactly 1") end
                    elseif entry.category == "supply" then
                        if entry.lootMode ~= "item" and entry.lootMode ~= "any_vendor_item" then Fail("Supply requires lootMode") end
                        if entry.lootMode == "item" and not Integer(entry.itemID) then Fail("specific-item collection requires itemID") end
                        if entry.lootMode == "any_vendor_item" and entry.itemID then Fail("any_vendor_item must not restrict itemID") end
                        if not Contains(type(entry.requiredNPCTags) == "table" and entry.requiredNPCTags or {}, "vendor") then Fail("Supply requires the vendor NPC tag") end
                    end
                end
            end
        end
    end
    return #errors == 0, errors
end

local function Merge(overrides)
    local result, errors = Copy(base), {}
    if type(overrides) ~= "table" or overrides.version ~= 1 then
        Error(errors, "zones", {}, "unsupported SavedVariables database override format")
        return result, errors
    end
    for _, kind in ipairs(kinds) do
        if overrides[kind] ~= nil and type(overrides[kind]) ~= "table" then
            Error(errors, kind, {}, "override collection must be a table")
        else
            for id, change in pairs(overrides[kind] or {}) do
                if type(change) ~= "table" then Error(errors, kind, {id = id}, "override must be a table")
                elseif change.disabled == true then result[kind][id] = nil
                elseif type(change.entry) ~= "table" or change.entry.id ~= id then Error(errors, kind, {id = id}, "override entry/ID mismatch")
                else result[kind][id] = Copy(change.entry) end
            end
        end
    end
    return result, errors
end

function Database:ZoneView(entry)
    local zone = Copy(entry)
    zone.questGivers = {}
    zone.data = {categories = {
        {id = "kill", name = "Kill", zoneId = zone.id, objectives = {}},
        {id = "supply", name = "Supply", zoneId = zone.id, objectives = {}},
        {id = "hunt", name = "Hunt", zoneId = zone.id, branches = {
            {id = "rare", name = "Rare target", objectives = {}}, {id = "elite", name = "Elite targets", objectives = {}}}},
    }, gather = Copy(self.professions)}
    for _, profession in ipairs(zone.data.gather) do profession.objectives = {} end
    return zone
end
function Database:BuildRuntime()
    local zones, order = {}, {}
    for _, entry in ipairs(Sorted(entries.zones)) do
        local zone = self:ZoneView(entry)
        zones[zone.id], order[#order + 1] = zone, zone.id
    end
    table.sort(order, function(a, b)
        local x, y = zones[a], zones[b]
        if (x.order or 100) ~= (y.order or 100) then return (x.order or 100) < (y.order or 100) end
        return x.name < y.name
    end)
    for _, objective in ipairs(Sorted(entries.objectives)) do
        local zone = zones[objective.zone]
        if zone then
            local list
            if objective.category == "gather" then
                for _, profession in ipairs(zone.data.gather) do if profession.id == objective.profession then list = profession.objectives end end
            else
                for _, category in ipairs(zone.data.categories) do
                    if category.id == objective.category then
                        if category.branches then
                            for _, branch in ipairs(category.branches) do if branch.id == objective.classification then list = branch.objectives end end
                        else list = category.objectives end
                    end
                end
            end
            if list then list[#list + 1] = Copy(objective) end
        end
    end
    for _, giver in ipairs(Sorted(entries.questGivers)) do
        local zone = zones[giver.zone]
        if zone then
            local item = Copy(giver)
            item.databaseID, item.id = item.id, item.npcID
            zone.questGivers[#zone.questGivers + 1] = item
        end
    end
    self.zones, self.zoneOrder = zones, order
end

local function MigrateLegacySupply(value, visited)
    if type(value) ~= "table" or visited[value] then return end
    visited[value] = true
    for key, item in pairs(value) do
        if type(item) == "table" then MigrateLegacySupply(item, visited)
        elseif item == "collect_sell" then value[key] = "supply"
        elseif item == "Collect & Sell" then value[key] = "Supply" end
    end
    for old, new in pairs({collect_sell = "supply", ["Collect & Sell"] = "Supply"}) do
        if value[old] ~= nil then
            if value[new] == nil then value[new] = value[old]
            elseif type(value[new]) == "number" and type(value[old]) == "number" then
                value[new] = value[new] + value[old]
            end
            value[old] = nil
        end
    end
end

local function MigrateLegacyNPCFields(saved)
    local overrides = type(saved.databaseOverrides) == "table" and saved.databaseOverrides or {}
    for _, change in pairs(type(overrides.objectives) == "table" and overrides.objectives or {}) do
        local entry = type(change) == "table" and change.entry
        if type(entry) == "table" and not entry.requiredNPCTags then
            local tag = entry.category == "supply" and "vendor"
                or entry.category == "gather" and "collector" or "questgiver"
            entry.requiredNPCTags = {tag}
        end
    end
    for _, change in pairs(type(overrides.questGivers) == "table" and overrides.questGivers or {}) do
        local entry = type(change) == "table" and change.entry
        if type(entry) == "table" then
            local tags = type(entry.tags) == "table" and entry.tags or {}
            for _, category in ipairs(type(entry.categories) == "table" and entry.categories or {}) do
                local tag = category == "supply" and "vendor" or category == "gather" and "collector"
                    or (category == "kill" or category == "hunt") and "questgiver"
                if tag and not Contains(tags, tag) then tags[#tags + 1] = tag end
            end
            if entry.vendor == true and not Contains(tags, "vendor") then tags[#tags + 1] = "vendor" end
            entry.tags, entry.categories, entry.vendor = tags, nil, nil
        end
    end
end

function Database:Initialize(saved)
    owner = saved or {}
    -- Old offers, progress, statistics, and editor overrides all used this ID.
    -- Migrate the save before overlay validation or tracking reads any records.
    MigrateLegacySupply(owner, {})
    MigrateLegacyNPCFields(owner)
    local overrides = owner.databaseOverrides or {version = 1}
    local candidate, errors = Merge(overrides)
    local valid, issues = self:Validate(candidate)
    for _, issue in ipairs(issues) do errors[#errors + 1] = issue end
    for _, issue in ipairs(registrationErrors) do errors[#errors + 1] = Copy(issue) end
    if #errors > 0 then
        -- Preserve a broken save for repair; never silently erase the user's edits.
        owner.databaseOverrideBackup = Copy(overrides)
        overrides, candidate = {version = 1}, Copy(base)
        -- Invalid source entries are excluded with precise diagnostics.
        for _ = 1, 4 do
            local clean, problems = self:Validate(candidate)
            if clean then break end
            for _, issue in ipairs(problems) do
                if issue.id then candidate[issue.kind][issue.id] = nil end
            end
        end
    end
    owner.databaseOverrides, entries = overrides, candidate
    self.errors = errors
    self:BuildRuntime()
    return #errors == 0, errors
end

function Database:List(kind, includeDisabled)
    local result = Copy(entries[kind] or {})
    if includeDisabled then
        for id, entry in pairs(base[kind] or {}) do
            if not result[id] then result[id] = Copy(entry); result[id]._disabled = true end
        end
    end
    return Sorted(result)
end
function Database:Get(kind, id) return Copy(entries[kind] and entries[kind][id]) end
function Database:GetFlavours(zone, category, profession)
    local result = {}
    for _, entry in ipairs(self:List("flavourText")) do
        if entry.category == category and (not entry.zone or entry.zone == zone)
            and (not entry.profession or entry.profession == profession) then result[#result + 1] = entry.text end
    end
    return result
end

local function Commit(self, overrides)
    local candidate, errors = Merge(overrides)
    local valid, issues = self:Validate(candidate)
    for _, issue in ipairs(issues) do errors[#errors + 1] = issue end
    if #errors > 0 then return false, errors end
    owner.databaseOverrides, entries = overrides, candidate
    self:BuildRuntime()
    if self.onChanged then self.onChanged() end
    return true, {}
end
function Database:Save(kind, entry, creating)
    if not self.schema[kind] or type(entry) ~= "table" or not Nonempty(entry.id) then
        return false, {{message = "Choose an entry type and supply a stable ID."}}
    end
    if creating then
        for _, name in ipairs(kinds) do
            if base[name][entry.id] or entries[name][entry.id] then
                local errors = {}; Error(errors, kind, entry, "duplicate ID"); return false, errors
            end
        end
    end
    local overrides = Copy(owner.databaseOverrides)
    overrides[kind] = overrides[kind] or {}
    overrides[kind][entry.id] = {entry = Copy(entry)}
    return Commit(self, overrides)
end
function Database:Delete(kind, id)
    if not self.schema[kind] or not entries[kind][id] then return false, {{message = "Select an existing entry."}} end
    local overrides = Copy(owner.databaseOverrides)
    overrides[kind] = overrides[kind] or {}
    overrides[kind][id] = {disabled = true}
    return Commit(self, overrides)
end
