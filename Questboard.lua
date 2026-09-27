local addonName = ...
local board, cards, db, debugPanel
local Refresh

-- Amounts are deliberately curated per objective. Mob levels and zone data use
-- the WoW Forever Elwynn Forest tables; counts are quest-balance choices.
local database = {
    categories = {
        {
            id = "kill", name = "Kill", source = "A local guard",
            objectives = {
                {id = "kobold_tunneler", name = "Kobold Tunneler", level = "5-6", amounts = {8, 10, 12}, location = "Fargodeep Mine"},
                {id = "murloc_streamrunner", name = "Murloc Streamrunner", level = "6-7", amounts = {7, 9, 11}, location = "Crystal Lake"},
                {id = "riverpaw_outrunner", name = "Riverpaw Outrunner", level = "9-10", amounts = {5, 6, 8}, location = "south of Eastvale"},
            },
        },
        {
            id = "collect_sell", name = "Collect & Sell", source = "A local trader",
            objectives = {
                {id = "kobold_spoils", name = "Kobold Spoils", target = "Kobold Workers, Tunnelers, and Miners", level = "5-7", amounts = {4, 5, 6}, location = "Fargodeep Mine"},
                {id = "murloc_spoils", name = "Murloc Spoils", target = "Murlocs", level = "6-10", amounts = {3, 4, 5}, location = "Crystal Lake"},
                {id = "riverpaw_spoils", name = "Riverpaw Spoils", target = "Riverpaw Gnolls", level = "8-10", amounts = {3, 4, 5}, location = "the eastern roads"},
            },
        },
        {
            id = "hunt", name = "Hunt", source = "A local scout",
            branches = {
                {
                    id = "rare", name = "Rare target",
                    objectives = {
                        {id = "narg", name = "Narg the Taskmaster", level = "10", amounts = {1}, location = "outside Fargodeep Mine", rarity = "Rare"},
                        {id = "morgaine", name = "Morgaine the Sly", level = "10", amounts = {1}, location = "near the river to Westfall", rarity = "Rare"},
                        {id = "fedfennel", name = "Fedfennel", level = "12", amounts = {1}, location = "northeast Elwynn Forest", rarity = "Rare"},
                    },
                },
                {
                    id = "elite", name = "Elite targets",
                    objectives = {
                        {id = "mine_spider", name = "Mine Spider", level = "7-9", amounts = {3, 4, 5}, location = "Jasperlode Mine", rarity = "Elite"},
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
                {id = "peacebloom", name = "Peacebloom", level = "Gathering skill 1", amounts = {4, 6, 8}, location = "throughout Elwynn Forest"},
                {id = "silverleaf", name = "Silverleaf", level = "Gathering skill 1", amounts = {4, 6, 8}, location = "near trees and shaded areas"},
                {id = "earthroot", name = "Earthroot", level = "Gathering skill 15", amounts = {3, 4, 5}, location = "hillsides and rocky ground"},
            },
        },
        {
            id = "mining", name = "Mining",
            skillLine = 186,
            objectives = {
                {id = "copper_ore", name = "Copper Ore", level = "Mining skill 1", amounts = {5, 7, 9}, location = "hillsides and rocky ground"},
                {id = "rough_stone", name = "Rough Stone", level = "Mining skill 1", amounts = {5, 7, 9}, location = "from Copper Veins"},
            },
        },
        {
            id = "skinning", name = "Skinning",
            skillLine = 393,
            objectives = {
                {id = "ruined_leather_scraps", name = "Ruined Leather Scraps", level = "Skinning skill 1", amounts = {4, 6, 8}, location = "skinnable beasts throughout Elwynn"},
                {id = "light_leather", name = "Light Leather", level = "Skinning skill 1", amounts = {3, 4, 5}, location = "skinnable beasts throughout Elwynn"},
            },
        },
        {
            id = "fishing", name = "Fishing",
            skillLine = 356,
            objectives = {
                {id = "brilliant_smallfish", name = "Raw Brilliant Smallfish", level = "Fishing skill 1", amounts = {5, 7, 9}, location = "lakes and rivers"},
                {id = "longjaw_mud_snapper", name = "Raw Longjaw Mud Snapper", level = "Fishing skill 50", amounts = {4, 6, 8}, location = "lakes and rivers"},
                {id = "bristle_whisker_catfish", name = "Raw Bristle Whisker Catfish", level = "Fishing skill 100", amounts = {2, 3, 4}, location = "Wildbend River"},
            },
        },
    },
}

local function RandomFrom(list)
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
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

local function ObjectiveOptions(category, branch)
    if not category then return {} end
    if category.id == "hunt" then return branch and branch.objectives or {} end
    if category.profession then return category.profession.objectives end
    return category.objectives or {}
end

local function BuildQuest(category, branch, objective, amount)
    if not category or not objective then return nil end
    amount = amount or objective.amounts[1]
    local kind = category.baseName or category.name
    local target = objective.target or objective.name
    local location = objective.location and (" at " .. objective.location) or " in Elwynn Forest"
    local action
    if category.id == "kill" then
        action = "Travel to " .. objective.location .. " and defeat " .. amount .. " " .. target .. "."
    elseif category.id == "collect_sell" then
        action = "Collect " .. amount .. " vendor-value item" .. (amount == 1 and "" or "s") .. " from " .. target .. " near " .. objective.location .. ", then sell the items to a vendor."
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
    }
end

local function GenerateQuest()
    local categories = CategoryOptions(false)
    local category = RandomFrom(categories)
    if not category then return nil end
    local branch
    if category.id == "hunt" then branch = RandomFrom(category.branches) end
    local objective = RandomFrom(ObjectiveOptions(category, branch))
    if not objective then return nil end
    return BuildQuest(category, branch, objective, RandomFrom(objective.amounts))
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
    if type(displayed) ~= "table" or #displayed ~= 3 then return false end
    local seen = {}
    for _, quest in ipairs(displayed) do
        if not ValidQuest(quest) or seen[quest.id] then return false end
        seen[quest.id] = true
    end
    return true
end

local debugState = {layer = 1, categoryIndex = 1, branchIndex = 1, objectiveIndex = 1, amountIndex = 1}

local function DebugSelection()
    local categories = CategoryOptions(true)
    local category = categories[debugState.categoryIndex]
    if not category then return categories, nil end
    local branch
    if category.id == "hunt" then
        branch = category.branches[debugState.branchIndex]
    end
    local objectives = ObjectiveOptions(category, branch)
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
            for _, amount in ipairs(objective.amounts) do options[#options + 1] = tostring(amount) end
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
    debugState.amountIndex = math.min(math.max(debugState.amountIndex, 1), objective and #objective.amounts or 1)
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

local function RenderDebug()
    ClampDebugState()
    local _, category, branch, objectives, objective = DebugSelection()
    local count = DebugLayerCount(category)
    local layerName, options = DebugLayerOptions(debugState.layer)
    local selectionIndex
    if debugState.layer == 1 then
        selectionIndex = debugState.categoryIndex
    elseif debugState.layer == 2 and category.id == "hunt" then
        selectionIndex = debugState.branchIndex
    elseif (debugState.layer == 2) or (debugState.layer == 3 and category.id == "hunt") then
        selectionIndex = debugState.objectiveIndex
    else
        selectionIndex = debugState.amountIndex
    end
    local selected = options[selectionIndex] or "(no options)"
    debugPanel.layer:SetText("Layer " .. debugState.layer .. " of " .. count .. "  |  " .. (layerName or ""))
    debugPanel.selection:SetText(selected)
    debugPanel.position:SetText("Option " .. selectionIndex .. " of " .. #options)

    local detail
    if debugState.layer == 1 then
        local available = CategoryOptions(false)
        local availableNames = {}
        for _, item in ipairs(available) do availableNames[#availableNames + 1] = item.name end
        detail = category.id == "hunt"
            and "Hunt randomly branches to a Rare target or Elite targets; the next layer chooses the target."
            or "Generator order: choose a category, then an objective, then one of that objective's allowed amounts."
        detail = detail .. "\n\nAvailable to this character: " .. table.concat(availableNames, ", ")
        if category.locked then detail = detail .. "\n\nThis gathering profession is not learned, so normal generation skips it." end
    elseif objective then
        detail = "Objective: " .. objective.name ..
            "\nLevel or skill: " .. objective.level ..
            "\nElwynn location: " .. objective.location ..
            "\nAllowed amounts: " .. table.concat(objective.amounts, " / ")
        if category.id == "collect_sell" then
            detail = detail .. "\nAmount counts vendor-value drops collected and then sold."
        elseif category.id == "hunt" and branch.id == "rare" then
            detail = detail .. "\nRare targets are always exactly one."
        elseif category.id == "hunt" then
            detail = detail .. "\nElite hunt amounts are kept to a small group."
        end
    elseif category then
        detail = category.name .. " has " .. #objectives .. " objectives in this selection."
    else
        detail = "No objectives are available for this layer."
    end
    debugPanel.details:SetText(detail)

    debugPanel.previousOption:SetEnabled(#options > 1)
    debugPanel.nextOption:SetEnabled(#options > 1)
    debugPanel.previousLayer:SetEnabled(debugState.layer > 1)
    debugPanel.nextLayer:SetEnabled(debugState.layer < count)
    debugPanel.previewButton:SetEnabled(objective ~= nil)
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
    title:SetText("WoW Forever | Questboard — Alpha V0.2.1 (0.2.1)")
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
    debugPanel.header:SetPoint("TOPLEFT", 22, -22)
    debugPanel.header:SetText("Generator Debug Browser")
    debugPanel.layer = Text(debugPanel, "GameFontNormal")
    debugPanel.layer:SetPoint("TOPLEFT", 22, -70)
    debugPanel.layer:SetSize(700, 24)
    debugPanel.selection = Text(debugPanel, "GameFontNormalLarge", {1, 0.82, 0.25})
    debugPanel.selection:SetPoint("TOPLEFT", 22, -106)
    debugPanel.selection:SetSize(740, 30)
    debugPanel.position = Text(debugPanel, "GameFontHighlightSmall")
    debugPanel.position:SetPoint("TOPLEFT", 22, -140)
    debugPanel.details = Text(debugPanel, "GameFontHighlight")
    debugPanel.details:SetPoint("TOPLEFT", 22, -170)
    debugPanel.details:SetSize(744, 116)
    debugPanel.previousOption = CreateFrame("Button", nil, debugPanel, "UIPanelButtonTemplate")
    debugPanel.previousOption:SetSize(126, 26)
    debugPanel.previousOption:SetPoint("BOTTOMLEFT", 22, 54)
    debugPanel.previousOption:SetText("Previous option")
    debugPanel.previousOption:SetScript("OnClick", function() ChangeDebugOption(-1) end)
    debugPanel.nextOption = CreateFrame("Button", nil, debugPanel, "UIPanelButtonTemplate")
    debugPanel.nextOption:SetSize(126, 26)
    debugPanel.nextOption:SetPoint("LEFT", debugPanel.previousOption, "RIGHT", 8, 0)
    debugPanel.nextOption:SetText("Next option")
    debugPanel.nextOption:SetScript("OnClick", function() ChangeDebugOption(1) end)
    debugPanel.previousLayer = CreateFrame("Button", nil, debugPanel, "UIPanelButtonTemplate")
    debugPanel.previousLayer:SetSize(112, 26)
    debugPanel.previousLayer:SetPoint("LEFT", debugPanel.nextOption, "RIGHT", 28, 0)
    debugPanel.previousLayer:SetText("Previous layer")
    debugPanel.previousLayer:SetScript("OnClick", function() ChangeDebugLayer(-1) end)
    debugPanel.nextLayer = CreateFrame("Button", nil, debugPanel, "UIPanelButtonTemplate")
    debugPanel.nextLayer:SetSize(112, 26)
    debugPanel.nextLayer:SetPoint("LEFT", debugPanel.previousLayer, "RIGHT", 8, 0)
    debugPanel.nextLayer:SetText("Next layer")
    debugPanel.nextLayer:SetScript("OnClick", function() ChangeDebugLayer(1) end)
    debugPanel.previewButton = CreateFrame("Button", nil, debugPanel, "UIPanelButtonTemplate")
    debugPanel.previewButton:SetSize(142, 26)
    debugPanel.previewButton:SetPoint("BOTTOMRIGHT", -22, 54)
    debugPanel.previewButton:SetText("Preview selection")
    debugPanel.previewButton:SetScript("OnClick", function()
        local _, category, branch, _, objective = DebugSelection()
        if not objective then return end
        local amount = objective.amounts[debugState.amountIndex]
        local preview = BuildQuest(category, branch, objective, amount)
        debugPanel.preview:SetText(preview.title .. "  |  " .. preview.kind .. "  |  " .. preview.amount .. "\n" .. preview.objective)
    end)
    debugPanel.preview = Text(debugPanel, "GameFontHighlightSmall", {0.6, 1, 0.6})
    debugPanel.preview:SetPoint("BOTTOMLEFT", 22, 14)
    debugPanel.preview:SetSize(748, 34)
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
        local accepted = db.activeQuest and db.activeQuest.id == quest.id
        card.heading:SetText(quest.title)
        card.meta:SetText(quest.kind .. "  |  " .. quest.zone .. "\nLevel or skill: " .. quest.level .. "  |  " .. quest.source)
        card.story:SetText(quest.description)
        card.objective:SetText("Your objective\n|cffffffff" .. quest.objective .. "|r")
        card.prompt:SetText("Roleplay prompt\n|cffffffff" .. quest.prompt .. "|r")
        card.button:SetText(accepted and "Accepted" or (db.activeQuest and "Unavailable" or "Accept objective"))
        card.button:SetEnabled(not db.activeQuest)
        card.marker:SetText(accepted and "YOUR ACTIVE OBJECTIVE" or "")
        card:SetBackdropBorderColor(accepted and 0.9 or 0.36, accepted and 0.3 or 0.3, accepted and 0.16 or 0.16, 1)
    end
    local active = db.activeQuest
    board.status:SetText(active and ("Active: " .. active.title) or "Choose one notice to begin your adventure.")
    board.release:SetEnabled(active ~= nil)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, loaded)
    if loaded ~= addonName then return end
    WoWForeverDB = type(WoWForeverDB) == "table" and WoWForeverDB or {}
    db = WoWForeverDB
    if not ValidQuest(db.activeQuest) then db.activeQuest = nil end
    if db.activeQuest then db.activeQuestId = nil end
    if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_WOWFOREVERQUESTBOARD1 = "/cq"
local function ToggleBoard(wantsDebug)
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
