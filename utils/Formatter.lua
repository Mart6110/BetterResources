-- Better Resources: Text Formatting Utilities
-- Single Responsibility: Handle all text formatting operations
local _, BR = ...

BR.Formatter = {}

-- Format number for display (just convert to string, no abbreviation)
function BR.Formatter:FormatNumber(value)
    -- Just convert to string to handle "secret values" from WoW API
    -- Don't do comparisons or math operations on protected values
    if not value then return "0" end
    return tostring(value)
end

-- Format power display (current/max)
function BR.Formatter:FormatPower(current, max)
    -- Just display the values as-is, no math operations on protected values
    if not current or not max then return "" end
    
    local currentStr = self:FormatNumber(current)
    local maxStr = self:FormatNumber(max)
    
    return string.format("%s / %s", currentStr, maxStr)
end
