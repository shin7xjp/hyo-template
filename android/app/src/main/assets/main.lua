-- main.lua — Hyo Mobile Application Starter
local hyo = require("hyo")

hyo.create({
    name = "My Application",
    title = "My Application",
    version = "1.0.0"
})

local count = State(0)

hyo.run(function()
    return Column({
        padding = 32,
        spacing = 20,
        background = "#0f172a",

        children = {
            Text({
                text = "Welcome to Hyo",
                size = 32,
                weight = "bold",
                color = "#ffffff"
            }),

            Text({
                text = "Build mobile applications with Lua & C++.",
                size = 16,
                color = "#94a3b8"
            }),

            Text({
                text = "Button Taps: " .. tostring(count:get()),
                size = 20,
                weight = "bold",
                color = "#38bdf8"
            }),

            Button({
                text = "Tap to Increment",
                background = "#2563eb",
                size = 16,
                onClick = function()
                    local current = count:get()
                    count:set(current + 1)
                    hyo.log("Button pressed! New count: " .. tostring(count:get()))
                end
            })
        }
    })
end)

