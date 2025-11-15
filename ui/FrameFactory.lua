-- Better Resources: Frame Factory
-- Single Responsibility: Create UI elements consistently
local _, BR = ...

BR.FrameFactory = {}

-- Create a status bar with consistent styling
function BR.FrameFactory:CreateStatusBar(parent, height)
    if not parent then return end
    
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetHeight(height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    
    -- Background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    bar.bg = bg
    
    -- Border
    local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetAllPoints(bar)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)
    bar.border = border
    
    return bar
end

-- Create a font string with consistent styling
function BR.FrameFactory:CreateText(parent, size, position, xOffset, yOffset)
    if not parent then return end
    
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", size or 12, "OUTLINE")
    text:SetTextColor(1, 1, 1)
    
    if position then
        text:SetPoint(position, parent, position, xOffset or 0, yOffset or 0)
    end
    
    return text
end

-- Make a frame movable (for user customization)
function BR.FrameFactory:MakeMovable(frame, frameName)
    if not frame then return end
    
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        
        -- Save position to database
        if frameName and BR.db and BR.db.positions then
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            BR.db.positions[frameName] = {
                point = point,
                relativePoint = relativePoint,
                xOffset = xOfs,
                yOffset = yOfs,
            }
        end
    end)
end

-- Restore saved position for a frame
function BR.FrameFactory:RestorePosition(frame, frameName)
    if not frame or not frameName then return end
    if not BR.db or not BR.db.positions or not BR.db.positions[frameName] then return end
    
    local pos = BR.db.positions[frameName]
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOffset, pos.yOffset)
end
