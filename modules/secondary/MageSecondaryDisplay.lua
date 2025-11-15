-- Better Resources: Mage Secondary Resource Display Component
-- Single Responsibility: Display Mage arcane charges
local _, BR = ...

BR.MageSecondaryDisplay = {}
BR.MageSecondaryDisplay.__index = BR.MageSecondaryDisplay

-- Constructor
function BR.MageSecondaryDisplay:new(parent, width)
    local self = setmetatable({}, BR.MageSecondaryDisplay)
    
    self.parent = parent
    self.charges = {}
    self.width = width or 250
    self.maxCharges = 4
    
    self:CreateCharges()
    
    return self
end

-- Create individual charge displays
function BR.MageSecondaryDisplay:CreateCharges()
    local chargeWidth = math.floor((self.width - 12) / self.maxCharges)
    local chargeSpacing = 4
    local totalWidth = (chargeWidth * self.maxCharges) + (chargeSpacing * (self.maxCharges - 1))
    
    for i = 1, self.maxCharges do
        -- Create a status bar for each charge to show filling without comparing secret values
        local charge = CreateFrame("StatusBar", nil, self.parent, "BackdropTemplate")
        charge:SetSize(chargeWidth, 9)
        charge:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        charge:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        charge:SetBackdropBorderColor(0.1, 0.3, 0.5, 1) -- Blue border
        charge:EnableMouse(false)
        charge:SetMinMaxValues(0, 1)
        charge:SetValue(0)
        
        if i == 1 then
            charge:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (chargeWidth/2), -2)
        else
            charge:SetPoint("LEFT", self.charges[i-1], "RIGHT", chargeSpacing, 0)
        end
        
        -- Set the status bar texture
        charge:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        charge:SetStatusBarColor(0.41, 0.8, 0.94, 1) -- Bright blue for arcane charges
        
        self.charges[i] = charge
    end
end

-- Update arcane charges display
function BR.MageSecondaryDisplay:Update()
    -- Only show arcane charges for Arcane spec (spec 1)
    local specIndex = GetSpecialization()
    if specIndex ~= 1 then
        self:Hide()
        return
    end
    
    -- Get arcane charges as raw value (not secret when using StatusBar)
    local current = UnitPower("player", Enum.PowerType.ArcaneCharges)
    local max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    
    -- Check if we have valid max
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Ensure current is valid, default to 0
    current = current or 0
    
    -- Update each charge using StatusBar approach
    for i = 1, self.maxCharges do
        local charge = self.charges[i]
        if charge then
            if i <= max then
                charge:Show()
                
                -- Each charge represents exactly 1 arcane charge
                local minValue = i - 1
                local maxValue = i
                charge:SetMinMaxValues(minValue, maxValue)
                
                -- Set the current value directly - StatusBar handles the display
                charge:SetValue(current)
            else
                charge:Hide()
            end
        end
    end
end

-- Update width when parent frame is resized
function BR.MageSecondaryDisplay:UpdateWidth(width)
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
function BR.MageSecondaryDisplay:Show()
    local max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    for i = 1, max do
        if self.charges[i] then
            self.charges[i]:Show()
        end
    end
end

-- Hide all charges
function BR.MageSecondaryDisplay:Hide()
    for i = 1, self.maxCharges do
        if self.charges[i] then
            self.charges[i]:Hide()
        end
    end
end

-- Get height occupied by charges
function BR.MageSecondaryDisplay:GetHeight()
    return 11 -- 9 for charge height + 2 for spacing
end
