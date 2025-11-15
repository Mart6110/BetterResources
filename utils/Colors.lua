-- Better Resources: Color Utilities
-- Single Responsibility: Handle all color-related operations
local _, BR = ...

BR.Colors = {}

-- Get power color based on power type
function BR.Colors:GetPowerColor(powerType)
    local info = PowerBarColor[powerType]
    if info then
        return info.r, info.g, info.b
    end
    return 0.5, 0.5, 1 -- Default blue
end
