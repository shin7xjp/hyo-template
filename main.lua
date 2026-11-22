-- main.lua — Hyo Mobile Application (Phase 6 Full Framework)
local hyo = require("hyo")

hyo.create({
    name = "My Application",
    title = "My Application",
    version = "1.0.0"
})

-- Reactive App State
local count = State(0)
local noteInput = ""
local savedNote = State(hyo.storage.get("user_note", "No note saved yet."))
local networkStatus = State("Tap below to test HTTP request.")

-- Screen: Home
hyo.navigation.route("home", function()
    return ScrollView({
        background = "#0b0f19",
        children = {
            Column({
                padding = 16,
                spacing = 16,

                children = {
                    -- Header Card
                    Card({
                        padding = 18,
                        spacing = 6,
                        background = "#161e2e",
                        radius = 16,
                        border = { color = "#26324b", width = 1 },
                        children = {
                            Text({
                                text = "HYO MOBILE FRAMEWORK",
                                size = 20,
                                weight = "bold",
                                color = "#38bdf8"
                            }),
                            Text({
                                text = "Platform: " .. hyo.device.platform .. "  |  Density: " .. string.format("%.1f", hyo.device.screen.density()) .. "x",
                                size = 13,
                                color = "#94a3b8"
                            })
                        }
                    }),

                    -- Card 1: Reactive State
                    Card({
                        padding = 18,
                        spacing = 14,
                        background = "#161e2e",
                        radius = 16,
                        border = { color = "#1e3a8a", width = 1 },
                        children = {
                            Text({
                                text = "1. Reactive State & Events",
                                size = 16,
                                weight = "bold",
                                color = "#f8fafc"
                            }),
                            Text({
                                text = function()
                                    return "Taps Count: " .. tostring(count:get())
                                end,
                                size = 18,
                                weight = "bold",
                                color = "#60a5fa"
                            }),
                            Row({
                                spacing = 12,
                                children = {
                                    Button({
                                        text = "+ Tap Count",
                                        background = "#2563eb",
                                        size = 14,
                                        onClick = function()
                                            count:set(count:get() + 1)
                                        end
                                    }),
                                    Button({
                                        text = "Reset",
                                        background = "#dc2626",
                                        size = 14,
                                        onClick = function()
                                            count:set(0)
                                        end
                                    })
                                }
                            })
                        }
                    }),
                    -- Card 3: Network Engine
                    Card({
                        padding = 18,
                        spacing = 14,
                        background = "#161e2e",
                        radius = 16,
                        border = { color = "#92400e", width = 1 },
                        children = {
                            Text({
                                text = "3. HTTP & HTTPS Network Engine",
                                size = 16,
                                weight = "bold",
                                color = "#f8fafc"
                            }),
                            Text({
                                text = "Endpoint: https://httpbin.org/get",
                                size = 13,
                                color = "#94a3b8"
                            }),
                            Button({
                                text = "Fetch HTTP Data",
                                background = "#d97706",
                                size = 14,
                                onClick = function()
                                    networkStatus:set("Fetching data from httpbin.org...")
                                    local resp = hyo.network.get("https://httpbin.org/get", 6000)
                                    if resp.status == 200 then
                                        networkStatus:set("HTTP 200 OK — Received " .. string.len(resp.body) .. " bytes!")
                                    else
                                        local errDesc = (resp.error ~= "") and resp.error or ("HTTP " .. tostring(resp.status))
                                        networkStatus:set("Request failed: " .. errDesc)
                                    end
                                end
                            }),
                            Text({
                                text = function()
                                    return "Status: " .. networkStatus:get()
                                end,
                                size = 13,
                                color = "#fde68a"
                            })
                        }
                    }),

                    -- Card 4: Screen Navigation
                    Card({
                        padding = 18,
                        spacing = 14,
                        background = "#161e2e",
                        radius = 16,
                        border = { color = "#5b21b6", width = 1 },
                        children = {
                            Text({
                                text = "4. Multi-Screen Navigation",
                                size = 16,
                                weight = "bold",
                                color = "#f8fafc"
                            }),
                            Button({
                                text = "Open App Settings ->",
                                background = "#7c3aed",
                                size = 14,
                                onClick = function()
                                    hyo.navigation.push("settings")
                                end
                            })
                        }
                    }),

                    Spacer({ height = 24 })
                }
            })
        }
    })
end)

-- Screen: Settings
hyo.navigation.route("settings", function()
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
                text = "Multi-screen route navigation with backward history stack.",
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
end)

-- App entrypoint
hyo.run(function()
    hyo.navigation.push("home")
end)
