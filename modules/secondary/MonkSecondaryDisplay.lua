-- Better Resources: Monk Secondary Resource Display Component
-- Single Responsibility: Display Monk chi points
local _, BR = ...

BR.MonkSecondaryDisplay = {}
BR.MonkSecondaryDisplay.__index = BR.MonkSecondaryDisplay

-- Constructor
function BR.MonkSecondaryDisplay:new(parent, width)
    local self = setmetatable({}, BR.MonkSecondaryDisplay)
    
    self.parent = parent
    self.orbs = {}
    self.width = width or 250
    self.maxOrbs = 6
    
    self:CreateOrbs()
    
    return self
end

-- Create individual chi orb displays
function BR.MonkSecondaryDisplay:CreateOrbs()
    local orbWidth = math.floor((self.width - 20) / self.maxOrbs)
    local orbSpacing = 4
    local totalWidth = (orbWidth * self.maxOrbs) + (orbSpacing * (self.maxOrbs - 1))
    
    for i = 1, self.maxOrbs do
        local orb = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
        orb:SetSize(orbWidth, 8)
        orb:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        orb:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        orb:SetBackdropBorderColor(0, 0, 0, 1)
        orb:EnableMouse(false)
        
        if i == 1 then
            orb:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (orbWidth/2), -2)
        else
            orb:SetPoint("LEFT", self.orbs[i-1], "RIGHT", orbSpacing, 0)
        end
        
        orb.fill = orb:CreateTexture(nil, "ARTWORK")
        orb.fill:SetAllPoints(orb)
        orb.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
        orb.fill:SetVertexColor(0, 1, 0.59, 1) -- Green
        orb.fill:Hide()
        
        orb:Hide()
        self.orbs[i] = orb
    end
end

-- Update chi display
function BR.MonkSecondaryDisplay:Update()
    local current = UnitPower("player", Enum.PowerType.Chi) or 0
    local max = UnitPowerMax("player", Enum.PowerType.Chi) or 0
    
    if max == 0 then
        self:Hide()
        return
    end
    
    -- Show and update orbs
    for i = 1, max do
        local orb = self.orbs[i]
        if orb then
            orb:Show()
            
            if i <= (current or 0) then
                orb.fill:Show()
            else
                orb.fill:Hide()
            end
        end
    end
    
    -- Hide extra orbs
    for i = max + 1, self.maxOrbs do
        if self.orbs[i] then
            self.orbs[i]:Hide()
        end
    end
end

-- Update width when parent frame is resized
function BR.MonkSecondaryDisplay:UpdateWidth(width)
    self.width = width
    
    local orbWidth = math.floor((width - 20) / self.maxOrbs)
    local orbSpacing = 4
    local totalWidth = (orbWidth * self.maxOrbs) + (orbSpacing * (self.maxOrbs - 1))
    
    for i = 1, self.maxOrbs do
        if self.orbs[i] then
            self.orbs[i]:SetWidth(orbWidth)
            
            if i == 1 then
                self.orbs[i]:ClearAllPoints()
                self.orbs[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (orbWidth/2), -2)
            else
                self.orbs[i]:ClearAllPoints()
                self.orbs[i]:SetPoint("LEFT", self.orbs[i-1], "RIGHT", orbSpacing, 0)
            end
        end
    end
end

-- Show all orbs
function BR.MonkSecondaryDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.Chi) or 0
    for i = 1, max do
        if self.orbs[i] then
            self.orbs[i]:Show()
        end
    end
end

-- Hide all orbs
function BR.MonkSecondaryDisplay:Hide()
    for i = 1, self.maxOrbs do
        if self.orbs[i] then
            self.orbs[i]:Hide()
        end
    end
end

-- Get height occupied by chi
function BR.MonkSecondaryDisplay:GetHeight()
    return 10
end
