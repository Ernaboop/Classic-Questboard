local addonName = ...
local board, cards, db, minimapButton, questBrowser, debugModeButton
local Refresh
local ToggleBoard
local CreateMinimapButton
local RefreshQuestBrowser, SetDebugMode
local CreateBoard
local debugMode = false
local QuestGenerationLevel
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

-- The browser is an inspection tool, so keep showing a category's nearest
-- supported band when the selected level falls outside its available ranges.
local function BrowserObjectives(objectives, playerLevel)
    local eligible = EligibleObjectives(objectives, playerLevel)
    if #eligible > 0 then return eligible, playerLevel end

    local closestLevel, closestDistance
    for _, objective in ipairs(objectives or {}) do
        local minimum, maximum = objective.minPlayerLevel, objective.maxPlayerLevel
        if type(minimum) == "number" and type(maximum) == "number" then
            local candidateLevel
            if playerLevel < minimum then
                candidateLevel = minimum
            elseif playerLevel > maximum then
                candidateLevel = maximum
            else
                candidateLevel = playerLevel
            end
            local distance = math.abs(playerLevel - candidateLevel)
            if not closestDistance or distance < closestDistance
                or (distance == closestDistance and candidateLevel < closestLevel) then
                closestLevel, closestDistance = candidateLevel, distance
            end
        end
    end
    if not closestLevel then return {}, nil end
    return EligibleObjectives(objectives, closestLevel), closestLevel
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
    local generationLevel = QuestGenerationLevel and QuestGenerationLevel() or NormalGenerationLevel()
    if db.activeQuest then
        chosen[1] = db.activeQuest
        seen[db.activeQuest.selectionId or db.activeQuest.id] = true
    end
    local attempts = 0
    while #chosen < 3 and attempts < 100 do
        attempts = attempts + 1
        local quest = GenerateQuest(generationLevel)
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

local debugState = {testLevel = math.min(CurrentPlayerLevel(), ELWYNN_MAX_LEVEL)}
local ChangeDebugLevel

QuestGenerationLevel = function()
    return debugMode and debugState.testLevel or NormalGenerationLevel()
end

