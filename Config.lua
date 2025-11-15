-- Better Resources Configuration
local addonName, BR = ...

-- Slash command handler - opens settings UI
SLASH_BETTERRESOURCES1 = "/betterresources"
SLASH_BETTERRESOURCES2 = "/br"

SlashCmdList["BETTERRESOURCES"] = function(msg)
    -- Always open settings UI, ignore any parameters
    BR.SettingsPanel:Toggle()
end
