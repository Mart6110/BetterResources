-- Better Resources: Evoker Essence Display Component
-- Single Responsibility: Display Evoker essence
local _, BR = ...

BR.EssenceDisplay = {}
BR.EssenceDisplay.__index = BR.EssenceDisplay

-- Constructor
function BR.EssenceDisplay:new(parent, width)
    local self = setmetatable({}, BR.EssenceDisplay)
    
    self.parent = parent
    self.points = {}
    self.width = width or 250
    self.maxPoints = 6 -- Evokers have max 6 essence
    
    self:CreatePoints()
    
    return self
end

-- Create individual essence displays
function BR.EssenceDisplay:CreatePoints()
    local pointWidth = math.floor((self.width - 20) / self.maxPoints)
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
        point.fill:SetVertexColor(0.2, 0.58, 0.5, 1) -- Teal/cyan color for Essence
        point.fill:Hide()
        
        point:Hide()
        self.points[i] = point
    end
end

-- Update essence display
function BR.EssenceDisplay:Update()
    -- Get power values and desecretize through string formatting
    local rawCurrent = UnitPower("player", Enum.PowerType.Essence)
    local rawMax = UnitPowerMax("player", Enum.PowerType.Essence)
    
    -- Convert through string to remove taint/secret status, handle nil first
    local current = (rawCurrent and tonumber(format("%d", rawCurrent))) or 0
    local max = (rawMax and tonumber(format("%d", rawMax))) or 0
    
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Show and update points
    -- Values are not secret when called from event callbacks
    for i = 1, max do
        local point = self.points[i]
        if point then
            point.shouldShow = true
            point:Show()
            
            if i <= (current or 0) then
                -- Essence is active
                point.fill:Show()
            else
                -- Essence is inactive
                point.fill:Hide()
            end
        end
    end
    
    -- Hide extra points
    for i = max + 1, self.maxPoints do
        if self.points[i] then
            self.points[i].shouldShow = false
            self.points[i]:Hide()
        end
    end
end

-- Update width when parent frame is resized
function BR.EssenceDisplay:UpdateWidth(width)
    self.width = width
    
    local pointWidth = math.floor((width - 20) / self.maxPoints)
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
function BR.EssenceDisplay:Show()
    -- Only show points that were marked as visible by Update()
    -- Don't call UnitPowerMax here as it may be a secret value
    for i = 1, self.maxPoints do
        if self.points[i] and not self.points[i]:IsForbidden() then
            -- Only show if it was previously made visible
            if self.points[i].shouldShow then
                self.points[i]:Show()
            end
        end
    end
end

-- Hide all points
function BR.EssenceDisplay:Hide()
    for i = 1, self.maxPoints do
        if self.points[i] then
            self.points[i]:Hide()
        end
    end
end

-- Get height occupied by essence
function BR.EssenceDisplay:GetHeight()
    return 10 -- 8 for point height + 2 for spacing
end
