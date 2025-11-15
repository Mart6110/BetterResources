-- Better Resources: Death Knight Rune Display Component
-- Single Responsibility: Display and update Death Knight runes
local _, BR = ...

BR.RuneDisplay = {}
BR.RuneDisplay.__index = BR.RuneDisplay

-- Constructor
function BR.RuneDisplay:new(parent, width)
    local self = setmetatable({}, BR.RuneDisplay)
    
    self.parent = parent
    self.runes = {}
    self.width = width or 250
    
    self:CreateRunes()
    
    return self
end

-- Create rune frames
function BR.RuneDisplay:CreateRunes()
    local runeWidth = math.floor((self.width - 15) / 6)
    local runeSpacing = 3
    local totalWidth = (runeWidth * 6) + (runeSpacing * 5)
    
    for i = 1, 6 do
        local rune = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
        rune:SetSize(runeWidth, 8)
        rune:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        rune:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        rune:SetBackdropBorderColor(0, 0, 0, 1)
        rune:EnableMouse(false)
        
        if i == 1 then
            rune:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (runeWidth/2), -2)
        else
            rune:SetPoint("LEFT", self.runes[i-1], "RIGHT", runeSpacing, 0)
        end
        
        rune.fill = rune:CreateTexture(nil, "ARTWORK")
        rune.fill:SetAllPoints(rune)
        rune.fill:SetTexture("Interface\\Buttons\\WHITE8X8")
        rune.fill:SetVertexColor(0.3, 0.5, 1, 1)
        rune.fill:Hide()
        
        rune:Hide()
        self.runes[i] = rune
    end
end

-- Update rune display
function BR.RuneDisplay:Update()
    -- Collect rune data and sort by cooldown (ready first, then by remaining time)
    local runeData = {}
    for i = 1, 6 do
        local start, duration, ready = GetRuneCooldown(i)
        local elapsed = GetTime() - start
        local remaining = duration - elapsed
        
        table.insert(runeData, {
            index = i,
            ready = ready,
            progress = ready and 1 or (elapsed / duration),
            remaining = ready and 0 or remaining
        })
    end
    
    -- Sort: ready runes first (left), then by most charged
    table.sort(runeData, function(a, b)
        if a.ready ~= b.ready then
            return a.ready
        end
        return a.remaining < b.remaining
    end)
    
    -- Display runes in sorted order
    for displayPos = 1, 6 do
        local data = runeData[displayPos]
        local rune = self.runes[displayPos]
        
        if rune then
            rune:Show()
            
            if data.ready then
                -- Rune is ready - full bright fill
                rune.fill:Show()
                rune.fill:SetVertexColor(0.3, 0.8, 1, 1)
                rune.fill:ClearAllPoints()
                rune.fill:SetAllPoints(rune)
            else
                -- Rune is on cooldown - show fill animation from left to right
                rune.fill:Show()
                
                if data.progress < 1 then
                    -- Cooldown in progress - dim color, partial fill from left
                    rune.fill:SetVertexColor(0.1, 0.3, 0.5, 0.8)
                    local fillWidth = rune:GetWidth() * data.progress
                    rune.fill:SetWidth(fillWidth)
                    rune.fill:ClearAllPoints()
                    rune.fill:SetPoint("LEFT", rune, "LEFT", 0, 0)
                    rune.fill:SetPoint("TOP", rune, "TOP", 0, 0)
                    rune.fill:SetPoint("BOTTOM", rune, "BOTTOM", 0, 0)
                else
                    -- Just finished - full bright
                    rune.fill:SetVertexColor(0.3, 0.8, 1, 1)
                    rune.fill:ClearAllPoints()
                    rune.fill:SetAllPoints(rune)
                end
            end
        end
    end
end

-- Update width when parent frame is resized
function BR.RuneDisplay:UpdateWidth(width)
    self.width = width
    
    local runeWidth = math.floor((width - 15) / 6)
    local runeSpacing = 3
    local totalWidth = (runeWidth * 6) + (runeSpacing * 5)
    
    for i = 1, 6 do
        if self.runes[i] then
            self.runes[i]:SetWidth(runeWidth)
            
            if i == 1 then
                self.runes[i]:ClearAllPoints()
                self.runes[i]:SetPoint("TOP", self.parent, "BOTTOM", -(totalWidth/2) + (runeWidth/2), -2)
            else
                self.runes[i]:ClearAllPoints()
                self.runes[i]:SetPoint("LEFT", self.runes[i-1], "RIGHT", runeSpacing, 0)
            end
        end
    end
end

-- Show all runes
function BR.RuneDisplay:Show()
    for i = 1, 6 do
        if self.runes[i] then
            self.runes[i]:Show()
        end
    end
end

-- Hide all runes
function BR.RuneDisplay:Hide()
    for i = 1, 6 do
        if self.runes[i] then
            self.runes[i]:Hide()
        end
    end
end

-- Get height occupied by runes
function BR.RuneDisplay:GetHeight()
    return 10 -- 8 for rune height + 2 for spacing
end
