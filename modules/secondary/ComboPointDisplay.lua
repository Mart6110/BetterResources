-- Better Resources: Combo Point Display Component
-- Single Responsibility: Display combo points, chi, holy power, soul shards, arcane charges, etc.
local _, BR = ...

BR.ComboPointDisplay = {}
BR.ComboPointDisplay.__index = BR.ComboPointDisplay

-- Constructor
function BR.ComboPointDisplay:new(parent, width)
    local self = setmetatable({}, BR.ComboPointDisplay)
    
    self.parent = parent
    self.points = {}
    self.width = width or 250
    self.maxPoints = 5
    
    self:CreatePoints()
    
    return self
end

-- Create individual point displays
function BR.ComboPointDisplay:CreatePoints()
    local pointWidth = math.floor((self.width - 16) / self.maxPoints)
    local pointSpacing = 4
    local totalWidth = (pointWidth * self.maxPoints) + (pointSpacing * (self.maxPoints - 1))
    
    for i = 1, self.maxPoints do
        local point = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
        point:SetSize(pointWidth, 8)
        point:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        point:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        point:SetBackdropBorderColor(0, 0, 0, 1)
        point:EnableMouse(false)
        
        if i == 1 then
            point:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (pointWidth/2), -2)
        else
            point:SetPoint("LEFT", self.points[i-1], "RIGHT", pointSpacing, 0)
        end
        
        point.fill = point:CreateTexture(nil, "ARTWORK")
        point.fill:SetAllPoints(point)
        point.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
        point.fill:Hide()
        
        point:Hide()
        self.points[i] = point
    end
end

-- Update combo point display
function BR.ComboPointDisplay:Update()
    -- Simply read the power values - event callbacks are not tainted
    local current = UnitPower("player", Enum.PowerType.ComboPoints) or 0
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    
    -- Don't show if max is 0 (class/spec doesn't use combo points)
    if max == 0 then
        self:Hide()
        return
    end
    
    -- Adjust max points if needed (for talents that increase max)
    if max > #self.points then
        -- Need to create more points
        self.maxPoints = max
        -- Clear existing points
        for i = 1, #self.points do
            if self.points[i] then
                self.points[i]:Hide()
                self.points[i] = nil
            end
        end
        self.points = {}
        self:CreatePoints()
    end
    
    -- Get class-specific color
    local _, class = UnitClass("player")
    local r, g, b = self:GetColorForClass(class)
    
    -- Show and update points
    -- Values are not secret when called from event callbacks
    for i = 1, max do
        local point = self.points[i]
        if point then
            point:Show()
            
            if i <= (current or 0) then
                -- Point is active
                point.fill:Show()
                point.fill:SetVertexColor(r, g, b, 1)
            else
                -- Point is inactive
                point.fill:Hide()
            end
        end
    end
    
    -- Hide extra points
    for i = max + 1, #self.points do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Get color based on class
function BR.ComboPointDisplay:GetColorForClass(class)
    if class == "ROGUE" or class == "DRUID" then
        return 1, 0.96, 0.41 -- Yellow (Combo Points)
    elseif class == "MONK" then
        return 0, 1, 0.59 -- Green (Chi)
    elseif class == "PALADIN" then
        return 0.95, 0.9, 0.6 -- Holy Power yellow
    elseif class == "WARLOCK" then
        return 0.58, 0.51, 0.79 -- Purple (Soul Shards)
    elseif class == "MAGE" then
        return 0.41, 0.8, 0.94 -- Blue (Arcane Charges)
    else
        return 0.7, 0.7, 1 -- Default light blue
    end
end

-- Update width when parent frame is resized
function BR.ComboPointDisplay:UpdateWidth(width)
    self.width = width
    
    local pointWidth = math.floor((width - 16) / self.maxPoints)
    local pointSpacing = 4
    local totalWidth = (pointWidth * self.maxPoints) + (pointSpacing * (self.maxPoints - 1))
    
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:SetWidth(pointWidth)
            
            if i == 1 then
                self.points[i]:ClearAllPoints()
                self.points[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (pointWidth/2), -2)
            else
                self.points[i]:ClearAllPoints()
                self.points[i]:SetPoint("LEFT", self.points[i-1], "RIGHT", pointSpacing, 0)
            end
        end
    end
end

-- Show all points
function BR.ComboPointDisplay:Show()
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Show()
        end
    end
end

-- Hide all points
function BR.ComboPointDisplay:Hide()
    for i = 1, #self.points do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Check if this display is applicable for current class
function BR.ComboPointDisplay:IsApplicable()
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    return max and max > 0
end

-- Get height occupied by combo points
function BR.ComboPointDisplay:GetHeight()
    return 10 -- 8 for point height + 2 for spacing
end
