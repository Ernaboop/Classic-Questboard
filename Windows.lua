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
    local uiScale = UIParent:GetEffectiveScale()
    local screenWidth = UIParent:GetWidth() * uiScale
    local screenHeight = UIParent:GetHeight() * uiScale
    local scale = frame:GetEffectiveScale()
    local margin = 12 * uiScale
    -- Only shrink a window if the whole window is larger than the screen.
    -- Limited space below its parent must not make it unreadably small.
    local fit = math.min(1, (screenWidth - 2 * margin) / (frame:GetWidth() * scale),
        (screenHeight - 2 * margin) / (frame:GetHeight() * scale))
    if fit < 1 then frame:SetScale(fit) end
    scale = frame:GetEffectiveScale()
    local width, height = frame:GetWidth() * scale, frame:GetHeight() * scale
    local parentScale = parent:GetEffectiveScale()
    local right, left = parent:GetRight(), parent:GetLeft()
    local parentEntry = Windows.entries[parent]
    local beside = not (parentEntry and parentEntry.parent)
        and (not right or right * parentScale + 8 * uiScale + width + margin <= screenWidth)
    local top = beside and parent:GetTop() or parent:GetBottom()
    local x = beside and right or left
    if x and top then
        x = x * parentScale + (beside and 8 * uiScale or 0)
        top = top * parentScale - (beside and 0 or 8 * uiScale)
        local clampedX = math.max(margin, math.min(x, screenWidth - width - margin))
        local clampedTop = math.max(height + margin, math.min(top, screenHeight - margin))
        if clampedX ~= x or clampedTop ~= top then
            -- Keep the requested column, but slide the whole window onto the
            -- screen when there is not enough room beneath its parent.
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", clampedX / uiScale,
                (clampedTop - screenHeight) / uiScale)
        else
            frame:SetPoint("TOPLEFT", parent, beside and "TOPRIGHT" or "BOTTOMLEFT",
                beside and 8 or 0, beside and 0 or -8)
        end
    else
        frame:SetPoint("TOPLEFT", parent, beside and "TOPRIGHT" or "BOTTOMLEFT",
            beside and 8 or 0, beside and 0 or -8)
    end
    frame:Show()
    Windows.Raise(frame)
end
