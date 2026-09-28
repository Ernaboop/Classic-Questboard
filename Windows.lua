local _, ns = ...
local Windows = {entries = {}, serial = 0}
ns.Windows = Windows

local function IsBelow(frame, ancestor)
    local current = frame
    while current do
        if current == ancestor then return true end
        local entry = Windows.entries[current]
        current = entry and entry.parent
    end
    return false
end

function Windows.Register(frame, parent)
    Windows.entries[frame] = {parent = parent, order = 0}
    frame:SetClampedToScreen(true)
    frame:HookScript("OnMouseDown", function() Windows.Raise(frame) end)
end

function Windows.Raise(frame)
    local entry = Windows.entries[frame]
    if not entry then return end
    if not entry.parent then return end -- Main window remains below auxiliaries.
    Windows.serial = Windows.serial + 1
    entry.order = Windows.serial
    frame:SetFrameLevel(100 + Windows.serial * 50)
    for child, childEntry in pairs(Windows.entries) do
        if childEntry.parent == frame and child:IsShown() then Windows.Raise(child) end
    end
end

function Windows.Previous(root, opening)
    local previous, order = root, -1
    for frame, entry in pairs(Windows.entries) do
        if frame ~= opening and frame:IsShown() and IsBelow(frame, root)
            and not IsBelow(frame, opening) and entry.order > order then
            previous, order = frame, entry.order
        end
    end
    return previous
end

function Windows.Open(frame, parent)
    local entry = Windows.entries[frame]
    if not entry or not parent or IsBelow(parent, frame) then return end
    entry.parent = parent
    frame:ClearAllPoints()
    frame:SetScale(1)
    local right, left = parent:GetRight(), parent:GetLeft()
    local parentScale = parent:GetEffectiveScale()
    local scale = frame:GetEffectiveScale()
    local screenWidth = UIParent:GetWidth() * UIParent:GetEffectiveScale()
    local required = (frame:GetWidth() + 8) * scale
    local parentEntry = Windows.entries[parent]
    if (parentEntry and parentEntry.parent) or (right and right * parentScale + required > screenWidth) then
        -- Nested windows continue down the auxiliary column, never back over
        -- the main board to the left. Fit that column when screen space permits.
        local bottom = parent:GetBottom()
        if left and bottom and bottom > 20 then
            local availableWidth = math.max(100, screenWidth - left * parentScale - 12)
            local availableHeight = math.max(100, bottom * parentScale - 12)
            frame:SetScale(math.min(1, availableWidth / (frame:GetWidth() * scale), availableHeight / (frame:GetHeight() * scale)))
        end
        frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -8)
    else
        frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 8, 0)
    end
    frame:Show()
    Windows.Raise(frame)
end
