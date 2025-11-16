-- Better Resources Core
-- Single Responsibility: Initialize addon and coordinate modules
-- Dependency Inversion: Depends on abstractions (modules), not implementations
local addonName, BR = ...

-- Addon metadata
BR.version = "1.0.0"
BR.frames = {}

-- Module initialization functions will be defined by each module file

-- Default configuration
local defaultConfig = {
    enabled = true,
    scale = 1.0,
    positions = {},  -- Store frame positions
    lockFrames = false,  -- Allow frames to be moved by default
    frameSettings = {},  -- Per-frame customization settings
}

-- Initialize saved variables
local function InitializeDatabase()
    if not BetterResourcesDB then
        BetterResourcesDB = CopyTable(defaultConfig)
    else
        -- Merge with defaults for any missing values
        for key, value in pairs(defaultConfig) do
            if BetterResourcesDB[key] == nil then
                BetterResourcesDB[key] = value
            end
        end
        -- Ensure positions table exists
        if not BetterResourcesDB.positions then
            BetterResourcesDB.positions = {}
        end
    end
    BR.db = BetterResourcesDB
end

-- Initialize all custom frames
local function InitializeFrames()
    if not BR.db.enabled then return end
    
    -- Hide default UI secondary resources
    BR:InitializeHideDefaultSecondaryResources()
    
    -- Create our custom resource frame
    BR:InitializeResourceFrame()
    
    print("|cff00ff00Better Resources|r v" .. BR.version .. " loaded!")
    print("|cff00ff00Better Resources:|r Type /br for commands")
end

-- Addon loaded event handler
local function OnAddonLoaded(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    
    InitializeDatabase()
    
    self:RegisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("ADDON_LOADED")
end

-- Player login event handler
local function OnPlayerLogin(self, event)
    InitializeFrames()
    self:UnregisterEvent("PLAYER_LOGIN")
end

-- Event coordinator
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(self, event, ...)
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin(self, event, ...)
    end
end)

-- Expose to global namespace
_G["BetterResources"] = BR
