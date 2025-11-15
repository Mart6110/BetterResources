-- Better Resources: Rogue Secondary Resource Display Component
-- Single Responsibility: Display Rogue combo points
local _, BR = ...

BR.RogueSecondaryDisplay = {}
BR.RogueSecondaryDisplay.__index = BR.RogueSecondaryDisplay

-- Constructor
function BR.RogueSecondaryDisplay:new(parent, width)
    local self = setmetatable({}, BR.RogueSecondaryDisplay)
    
    self.parent = parent
    self.points = {}
    self.width = width or 250
    self.maxPoints = 7 -- Rogues can have up to 7 with talents
    
    self:CreatePoints()
    
    return self
end

-- Create individual point displays
function BR.RogueSecondaryDisplay:CreatePoints()
    local pointWidth = math.floor((self.width - 24) / self.maxPoints)
    local pointSpacing = 4
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
        point:SetStatusBarColor(1, 0.96, 0.41, 1) -- Yellow
        
        self.points[i] = point
    end
end

-- Update combo point display
function BR.RogueSecondaryDisplay:Update()
    -- Get combo points as raw value (not secret when using StatusBar)
    local current = UnitPower("player", Enum.PowerType.ComboPoints)
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    
    -- Check if we have valid max
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Ensure current is valid, default to 0
    current = current or 0
    
    -- Update each point using StatusBar approach
    for i = 1, self.maxPoints do
        local point = self.points[i]
        if point then
            if i <= max then
                point:Show()
                
                -- Each point represents exactly 1 combo point
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

-- Update width when parent frame is resized
function BR.RogueSecondaryDisplay:UpdateWidth(width)
    self.width = width
    
    local pointWidth = math.floor((width - 24) / self.maxPoints)
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
function BR.RogueSecondaryDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    for i = 1, max do
        if self.points[i] then
            self.points[i]:Show()
        end
    end
end

-- Hide all points
function BR.RogueSecondaryDisplay:Hide()
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Get height occupied by combo points
function BR.RogueSecondaryDisplay:GetHeight()
    return 10
end
