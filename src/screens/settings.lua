-- src/screens/settings.lua — Settings Screen Component
local hyo = require("hyo")

local function SettingsScreen()
    return Column({
        padding = 24,
        spacing = 16,
        background = "#0b0f19",
        children = {
            Text({
                text = "Application Settings",
                size = 24,
                weight = "bold",
                color = "#ffffff"
            }),
            Text({
                text = "Modular screen component imported via require('screens.settings')!",
                size = 14,
                color = "#94a3b8"
            }),
            Divider({ thickness = 1, background = "#26324b" }),
            Button({
                text = "<- Back to Dashboard",
                background = "#2563eb",
                size = 14,
                onClick = function()
                    hyo.navigation.pop()
                end
            })
        }
    })
end

return SettingsScreen
