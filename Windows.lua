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
    frame:HookScript("OnHide", function()
        -- These windows are UIParent children so that they can be moved freely.
        -- Their logical parent/child relationship must be closed explicitly.
        for child, childEntry in pairs(Windows.entries) do
            if childEntry.parent == frame and child:IsShown() then child:Hide() end
        end
    end)
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

local function Overlap(left, bottom, right, top, other)
    local scale = other:GetEffectiveScale()
    local otherLeft, otherRight = other:GetLeft(), other:GetRight()
    local otherBottom, otherTop = other:GetBottom(), other:GetTop()
    if not (otherLeft and otherRight and otherBottom and otherTop) then return 0 end
    return math.max(0, math.min(right, otherRight * scale) - math.max(left, otherLeft * scale))
        * math.max(0, math.min(top, otherTop * scale) - math.max(bottom, otherBottom * scale))
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
    local margin, gap = 12 * uiScale, 8 * uiScale

    -- Only shrink when the window itself is larger than the usable screen.
    local fit = math.min(1, (screenWidth - 2 * margin) / (frame:GetWidth() * scale),
        (screenHeight - 2 * margin) / (frame:GetHeight() * scale))
    if fit < 1 then frame:SetScale(fit) end
    scale = frame:GetEffectiveScale()
    local width, height = frame:GetWidth() * scale, frame:GetHeight() * scale

    local parentScale = parent:GetEffectiveScale()
    local left, right = parent:GetLeft(), parent:GetRight()
    local top, bottom = parent:GetTop(), parent:GetBottom()
    if left then left = left * parentScale end
    if right then right = right * parentScale end
    if top then top = top * parentScale end
    if bottom then bottom = bottom * parentScale end

    local nested = Windows.entries[parent] and Windows.entries[parent].parent
    local candidates = {}
    local function Add(kind, x, y, preference)
        if not (x and y) then return end
        local clampedX = math.max(margin, math.min(x, screenWidth - width - margin))
        local clampedTop = math.max(height + margin, math.min(y, screenHeight - margin))
        local overlap = 0
        for other in pairs(Windows.entries) do
            if other ~= frame and other:IsShown() then
                overlap = overlap + Overlap(clampedX, clampedTop - height,
                    clampedX + width, clampedTop, other)
            end
        end
        candidates[#candidates + 1] = {kind = kind, clampedX = clampedX,
            clampedTop = clampedTop, visible = clampedX == x and clampedTop == y,
            overlap = overlap, displacement = math.abs(x - clampedX) + math.abs(y - clampedTop),
            preference = preference}
    end

    -- Nested windows usually continue downward. At an edge, either side can
    -- be better; evaluate both before falling back to a screen-clamped spot.
    Add("right", right and right + gap, top, nested and 2 or 1)
    Add("left", left and left - gap - width, top, nested and 3 or 2)
    Add("below", left, bottom and bottom - gap, nested and 1 or 3)

    local best
    for _, candidate in ipairs(candidates) do
        if not best
            or (candidate.visible and not best.visible)
            or (candidate.visible == best.visible and candidate.overlap < best.overlap)
            or (candidate.visible == best.visible and candidate.overlap == best.overlap
                and candidate.displacement < best.displacement)
            or (candidate.visible == best.visible and candidate.overlap == best.overlap
                and candidate.displacement == best.displacement
                and candidate.preference < best.preference) then
            best = candidate
        end
    end

    if best and best.visible then
        if best.kind == "right" then
            frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 8, 0)
        elseif best.kind == "left" then
            frame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -8, 0)
        else
            frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -8)
        end
    elseif best then
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", best.clampedX / uiScale,
            (best.clampedTop - screenHeight) / uiScale)
    else
        -- Initial layout before WoW has measured the parent frame.
        frame:SetPoint("TOPLEFT", parent, nested and "BOTTOMLEFT" or "TOPRIGHT",
            nested and 0 or 8, nested and -8 or 0)
    end
    frame:Show()
    Windows.Raise(frame)
end
