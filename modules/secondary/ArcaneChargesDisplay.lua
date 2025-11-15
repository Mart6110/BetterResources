-- Better Resources: Mage Arcane Charges Display Component
-- Single Responsibility: Display Mage arcane charges
local _, BR = ...

BR.ArcaneChargesDisplay = {}
BR.ArcaneChargesDisplay.__index = BR.ArcaneChargesDisplay

-- Constructor
function BR.ArcaneChargesDisplay:new(parent, width)
    local self = setmetatable({}, BR.ArcaneChargesDisplay)
    
    self.parent = parent
    self.charges = {}
    self.width = width or 250
    self.maxCharges = 4
    
    self:CreateCharges()
    
    return self
end

-- Create individual charge displays
function BR.ArcaneChargesDisplay:CreateCharges()
    local chargeWidth = math.floor((self.width - 12) / self.maxCharges)
    local chargeSpacing = 4
    local totalWidth = (chargeWidth * self.maxCharges) + (chargeSpacing * (self.maxCharges - 1))
    
    for i = 1, self.maxCharges do
        local charge = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
        charge:SetSize(chargeWidth, 9)
        charge:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        charge:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        charge:SetBackdropBorderColor(0.1, 0.3, 0.5, 1) -- Blue border
        charge:EnableMouse(false)
        
        if i == 1 then
            charge:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (chargeWidth/2), -2)
        else
            charge:SetPoint("LEFT", self.charges[i-1], "RIGHT", chargeSpacing, 0)
        end
        
        charge.fill = charge:CreateTexture(nil, "ARTWORK")
        charge.fill:SetAllPoints(charge)
        charge.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
        charge.fill:SetVertexColor(0.41, 0.8, 0.94, 1) -- Bright blue for arcane charges
        charge.fill:Hide()
        
        charge:Hide()
        self.charges[i] = charge
    end
end

-- Update arcane charges display
function BR.ArcaneChargesDisplay:Update()
    -- Get power values and desecretize through string formatting
    local rawCurrent = UnitPower("player", Enum.PowerType.ArcaneCharges)
    local rawMax = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    
    -- Convert through string to remove taint/secret status, handle nil first
    local current = (rawCurrent and tonumber(format("%d", rawCurrent))) or 0
    local max = (rawMax and tonumber(format("%d", rawMax))) or 0
    
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Show and update charges
    -- Values are not secret when called from event callbacks
    for i = 1, max do
        local charge = self.charges[i]
        if charge then
            charge:Show()
            
            if i <= (current or 0) then
                -- Charge is active
                charge.fill:Show()
            else
                -- Charge is inactive
                charge.fill:Hide()
            end
        end
    end
    
    -- Hide extra charges
    for i = max + 1, self.maxCharges do
        if self.charges[i] then
            self.charges[i]:Hide()
        end
    end
end

-- Update width when parent frame is resized
function BR.ArcaneChargesDisplay:UpdateWidth(width)
    self.width = width
    
    local chargeWidth = math.floor((width - 12) / self.maxCharges)
    local chargeSpacing = 4
    local totalWidth = (chargeWidth * self.maxCharges) + (chargeSpacing * (self.maxCharges - 1))
    
    for i = 1, self.maxCharges do
        if self.charges[i] then
            self.charges[i]:SetWidth(chargeWidth)
            
            if i == 1 then
                self.charges[i]:ClearAllPoints()
                self.charges[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (chargeWidth/2), -2)
            else
                self.charges[i]:ClearAllPoints()
                self.charges[i]:SetPoint("LEFT", self.charges[i-1], "RIGHT", chargeSpacing, 0)
            end
        end
    end
end

-- Show all charges
function BR.ArcaneChargesDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    for i = 1, max do
        if self.charges[i] then
            self.charges[i]:Show()
        end
    end
end

-- Hide all charges
function BR.ArcaneChargesDisplay:Hide()
    for i = 1, self.maxCharges do
        if self.charges[i] then
            self.charges[i]:Hide()
        end
    end
end

-- Get height occupied by charges
function BR.ArcaneChargesDisplay:GetHeight()
    return 11 -- 9 for charge height + 2 for spacing
end
