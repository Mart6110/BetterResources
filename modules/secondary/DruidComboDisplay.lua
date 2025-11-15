-- Better Resources: Druid Combo Points Display Component
-- Single Responsibility: Display Druid Feral combo points
local _, BR = ...

BR.DruidComboDisplay = {}
BR.DruidComboDisplay.__index = BR.DruidComboDisplay

-- Constructor
function BR.DruidComboDisplay:new(parent, width)
    local self = setmetatable({}, BR.DruidComboDisplay)
    
    self.parent = parent
    self.points = {}
    self.width = width or 250
    self.maxPoints = 5
    
    self:CreatePoints()
    
    return self
end

-- Create individual point displays
function BR.DruidComboDisplay:CreatePoints()
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
        point.fill:SetVertexColor(1, 0.49, 0.04, 1) -- Orange
        point.fill:Hide()
        
        point:Hide()
        self.points[i] = point
    end
end

-- Update combo point display
function BR.DruidComboDisplay:Update()
    local current = UnitPower("player", Enum.PowerType.ComboPoints) or 0
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    
    if max == 0 then
        self:Hide()
        return
    end
    
    -- Show and update points
    for i = 1, max do
        local point = self.points[i]
        if point then
            point:Show()
            
            if i <= (current or 0) then
                point.fill:Show()
            else
                point.fill:Hide()
            end
        end
    end
    
    -- Hide extra points
    for i = max + 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Update width when parent frame is resized
function BR.DruidComboDisplay:UpdateWidth(width)
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
function BR.DruidComboDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    for i = 1, max do
        if self.points[i] then
            self.points[i]:Show()
        end
    end
end

-- Hide all points
function BR.DruidComboDisplay:Hide()
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Get height occupied by combo points
function BR.DruidComboDisplay:GetHeight()
    return 10
end
