-- Better Resources: Evoker Secondary Resource Display Component
-- Single Responsibility: Display Evoker essence points
local _, BR = ...

BR.EvokerSecondaryDisplay = {}
BR.EvokerSecondaryDisplay.__index = BR.EvokerSecondaryDisplay

-- Constructor
function BR.EvokerSecondaryDisplay:new(parent, width)
    local self = setmetatable({}, BR.EvokerSecondaryDisplay)
    
    self.parent = parent
    self.points = {}
    self.width = width or 250
    self.maxPoints = 6 -- Allow for up to 6 essence with talents
    
    self:CreatePoints()
    
    return self
end

-- Create individual essence displays
function BR.EvokerSecondaryDisplay:CreatePoints()
    local pointWidth = math.floor((self.width - 20) / self.maxPoints)
    local pointSpacing = 3
    local totalWidth = (pointWidth * self.maxPoints) + (pointSpacing * (self.maxPoints - 1))
    
    for i = 1, self.maxPoints do
        -- Create a status bar for each point to show filling without comparing secret values
        local point = CreateFrame("StatusBar", nil, self.parent, "BackdropTemplate")
        point:SetSize(pointWidth, 8)
        point:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        point:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        point:SetBackdropBorderColor(0, 0, 0, 1)
        point:EnableMouse(false)
        point:SetMinMaxValues(0, 1)
        point:SetValue(0)
        
        if i == 1 then
            point:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (pointWidth/2), -2)
        else
            point:SetPoint("LEFT", self.points[i-1], "RIGHT", pointSpacing, 0)
        end
        
        -- Set the status bar texture
        point:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        point:SetStatusBarColor(0.2, 0.58, 0.5, 1) -- Teal/cyan color for Essence
        
        self.points[i] = point
    end
end

-- Update essence display
function BR.EvokerSecondaryDisplay:Update()
    -- Get essence as raw value (not secret when using StatusBar)
    local current = UnitPower("player", Enum.PowerType.Essence)
    local max = UnitPowerMax("player", Enum.PowerType.Essence)
    
    -- Check if we have valid max
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Ensure current is valid, default to 0
    current = current or 0
    
    -- Realign if max changed (talent change)
    if self.lastMax ~= max then
        self.lastMax = max
        self:RealignPoints(max)
    end
    
    -- Update each point using StatusBar approach
    for i = 1, self.maxPoints do
        local point = self.points[i]
        if point then
            if i <= max then
                point:Show()
                
                -- Each point represents exactly 1 essence
                local minValue = i - 1
                local maxValue = i
                point:SetMinMaxValues(minValue, maxValue)
                
                -- Set the current value directly - StatusBar handles the display
                point:SetValue(current)
            else
                point:Hide()
            end
        end
    end
end

-- Realign points based on current max essence
function BR.EvokerSecondaryDisplay:RealignPoints(max)
    local pointWidth = math.floor((self.width - 20) / self.maxPoints)
    local pointSpacing = 3
    local totalWidth = (pointWidth * max) + (pointSpacing * (max - 1))
    
    for i = 1, max do
        if self.points[i] then
            self.points[i]:ClearAllPoints()
            
            if i == 1 then
                self.points[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (pointWidth/2), -2)
            else
                self.points[i]:SetPoint("LEFT", self.points[i-1], "RIGHT", pointSpacing, 0)
            end
        end
    end
end

-- Update width when parent frame is resized
function BR.EvokerSecondaryDisplay:UpdateWidth(width)
    self.width = width
    
    local pointWidth = math.floor((width - 20) / self.maxPoints)
    local pointSpacing = 3
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
function BR.EvokerSecondaryDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.Essence) or 0
    for i = 1, max do
        if self.points[i] then
            self.points[i]:Show()
        end
    end
end

-- Hide all points
function BR.EvokerSecondaryDisplay:Hide()
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Get height occupied by essence
function BR.EvokerSecondaryDisplay:GetHeight()
    return 10 -- 8 for point height + 2 for spacing
end
