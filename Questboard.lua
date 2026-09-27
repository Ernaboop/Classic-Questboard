local addonName = ...
local board, cards, db, debugPanel, minimapButton
local Refresh
local ToggleBoard
local CreateMinimapButton
local ELWYNN_MAX_LEVEL = 12

-- Amount ranges are deliberately curated per objective. Mob levels and zone
-- data use the WoW Forever Elwynn Forest tables; counts are balance choices.
local database = {
    categories = {
        {
            id = "kill", name = "Kill", source = "A local guard",
            objectives = {
                {id = "kobold_vermin", name = "Kobold Vermin", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Northshire Valley"},
                {id = "young_wolf", name = "Young Wolf", level = "1", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Northshire and the western woods"},
                {id = "timber_wolf", name = "Timber Wolf", level = "2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 7, maxAmount = 10, location = "Northshire and the western woods"},
                {id = "defias_thug", name = "Defias Thug", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the vineyards north of Goldshire"},
                {id = "kobold_laborer", name = "Kobold Laborer", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the kobold camps north of Goldshire"},
                {id = "forest_spider", name = "Forest Spider", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 6, minAmount = 6, maxAmount = 9, location = "the woods around Goldshire"},
                {id = "kobold_tunneler", name = "Kobold Tunneler", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 8, maxAmount = 12, location = "Fargodeep Mine"},
                {id = "kobold_miner", name = "Kobold Miner", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 7, maxAmount = 10, location = "Fargodeep Mine"},
                {id = "stonetusk_boar", name = "Stonetusk Boar", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "Stonefield and Maclure farms"},
                {id = "defias_cutpurse", name = "Defias Cutpurse", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "the roads east of Goldshire"},
                {id = "murloc_streamrunner", name = "Murloc Streamrunner", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 7, maxAmount = 11, location = "Crystal Lake"},
                {id = "gray_forest_wolf", name = "Gray Forest Wolf", level = "7-8", minPlayerLevel = 6, maxPlayerLevel = 9, minAmount = 5, maxAmount = 8, location = "the eastern woods"},
                {id = "riverpaw_runt", name = "Riverpaw Runt", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the Hogger camp"},
                {id = "young_forest_bear", name = "Young Forest Bear", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the eastern woods"},
                {id = "murloc_lurker", name = "Murloc Lurker", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the eastern shore of Crystal Lake"},
                {id = "murloc_forager", name = "Murloc Forager", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Crystal Lake"},
                {id = "prowler", name = "Prowler", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "the eastern woods"},
                {id = "riverpaw_outrunner", name = "Riverpaw Outrunner", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "south of Eastvale"},
                {id = "defias_bandit", name = "Defias Bandit", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Brackwell Pumpkin Patch"},
                {id = "defias_rogue_wizard", name = "Defias Rogue Wizard", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "Jasperlode Mine"},
            },
        },
        {
            id = "collect_sell", name = "Collect & Sell", source = "A local trader",
            objectives = {
                {id = "northshire_kobold_loot", name = "Kobold Camp Loot", target = "Kobold Vermin and Laborers", level = "1-4", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 3, maxAmount = 5, location = "Northshire Valley"},
                {id = "young_wolf_meat", name = "Meat from the Western Woods", target = "Young Wolves and Timber Wolves", item = "Tough Wolf Meat", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 3, maxAmount = 5, location = "Northshire and the western woods"},
                {id = "defias_thug_loot", name = "Thieves' Pockets", target = "Defias Thugs", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 3, maxAmount = 5, location = "the vineyards north of Goldshire"},
                {id = "fargodeep_kobold_loot", name = "Fargodeep Mine Spoils", target = "Kobold Tunnelers and Miners", level = "5-7", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 4, maxAmount = 6, location = "Fargodeep Mine"},
                {id = "stonetusk_boar_meat", name = "Boar Meat for the Market", target = "Stonetusk Boars", item = "Chunk of Boar Meat", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 4, maxAmount = 7, location = "Stonefield and Maclure farms"},
                {id = "crystal_lake_murloc_loot", name = "Crystal Lake Salvage", target = "Murlocs and Streamrunners", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 3, maxAmount = 5, location = "Crystal Lake"},
                {id = "eastern_wolf_loot", name = "Eastern Wolf Pelts", target = "Gray Forest Wolves and Young Forest Bears", level = "7-9", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "the eastern woods"},
                {id = "riverpaw_runt_loot", name = "Hogger Camp Spoils", target = "Riverpaw Runts", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "the Hogger camp"},
                {id = "murloc_forager_loot", name = "Murloc Forager Supplies", target = "Murloc Foragers and Lurkers", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Crystal Lake"},
                {id = "brackwell_defias_loot", name = "Brackwell Salvage", target = "Defias Bandits", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Brackwell Pumpkin Patch"},
                {id = "riverpaw_outrunner_loot", name = "Eastern Road Spoils", target = "Riverpaw Outrunners", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "south of Eastvale"},
            },
        },
        {
            id = "hunt", name = "Hunt", source = "A local scout",
            branches = {
                {
                    id = "rare", name = "Rare target",
                    objectives = {
                        {id = "narg", name = "Narg the Taskmaster", level = "10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "outside Fargodeep Mine", rarity = "Rare"},
                        {id = "morgaine", name = "Morgaine the Sly", level = "10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "near the river to Westfall", rarity = "Rare"},
                        {id = "fedfennel", name = "Fedfennel", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "Stone Cairn Lake", rarity = "Rare"},
                        {id = "gruff_swiftbite", name = "Gruff Swiftbite", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the Hogger camp", rarity = "Rare"},
                    },
                },
                {
                    id = "elite", name = "Elite targets",
                    objectives = {
                        {id = "mine_spider", name = "Mine Spider", level = "7-9", minPlayerLevel = 6, maxPlayerLevel = 9, minAmount = 3, maxAmount = 5, location = "Jasperlode Mine", rarity = "Elite"},
                        {id = "mother_fang", name = "Mother Fang", level = "7-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "Jasperlode Mine", rarity = "Elite"},
                        {id = "hogger", name = "Hogger", level = "11", minPlayerLevel = 9, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the Hogger camp", rarity = "Elite"},
                    },
                },
            },
        },
    },
    gather = {
        {
            id = "herbalism", name = "Herbalism",
            skillLine = 182,
            objectives = {
                {id = "peacebloom", name = "Peacebloom", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "throughout Elwynn Forest"},
                {id = "silverleaf", name = "Silverleaf", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 7, minAmount = 4, maxAmount = 8, location = "near trees and shaded areas"},
                {id = "earthroot", name = "Earthroot", level = "Herbalism 15", minPlayerLevel = 3, maxPlayerLevel = 9, minAmount = 3, maxAmount = 5, location = "hillsides and rocky ground"},
                {id = "mageroyal", name = "Mageroyal", level = "Herbalism 50", minPlayerLevel = 6, maxPlayerLevel = 12, minAmount = 2, maxAmount = 4, location = "the more open eastern fields"},
            },
        },
        {
            id = "mining", name = "Mining",
            skillLine = 186,
            objectives = {
                {id = "copper_ore", name = "Copper Ore", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "Copper Veins throughout Elwynn Forest"},
                {id = "rough_stone", name = "Rough Stone", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "from Copper Veins throughout Elwynn Forest"},
                {id = "copper_vein_prospecting", name = "Copper Vein Prospecting", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 3, maxAmount = 5, location = "Copper Veins throughout Elwynn Forest", target = "Copper Veins"},
            },
        },
        {
            id = "skinning", name = "Skinning",
            skillLine = 393,
            objectives = {
                {id = "ruined_leather_scraps", name = "Ruined Leather Scraps", level = "Skinning 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "skinnable low-level creatures in western Elwynn"},
                {id = "stonefield_light_leather", name = "Light Leather from Boars", level = "Skinning 1", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 3, maxAmount = 5, location = "Stonetusk Boars at Stonefield and Maclure farms"},
                {id = "eastern_light_leather", name = "Light Leather from Forest Beasts", level = "Skinning 1", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "wolves, bears, and prowlers in eastern Elwynn"},
            },
        },
        {
            id = "fishing", name = "Fishing",
            skillLine = 356,
            objectives = {
                {id = "brilliant_smallfish", name = "Raw Brilliant Smallfish", level = "Fishing 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 5, maxAmount = 9, location = "lakes and rivers"},
                {id = "longjaw_mud_snapper", name = "Raw Longjaw Mud Snapper", level = "Fishing 50", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 4, maxAmount = 8, location = "lakes and rivers"},
                {id = "bristle_whisker_catfish", name = "Raw Bristle Whisker Catfish", level = "Fishing 100", minPlayerLevel = 7, maxPlayerLevel = 12, minAmount = 2, maxAmount = 4, location = "Wildbend River"},
            },
        },
    },
}

local function RandomFrom(list)
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
end

local function AmountOptions(objective)
    local options = {}
    if not objective then return options end
    for amount = objective.minAmount, objective.maxAmount do
        options[#options + 1] = amount
    end
    return options
end

local function RollAmount(objective)
    return math.random(objective.minAmount, objective.maxAmount)
end

local function LearnedGatherProfessions()
    local known = {}
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then return known end
    local primaryOne, primaryTwo, third, fourth, fifth = GetProfessions()
    local function IncludeProfession(index)
        if index then
            local _, _, _, _, _, _, skillLine = GetProfessionInfo(index)
            for _, profession in ipairs(database.gather) do
                if skillLine == profession.skillLine then known[profession.id] = true end
            end
        end
    end
    IncludeProfession(primaryOne)
    IncludeProfession(primaryTwo)
    IncludeProfession(third)
    IncludeProfession(fourth)
    IncludeProfession(fifth)
    return known
end

local function CategoryOptions(includeUnlearned)
    local result = {}
    for _, category in ipairs(database.categories) do result[#result + 1] = category end
    local known = LearnedGatherProfessions()
    for _, profession in ipairs(database.gather) do
        if includeUnlearned or known[profession.id] then
            result[#result + 1] = {
                id = "gather:" .. profession.id,
                name = "Gather — " .. profession.name,
                baseName = "Gather",
                profession = profession,
                source = "A gathering commission",
                locked = not known[profession.id],
            }
        end
    end
    return result
end

local function CurrentPlayerLevel()
    return type(UnitLevel) == "function" and UnitLevel("player") or 1
end

local function NormalGenerationLevel()
    return math.min(CurrentPlayerLevel(), ELWYNN_MAX_LEVEL)
end

local function ProgressionBand(level)
    if level <= 3 then return "Early" end
    if level <= 6 then return "Mid" end
    if level <= 12 then return "Late" end
    return "Beyond Elwynn"
end

local function EligibleObjectives(objectives, playerLevel)
    local result = {}
    playerLevel = playerLevel or CurrentPlayerLevel()
    for _, objective in ipairs(objectives or {}) do
        if type(objective.minPlayerLevel) == "number" and type(objective.maxPlayerLevel) == "number"
            and playerLevel >= objective.minPlayerLevel and playerLevel <= objective.maxPlayerLevel then
            result[#result + 1] = objective
        end
    end
    return result
end

local function ObjectiveOptions(category, branch, playerLevel)
    if not category then return {} end
    if category.id == "hunt" then return EligibleObjectives(branch and branch.objectives, playerLevel) end
    if category.profession then return EligibleObjectives(category.profession.objectives, playerLevel) end
    return EligibleObjectives(category.objectives, playerLevel)
end

local function BuildQuest(category, branch, objective, amount)
    if not category or not objective then return nil end
    amount = amount or RollAmount(objective)
    local kind = category.baseName or category.name
    local target = objective.target or objective.name
    local location = objective.location and (" at " .. objective.location) or " in Elwynn Forest"
    local action
    if category.id == "kill" then
        action = "Travel to " .. objective.location .. " and defeat " .. amount .. " " .. target .. "."
    elseif category.id == "collect_sell" then
        action = "Collect " .. amount .. " " .. (objective.item or "vendor-value item") .. (amount == 1 and "" or "s") .. " from " .. target .. " near " .. objective.location .. ", then sell them to a vendor."
    elseif category.id == "hunt" and branch.id == "rare" then
        action = "Find and defeat " .. target .. ", a level " .. objective.level .. " " .. objective.rarity .. " target, " .. location .. "."
    elseif category.id == "hunt" then
        action = "Travel to " .. objective.location .. " and defeat " .. amount .. " level " .. objective.level .. " " .. target .. " elites."
    elseif category.profession then
        action = "Gather " .. amount .. " " .. target .. " " .. location .. "."
    end
    return {
        id = table.concat({category.id, branch and branch.id or "", objective.id, tostring(amount)}, ":"),
        selectionId = table.concat({category.id, branch and branch.id or "", objective.id}, ":"),
        title = objective.name,
        kind = kind .. (branch and (" — " .. branch.name) or (category.profession and (" — " .. category.profession.name) or "")),
        categoryName = kind,
        zone = "Elwynn Forest",
        level = objective.level,
        source = category.source,
        description = (category.profession and (category.profession.name .. " supplies are needed.") or
            (category.id == "hunt" and "A dangerous target has been reported in the area." or
            (category.id == "kill" and "Local residents need help dealing with a threat." or
            "A local request has been posted on the questboard."))),
        objective = action,
        prompt = category.id == "hunt" and "Gather what is known about the target before you set out; bring back one detail for the story." or
            "Ask the quest giver what makes this request important to them before you leave.",
        objectiveId = objective.id,
        branchId = branch and branch.id,
        professionId = category.profession and category.profession.id,
        amount = amount,
        minPlayerLevel = objective.minPlayerLevel,
        maxPlayerLevel = objective.maxPlayerLevel,
    }
end

local function GenerateQuest(playerLevel)
    playerLevel = playerLevel or NormalGenerationLevel()
    local categories = {}
    for _, candidate in ipairs(CategoryOptions(false)) do
        if candidate.id == "hunt" then
            local hasEligible = false
            for _, branchOption in ipairs(candidate.branches) do
                if #ObjectiveOptions(candidate, branchOption, playerLevel) > 0 then hasEligible = true; break end
            end
            if hasEligible then categories[#categories + 1] = candidate end
        elseif #ObjectiveOptions(candidate, nil, playerLevel) > 0 then
            categories[#categories + 1] = candidate
        end
    end
    local category = RandomFrom(categories)
    if not category then return nil end
    local branch
    if category.id == "hunt" then
        local branches = {}
        for _, option in ipairs(category.branches) do
            if #ObjectiveOptions(category, option, playerLevel) > 0 then branches[#branches + 1] = option end
        end
        branch = RandomFrom(branches)
    end
    local objective = RandomFrom(ObjectiveOptions(category, branch, playerLevel))
    if not objective then return nil end
    return BuildQuest(category, branch, objective, RollAmount(objective))
end

local function PickDisplayedQuests()
    local chosen = {}
    local seen = {}
    if db.activeQuest then
        chosen[1] = db.activeQuest
        seen[db.activeQuest.selectionId or db.activeQuest.id] = true
    end
    local attempts = 0
    while #chosen < 3 and attempts < 100 do
        attempts = attempts + 1
        local quest = GenerateQuest()
        if quest and not seen[quest.selectionId] then
            chosen[#chosen + 1] = quest
            seen[quest.selectionId] = true
        end
    end
    return chosen
end

local function ValidQuest(quest)
    return type(quest) == "table"
        and type(quest.id) == "string"
        and type(quest.title) == "string"
        and type(quest.kind) == "string"
        and type(quest.objective) == "string"
        and type(quest.amount) == "number"
end

local function ValidDisplayedQuests(displayed)
    if type(displayed) ~= "table" or #displayed > 3 then return false end
    local seen = {}
    for _, quest in ipairs(displayed) do
        if not ValidQuest(quest) or seen[quest.id] then return false end
        seen[quest.id] = true
    end
    return true
end

local debugState = {
    layer = 1, categoryIndex = 1, branchIndex = 1, objectiveIndex = 1, amountIndex = 1,
    testLevel = math.min(CurrentPlayerLevel(), ELWYNN_MAX_LEVEL),
    expanded = {level = true, category = true, profession = true, objective = true, hunt = true, amount = true, preview = true},
}

local function DebugSelection()
    local categories = CategoryOptions(true)
    local category = categories[debugState.categoryIndex]
    if not category then return categories, nil end
    local branch
    if category.id == "hunt" then
        branch = category.branches[debugState.branchIndex]
    end
    local objectives = ObjectiveOptions(category, branch, debugState.testLevel)
    local objective = objectives[debugState.objectiveIndex]
    return categories, category, branch, objectives, objective
end

local function DebugLayerOptions(layer)
    local categories, category, branch, objectives, objective = DebugSelection()
    if layer == 1 then
        local options = {}
        for _, option in ipairs(categories) do
            options[#options + 1] = option.name .. (option.locked and " (not learned)" or "")
        end
        return "Category", options
    elseif layer == 2 then
        if category and category.id == "hunt" then
            local options = {}
            for _, option in ipairs(category.branches) do options[#options + 1] = option.name end
            return "Hunt type", options
        end
        local options = {}
        for _, option in ipairs(objectives) do options[#options + 1] = option.name end
        return "Objective", options
    elseif layer == 3 and category and category.id == "hunt" then
        local options = {}
        for _, option in ipairs(objectives) do options[#options + 1] = option.name end
        return "Target", options
    elseif (layer == 3 and category and category.id ~= "hunt") or (layer == 4 and category and category.id == "hunt") then
        local options = {}
        if objective then
            for _, amount in ipairs(AmountOptions(objective)) do options[#options + 1] = tostring(amount) end
        end
        return "Amount", options
    end
    return nil, {}
end

local function DebugLayerCount(category)
    return category and category.id == "hunt" and 4 or 3
end

local function ClampDebugState()
    local categories = CategoryOptions(true)
    debugState.categoryIndex = math.min(math.max(debugState.categoryIndex, 1), #categories)
    local _, category, selectedBranch, objectives = DebugSelection()
    if category and category.id == "hunt" then
        debugState.branchIndex = math.min(math.max(debugState.branchIndex, 1), #category.branches)
        local categories
        categories, category, selectedBranch, objectives = DebugSelection()
    else
        debugState.branchIndex = 1
    end
    debugState.objectiveIndex = math.min(math.max(debugState.objectiveIndex, 1), math.max(1, #objectives))
    local objective = objectives[debugState.objectiveIndex]
    debugState.amountIndex = math.min(math.max(debugState.amountIndex, 1), math.max(1, #AmountOptions(objective)))
    local count = DebugLayerCount(category)
    debugState.layer = math.min(math.max(debugState.layer, 1), count)
end

local function Text(parent, size, color)
    local text = parent:CreateFontString(nil, "OVERLAY", size or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if color then text:SetTextColor(unpack(color)) end
    return text
end

local RenderDebug, ChangeDebugLevel

local function CreateTreeFolder(key, title)
    local folder = {key = key, buttons = {}}
    folder.header = CreateFrame("Button", nil, debugPanel.treeContent, "UIPanelButtonTemplate")
    folder.header:SetHeight(24)
    folder.header:SetScript("OnClick", function()
        debugState.expanded[key] = not debugState.expanded[key]
        RenderDebug()
    end)
    folder.title = folder.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    folder.title:SetPoint("LEFT", 8, 0)
    folder.summary = Text(debugPanel.treeContent, "GameFontHighlightSmall")
    folder.controls = {}
    folder.label = title
    debugPanel.folders[key] = folder
    return folder
end

local function TreeButton(folder, index, label, selected, callback, width)
    local button = folder.buttons[index]
    if not button then
        button = CreateFrame("Button", nil, debugPanel.treeContent, "UIPanelButtonTemplate")
        folder.buttons[index] = button
    end
    button:ClearAllPoints()
    button:SetSize(width or 210, 22)
    button:SetText((selected and "• " or "  ") .. label)
    button:SetScript("OnClick", callback)
    button:SetShown(true)
    return button
end

local function HideUnusedTreeButtons(folder, used)
    for index = used + 1, #folder.buttons do folder.buttons[index]:Hide() end
end

RenderDebug = function()
    ClampDebugState()
    local categories, category, branch, objectives, objective = DebugSelection()
    local content, y = debugPanel.treeContent, -4
    local function BeginFolder(key, title, summary)
        local folder = debugPanel.folders[key] or CreateTreeFolder(key, title)
        folder.header:ClearAllPoints()
        folder.header:SetPoint("TOPLEFT", content, "TOPLEFT", 4, y)
        folder.header:SetWidth(748)
        folder.header:SetText("")
        folder.title:SetText((debugState.expanded[key] and "▼  " or "▶  ") .. title)
        folder.summary:ClearAllPoints()
        folder.summary:SetPoint("RIGHT", folder.header, "RIGHT", -10, 0)
        folder.summary:SetWidth(390)
        folder.summary:SetJustifyH("RIGHT")
        folder.summary:SetText(summary or "")
        folder.header:Show()
        folder.summary:Show()
        y = y - 27
        if debugState.expanded[key] then return folder end
        if folder.valueText then folder.valueText:Hide() end
        if folder.info then folder.info:Hide() end
        HideUnusedTreeButtons(folder, 0)
        return nil
    end
    local function AddOptionButtons(folder, options, selectedIndex, setter)
        local used = 0
        for index, option in ipairs(options) do
            used = used + 1
            local optionIndex = index
            TreeButton(folder, used, option, selectedIndex == optionIndex, function() setter(optionIndex) end, 235)
            local button = folder.buttons[used]
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", content, "TOPLEFT", 28, y)
            y = y - 23
        end
        HideUnusedTreeButtons(folder, used)
    end
    local function AddInfo(folder, text, height)
        if not folder.info then folder.info = Text(content, "GameFontHighlightSmall") end
        folder.info:ClearAllPoints()
        folder.info:SetPoint("TOPLEFT", content, "TOPLEFT", 30, y)
        folder.info:SetSize(690, height or 42)
        folder.info:SetText(text)
        folder.info:Show()
        y = y - (height or 42)
    end
    local function AddStepButtons(folder, value, onMinus, onPlus, suffix)
        local minus = TreeButton(folder, 1, "−", false, onMinus, 40)
        minus:ClearAllPoints(); minus:SetPoint("TOPLEFT", content, "TOPLEFT", 28, y)
        local valueText = folder.valueText
        if not valueText then valueText = Text(content, "GameFontHighlight"); folder.valueText = valueText end
        valueText:Show()
        valueText:ClearAllPoints(); valueText:SetPoint("LEFT", minus, "RIGHT", 8, 0)
        valueText:SetText(value .. (suffix or ""))
        local plus = TreeButton(folder, 2, "+", false, onPlus, 40)
        plus:ClearAllPoints(); plus:SetPoint("LEFT", valueText, "RIGHT", 8, 0)
        HideUnusedTreeButtons(folder, 2)
        y = y - 27
    end

    local folder = BeginFolder("level", "Generation Level / Level Override", debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
    if folder then AddStepButtons(folder, debugState.testLevel, function() ChangeDebugLevel(-1) end, function() ChangeDebugLevel(1) end, "  |  Character " .. CurrentPlayerLevel()) end

    local categoryNames = {}
    local categorySelected = category.profession and "Gather" or category.name
    for _, option in ipairs(categories) do categoryNames[#categoryNames + 1] = option.profession and ("Gather — " .. option.profession.name .. (option.locked and " (not learned)" or "")) or option.name end
    folder = BeginFolder("category", "Category", categorySelected)
    if folder then
        AddOptionButtons(folder, categoryNames, debugState.categoryIndex, function(index)
            debugState.categoryIndex = index; debugState.branchIndex, debugState.objectiveIndex, debugState.amountIndex = 1, 1, 1; RenderDebug()
        end)
        local available = CategoryOptions(false)
        local availableNames = {}
        for _, item in ipairs(available) do availableNames[#availableNames + 1] = item.name end
        AddInfo(folder, "Available to this character: " .. table.concat(availableNames, ", "), 36)
    elseif debugPanel.folders.category and debugPanel.folders.category.info then
        debugPanel.folders.category.info:Hide()
    end

    if category.profession then
        local professionOptions, professionIndex = {}, 0
        for index, option in ipairs(categories) do
            if option.profession then
                professionOptions[#professionOptions + 1] = option.name .. (option.locked and " (not learned)" or "")
                if index == debugState.categoryIndex then professionIndex = #professionOptions end
            end
        end
        folder = BeginFolder("profession", "Gathering Profession", category.profession.name .. (category.locked and " (not learned)" or ""))
        if folder then AddOptionButtons(folder, professionOptions, professionIndex, function(index)
                local found = 0
                for categoryIndex, option in ipairs(categories) do
                    if option.profession then found = found + 1; if found == index then debugState.categoryIndex = categoryIndex; break end end
                end
                debugState.objectiveIndex, debugState.amountIndex = 1, 1; RenderDebug()
            end)
        end
    else
        local hidden = debugPanel.folders.profession
        if hidden then hidden.header:Hide(); hidden.summary:Hide(); HideUnusedTreeButtons(hidden, 0) end
    end

    if category.id == "hunt" then
        folder = BeginFolder("hunt", "Hunt Subtype", branch and branch.name or "")
        if folder then
            local huntTypes = {}; for _, option in ipairs(category.branches) do huntTypes[#huntTypes + 1] = option.name end
            AddOptionButtons(folder, huntTypes, debugState.branchIndex, function(index)
                debugState.branchIndex, debugState.objectiveIndex, debugState.amountIndex = index, 1, 1; RenderDebug()
            end)
        end
    else
        local hidden = debugPanel.folders.hunt
        if hidden then hidden.header:Hide(); hidden.summary:Hide(); HideUnusedTreeButtons(hidden, 0) end
    end

    local objectiveOptions = {}
    for _, item in ipairs(objectives) do objectiveOptions[#objectiveOptions + 1] = item.name end
    local objectiveLayer = category.id == "hunt" and "Hunt Target" or "Objective"
    folder = BeginFolder("objective", objectiveLayer, objective and objective.name or "No eligible objectives")
    if folder then
        AddOptionButtons(folder, objectiveOptions, debugState.objectiveIndex, function(index)
            debugState.objectiveIndex, debugState.amountIndex = index, 1; RenderDebug()
        end)
        if objective then
            local details = "Level or skill: " .. objective.level .. "  |  Eligible character levels: " .. objective.minPlayerLevel .. "-" .. objective.maxPlayerLevel ..
                " (" .. ProgressionBand(objective.minPlayerLevel) .. " to " .. ProgressionBand(objective.maxPlayerLevel) .. ")\nLocation: " .. objective.location ..
                "  |  Amount range: " .. objective.minAmount .. "-" .. objective.maxAmount
            if category.id == "hunt" and branch.id == "rare" then details = details .. "  |  Rare targets are always exactly one." end
            if category.id == "hunt" and branch.id == "elite" then details = details .. "  |  Elite hunts use small group counts." end
            if category.id == "collect_sell" then details = details .. "\nCollect the requested vendor-value drops and sell them to a vendor." end
            AddInfo(folder, details, 50)
        elseif folder.info then
            folder.info:Hide()
        end
    elseif debugPanel.folders.objective and debugPanel.folders.objective.info then
        debugPanel.folders.objective.info:Hide()
    end

    local amountOptions = {}
    for _, amount in ipairs(AmountOptions(objective)) do amountOptions[#amountOptions + 1] = tostring(amount) end
    folder = BeginFolder("amount", "Amount Range", objective and (objective.minAmount .. "–" .. objective.maxAmount) or "")
    if folder then AddOptionButtons(folder, amountOptions, debugState.amountIndex, function(index)
        debugState.amountIndex = index; RenderDebug()
    end) end

    folder = BeginFolder("preview", "Quest Preview / Test Generation", "Preview selection or generate at override level")
    if folder then
        local previewButton = TreeButton(folder, 1, "Preview selection", false, function()
            local _, selectedCategory, selectedBranch, _, selectedObjective = DebugSelection()
            if not selectedObjective then return end
            local amount = AmountOptions(selectedObjective)[debugState.amountIndex]
            local preview = BuildQuest(selectedCategory, selectedBranch, selectedObjective, amount)
            debugPanel.preview:SetText(preview.title .. "  |  " .. preview.kind .. "  |  " .. preview.amount .. "\n" .. preview.objective)
        end, 190)
        previewButton:ClearAllPoints(); previewButton:SetPoint("TOPLEFT", content, "TOPLEFT", 28, y)
        local generateButton = TreeButton(folder, 2, "Generate test quest", false, function()
            local generated = GenerateQuest(debugState.testLevel)
            debugPanel.preview:SetText(generated and ("Generated at level " .. debugState.testLevel .. ": " .. generated.title .. "  |  " .. generated.kind .. "  |  " .. generated.amount .. "\n" .. generated.objective) or "No eligible objective at test level " .. debugState.testLevel .. ".")
        end, 190)
        generateButton:ClearAllPoints(); generateButton:SetPoint("LEFT", previewButton, "RIGHT", 8, 0)
        HideUnusedTreeButtons(folder, 2)
        y = y - 28
        debugPanel.preview:ClearAllPoints(); debugPanel.preview:SetPoint("TOPLEFT", content, "TOPLEFT", 28, y)
        debugPanel.preview:SetSize(720, 38); debugPanel.preview:Show()
        y = y - 44
    else
        debugPanel.preview:Hide()
    end

    content:SetHeight(math.max(1, -y + 8))
    debugPanel.treeScroll:UpdateScrollChildRect()
end

local function ChangeDebugOption(delta)
    local _, category = DebugSelection()
    local _, options = DebugLayerOptions(debugState.layer)
    if #options < 2 then return end
    local key
    if debugState.layer == 1 then
        key = "categoryIndex"
    elseif debugState.layer == 2 and category.id == "hunt" then
        key = "branchIndex"
    elseif (debugState.layer == 2) or (debugState.layer == 3 and category.id == "hunt") then
        key = "objectiveIndex"
    else
        key = "amountIndex"
    end
    debugState[key] = ((debugState[key] - 1 + delta) % #options) + 1
    if key == "categoryIndex" then
        debugState.branchIndex, debugState.objectiveIndex, debugState.amountIndex = 1, 1, 1
    elseif key == "branchIndex" then
        debugState.objectiveIndex, debugState.amountIndex = 1, 1
    elseif key == "objectiveIndex" then
        debugState.amountIndex = 1
    end
    RenderDebug()
end

local function ChangeDebugLayer(delta)
    local _, category = DebugSelection()
    debugState.layer = math.min(math.max(debugState.layer + delta, 1), DebugLayerCount(category))
    RenderDebug()
end

ChangeDebugLevel = function(delta)
    debugState.testLevel = math.min(ELWYNN_MAX_LEVEL, math.max(1, debugState.testLevel + delta))
    debugState.branchIndex, debugState.objectiveIndex, debugState.amountIndex = 1, 1, 1
    RenderDebug()
end

local function CreateBoard()
    board = CreateFrame("Frame", "WoWForeverQuestboard", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    board:SetSize(840, 570)
    board:SetPoint("CENTER")
    board:SetFrameStrata("DIALOG")
    board:SetClampedToScreen(true)
    board:SetMovable(true)
    board:EnableMouse(true)
    board:RegisterForDrag("LeftButton")
    board:SetScript("OnDragStart", board.StartMoving)
    board:SetScript("OnDragStop", board.StopMovingOrSizing)
    board:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    board:SetBackdropColor(0.12, 0.1, 0.08, 1)
    local title = Text(board, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 24, -22)
    title:SetText("WoW Forever | Questboard — Alpha V0.4.2 (0.4.2)")
    local subtitle = Text(board, "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", 24, -50)
    subtitle:SetText("Elwynn Forest commissions, assembled from category, objective, and amount.")
    local close = CreateFrame("Button", nil, board, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    table.insert(UISpecialFrames, "WoWForeverQuestboard")

    cards = {}
    for index = 1, 3 do
        local offerIndex = index
        local card = CreateFrame("Frame", nil, board, BackdropTemplateMixin and "BackdropTemplate" or nil)
        cards[index] = card
        card:SetSize(256, 396)
        card:SetPoint("TOPLEFT", 24 + (index - 1) * 268, -82)
        card:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = {left = 3, right = 3, top = 3, bottom = 3}})
        card:SetBackdropColor(0.16, 0.135, 0.09, 0.96)
        card.heading = Text(card, "GameFontNormalLarge")
        card.heading:SetPoint("TOPLEFT", 14, -16)
        card.heading:SetSize(228, 44)
        card.meta = Text(card, "GameFontHighlightSmall", {0.72, 0.65, 0.49})
        card.meta:SetPoint("TOPLEFT", 14, -62)
        card.meta:SetSize(228, 42)
        card.story = Text(card)
        card.story:SetPoint("TOPLEFT", 14, -108)
        card.story:SetSize(228, 88)
        card.objective = Text(card, "GameFontNormal")
        card.objective:SetPoint("TOPLEFT", 14, -202)
        card.objective:SetSize(228, 72)
        card.prompt = Text(card, "GameFontNormalSmall")
        card.prompt:SetPoint("TOPLEFT", 14, -282)
        card.prompt:SetSize(228, 60)
        card.marker = Text(card, "GameFontNormalSmall", {0.5, 0.9, 0.5})
        card.marker:SetPoint("BOTTOM", 0, 43)
        card.button = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        card.button:SetSize(218, 26)
        card.button:SetPoint("BOTTOM", 0, 12)
        card.button:SetScript("OnClick", function()
            if db.activeQuest then return end
            local quest = db.displayedQuests[offerIndex]
            if not quest then return end
            db.activeQuest = quest
            db.displayedQuests = PickDisplayedQuests()
            Refresh()
            print("|cffffd27fWoW Forever:|r Accepted \"" .. quest.title .. "\". Open /cq to view your objective.")
        end)
    end

    board.status = Text(board, "GameFontNormal")
    board.status:SetPoint("TOPLEFT", 24, -489)
    board.status:SetSize(350, 22)
    board.note = Text(board, "GameFontHighlightSmall", {0.65, 0.65, 0.65})
    board.note:SetPoint("TOPLEFT", 24, -523)
    board.note:SetText("Objectives are shown for roleplay; kills, loot, sales, and gathering are not tracked yet.")
    board.debugButton = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.debugButton:SetSize(142, 26)
    board.debugButton:SetPoint("TOPRIGHT", -24, -487)
    board.debugButton:SetText("Debug browser")
    board.release = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.release:SetSize(142, 26)
    board.release:SetPoint("RIGHT", board.debugButton, "LEFT", -8, 0)
    board.release:SetText("Release objective")
    board.release:SetScript("OnClick", function()
        db.activeQuest = nil
        db.displayedQuests = PickDisplayedQuests()
        Refresh()
    end)
    board.reroll = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.reroll:SetSize(120, 26)
    board.reroll:SetPoint("RIGHT", board.release, "LEFT", -8, 0)
    board.reroll:SetText("Reroll quests")
    board.reroll:SetScript("OnClick", function()
        db.displayedQuests = PickDisplayedQuests()
        Refresh()
    end)

    debugPanel = CreateFrame("Frame", nil, board, BackdropTemplateMixin and "BackdropTemplate" or nil)
    debugPanel:SetSize(792, 396)
    debugPanel:SetPoint("TOPLEFT", 24, -82)
    debugPanel:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    debugPanel:SetBackdropColor(0.16, 0.135, 0.09, 0.96)
    debugPanel.header = Text(debugPanel, "GameFontNormalLarge")
    debugPanel.header:SetPoint("TOPLEFT", 18, -12)
    debugPanel.header:SetText("Quest Generator Structure")
    debugPanel.treeScroll = CreateFrame("ScrollFrame", nil, debugPanel, "UIPanelScrollFrameTemplate")
    debugPanel.treeScroll:SetPoint("TOPLEFT", 12, -38)
    debugPanel.treeScroll:SetPoint("BOTTOMRIGHT", -30, 8)
    debugPanel.treeContent = CreateFrame("Frame", nil, debugPanel.treeScroll)
    debugPanel.treeContent:SetWidth(748)
    debugPanel.treeContent:SetHeight(1)
    debugPanel.treeScroll:SetScrollChild(debugPanel.treeContent)
    debugPanel.folders = {}
    debugPanel.preview = Text(debugPanel.treeContent, "GameFontHighlightSmall", {0.6, 1, 0.6})
    debugPanel.preview:Hide()
    debugPanel:Hide()
    board.debugMode = false
    board.debugButton:SetScript("OnClick", function()
        board.debugMode = not board.debugMode
        board.debugButton:SetText(board.debugMode and "Quest board" or "Debug browser")
        for _, card in ipairs(cards) do
            if board.debugMode then card:Hide() else card:Show() end
        end
        board.status:SetShown(not board.debugMode)
        board.note:SetShown(not board.debugMode)
        board.reroll:SetShown(not board.debugMode)
        board.release:SetShown(not board.debugMode)
        debugPanel:SetShown(board.debugMode)
        if board.debugMode then
            debugPanel.preview:SetText("")
            RenderDebug()
        end
    end)
    board:Hide()
end

Refresh = function()
    for index, card in ipairs(cards) do
        local quest = db.displayedQuests[index]
        local accepted = quest and db.activeQuest and db.activeQuest.id == quest.id
        card.heading:SetText(quest and quest.title or "No suitable quest")
        card.meta:SetText(quest and (quest.kind .. "  |  " .. quest.zone .. "\nLevel or skill: " .. quest.level .. "  |  " .. quest.source) or "Elwynn Forest")
        card.story:SetText(quest and quest.description or "No objectives match your current level and known professions.")
        card.objective:SetText(quest and ("Your objective\n|cffffffff" .. quest.objective .. "|r") or "")
        card.prompt:SetText(quest and ("Roleplay prompt\n|cffffffff" .. quest.prompt .. "|r") or "")
        card.button:SetText(not quest and "Unavailable" or (accepted and "Accepted" or (db.activeQuest and "Unavailable" or "Accept objective")))
        card.button:SetEnabled(quest ~= nil and not db.activeQuest)
        card.marker:SetText(accepted and "YOUR ACTIVE OBJECTIVE" or "")
        card:SetBackdropBorderColor(accepted and 0.9 or 0.36, accepted and 0.3 or 0.3, accepted and 0.16 or 0.16, 1)
    end
    local active = db.activeQuest
    board.status:SetText(active and ("Active: " .. active.title) or (#db.displayedQuests == 0 and "No Elwynn objectives match your current level and known professions." or "Choose one notice to begin your adventure."))
    board.release:SetEnabled(active ~= nil)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, loaded)
    if loaded ~= addonName then return end
    WoWForeverDB = type(WoWForeverDB) == "table" and WoWForeverDB or {}
    db = WoWForeverDB
    if db.minimapPositionVersion ~= 2 then
        -- Older releases saved the button at the lower-right tracking control.
        db.minimapAngle = 45
        db.minimapPositionVersion = 2
    end
    if db.generatorDataVersion ~= "0.4.0" then
        db.displayedQuests = nil
        db.generatorDataVersion = "0.4.0"
    end
    if not ValidQuest(db.activeQuest) then db.activeQuest = nil end
    if db.activeQuest then db.activeQuestId = nil end
    if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
    CreateMinimapButton()
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_WOWFOREVERQUESTBOARD1 = "/cq"
ToggleBoard = function(wantsDebug)
    if not db then return end
    if not board then CreateBoard() end
    if board:IsShown() then
        if wantsDebug and not board.debugMode then
            board.debugButton:Click()
            return
        elseif wantsDebug and board.debugMode then
            return
        else
            board:Hide()
            return
        end
    end
    if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
    board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
    Refresh()
    board:Show()
    if wantsDebug and not board.debugMode then board.debugButton:Click() end
end

SlashCmdList.WOWFOREVERQUESTBOARD = function(message)
    ToggleBoard(type(message) == "string" and string.lower(message) == "debug")
end

SLASH_WOWFOREVERQUESTBOARDDEBUG1 = "/cqdebug"
SlashCmdList.WOWFOREVERQUESTBOARDDEBUG = function()
    ToggleBoard(true)
end

CreateMinimapButton = function()
    if minimapButton or not Minimap then return end
    minimapButton = CreateFrame("Button", "WoWForeverMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    minimapButton:EnableMouse(true)
    minimapButton:RegisterForClicks("LeftButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton.icon = minimapButton:CreateTexture(nil, "ARTWORK")
    minimapButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    minimapButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    minimapButton.icon:SetSize(18, 18)
    minimapButton.icon:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
    minimapButton.border = minimapButton:CreateTexture(nil, "OVERLAY")
    minimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton.border:SetSize(54, 54)
    minimapButton.border:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
    local function PositionButton()
        -- The upper-right keeps the Questboard clear of the default lower-right
        -- minimap tracking control; users can still drag it to another position.
        local angle = math.rad(tonumber(db.minimapAngle) or 45)
        local radius = (Minimap:GetWidth() / 2) + 8
        minimapButton:ClearAllPoints()
        minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    PositionButton()
    minimapButton:SetScript("OnClick", function(self, button)
        if self.dragStoppedAt and GetTime() - self.dragStoppedAt < 0.25 then return end
        self.dragStoppedAt = nil
        if button == "LeftButton" then ToggleBoard(false) end
    end)
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WoW Forever Questboard")
        GameTooltip:AddLine("Click to open the questboard", 1, 1, 1)
        GameTooltip:AddLine("Drag to reposition this button", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    minimapButton:SetScript("OnDragStart", function(self)
        self.dragStoppedAt = nil
        self:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local scale = UIParent:GetScale()
            local centerX, centerY = Minimap:GetCenter()
            x, y = x / scale - centerX, y / scale - centerY
            if x ~= 0 or y ~= 0 then db.minimapAngle = math.deg(math.atan2(y, x)); PositionButton() end
        end)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self.dragStoppedAt = GetTime()
    end)
end
