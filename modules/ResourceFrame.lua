-- Better Resources: Resource Frame Module
-- Separate movable frame for player power/resources
local _, BR = ...

BR.ResourceFrame = {}
BR.ResourceFrame.__index = BR.ResourceFrame

-- Constructor
function BR.ResourceFrame:new()
    local self = setmetatable({}, BR.ResourceFrame)
    
    self.unit = "player"
    self.config = BR.db
    
    -- Initialize frame settings if they don't exist
    if not BR.db.frameSettings then
        BR.db.frameSettings = {}
    end
    if not BR.db.frameSettings.ResourceFrame then
        BR.db.frameSettings.ResourceFrame = {
            enabled = true,
            width = 250,
            height = 40,
            scale = 1.0,
            opacity = 1.0
        }
    end
    
    local settings = BR.db.frameSettings.ResourceFrame
    
    -- Create main frame
    self.frame = CreateFrame("Frame", "BR_ResourceFrame", UIParent)
    self.frame:SetSize(settings.width or 250, settings.height or 40)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    self.frame:SetScale(self.config.scale * (settings.scale or 1.0))
    self.frame:SetAlpha(settings.opacity or 1.0)
    
    -- Make movable with position saving
    BR.FrameFactory:MakeMovable(self.frame, "ResourceFrame")
    
    -- Restore saved position (if any)
    BR.FrameFactory:RestorePosition(self.frame, "ResourceFrame")
    
    -- Create power bar
    self:CreatePowerBar()
    
    -- Create secondary power (runes, combo points, etc.)
    self:CreateSecondaryPower()
    
    -- Register events
    self:RegisterEvents()
    
    -- Initial update - using C_Timer to defer until after initialization
    C_Timer.After(0.1, function()
        self:Update()
    end)
    
    return self
end

-- Create power bar
function BR.ResourceFrame:CreatePowerBar()
    local settings = BR.db.frameSettings.ResourceFrame
    local barHeight = settings.height or 40
    
    local power = BR.FrameFactory:CreateStatusBar(self.frame, barHeight)
    power:SetPoint("TOP", self.frame, "TOP", 0, 0)
    power:SetWidth(settings.width or 250)
    power:SetMinMaxValues(0, 1)
    power:SetValue(1)
    
    -- Allow clicks to pass through (resource frame doesn't need clicks)
    power:EnableMouse(false)
    
    power.text = BR.FrameFactory:CreateText(power, 12, "CENTER", 0, 0)
    
    self.power = power
    return power
end

-- Create secondary power displays (runes, combo points, etc.)
function BR.ResourceFrame:CreateSecondaryPower()
    local settings = BR.db.frameSettings.ResourceFrame
    local _, class = UnitClass("player")
    
    -- Create class-specific component
    if class == "DEATHKNIGHT" then
        self.secondaryResource = BR.RuneDisplay:new(self.power, settings.width or 250)
    elseif class == "ROGUE" then
        self.secondaryResource = BR.RogueComboDisplay:new(self.power, settings.width or 250)
    elseif class == "DRUID" then
        self.secondaryResource = BR.DruidComboDisplay:new(self.power, settings.width or 250)
    elseif class == "MONK" then
        self.secondaryResource = BR.MonkChiDisplay:new(self.power, settings.width or 250)
    elseif class == "PALADIN" then
        self.secondaryResource = BR.PaladinHolyPowerDisplay:new(self.power, settings.width or 250)
    elseif class == "EVOKER" then
        self.secondaryResource = BR.EssenceDisplay:new(self.power, settings.width or 250)
    elseif class == "WARLOCK" then
        self.secondaryResource = BR.SoulShardDisplay:new(self.power, settings.width or 250)
    elseif class == "MAGE" then
        self.secondaryResource = BR.ArcaneChargesDisplay:new(self.power, settings.width or 250)
    end
end

-- Update power display
function BR.ResourceFrame:UpdatePower()
    if not UnitExists("player") then return end
    
    local current = UnitPower("player")
    local max = UnitPowerMax("player")
    local powerType = UnitPowerType("player")
    
    if max and current then
        self.power:Show()
        self.power:SetMinMaxValues(0, max)
        self.power:SetValue(current)
        self.power.text:SetText(BR.Formatter:FormatPower(current, max))
        
        local r, g, b = BR.Colors:GetPowerColor(powerType)
        self.power:SetStatusBarColor(r, g, b)
    else
        self.power:Hide()
    end
end

-- Update secondary power display
function BR.ResourceFrame:UpdateSecondaryPower()
    if self.secondaryResource and self.secondaryResource.Update then
        self.secondaryResource:Update()
    end
end

-- Full update
function BR.ResourceFrame:Update()
    self:UpdatePower()
    self:UpdateSecondaryPower()
end

-- Register events
function BR.ResourceFrame:RegisterEvents()
    local events = {
        "UNIT_POWER_UPDATE",
        "UNIT_MAXPOWER",
        "UNIT_DISPLAYPOWER",
        "UNIT_POWER_FREQUENT",
        "RUNE_POWER_UPDATE",
    }
    
    for _, event in ipairs(events) do
        self.frame:RegisterEvent(event)
    end
    
    self.frame:SetScript("OnEvent", function(frame, event, ...)
        self:Update()
    end)
end

-- Reset position
function BR.ResourceFrame:ResetPosition()
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    if BR.db.positions then
        BR.db.positions["ResourceFrame"] = nil
    end
end

-- Show frame
function BR.ResourceFrame:Show()
    self.frame:Show()
end

-- Hide frame
function BR.ResourceFrame:Hide()
    self.frame:Hide()
end

-- Initialize resource frame (called from Core)
function BR:InitializeResourceFrame()
    -- Create custom resource frame
    self.frames.resources = BR.ResourceFrame:new()
end
