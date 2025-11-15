-- Better Resources: Warlock Secondary Resource Display Component
-- Single Responsibility: Display Warlock soul shards with larger, more visible display
local _, BR = ...

BR.WarlockSecondaryDisplay = {}
BR.WarlockSecondaryDisplay.__index = BR.WarlockSecondaryDisplay

-- Constructor
function BR.WarlockSecondaryDisplay:new(parent, width)
    local self = setmetatable({}, BR.WarlockSecondaryDisplay)
    
    self.parent = parent
    self.shards = {}
    self.width = width or 250
    self.maxShards = 5
    
    self:CreateShards()
    
    return self
end

-- Create individual shard displays
function BR.WarlockSecondaryDisplay:CreateShards()
    local shardWidth = math.floor((self.width - 16) / self.maxShards)
    local shardSpacing = 4
    local totalWidth = (shardWidth * self.maxShards) + (shardSpacing * (self.maxShards - 1))
    
    for i = 1, self.maxShards do
        -- Create a status bar for each shard to show partial filling
        local shard = CreateFrame("StatusBar", nil, self.parent, "BackdropTemplate")
        shard:SetSize(shardWidth, 10)
        shard:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        shard:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        shard:SetBackdropBorderColor(0.3, 0.1, 0.4, 1) -- Purple border
        shard:EnableMouse(false)
        shard:SetMinMaxValues(0, 1)
        shard:SetValue(0)
        
        if i == 1 then
            shard:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (shardWidth/2), -2)
        else
            shard:SetPoint("LEFT", self.shards[i-1], "RIGHT", shardSpacing, 0)
        end
        
        -- Set the status bar texture
        shard:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        shard:SetStatusBarColor(0.58, 0.51, 0.79, 1) -- Purple for soul shards
        
        self.shards[i] = shard
    end
end

-- Update soul shard display
function BR.WarlockSecondaryDisplay:Update()
    -- Get raw fragments (10 fragments = 1 shard)
    local currentFragments = UnitPower("player", Enum.PowerType.SoulShards, true)
    local maxFragments = UnitPowerMax("player", Enum.PowerType.SoulShards, true)
    local max = UnitPowerMax("player", Enum.PowerType.SoulShards)
    
    -- Check if we have valid max
    if not max or max == 0 then
        self:Hide()
        return
    end
    
    -- Ensure current is valid, default to 0
    currentFragments = currentFragments or 0
    
    -- Update each shard - each shard represents 10 fragments
    for i = 1, self.maxShards do
        local shard = self.shards[i]
        if shard then
            if i <= max then
                shard:Show()
                
                -- Each shard represents 10 fragments (0-10, 10-20, 20-30, etc.)
                local minFragments = (i - 1) * 10
                local maxFragments = i * 10
                shard:SetMinMaxValues(minFragments, maxFragments)
                
                -- Set the current fragment value directly - StatusBar handles the display
                shard:SetValue(currentFragments)
            else
                shard:Hide()
            end
        end
    end
end

-- Update width when parent frame is resized
function BR.WarlockSecondaryDisplay:UpdateWidth(width)
    self.width = width
    
    local shardWidth = math.floor((width - 16) / self.maxShards)
    local shardSpacing = 4
    local totalWidth = (shardWidth * self.maxShards) + (shardSpacing * (self.maxShards - 1))
    
    for i = 1, self.maxShards do
        if self.shards[i] then
            self.shards[i]:SetSize(shardWidth, 10)
            
            if i == 1 then
                self.shards[i]:ClearAllPoints()
                self.shards[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (shardWidth/2), -2)
            else
                self.shards[i]:ClearAllPoints()
                self.shards[i]:SetPoint("LEFT", self.shards[i-1], "RIGHT", shardSpacing, 0)
            end
        end
    end
end

-- Show all shards
function BR.WarlockSecondaryDisplay:Show()
    for i = 1, self.maxShards do
        if self.shards[i] then
            self.shards[i]:Show()
        end
    end
end

-- Hide all shards
function BR.WarlockSecondaryDisplay:Hide()
    for i = 1, self.maxShards do
        if self.shards[i] then
            self.shards[i]:Hide()
        end
    end
end

-- Get height occupied by shards
function BR.WarlockSecondaryDisplay:GetHeight()
    return 12 -- 10 for shard height + 2 for spacing
end
