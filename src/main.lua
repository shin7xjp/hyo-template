-- src/main.lua — Clean Starter Application for Hyo Framework
local hyo = require("hyo")

-- Official Modular Packages
local UI = require("hyo-ui")
local Navigation = require("hyo-navigation")
local Storage = require("hyo-storage")

hyo.create({
    name = "Hyo Starter",
    title = "Hyo Starter",
    version = "1.0.0"
})

-- ─── Reactive Application State ──────────────────────────
local count = State(0)
local noteText = State(Storage.get("starter_note", "Welcome to Hyo!"))
local currentInput = ""

-- ─── Screen: Home ────────────────────────────────────────
Navigation.route("home", function()
    local theme = hyo.theme:colors()

    return Column({
        background = theme.background,
        children = {
            -- Application Header Bar
            UI.AppBar({
                title = "Hyo Mobile App",
                background = theme.surface,
                trailing = Button({
                    text = "About →",
                    size = 13,
                    background = theme.primary,
                    radius = 8,
                    padding = { top = 6, bottom = 6, left = 12, right = 12 },
                    onClick = function()
                        Navigation.push("about")
                    end
                })
            }),

            -- Scrollable Main Content
            ScrollView({
                children = {
                    Column({
                        padding = { top = 20, bottom = 40, left = 16, right = 16 },
                        spacing = 16,
                        children = {
                            -- Welcome Card
                            Card({
                                background = theme.primary,
                                radius = 16,
                                padding = 20,
                                spacing = 8,
                                children = {
                                    Text({
                                        text = "Hello, Developer! 👋",
                                        size = 22,
                                        weight = "bold",
                                        color = "#ffffff"
                                    }),
                                    Text({
                                        text = "You are running Hyo with native C++20, Skia 2D rendering, and Lua 5.5.1 scripting.",
                                        size = 14,
                                        color = "#e0e7ff"
                                    }),
                                }
                            }),

                            -- Section: Reactive Counter
                            UI.SectionHeader({ title = "Interactive Counter" }),

                            Card({
                                background = theme.surface,
                                radius = 14,
                                padding = 16,
                                spacing = 12,
                                border = { color = theme.border, width = 1 },
                                children = {
                                    Text({
                                        text = function()
                                            return "Current Count: " .. count:get()
                                        end,
                                        size = 18,
                                        weight = "bold",
                                        color = theme.textPrimary,
                                        alignment = "center"
                                    }),
                                    Row({
                                        spacing = 12,
                                        alignment = "center",
                                        children = {
                                            Button({
                                                text = "− Decrease",
                                                background = theme.surfaceVariant,
                                                size = 13,
                                                radius = 8,
                                                padding = { top = 10, bottom = 10, left = 16, right = 16 },
                                                onClick = function()
                                                    count:set(count:get() - 1)
                                                end
                                            }),
                                            Button({
                                                text = "+ Increase",
                                                background = theme.primary,
                                                size = 13,
                                                radius = 8,
                                                padding = { top = 10, bottom = 10, left = 16, right = 16 },
                                                onClick = function()
                                                    count:set(count:get() + 1)
                                                end
                                            }),
                                            Button({
                                                text = "Reset",
                                                background = "#ef4444",
                                                size = 13,
                                                radius = 8,
                                                padding = { top = 10, bottom = 10, left = 14, right = 14 },
                                                onClick = function()
                                                    count:set(0)
                                                end
                                            }),
                                        }
                                    })
                                }
                            }),

                            -- Section: Persistent Storage
                            UI.SectionHeader({ title = "Persistent Storage" }),

                            Card({
                                background = theme.surface,
                                radius = 14,
                                padding = 16,
                                spacing = 12,
                                border = { color = theme.border, width = 1 },
                                children = {
                                    TextField({
                                        placeholder = "Type a note to save...",
                                        size = 14,
                                        background = theme.surfaceVariant,
                                        radius = 8,
                                        padding = { top = 10, bottom = 10, left = 12, right = 12 },
                                        onChange = function(text)
                                            currentInput = text
                                        end
                                    }),
                                    Button({
                                        text = "Save Note",
                                        background = "#10b981",
                                        size = 13,
                                        radius = 8,
                                        padding = { top = 10, bottom = 10, left = 16, right = 16 },
                                        onClick = function()
                                            if currentInput ~= "" then
                                                Storage.set("starter_note", currentInput)
                                                noteText:set(currentInput)
                                            end
                                        end
                                    }),
                                    Text({
                                        text = function()
                                            return "Saved Note: " .. noteText:get()
                                        end,
                                        size = 13,
                                        color = theme.textSecondary
                                    })
                                }
                            }),

                            Spacer({ height = 20 }),
                        }
                    })
                }
            })
        }
    })
end)

-- ─── Screen: About ───────────────────────────────────────
Navigation.route("about", function()
    local theme = hyo.theme:colors()

    return Column({
        background = theme.background,
        children = {
            UI.AppBar({
                title = "About Hyo",
                background = theme.surface,
                leading = Button({
                    text = "← Back",
                    size = 14,
                    background = "transparent",
                    padding = 4,
                    onClick = function()
                        Navigation.pop()
                    end
                })
            }),

            ScrollView({
                children = {
                    Column({
                        padding = { top = 20, bottom = 40, left = 16, right = 16 },
                        spacing = 16,
                        children = {
                            Card({
                                background = theme.surface,
                                radius = 14,
                                padding = 18,
                                spacing = 10,
                                border = { color = theme.border, width = 1 },
                                children = {
                                    Text({
                                        text = "Framework Information",
                                        size = 16,
                                        weight = "bold",
                                        color = theme.textPrimary
                                    }),
                                    Text({
                                        text = "• Core: C++20 Runtime Engine\n• Graphics: Google Skia 2D Engine\n• Scripting: Lua 5.5.1 Environment\n• Packages: Official modular packages in packages/",
                                        size = 13,
                                        color = theme.textSecondary
                                    }),
                                    Spacer({ height = 6 }),
                                    Button({
                                        text = "Return to Home",
                                        background = theme.primary,
                                        size = 13,
                                        radius = 8,
                                        padding = { top = 10, bottom = 10, left = 16, right = 16 },
                                        onClick = function()
                                            Navigation.pop()
                                        end
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }
    })
end)

-- Start Application on Home screen
hyo.run(function()
    Navigation.push("home")
end)
