local _, ns = ...
local Database, Windows = ns.Database, ns.Windows
local Editor = {}
ns.DatabaseEditor = Editor
local frame
local state = {view = "objectives", kind = "objectives"}
local views = {
    {id = "zones", label = "Zones", kind = "zones"},
    {id = "objectives", label = "Objectives", kind = "objectives"},
    {id = "questGivers", label = "Quest Givers", kind = "questGivers"},
    {id = "vendors", label = "Vendors", kind = "questGivers"},
    {id = "flavourText", label = "Flavour Text", kind = "flavourText"},
}
local RenderForm, RefreshList, ReadForm
local function Text(parent, font)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    label:SetJustifyH("LEFT"); label:SetJustifyV("TOP")
    return label
end
local function Button(parent, label, width, callback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 26); button:SetText(label); button:SetScript("OnClick", callback)
    return button
end
local function Window(name, title, width, height)
    local result = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    result:SetSize(width, height); result:SetFrameStrata("FULLSCREEN_DIALOG")
    result:SetMovable(true); result:EnableMouse(true); result:RegisterForDrag("LeftButton")
    result:SetScript("OnDragStart", result.StartMoving); result:SetScript("OnDragStop", result.StopMovingOrSizing)
    result:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    result:SetBackdropColor(0.12, 0.1, 0.08, 1)
    result.title = Text(result, "GameFontNormalLarge")
    result.title:SetPoint("TOPLEFT", 22, -20); result.title:SetText(title)
    local close = CreateFrame("Button", nil, result, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    Windows.Register(result)
    table.insert(UISpecialFrames, name)
    return result
end
local function Scroll(parent, left, top, right, bottom)
    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", left, top); scroll:SetPoint("BOTTOMRIGHT", right, bottom)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1); scroll:SetScrollChild(content)
    return scroll, content
end
local function Message(text, errors)
    frame.message:SetText(text or "")
    frame.validationErrors = errors
end
local function Relevant(field, entry)
    return not field.categories or field.categories[entry.category]
end
local function ChoiceLabel(value)
    return Database.categories[value] or (value and tostring(value)) or "(none)"
end
local function Dropdown(parent, width, options, callback)
    local control = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    control.value = false
    UIDropDownMenu_SetWidth(control, width)
    UIDropDownMenu_Initialize(control, function(self, level)
        for _, option in ipairs(options()) do
            local choice = option
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.checked = choice.label, self.value == choice.value
            info.func = function()
                self.value = choice.value or false
                UIDropDownMenu_SetText(self, choice.label)
                CloseDropDownMenus()
                callback(choice.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    return control
end
local function FieldChoices(field)
    local options = {}
    if not field.required then options[#options + 1] = {label = "(none)"} end
    if field.choices == "zones" then
        for _, zone in ipairs(Database:List("zones")) do options[#options + 1] = {label = zone.name, value = zone.id} end
    else
        for _, value in ipairs(field.choices) do options[#options + 1] = {label = ChoiceLabel(value), value = value} end
    end
    return options
end
local function Trim(text) return (text or ""):match("^%s*(.-)%s*$") end
local function Parse(field, control)
    if field.type == "boolean" then return not not control:GetChecked() end
    if field.type == "choice" then return control.value or nil end
    local text = Trim(control:GetText())
    if text == "" then return nil end
    if field.type == "number" then return tonumber(text) or text end
    if field.type == "strings" or field.type == "numbers" then
        local list = {}
        for part in text:gmatch("[^;]+") do
            part = Trim(part)
            list[#list + 1] = field.type == "numbers" and (tonumber(part) or part) or part
        end
        return list
    end
    return text
end
ReadForm = function()
    if not state.draft then return nil end
    local result = {}
    for _, field in ipairs(Database.schema[state.kind]) do
        if Relevant(field, state.draft) then result[field.key] = Parse(field, frame.fields[field.key]) end
    end
    if state.selected then result.id = state.selected end -- Existing IDs are immutable.
    return result
end
RenderForm = function()
    for _, row in pairs(frame.fieldRows) do row:Hide() end
    frame.fields = {}
    frame.save:SetEnabled(state.draft ~= nil)
    frame.delete:SetEnabled(state.selected ~= nil and Database:Get(state.kind, state.selected) ~= nil)
    if not state.draft then frame.formContent:SetHeight(1); return end
    local y = -4
    for _, definition in ipairs(Database.schema[state.kind]) do
        local field = definition
        if Relevant(field, state.draft) then
            local key = state.kind .. ":" .. field.key
            local row = frame.fieldRows[key]
            if not row then
                row = CreateFrame("Frame", nil, frame.formContent)
                row.label = Text(row, "GameFontNormalSmall")
                row.label:SetPoint("TOPLEFT", 0, 0)
                if field.type == "boolean" then
                    row.control = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
                    row.control:SetSize(26, 26); row.control:SetPoint("TOPLEFT", 0, -18)
                elseif field.type == "choice" then
                    row.control = Dropdown(row, 455, function() return FieldChoices(field) end, function(value)
                        local draft = ReadForm()
                        draft[field.key] = value
                        state.draft = draft
                        RenderForm()
                    end)
                    row.control:SetPoint("TOPLEFT", -16, -18)
                else
                    row.control = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                    row.control:SetAutoFocus(false)
                    row.control:SetSize(470, field.type == "text" and 78 or 24)
                    row.control:SetPoint("TOPLEFT", 6, -20)
                    row.control:SetFontObject("GameFontHighlightSmall")
                    row.control:SetMultiLine(field.type == "text")
                    row.control:SetMaxLetters(field.type == "text" and 2000 or 500)
                    row.control:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                end
                frame.fieldRows[key] = row
            end
            row:SetPoint("TOPLEFT", 8, y)
            row:SetSize(488, field.type == "text" and 110 or 58)
            row.label:SetText(field.label .. (field.required and " *" or ""))
            local control, value = row.control, state.draft[field.key]
            if field.type == "boolean" then control:SetChecked(value == true)
            elseif field.type == "choice" then
                control.value = value or false
                local label = ChoiceLabel(value)
                for _, option in ipairs(FieldChoices(field)) do if option.value == value then label = option.label end end
                UIDropDownMenu_SetText(control, label)
            else
                if type(value) == "table" then value = table.concat(value, "; ") end
                control:SetText(value ~= nil and tostring(value) or "")
                control:SetEnabled(field.key ~= "id" or state.selected == nil)
            end
            frame.fields[field.key] = control
            row:Show(); y = y - row:GetHeight()
        end
    end
    frame.formContent:SetHeight(-y + 12)
    frame.formScroll:UpdateScrollChildRect()
end
RefreshList = function()
    for _, row in ipairs(frame.rows) do row:Hide() end
    local count = 0
    for _, entry in ipairs(Database:List(state.kind, true)) do
        local inZone = not state.zone or entry.zone == state.zone or (state.kind == "zones" and entry.id == state.zone)
        local inCategory = not state.category or entry.category == state.category
            or (state.kind == "questGivers" and (function()
                for _, id in ipairs(entry.categories) do if id == state.category then return true end end
            end)())
        if inZone and inCategory and (not state.profession or entry.profession == state.profession)
            and (state.view ~= "vendors" or entry.vendor) then
            count = count + 1
            local selected = entry
            local row = frame.rows[count]
            if not row then row = Button(frame.listContent, "", 250, function() end); frame.rows[count] = row end
            row:SetSize(250, 42); row:SetPoint("TOPLEFT", 0, -(count - 1) * 46)
            row:SetText((entry._disabled and "[Disabled] " or "") .. (entry.name or (entry.text or entry.id):sub(1, 35)) .. "\n" .. entry.id)
            row:SetScript("OnClick", function() Editor.Select(state.kind, selected.id) end)
            row:Show()
        end
    end
    frame.listContent:SetHeight(math.max(1, count * 46))
    frame.listScroll:UpdateScrollChildRect()
    frame.listScroll:SetVerticalScroll(0)
end
function Editor.Select(kind, id)
    if not frame then return end
    local entry = Database:Get(kind, id)
    if not entry then
        for _, item in ipairs(Database:List(kind, true)) do if item.id == id then entry = item end end
    end
    if not entry then return end
    state.kind, state.selected, state.draft = kind, id, entry
    state.draft._disabled = nil
    RenderForm(); frame.formScroll:SetVerticalScroll(0)
    Message("Edit this entry, then Save. Existing rolled quests keep their saved content.")
end
function Editor.New()
    state.selected = nil
    state.draft = {zone = state.zone, category = state.category}
    if state.kind == "zones" then state.draft = {minLevel = 1, maxLevel = 12}
    elseif state.kind == "objectives" then
        state.draft.category = state.category or "kill"
        state.draft.minPlayerLevel, state.draft.maxPlayerLevel = 1, 12
        state.draft.minAmount, state.draft.maxAmount = 1, 1
        state.draft.profession = state.profession
    elseif state.kind == "questGivers" then
        state.draft = {zone = state.zone, faction = "Alliance", vendor = state.view == "vendors",
            categories = {state.view == "vendors" and "supply" or "kill"}}
    end
    RenderForm(); frame.formScroll:SetVerticalScroll(0)
    Message("New entry: use a unique permanent ID. Required fields are marked *.")
end
function Editor.Save()
    local entry = ReadForm()
    if not entry then return end
    local ok, errors = Database:Save(state.kind, entry, not state.selected)
    if not ok then Message(Database:FormatErrors(errors), errors); return false end
    state.selected, state.draft = entry.id, Database:Get(state.kind, entry.id)
    RefreshList(); RenderForm()
    Message("Saved for this character. Reroll to generate new quests using these changes.")
    return true
end
function Editor.Cancel()
    if state.selected then Editor.Select(state.kind, state.selected)
    else state.draft = nil; RenderForm(); Message("New entry cancelled.") end
end
function Editor.RequestDelete()
    if not state.selected then return end
    if not frame.confirmation then
        local dialog = Window("ClassicQuestboardDatabaseDelete", "Delete database entry?", 420, 180)
        dialog.message = Text(dialog)
        dialog.message:SetPoint("TOPLEFT", 24, -58); dialog.message:SetSize(370, 54)
        dialog.confirm = Button(dialog, "Delete", 130, function()
            local ok, errors = Database:Delete(dialog.kind, dialog.entryID)
            dialog:Hide()
            if not ok then Message(Database:FormatErrors(errors), errors); return end
            state.selected, state.draft = nil, nil
            RefreshList(); RenderForm(); Message("Deleted from the runtime database. Built-in source files were not changed.")
        end)
        dialog.confirm:SetPoint("BOTTOMLEFT", 24, 20)
        dialog.cancel = Button(dialog, "Cancel", 130, function() dialog:Hide() end)
        dialog.cancel:SetPoint("BOTTOMRIGHT", -24, 20)
        frame.confirmation = dialog
    end
    local dialog = frame.confirmation
    dialog.kind, dialog.entryID = state.kind, state.selected
    dialog.message:SetText("Delete " .. state.selected .. "?\nBuilt-in entries are disabled by an override. Existing quests are preserved.")
    Windows.Open(dialog, frame)
end
local function Create()
    frame = Window("ClassicQuestboardDatabaseEditor", "Classic Questboard Database Editor", 880, 670)
    Editor.frame = frame
    frame.confirmation = false
    frame.rows, frame.fieldRows, frame.fields = {}, {}, {}
    for index, view in ipairs(views) do
        local tab = view
        local button = Button(frame, tab.label, 156, function()
            state.view, state.kind, state.selected, state.draft = tab.id, tab.kind, nil, nil
            state.category, state.profession = nil, nil
            frame.categoryFilter.value, frame.professionFilter.value = nil, nil
            UIDropDownMenu_SetText(frame.categoryFilter, "All categories")
            UIDropDownMenu_SetText(frame.professionFilter, "All professions")
            RefreshList(); RenderForm(); Message("Browsing " .. tab.label)
        end)
        button:SetPoint("TOPLEFT", 22 + (index - 1) * 166, -55)
    end
    frame.zoneFilter = Dropdown(frame, 230, function()
        local options = {{label = "All zones"}}
        for _, zone in ipairs(Database:List("zones")) do options[#options + 1] = {label = zone.name, value = zone.id} end
        return options
    end, function(value) state.zone = value; RefreshList() end)
    frame.zoneFilter:SetPoint("TOPLEFT", 6, -95); UIDropDownMenu_SetText(frame.zoneFilter, "All zones")
    frame.categoryFilter = Dropdown(frame, 230, function()
        local options = {{label = "All categories"}}
        for _, id in ipairs({"kill", "supply", "hunt", "gather"}) do options[#options + 1] = {label = Database.categories[id], value = id} end
        return options
    end, function(value) state.category = value; RefreshList() end)
    frame.categoryFilter:SetPoint("TOPLEFT", 282, -95); UIDropDownMenu_SetText(frame.categoryFilter, "All categories")
    frame.professionFilter = Dropdown(frame, 230, function()
        local options = {{label = "All professions"}}
        for _, profession in ipairs(Database.professions) do options[#options + 1] = {label = profession.name, value = profession.id} end
        return options
    end, function(value) state.profession = value; RefreshList() end)
    frame.professionFilter:SetPoint("TOPLEFT", 558, -95); UIDropDownMenu_SetText(frame.professionFilter, "All professions")
    frame.listScroll, frame.listContent = Scroll(frame, 22, -142, -600, 120)
    frame.listContent:SetWidth(250)
    frame.formScroll, frame.formContent = Scroll(frame, 318, -142, -40, 120)
    frame.formContent:SetWidth(500)
    frame.add = Button(frame, "Add", 110, Editor.New); frame.add:SetPoint("BOTTOMLEFT", 22, 76)
    frame.save = Button(frame, "Save", 110, Editor.Save); frame.save:SetPoint("LEFT", frame.add, "RIGHT", 12, 0)
    frame.delete = Button(frame, "Delete", 110, Editor.RequestDelete); frame.delete:SetPoint("LEFT", frame.save, "RIGHT", 12, 0)
    frame.cancel = Button(frame, "Cancel", 110, Editor.Cancel); frame.cancel:SetPoint("LEFT", frame.delete, "RIGHT", 12, 0)
    frame.message = Text(frame)
    frame.message:SetPoint("BOTTOMLEFT", 24, 18); frame.message:SetSize(830, 48)
    frame:HookScript("OnEnter", function(self)
        if not self.validationErrors then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        for _, issue in ipairs(self.validationErrors) do GameTooltip:AddLine(issue.message, 1, 0.6, 0.4, true) end
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
    frame:SetScript("OnHide", function() if frame.confirmation then frame.confirmation:Hide() end end)
end
function Editor.Toggle(parent)
    if frame and frame:IsShown() then frame:Hide(); return end
    if not frame then Create() end
    RefreshList(); RenderForm()
    Message(#(Database.errors or {}) > 0 and Database:FormatErrors(Database.errors)
        or "Changes are saved per character. Grey/disabled built-in entries can be restored by selecting them and saving.", Database.errors)
    Windows.Open(frame, parent)
end