local function Text(parent, size, color)
    local text = parent:CreateFontString(nil, "OVERLAY", size or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if color then text:SetTextColor(unpack(color)) end
    return text
end

ChangeDebugLevel = function(delta)
    debugState.testLevel = math.min(ELWYNN_MAX_LEVEL, math.max(1, debugState.testLevel + delta))
    if board and board.debugLevelText then
        board.debugLevelText:SetText("Generation level: " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
        board.debugLevelDown:SetEnabled(debugState.testLevel > 1)
        board.debugLevelUp:SetEnabled(debugState.testLevel < ELWYNN_MAX_LEVEL)
    end
    if db and not db.activeQuest then
        db.displayedQuests = PickDisplayedQuests()
        if board and board:IsShown() then Refresh() end
    end
    if questBrowser and questBrowser:IsShown() then RefreshQuestBrowser() end
end

local browserTab = "kill"
local browserTabData = {
    {id = "kill", label = "Kill", icon = "Interface\\Icons\\Ability_Warrior_SavageBlow"},
    {id = "collect_sell", label = "Collect & Sell", icon = "Interface\\Icons\\INV_Misc_Bag_08"},
    {id = "hunt", label = "Hunt", icon = "Interface\\Icons\\Ability_Hunter_SniperShot"},
    {id = "gather", label = "Gather", icon = "Interface\\Icons\\Trade_Herbalism"},
}

local function BrowserCategory(categoryId)
    for _, category in ipairs(database.categories) do
        if category.id == categoryId then return category end
    end
end

local function BrowserGatherCategory(profession)
    for _, category in ipairs(CategoryOptions(true)) do
        if category.profession and category.profession.id == profession.id then return category end
    end
end

local function CreateQuestBrowser()
    if questBrowser then return end
    questBrowser = CreateFrame("Frame", "WoWForeverQuestBrowser", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    questBrowser:SetSize(680, 510)
    questBrowser:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    questBrowser:SetFrameStrata("FULLSCREEN_DIALOG")
    questBrowser:SetFrameLevel((board and board:GetFrameLevel() or 20) + 20)
    questBrowser:SetClampedToScreen(true)
    questBrowser:SetMovable(true)
    questBrowser:EnableMouse(true)
    questBrowser:RegisterForDrag("LeftButton")
    questBrowser:SetScript("OnDragStart", questBrowser.StartMoving)
    questBrowser:SetScript("OnDragStop", questBrowser.StopMovingOrSizing)
    questBrowser:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    questBrowser:SetBackdropColor(0.12, 0.1, 0.08, 1)
    local title = Text(questBrowser, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -18)
    title:SetText("Quest Browser")
    local close = CreateFrame("Button", nil, questBrowser, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    table.insert(UISpecialFrames, "WoWForeverQuestBrowser")

    questBrowser.levelLabel = Text(questBrowser, "GameFontNormal")
    questBrowser.levelLabel:SetPoint("TOPLEFT", 24, -54)
    questBrowser.levelLabel:SetSize(250, 24)
    questBrowser.levelDown = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.levelDown:SetSize(30, 24)
    questBrowser.levelDown:SetPoint("LEFT", questBrowser.levelLabel, "RIGHT", 6, 0)
    questBrowser.levelDown:SetText("<")
    questBrowser.levelDown:SetScript("OnClick", function() ChangeDebugLevel(-1) end)
    questBrowser.levelUp = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.levelUp:SetSize(30, 24)
    questBrowser.levelUp:SetPoint("LEFT", questBrowser.levelDown, "RIGHT", 4, 0)
    questBrowser.levelUp:SetText(">")
    questBrowser.levelUp:SetScript("OnClick", function() ChangeDebugLevel(1) end)
    questBrowser.tabs = {}
    for index, tabInfo in ipairs(browserTabData) do
        local tabId = tabInfo.id
        local tab = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
        questBrowser.tabs[index] = tab
        tab:SetSize(150, 38)
        tab:SetPoint("TOPLEFT", 22 + (index - 1) * 158, -88)
        tab.icon = tab:CreateTexture(nil, "ARTWORK")
        tab.icon:SetSize(22, 22)
        tab.icon:SetPoint("LEFT", 8, 0)
        tab.icon:SetTexture(tabInfo.icon)
        tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.label:SetPoint("LEFT", tab.icon, "RIGHT", 6, 0)
        tab.label:SetText(tabInfo.label)
        tab.activeMark = tab:CreateTexture(nil, "OVERLAY")
        tab.activeMark:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        tab.activeMark:SetBlendMode("ADD")
        tab.activeMark:SetSize(52, 52)
        tab.activeMark:SetPoint("CENTER", tab.icon, "CENTER", 0, 0)
        tab:SetScript("OnClick", function()
            browserTab = tabId
            RefreshQuestBrowser()
        end)
    end

    questBrowser.scroll = CreateFrame("ScrollFrame", nil, questBrowser, "UIPanelScrollFrameTemplate")
    questBrowser.scroll:SetPoint("TOPLEFT", 18, -136)
    questBrowser.scroll:SetPoint("BOTTOMRIGHT", -34, 110)
    questBrowser.content = CreateFrame("Frame", nil, questBrowser.scroll)
    questBrowser.content:SetWidth(610)
    questBrowser.content:SetHeight(1)
    questBrowser.scroll:SetScrollChild(questBrowser.content)
    questBrowser.sectionRows = {}
    questBrowser.objectiveRows = {}
    questBrowser.testButton = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.testButton:SetSize(150, 26)
    questBrowser.testButton:SetPoint("BOTTOMLEFT", 22, 28)
    questBrowser.testButton:SetText("Generate test quest")
    questBrowser.testButton:SetScript("OnClick", function()
        local quest = GenerateQuest(debugState.testLevel)
        questBrowser.preview:SetText(quest and ("Test quest: " .. quest.title .. " — " .. quest.kind .. " — " .. quest.amount .. "\n" .. quest.objective) or "No eligible quest at this generation level.")
    end)
    questBrowser.preview = Text(questBrowser, "GameFontHighlightSmall", {0.6, 1, 0.6})
    questBrowser.preview:SetPoint("BOTTOMLEFT", questBrowser.testButton, "TOPLEFT", 0, 6)
    questBrowser.preview:SetSize(620, 44)
    questBrowser:Hide()
end

RefreshQuestBrowser = function()
    if not questBrowser then return end
    questBrowser.levelLabel:SetText("Generation Level: " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
    questBrowser.levelDown:SetEnabled(debugState.testLevel > 1)
    questBrowser.levelUp:SetEnabled(debugState.testLevel < ELWYNN_MAX_LEVEL)
    for index, tab in ipairs(questBrowser.tabs) do
        local active = browserTabData[index].id == browserTab
        tab.activeMark:SetShown(active)
        tab.label:SetTextColor(active and 1 or 0.82, active and 0.82 or 0.82, active and 0.2 or 0.82)
    end
    local sectionRows, objectiveRows = questBrowser.sectionRows, questBrowser.objectiveRows
    local sectionCount, objectiveCount, y = 0, 0, -8
    local function AddSection(label, icon)
        sectionCount = sectionCount + 1
        local row = sectionRows[sectionCount]
        if not row then
            row = Text(questBrowser.content, "GameFontNormal")
            sectionRows[sectionCount] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", questBrowser.content, "TOPLEFT", 8, y)
        row:SetSize(570, 22)
        row:SetText((icon and "|T" .. icon .. ":16:16:0:0|t  " or "") .. label)
        row:Show()
        y = y - 23
    end
    local function AddObjective(category, branch, objective)
        objectiveCount = objectiveCount + 1
        local row = objectiveRows[objectiveCount]
        if not row then
            row = CreateFrame("Button", nil, questBrowser.content, "UIPanelButtonTemplate")
            row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.title:SetPoint("LEFT", 10, 0)
            row.amount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.amount:SetPoint("RIGHT", -12, 0)
            objectiveRows[objectiveCount] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", questBrowser.content, "TOPLEFT", 8, y)
        row:SetSize(570, 26)
        row.title:SetText(objective.name)
        row.amount:SetText(objective.minAmount == objective.maxAmount and ("(" .. objective.minAmount .. ")") or ("(" .. objective.minAmount .. "–" .. objective.maxAmount .. ")"))
        row:SetScript("OnClick", function()
            local preview = BuildQuest(category, branch, objective, RollAmount(objective))
            questBrowser.preview:SetText(preview.title .. " — " .. preview.kind .. " — " .. preview.amount .. "\n" .. preview.objective)
        end)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(objective.name)
            GameTooltip:AddLine("Creature/resource level or skill: " .. objective.level, 1, 1, 1)
            GameTooltip:AddLine("Eligible character levels: " .. objective.minPlayerLevel .. "-" .. objective.maxPlayerLevel, 1, 1, 1)
            GameTooltip:AddLine("Location: " .. objective.location, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Show()
        y = y - 28
    end
    if browserTab == "hunt" then
        local category = BrowserCategory("hunt")
        for _, branch in ipairs(category.branches) do
            local objectives, effectiveLevel = BrowserObjectives(branch.objectives, debugState.testLevel)
            local label = branch.name == "Rare target" and "Rare Targets" or "Elite Targets"
            if effectiveLevel then
                label = label .. " — Level " .. effectiveLevel
                if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
            end
            AddSection(label)
            for _, objective in ipairs(objectives) do
                AddObjective(category, branch, objective)
            end
        end
    elseif browserTab == "gather" then
        for _, profession in ipairs(database.gather) do
            local category = BrowserGatherCategory(profession)
            local objectives, effectiveLevel = BrowserObjectives(profession.objectives, debugState.testLevel)
            local label = profession.name
            if effectiveLevel then
                label = label .. " — Level " .. effectiveLevel
                if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
            end
            AddSection(label, profession.icon)
            for _, objective in ipairs(objectives) do
                AddObjective(category, nil, objective)
            end
        end
    else
        local category = BrowserCategory(browserTab)
        local objectives, effectiveLevel = BrowserObjectives(category.objectives, debugState.testLevel)
        local label = category.name .. " Objectives"
        if effectiveLevel then
            label = label .. " — Level " .. effectiveLevel
            if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
        end
        AddSection(label)
        for _, objective in ipairs(objectives) do
            AddObjective(category, nil, objective)
        end
    end
    for index = sectionCount + 1, #sectionRows do sectionRows[index]:Hide() end
    for index = objectiveCount + 1, #objectiveRows do objectiveRows[index]:Hide() end
    if objectiveCount == 0 then AddSection("No objectives are eligible at this level.") end
    questBrowser.content:SetHeight(math.max(1, -y + 8))
    questBrowser.scroll:UpdateScrollChildRect()
    questBrowser.scroll:SetVerticalScroll(0)
end

local function CreateDebugModeButton(parent)
    if debugModeButton then return end
    debugModeButton = CreateFrame("Button", "WoWForeverDebugModeButton", parent, "UIPanelButtonTemplate")
    debugModeButton:SetSize(30, 30)
    debugModeButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
    debugModeButton:EnableMouse(true)
    debugModeButton.icon = debugModeButton:CreateTexture(nil, "ARTWORK")
    debugModeButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    debugModeButton.icon:SetDrawLayer("OVERLAY")
    debugModeButton.icon:SetPoint("CENTER", debugModeButton, "CENTER", 0, 0)
    debugModeButton.icon:SetSize(20, 20)
    debugModeButton.active = debugModeButton:CreateTexture(nil, "OVERLAY")
    debugModeButton.active:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    debugModeButton.active:SetBlendMode("ADD")
    debugModeButton.active:SetPoint("CENTER")
    debugModeButton.active:SetSize(42, 42)
    debugModeButton.active:Hide()
    debugModeButton:SetScript("OnClick", function() SetDebugMode(not debugMode, false) end)
    debugModeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Questboard Debug Mode")
        GameTooltip:AddLine(debugMode and "Click to turn off" or "Click to turn on", 1, 1, 1)
        GameTooltip:Show()
    end)
    debugModeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

CreateBoard = function()
    board = CreateFrame("Frame", "WoWForeverQuestboard", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    board:SetSize(840, 570)
    board:SetPoint("CENTER")
    board:SetFrameStrata("DIALOG")
    board:SetFrameLevel(20)
    board:SetClampedToScreen(true)
    board:SetMovable(true)
    board:EnableMouse(true)
    board:RegisterForDrag("LeftButton")
    board:SetScript("OnDragStart", board.StartMoving)
    board:SetScript("OnDragStop", board.StopMovingOrSizing)
    board:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    board:SetBackdropColor(0.12, 0.1, 0.08, 1)
    local title = Text(board, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 54, -22)
    title:SetText("WoW Forever | Questboard — Alpha V0.4.6 (0.4.6)")
    local subtitle = Text(board, "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", 24, -50)
    subtitle:SetText("Generated Elwynn Forest adventures.")
    local close = CreateFrame("Button", nil, board, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    table.insert(UISpecialFrames, "WoWForeverQuestboard")
    CreateDebugModeButton(board)

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
            local quest = db.displayedQuests[offerIndex]
            if not quest then return end
            if db.activeQuest then
                if db.activeQuest.id ~= quest.id then return end
                db.activeQuest = nil
                db.displayedQuests = PickDisplayedQuests()
                Refresh()
                return
            end
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
    board.debugLevelControls = CreateFrame("Frame", nil, board)
    board.debugLevelControls:SetSize(300, 28)
    board.debugLevelControls:SetPoint("TOPRIGHT", -64, -46)
    board.debugLevelText = Text(board.debugLevelControls, "GameFontHighlight")
    board.debugLevelText:SetPoint("LEFT", 0, 0)
    board.debugLevelText:SetSize(214, 24)
    board.debugLevelDown = CreateFrame("Button", nil, board.debugLevelControls, "UIPanelButtonTemplate")
    board.debugLevelDown:SetSize(30, 24)
    board.debugLevelDown:SetPoint("LEFT", board.debugLevelText, "RIGHT", 2, 0)
    board.debugLevelDown:SetText("<")
    board.debugLevelDown:SetScript("OnClick", function() ChangeDebugLevel(-1) end)
    board.debugLevelUp = CreateFrame("Button", nil, board.debugLevelControls, "UIPanelButtonTemplate")
    board.debugLevelUp:SetSize(30, 24)
    board.debugLevelUp:SetPoint("LEFT", board.debugLevelDown, "RIGHT", 2, 0)
    board.debugLevelUp:SetText(">")
    board.debugLevelUp:SetScript("OnClick", function() ChangeDebugLevel(1) end)
    board.debugButton = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.debugButton:SetSize(142, 26)
    board.debugButton:SetPoint("TOPRIGHT", -24, -487)
    board.debugButton:SetText("Quest Browser")
    board.debugButton:Hide()
    board.debugButton:SetScript("OnClick", function()
        if not debugMode then return end
        CreateQuestBrowser()
        RefreshQuestBrowser()
        questBrowser:SetFrameLevel(board:GetFrameLevel() + 20)
        questBrowser:Show()
    end)
    board.reroll = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.reroll:SetSize(120, 26)
    board.reroll:SetPoint("RIGHT", board.debugButton, "LEFT", -8, 0)
    board.reroll:SetText("Reroll quests")
    board.reroll:SetScript("OnClick", function()
        if db.activeQuest then return end
        db.displayedQuests = PickDisplayedQuests()
        Refresh()
    end)

    board.debugLevelControls:Hide()
    board:Hide()
end

SetDebugMode = function(enabled, openBrowser)
    local wasDebugMode = debugMode
    debugMode = not not enabled
    if not board then CreateBoard() end
    if wasDebugMode ~= debugMode then
        db.displayedQuests = PickDisplayedQuests()
    end
    if debugMode then
        if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
        board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
        Refresh()
        board:Show()
        if openBrowser then
            CreateQuestBrowser()
            RefreshQuestBrowser()
            questBrowser:SetFrameLevel(board:GetFrameLevel() + 20)
            questBrowser:Show()
        end
    elseif questBrowser then
        questBrowser:Hide()
    end
    if debugModeButton then debugModeButton.active:SetShown(debugMode) end
    if board then
        board.debugLevelText:SetText("Generation level: " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
        board.debugLevelDown:SetEnabled(debugState.testLevel > 1)
        board.debugLevelUp:SetEnabled(debugState.testLevel < ELWYNN_MAX_LEVEL)
        board.debugLevelControls:SetShown(debugMode)
        board.debugButton:SetShown(debugMode)
    end
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
        card.button:SetText(not quest and "Unavailable" or (accepted and "Abandon Quest" or (db.activeQuest and "Unavailable" or "Accept Quest")))
        card.button:SetEnabled(quest ~= nil and (not db.activeQuest or accepted))
        card.marker:SetText(accepted and "YOUR ACTIVE OBJECTIVE" or "")
        card:SetBackdropBorderColor(accepted and 0.9 or 0.36, accepted and 0.3 or 0.3, accepted and 0.16 or 0.16, 1)
    end
    local active = db.activeQuest
    board.status:SetText(active and ("Active: " .. active.title) or (#db.displayedQuests == 0 and "No Elwynn objectives match your current level and known professions." or "Choose one notice to begin your adventure."))
    board.reroll:SetEnabled(active == nil)
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
    if wantsDebug then
        SetDebugMode(true, true)
        return
    end
    if not board then CreateBoard() end
    if board:IsShown() then
        board:Hide()
        return
    end
    if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
    board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
    board.debugLevelControls:SetShown(debugMode)
    board.debugButton:SetShown(debugMode)
    Refresh()
    board:Show()
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
    local button = CreateFrame("Button", "WoWForeverMinimapButton", Minimap)
    minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    button.background:SetSize(24, 24)
    button.background:SetPoint("CENTER", button, "CENTER", 0, 0)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon:SetSize(20, 20)
    button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.iconMask = button:CreateMaskTexture()
    button.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.iconMask:SetAllPoints(button.icon)
    button.icon:AddMaskTexture(button.iconMask)

    -- The tracking texture includes transparent padding on its right/bottom.
    -- Its standard TOPLEFT anchor aligns the visible ring with the 32px button.
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border:SetSize(53, 53)
    button.border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    local function PositionButton()
        local angle = math.rad(tonumber(db.minimapAngle) or 45)
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER",
            math.cos(angle) * (Minimap:GetWidth() / 2 + 8),
            math.sin(angle) * (Minimap:GetHeight() / 2 + 8))
    end
    local function UpdateDrag()
        local centerX, centerY = Minimap:GetCenter()
        if not centerX or not centerY then return end
        local x, y = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        x, y = x / scale - centerX, y / scale - centerY
        if x ~= 0 or y ~= 0 then
            db.minimapAngle = math.deg(math.atan2(y, x)) % 360
            PositionButton()
        end
    end
    local function StopDrag(self)
        self:SetScript("OnUpdate", nil)
        self.dragging = false
    end

    button:SetScript("OnMouseDown", function(self) self.suppressClick = false end)
    button:SetScript("OnClick", function(self)
        if self.suppressClick then
            self.suppressClick = false
            return
        end
        ToggleBoard(false)
    end)
    button:SetScript("OnEnter", function(self)
        if self.dragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WoW Forever Questboard")
        GameTooltip:AddLine("Click to open the questboard", 1, 1, 1)
        GameTooltip:AddLine("Drag to reposition this button", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function(self)
        self.dragging, self.suppressClick = true, true
        GameTooltip:Hide()
        self:SetScript("OnUpdate", UpdateDrag)
        UpdateDrag()
    end)
    button:SetScript("OnDragStop", function(self)
        UpdateDrag()
        StopDrag(self)
    end)
    button:SetScript("OnHide", function(self)
        StopDrag(self)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)
    button:SetScript("OnShow", PositionButton)
    PositionButton()
end
