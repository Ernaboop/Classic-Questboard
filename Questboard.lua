local addonName = ...
local board, cards, db

local quests = {
    {
        id = "fargodeep_kobolds", title = "Trouble in Fargodeep Mine", kind = "HUNT",
        zone = "Elwynn Forest", level = 5, source = "A Goldshire miner",
        description = "Kobolds have been spotted gathering in Fargodeep Mine. A miner wants the entrance made safer before the next shift heads underground.",
        objective = "Travel to Fargodeep Mine and kill 8 Kobold Workers.",
        prompt = "Ask the miners what drove the kobolds into the mine before you go in.",
    },
    {
        id = "stone_cairn_linen", title = "Cloth for the Abbey", kind = "COLLECT",
        zone = "Elwynn Forest", level = 6, source = "A Northshire quartermaster",
        description = "The Abbey needs clean linen for bandages. Defias trouble around Stone Cairn Lake has left useful supplies in short supply.",
        objective = "Collect 6 Linen Cloth from Defias Bandits near Stone Cairn Lake, then bring it to Northshire Abbey.",
        prompt = "Consider whether the bandits are merely enemies, or people in need of help themselves.",
    },
    {
        id = "eastvale_wolves", title = "Wolves at the Treeline", kind = "HUNT",
        zone = "Elwynn Forest", level = 7, source = "A lumberjack at Eastvale Logging Camp",
        description = "The workers at Eastvale say wolves have been prowling closer to camp. Thin the pack before someone gets hurt.",
        objective = "Travel to the woods around Eastvale Logging Camp and kill 6 Prowlers or Young Forest Bears.",
        prompt = "Look for signs of what has drawn the predators toward the logging camp.",
    },
    {
        id = "goldshire_boar_meat", title = "Fresh Meat for the Inn", kind = "GATHER & DELIVER",
        zone = "Elwynn Forest", level = 3, source = "Innkeeper Farley in Goldshire",
        description = "The Lion's Pride Inn is running short on fresh meat. Innkeeper Farley will pay for a small delivery from the nearby woods.",
        objective = "Collect 6 Chunks of Boar Meat from boars in Elwynn Forest. Sell all 6 to Innkeeper Farley at the Lion's Pride Inn in Goldshire.",
        prompt = "Ask the inn's patrons how business has been along the roads lately.",
    },
    {
        id = "crystal_lake_scout", title = "A Scout at Crystal Lake", kind = "SCOUT",
        zone = "Elwynn Forest", level = 4, source = "A Stormwind courier",
        description = "A courier has heard that the path around Crystal Lake may be unsafe. Check the lakeshore and report what you find.",
        objective = "Travel to Crystal Lake in Elwynn Forest. Walk its shore, then return to Goldshire and report your observations.",
        prompt = "Decide what details would convince your character that a place is safe for travelers.",
    },
}

local questsById = {}
for _, quest in ipairs(quests) do questsById[quest.id] = quest end

local function PickDisplayedQuests()
    local pool = {}
    for _, quest in ipairs(quests) do
        if quest.id ~= db.activeQuestId then pool[#pool + 1] = quest.id end
    end
    for index = #pool, 2, -1 do
        local swap = math.random(index)
        pool[index], pool[swap] = pool[swap], pool[index]
    end
    local chosen = {}
    if db.activeQuestId and questsById[db.activeQuestId] then
        chosen[1] = db.activeQuestId
    end
    local needed = 3 - #chosen
    for index = 1, needed do chosen[#chosen + 1] = pool[index] end
    for index = #chosen, 2, -1 do
        local swap = math.random(index)
        chosen[index], chosen[swap] = chosen[swap], chosen[index]
    end
    return chosen
end

local function Text(parent, size, color)
    local text = parent:CreateFontString(nil, "OVERLAY", size or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if color then text:SetTextColor(unpack(color)) end
    return text
end

local function Refresh()
    for index, card in ipairs(cards) do
        local questId = db.displayedQuestIds[index]
        local offer = questsById[questId]
        local accepted = db.activeQuestId == questId
        card.heading:SetText(offer.title)
        card.meta:SetText(offer.kind .. "  |  " .. offer.zone .. "\nSuggested level " .. offer.level .. "  |  " .. offer.source)
        card.story:SetText(offer.description)
        card.objective:SetText("Your objective\n|cffffffff" .. offer.objective .. "|r")
        card.prompt:SetText("Roleplay prompt\n|cffffffff" .. offer.prompt .. "|r")
        card.button:SetText(accepted and "Accepted" or (db.activeQuestId and "Unavailable" or "Accept objective"))
        card.button:SetEnabled(not db.activeQuestId)
        card.marker:SetText(accepted and "YOUR ACTIVE OBJECTIVE" or "")
        card:SetBackdropBorderColor(accepted and 0.9 or 0.36, accepted and 0.7 or 0.3, 0.16, 1)
    end
    local active = db.activeQuestId and questsById[db.activeQuestId]
    board.status:SetText(active and ("Active: " .. active.title) or "Choose one notice to begin your adventure.")
    board.release:SetEnabled(active ~= nil)
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
    title:SetText("WoW Forever | Questboard — Alpha V0.1")
    local subtitle = Text(board, "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", 24, -50)
    subtitle:SetText("Three notices. One adventure. Bring your character's story to the world.")
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
            if db.activeQuestId then return end
            local questId = db.displayedQuestIds[offerIndex]
            db.activeQuestId = questId
            db.displayedQuestIds = PickDisplayedQuests()
            Refresh()
            print("|cffffd27fWoW Forever:|r Accepted \"" .. questsById[questId].title .. "\". Open /cq to view your objective.")
        end)
    end
    board.status = Text(board, "GameFontNormal")
    board.status:SetPoint("TOPLEFT", 24, -494)
    board.status:SetSize(430, 22)
    local note = Text(board, "GameFontHighlightSmall", {0.65, 0.65, 0.65})
    note:SetPoint("TOPLEFT", 24, -529)
    note:SetText("RP objectives are self-guided. This prototype does not track completion or share with your party.")
    board.release = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.release:SetSize(156, 26)
    board.release:SetPoint("TOPRIGHT", -24, -490)
    board.release:SetText("Release objective")
    board.release:SetScript("OnClick", function() db.activeQuestId = nil; Refresh() end)
    board.reroll = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.reroll:SetSize(140, 26)
    board.reroll:SetPoint("RIGHT", board.release, "LEFT", -8, 0)
    board.reroll:SetText("Reroll quests")
    board.reroll:SetScript("OnClick", function()
        db.displayedQuestIds = PickDisplayedQuests()
        Refresh()
    end)
    board:Hide()
end

local function ValidDisplayedQuests(displayed)
    if type(displayed) ~= "table" or #displayed ~= 3 then return false end
    local seen = {}
    for _, questId in ipairs(displayed) do
        if type(questId) ~= "string" or not questsById[questId] or seen[questId] then return false end
        seen[questId] = true
    end
    return true
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, loaded)
    if loaded ~= addonName then return end
    WoWForeverDB = type(WoWForeverDB) == "table" and WoWForeverDB or {}
    db = WoWForeverDB
    if not questsById[db.activeQuestId] then db.activeQuestId = nil end
    if not ValidDisplayedQuests(db.displayedQuestIds) then db.displayedQuestIds = PickDisplayedQuests() end
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_WOWFOREVERQUESTBOARD1 = "/cq"
SlashCmdList.WOWFOREVERQUESTBOARD = function()
    if not db then return end
    if not board then CreateBoard() end
    if board:IsShown() then board:Hide(); return end
    board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
    Refresh()
    board:Show()
end
