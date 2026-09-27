local _, ns = ...
local tooltip = GameTooltip
if not tooltip then return end
local lineIndex, lastText, elapsed
local function Public(value) return not (issecretvalue and issecretvalue(value)) end
local function Update()
    if not tooltip:IsShown() then return end
    local ok, _, unit = pcall(tooltip.GetUnit, tooltip)
    local text
    if ok and Public(unit) and type(unit) == "string" then text = ns.Tracking.TooltipText(unit) end
    if text == lastText then return end
    if lineIndex then
        local line = _G[tooltip:GetName() .. "TextLeft" .. lineIndex]
        if line then line:SetText(text or "") end
    elseif text then
        tooltip:AddLine(text, 0.78, 0.72, 0.52, true)
        lineIndex = tooltip:NumLines()
    end
    lastText = text
    if text then tooltip:Show() end
end
tooltip:HookScript("OnTooltipCleared", function() lineIndex, lastText = nil, nil end)
if TooltipDataProcessor and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tip)
        if tip == tooltip then Update() end
    end)
elseif tooltip:HasScript("OnTooltipSetUnit") then
    tooltip:HookScript("OnTooltipSetUnit", Update)
end
-- Refresh the existing line while a mob stays hovered; never append duplicates.
tooltip:HookScript("OnUpdate", function(_, delta)
    elapsed = (elapsed or 0) + delta
    if elapsed < 0.2 then return end
    elapsed = 0
    Update()
end)
