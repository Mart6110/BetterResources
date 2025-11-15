-- Better Resources: Settings Panel UI
local _, BR = ...

BR.SettingsPanel = {}

-- Create the settings frame
function BR.SettingsPanel:Create()
    if self.frame then
        return self.frame
    end
    
    -- Main frame
    local frame = CreateFrame("Frame", "BRSettingsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(600, 500)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("|cff00ff00Better Resources|r Settings")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 20, -50)
    content:SetPoint("BOTTOMRIGHT", -20, 60)
    
    -- Create settings content
    self:CreateSettingsContent(content)
    
    -- Bottom button
    local reloadBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    reloadBtn:SetSize(100, 30)
    reloadBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Info text
    local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("BOTTOM", 0, 10)
    infoText:SetText("Most settings apply instantly. Drag the resource frame to reposition.")
    infoText:SetTextColor(0.7, 0.7, 0.7)
    
    self.frame = frame
    return frame
end

-- Create combined settings content
function BR.SettingsPanel:CreateSettingsContent(parent)
    -- Create scrollable content
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints()
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(520, 1000)
    scrollFrame:SetScrollChild(content)
    
    local yOffset = 0
    local frameKey = "ResourceFrame"
    
    -- Initialize frame settings if they don't exist
    if not BR.db.frameSettings then
        BR.db.frameSettings = {}
    end
    if not BR.db.frameSettings[frameKey] then
        BR.db.frameSettings[frameKey] = {
            enabled = true,
            width = 250,
            height = 40,
            scale = 1.0,
            opacity = 1.0
        }
    end
    
    -- General Settings Section
    local generalHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    generalHeader:SetPoint("TOPLEFT", 0, yOffset)
    generalHeader:SetText("General Settings")
    yOffset = yOffset - 30
    
    -- Lock frames checkbox
    local lockCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    lockCheck:SetPoint("TOPLEFT", 10, yOffset)
    lockCheck.Text:SetText("Lock Frame Position")
    lockCheck:SetChecked(BR.db.lockFrames or false)
    lockCheck:SetScript("OnClick", function(self)
        BR.db.lockFrames = self:GetChecked()
        
        -- Apply lock/unlock to the resource frame
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            if BR.db.lockFrames then
                frameObj.frame:SetMovable(false)
                frameObj.frame:EnableMouse(false)
            else
                frameObj.frame:SetMovable(true)
                frameObj.frame:EnableMouse(true)
            end
        end
        
        if BR.db.lockFrames then
            print("|cff00ff00Better Resources:|r Frame locked")
        else
            print("|cff00ff00Better Resources:|r Frame unlocked")
        end
    end)
    yOffset = yOffset - 40
    
    -- Global scale slider
    local scaleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scaleLabel:SetPoint("TOPLEFT", 10, yOffset)
    scaleLabel:SetText("Global Scale: " .. BR.db.scale)
    
    local scaleSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    scaleSlider:SetWidth(250)
    scaleSlider:SetMinMaxValues(0.5, 2.0)
    scaleSlider:SetValue(BR.db.scale)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        BR.db.scale = value
        scaleLabel:SetText("Global Scale: " .. value)
        
        -- Apply scale immediately to the resource frame
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            local individualScale = BR.db.frameSettings[frameKey].scale or 1.0
            frameObj.frame:SetScale(value * individualScale)
        end
    end)
    yOffset = yOffset - 70
    
    -- Resource Frame Settings Section
    local resourceHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    resourceHeader:SetPoint("TOPLEFT", 0, yOffset)
    resourceHeader:SetText("Resource Frame Settings")
    yOffset = yOffset - 30
    
    -- Show/Hide frame
    local enableCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 10, yOffset)
    enableCheck.Text:SetText("Show Resource Frame")
    enableCheck:SetChecked(BR.db.frameSettings[frameKey].enabled ~= false)
    enableCheck:SetScript("OnClick", function(self)
        BR.db.frameSettings[frameKey].enabled = self:GetChecked()
        
        -- Show/hide frame immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            if BR.db.frameSettings[frameKey].enabled then
                frameObj.frame:Show()
            else
                frameObj.frame:Hide()
            end
        end
    end)
    yOffset = yOffset - 40
    
    -- Size Section
    local sizeHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sizeHeader:SetPoint("TOPLEFT", 0, yOffset)
    sizeHeader:SetText("Size")
    yOffset = yOffset - 25
    
    -- Width slider with input
    local widthLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widthLabel:SetPoint("TOPLEFT", 10, yOffset)
    local frameWidth = BR.db.frameSettings[frameKey].width or 250
    widthLabel:SetText("Width:")
    
    local widthInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    widthInput:SetSize(60, 20)
    widthInput:SetPoint("LEFT", widthLabel, "RIGHT", 5, 0)
    widthInput:SetAutoFocus(false)
    widthInput:SetNumeric(true)
    widthInput:SetMaxLetters(3)
    widthInput:SetText(tostring(frameWidth))
    
    local widthSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    widthSlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    widthSlider:SetWidth(250)
    widthSlider:SetMinMaxValues(100, 400)
    widthSlider:SetValue(frameWidth)
    widthSlider:SetValueStep(5)
    widthSlider:SetObeyStepOnDrag(true)
    
    local function ApplyWidth(value)
        value = math.floor(value)
        value = math.max(100, math.min(400, value))
        BR.db.frameSettings[frameKey].width = value
        widthInput:SetText(tostring(value))
        widthSlider:SetValue(value)
        
        -- Apply immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            frameObj.frame:SetWidth(value)
            if frameObj.power then
                frameObj.power:SetWidth(value)
            end
            -- Update secondary resource component width
            if frameObj.secondaryResource and frameObj.secondaryResource.UpdateWidth then
                frameObj.secondaryResource:UpdateWidth(value)
            end
        end
    end
    
    widthSlider:SetScript("OnValueChanged", function(self, value)
        ApplyWidth(value)
    end)
    
    widthInput:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or frameWidth
        ApplyWidth(value)
        self:ClearFocus()
    end)
    
    widthInput:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(BR.db.frameSettings[frameKey].width or 250))
        self:ClearFocus()
    end)
    yOffset = yOffset - 60
    
    -- Height slider with input
    local heightLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heightLabel:SetPoint("TOPLEFT", 10, yOffset)
    local frameHeight = BR.db.frameSettings[frameKey].height or 40
    heightLabel:SetText("Height:")
    
    local heightInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    heightInput:SetSize(60, 20)
    heightInput:SetPoint("LEFT", heightLabel, "RIGHT", 5, 0)
    heightInput:SetAutoFocus(false)
    heightInput:SetNumeric(true)
    heightInput:SetMaxLetters(3)
    heightInput:SetText(tostring(frameHeight))
    
    local heightSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    heightSlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    heightSlider:SetWidth(250)
    heightSlider:SetMinMaxValues(20, 100)
    heightSlider:SetValue(frameHeight)
    heightSlider:SetValueStep(5)
    heightSlider:SetObeyStepOnDrag(true)
    
    local function ApplyHeight(value)
        value = math.floor(value)
        value = math.max(20, math.min(100, value))
        BR.db.frameSettings[frameKey].height = value
        heightInput:SetText(tostring(value))
        heightSlider:SetValue(value)
        
        -- Apply immediately - resize power bar for ResourceFrame
        local frameObj = BR.frames.resources
        if frameObj and frameObj.power then
            frameObj.power:SetHeight(value)
            
            -- Calculate total frame height including secondary resources
            local totalHeight = value
            if frameObj.secondaryResource and frameObj.secondaryResource.GetHeight then
                -- Check if any secondary resource is available
                local _, class = UnitClass("player")
                local hasSecondary = false
                
                -- All classes with secondary resources
                if class == "DEATHKNIGHT" or class == "ROGUE" or class == "DRUID" or 
                   class == "MONK" or class == "PALADIN" or class == "EVOKER" or 
                   class == "WARLOCK" or class == "MAGE" then
                    hasSecondary = true
                end
                
                if hasSecondary then
                    totalHeight = totalHeight + frameObj.secondaryResource:GetHeight()
                end
            end
            
            frameObj.frame:SetHeight(totalHeight)
        end
    end
    
    heightSlider:SetScript("OnValueChanged", function(self, value)
        ApplyHeight(value)
    end)
    
    heightInput:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or frameHeight
        ApplyHeight(value)
        self:ClearFocus()
    end)
    
    heightInput:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(BR.db.frameSettings[frameKey].height or 40))
        self:ClearFocus()
    end)
    yOffset = yOffset - 70
    
    -- Position Section
    local positionHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    positionHeader:SetPoint("TOPLEFT", 0, yOffset)
    positionHeader:SetText("Position")
    yOffset = yOffset - 25
    
    -- Get current position
    local function GetCurrentPosition()
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            local point, relativeTo, relativePoint, xOfs, yOfs = frameObj.frame:GetPoint()
            return math.floor(xOfs or 0), math.floor(yOfs or 0)
        end
        return 0, -200
    end
    
    local currentX, currentY = GetCurrentPosition()
    
    -- X Position slider with input
    local xLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    xLabel:SetPoint("TOPLEFT", 10, yOffset)
    xLabel:SetText("X Position:")
    
    local xInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    xInput:SetSize(60, 20)
    xInput:SetPoint("LEFT", xLabel, "RIGHT", 5, 0)
    xInput:SetAutoFocus(false)
    xInput:SetNumeric(false)
    xInput:SetMaxLetters(5)
    xInput:SetText(tostring(currentX))
    
    local xSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    xSlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    xSlider:SetWidth(250)
    xSlider:SetMinMaxValues(-1000, 1000)
    xSlider:SetValue(currentX)
    xSlider:SetValueStep(1)
    xSlider:SetObeyStepOnDrag(true)
    
    local function ApplyXPosition(value)
        value = math.floor(value)
        value = math.max(-1000, math.min(1000, value))
        xInput:SetText(tostring(value))
        xSlider:SetValue(value)
        
        -- Apply immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            local _, currentY = GetCurrentPosition()
            frameObj.frame:ClearAllPoints()
            frameObj.frame:SetPoint("CENTER", UIParent, "CENTER", value, currentY)
            
            -- Save position
            if BR.db.positions then
                BR.db.positions[frameKey] = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOffset = value,
                    yOffset = currentY
                }
            end
        end
    end
    
    xSlider:SetScript("OnValueChanged", function(self, value)
        ApplyXPosition(value)
    end)
    
    xInput:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or currentX
        ApplyXPosition(value)
        self:ClearFocus()
    end)
    
    xInput:SetScript("OnEscapePressed", function(self)
        local x, _ = GetCurrentPosition()
        self:SetText(tostring(x))
        self:ClearFocus()
    end)
    yOffset = yOffset - 60
    
    -- Y Position slider with input
    local yLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yLabel:SetPoint("TOPLEFT", 10, yOffset)
    yLabel:SetText("Y Position:")
    
    local yInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    yInput:SetSize(60, 20)
    yInput:SetPoint("LEFT", yLabel, "RIGHT", 5, 0)
    yInput:SetAutoFocus(false)
    yInput:SetNumeric(false)
    yInput:SetMaxLetters(5)
    yInput:SetText(tostring(currentY))
    
    local ySlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    ySlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    ySlider:SetWidth(250)
    ySlider:SetMinMaxValues(-1000, 1000)
    ySlider:SetValue(currentY)
    ySlider:SetValueStep(1)
    ySlider:SetObeyStepOnDrag(true)
    
    local function ApplyYPosition(value)
        value = math.floor(value)
        value = math.max(-1000, math.min(1000, value))
        yInput:SetText(tostring(value))
        ySlider:SetValue(value)
        
        -- Apply immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            local currentX, _ = GetCurrentPosition()
            frameObj.frame:ClearAllPoints()
            frameObj.frame:SetPoint("CENTER", UIParent, "CENTER", currentX, value)
            
            -- Save position
            if BR.db.positions then
                BR.db.positions[frameKey] = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOffset = currentX,
                    yOffset = value
                }
            end
        end
    end
    
    ySlider:SetScript("OnValueChanged", function(self, value)
        ApplyYPosition(value)
    end)
    
    yInput:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or currentY
        ApplyYPosition(value)
        self:ClearFocus()
    end)
    
    yInput:SetScript("OnEscapePressed", function(self)
        local _, y = GetCurrentPosition()
        self:SetText(tostring(y))
        self:ClearFocus()
    end)
    yOffset = yOffset - 70
    
    -- Other Settings Section
    local otherHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    otherHeader:SetPoint("TOPLEFT", 0, yOffset)
    otherHeader:SetText("Other Settings")
    yOffset = yOffset - 25
    
    -- Individual scale slider
    local individualScaleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    individualScaleLabel:SetPoint("TOPLEFT", 10, yOffset)
    local frameScale = (BR.db.frameSettings[frameKey].scale or 1.0)
    individualScaleLabel:SetText("Individual Scale: " .. frameScale)
    
    local individualScaleSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    individualScaleSlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    individualScaleSlider:SetWidth(250)
    individualScaleSlider:SetMinMaxValues(0.5, 2.0)
    individualScaleSlider:SetValue(frameScale)
    individualScaleSlider:SetValueStep(0.1)
    individualScaleSlider:SetObeyStepOnDrag(true)
    individualScaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        BR.db.frameSettings[frameKey].scale = value
        individualScaleLabel:SetText("Individual Scale: " .. value)
        
        -- Apply scale immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            frameObj.frame:SetScale(BR.db.scale * value)
        end
    end)
    yOffset = yOffset - 60
    
    -- Frame opacity slider
    local opacityLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", 10, yOffset)
    local frameOpacity = (BR.db.frameSettings[frameKey].opacity or 1.0)
    opacityLabel:SetText("Opacity: " .. math.floor(frameOpacity * 100) .. "%")
    
    local opacitySlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", 10, yOffset - 20)
    opacitySlider:SetWidth(250)
    opacitySlider:SetMinMaxValues(0.1, 1.0)
    opacitySlider:SetValue(frameOpacity)
    opacitySlider:SetValueStep(0.1)
    opacitySlider:SetObeyStepOnDrag(true)
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        BR.db.frameSettings[frameKey].opacity = value
        opacityLabel:SetText("Opacity: " .. math.floor(value * 100) .. "%")
        
        -- Apply opacity immediately
        local frameObj = BR.frames.resources
        if frameObj and frameObj.frame then
            frameObj.frame:SetAlpha(value)
        end
    end)
    yOffset = yOffset - 60
    
    -- Reset position button
    local resetBtn = CreateFrame("Button", nil, content, "GameMenuButtonTemplate")
    resetBtn:SetSize(180, 30)
    resetBtn:SetPoint("TOPLEFT", 10, yOffset)
    resetBtn:SetText("Reset Position")
    resetBtn:SetScript("OnClick", function()
        local frameObj = BR.frames.resources
        if frameObj and frameObj.ResetPosition then
            frameObj:ResetPosition()
            print("|cff00ff00Better Resources:|r Resource frame position reset!")
        end
    end)
    
    scrollFrame:Show()
end

-- Show the settings panel
function BR.SettingsPanel:Show()
    local frame = self:Create()
    frame:Show()
end

-- Hide the settings panel
function BR.SettingsPanel:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Toggle the settings panel
function BR.SettingsPanel:Toggle()
    local frame = self:Create()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
