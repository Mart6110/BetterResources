-- Better Resources: Balance Druid Mana Display Component
-- Single Responsibility: Display mana bar for Balance Druids under Astral Power
local _, BR = ...

BR.BalanceManaDisplay = {}
BR.BalanceManaDisplay.__index = BR.BalanceManaDisplay

-- Constructor
function BR.BalanceManaDisplay:new(parent, width)
    local self = setmetatable({}, BR.BalanceManaDisplay)
    
    self.parent = parent
    self.width = width or 250
    
    self:CreateManaBar()
    
    return self
end

-- Create mana bar
function BR.BalanceManaDisplay:CreateManaBar()
    -- Create a status bar for mana
    self.manaBar = CreateFrame("StatusBar", nil, self.parent, "BackdropTemplate")
    self.manaBar:SetSize(self.width, 8)
    self.manaBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    self.manaBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    self.manaBar:SetBackdropBorderColor(0, 0, 0, 1)
    self.manaBar:EnableMouse(false)
    self.manaBar:SetMinMaxValues(0, 1)
    self.manaBar:SetValue(1)
    
    -- Position below the parent (astral power bar)
    self.manaBar:SetPoint("TOP", self.parent, "BOTTOM", 0, -2)
    
    -- Set the status bar texture and color (blue for mana)
    self.manaBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    self.manaBar:SetStatusBarColor(0, 0.5, 1, 1) -- Blue for mana
    
    -- Create text overlay for mana percentage
    self.manaBar.text = self.manaBar:CreateFontString(nil, "OVERLAY")
    self.manaBar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    self.manaBar.text:SetPoint("CENTER", self.manaBar, "CENTER", 0, 0)
    self.manaBar.text:SetTextColor(1, 1, 1, 1)
    
    self.manaBar:Hide()
end

-- Update mana display
function BR.BalanceManaDisplay:Update()
    -- Only show for Balance spec (spec 1)
    local specIndex = GetSpecialization()
    if specIndex ~= 1 then
        self:Hide()
        return
    end
    
    -- Get mana values
    local current = UnitPower("player", Enum.PowerType.Mana)
    local max = UnitPowerMax("player", Enum.PowerType.Mana)
    
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Update the mana bar - StatusBar handles secret values internally
    self.manaBar:SetMinMaxValues(0, max)
    self.manaBar:SetValue(current or 0)
    
    self.manaBar:Show()
end

-- Update width when parent frame is resized
function BR.BalanceManaDisplay:UpdateWidth(width)
    self.width = width
    if self.manaBar then
        self.manaBar:SetWidth(width)
    end
end

-- Show mana bar
function BR.BalanceManaDisplay:Show()
    if self.manaBar then
        self.manaBar:Show()
    end
end

-- Hide mana bar
function BR.BalanceManaDisplay:Hide()
    if self.manaBar then
        self.manaBar:Hide()
    end
end

-- Get height occupied by mana bar
function BR.BalanceManaDisplay:GetHeight()
    return 10 -- 8 for bar height + 2 for spacing
end
