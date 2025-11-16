-- Better Resources: Hide Default Secondary Resources
-- Hides secondary resources from the default UI (combo points, runes, holy power, etc.)
local _, BR = ...

BR.HideDefaultSecondaryResources = {}

-- Initialize the module
function BR.HideDefaultSecondaryResources:Initialize()
    -- Wait for player frame to be loaded
    if not PlayerFrame then
        C_Timer.After(0.5, function()
            self:Initialize()
        end)
        return
    end
    
    -- Hide the secondary power bar(s)
    self:HideSecondaryPowerBars()
    
    -- Hide class-specific resource displays
    self:HideClassResourceDisplays()
    
    print("|cff00ff00Better Resources:|r Default secondary resources hidden")
end

-- Hide secondary power bars
function BR.HideDefaultSecondaryResources:HideSecondaryPowerBars()
    -- Hide the player frame's alternate power bar
    if PlayerFrame and PlayerFrame.PlayerFrameContent then
        local content = PlayerFrame.PlayerFrameContent
        
        -- Hide mana bar (for non-mana users or druids with mana)
        if content.PlayerFrameContentContextual then
            if content.PlayerFrameContentContextual.PlayerFrameContentContextualManaBar then
                content.PlayerFrameContentContextual.PlayerFrameContentContextualManaBar:SetAlpha(0)
                content.PlayerFrameContentContextual.PlayerFrameContentContextualManaBar:Hide()
            end
        end
    end
end

-- Hide class-specific resource displays
function BR.HideDefaultSecondaryResources:HideClassResourceDisplays()
    local _, class = UnitClass("player")
    
    -- Death Knight - Runes
    if class == "DEATHKNIGHT" then
        self:HideDeathKnightRunes()
    
    -- Rogue/Druid - Combo Points
    elseif class == "ROGUE" or class == "DRUID" then
        self:HideComboPoints()
    
    -- Monk - Chi/Stagger
    elseif class == "MONK" then
        self:HideMonkChi()
    
    -- Paladin - Holy Power
    elseif class == "PALADIN" then
        self:HidePaladinHolyPower()
    
    -- Warlock - Soul Shards
    elseif class == "WARLOCK" then
        self:HideWarlockShards()
    
    -- Mage - Arcane Charges
    elseif class == "MAGE" then
        self:HideMageArcaneCharges()
    
    -- Evoker - Essence
    elseif class == "EVOKER" then
        self:HideEvokerEssence()
    end
end

-- Hide Death Knight Runes
function BR.HideDefaultSecondaryResources:HideDeathKnightRunes()
    if RuneFrame then
        RuneFrame:Hide()
        RuneFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        RuneFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Hide Combo Points
function BR.HideDefaultSecondaryResources:HideComboPoints()
    if ComboFrame then
        ComboFrame:Hide()
        ComboFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        ComboFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
    
    -- Also hide combo point display on player frame
    if PlayerFrame_HideComboPointsBar then
        PlayerFrame_HideComboPointsBar()
    end
end

-- Hide Monk Chi
function BR.HideDefaultSecondaryResources:HideMonkChi()
    if MonkHarmonyBarFrame then
        MonkHarmonyBarFrame:Hide()
        MonkHarmonyBarFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        MonkHarmonyBarFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Hide Paladin Holy Power
function BR.HideDefaultSecondaryResources:HidePaladinHolyPower()
    if PaladinPowerBarFrame then
        PaladinPowerBarFrame:Hide()
        PaladinPowerBarFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        PaladinPowerBarFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Hide Warlock Soul Shards
function BR.HideDefaultSecondaryResources:HideWarlockShards()
    if WarlockPowerFrame then
        WarlockPowerFrame:Hide()
        WarlockPowerFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        WarlockPowerFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Hide Mage Arcane Charges
function BR.HideDefaultSecondaryResources:HideMageArcaneCharges()
    if MageArcaneChargesFrame then
        MageArcaneChargesFrame:Hide()
        MageArcaneChargesFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        MageArcaneChargesFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Hide Evoker Essence
function BR.HideDefaultSecondaryResources:HideEvokerEssence()
    if EssencePlayerFrame then
        EssencePlayerFrame:Hide()
        EssencePlayerFrame:UnregisterAllEvents()
        
        -- Prevent it from showing again
        EssencePlayerFrame:SetScript("OnShow", function(self)
            self:Hide()
        end)
    end
end

-- Re-show default UI (for disabling the addon or toggling)
function BR.HideDefaultSecondaryResources:RestoreDefaultUI()
    local _, class = UnitClass("player")
    
    -- Restore based on class
    if class == "DEATHKNIGHT" and RuneFrame then
        RuneFrame:SetScript("OnShow", nil)
        RuneFrame:Show()
        RuneFrame:RegisterEvent("RUNE_POWER_UPDATE")
        
    elseif (class == "ROGUE" or class == "DRUID") and ComboFrame then
        ComboFrame:SetScript("OnShow", nil)
        ComboFrame:Show()
        ComboFrame:RegisterEvent("UNIT_POWER_UPDATE")
        
    elseif class == "MONK" and MonkHarmonyBarFrame then
        MonkHarmonyBarFrame:SetScript("OnShow", nil)
        MonkHarmonyBarFrame:Show()
        MonkHarmonyBarFrame:RegisterEvent("UNIT_POWER_UPDATE")
        
    elseif class == "PALADIN" and PaladinPowerBarFrame then
        PaladinPowerBarFrame:SetScript("OnShow", nil)
        PaladinPowerBarFrame:Show()
        PaladinPowerBarFrame:RegisterEvent("UNIT_POWER_UPDATE")
        
    elseif class == "WARLOCK" and WarlockPowerFrame then
        WarlockPowerFrame:SetScript("OnShow", nil)
        WarlockPowerFrame:Show()
        WarlockPowerFrame:RegisterEvent("UNIT_POWER_UPDATE")
        
    elseif class == "MAGE" and MageArcaneChargesFrame then
        MageArcaneChargesFrame:SetScript("OnShow", nil)
        MageArcaneChargesFrame:Show()
        MageArcaneChargesFrame:RegisterEvent("UNIT_POWER_UPDATE")
        
    elseif class == "EVOKER" and EssencePlayerFrame then
        EssencePlayerFrame:SetScript("OnShow", nil)
        EssencePlayerFrame:Show()
        EssencePlayerFrame:RegisterEvent("UNIT_POWER_UPDATE")
    end
    
    print("|cff00ff00Better Resources:|r Default secondary resources restored")
end

-- Module initialization function (called from Core)
function BR:InitializeHideDefaultSecondaryResources()
    BR.HideDefaultSecondaryResources:Initialize()
end
