-- src/components/ui.lua — Modern Hyo UI Component Architecture
local hyo = require("hyo")

local UI = {}

-- ─── Section Header ─────────────────────────────────────
function UI.SectionHeader(options)
    local theme = hyo.theme:colors()
    return Container({
        padding = { top = 12, bottom = 4, left = 4, right = 4 },
        children = {
            Text({
                text = string.upper(options.title or ""),
                size = 12,
                weight = "bold",
                color = options.color or theme.textMuted,
            })
        }
    })
end

-- ─── AppBar ─────────────────────────────────────────────
function UI.AppBar(options)
    local theme = hyo.theme:colors()
    return Container({
        background = options.background or theme.surface,
        padding = { top = 44, bottom = 14, left = 20, right = 20 },
        border = { color = theme.border, width = 1 },
        children = {
            Row({
                alignment = "spaceBetween",
                crossAlignment = "center",
                children = {
                    Row({
                        spacing = 10,
                        crossAlignment = "center",
                        children = {
                            options.leading or Container({}),
                            Text({
                                text = options.title or "Hyo App",
                                size = 20,
                                weight = "bold",
                                color = theme.textPrimary
                            }),
                        }
                    }),
                    options.trailing or Container({})
                }
            })
        }
    })
end

-- ─── 3.1 Tabs ───────────────────────────────────────────
-- Requirements: Multiple tabs, indicator movement, transitions, icons, labels, responsive sizing
function UI.Tabs(options)
    local theme = hyo.theme:colors()
    local tabs = options.tabs or options.items or {}
    local selectedIndex = options.selected or options.currentIndex or 1
    local onChange = options.onChange or options.onSelect or function() end

    local tabButtons = {}
    for i, tab in ipairs(tabs) do
        local isSelected = (i == selectedIndex)
        local title = type(tab) == "table" and (tab.title or tab.label or "") or tostring(tab)
        local icon = type(tab) == "table" and tab.icon or nil

        local tabChildren = {}
        if icon then
            table.insert(tabChildren, Text({
                text = icon,
                size = 16,
                color = isSelected and "#ffffff" or theme.textSecondary,
                alignment = "center"
            }))
            table.insert(tabChildren, Spacer({ width = 6 }))
        end
        table.insert(tabChildren, Text({
            text = title,
            size = 13,
            weight = isSelected and "bold" or "normal",
            color = isSelected and "#ffffff" or theme.textSecondary,
            alignment = "center"
        }))

        table.insert(tabButtons, Container({
            background = isSelected and (options.activeColor or theme.primary) or "transparent",
            radius = 10,
            padding = { top = 8, bottom = 8, left = 16, right = 16 },
            onClick = function()
                onChange(i)
            end,
            children = {
                Row({
                    crossAlignment = "center",
                    alignment = "center",
                    children = tabChildren
                })
            }
        }))
    end

    return Container({
        background = options.background or theme.surfaceVariant,
        radius = 14,
        padding = 4,
        children = {
            Row({
                spacing = 4,
                crossAlignment = "center",
                children = tabButtons
            })
        }
    })
end

-- ─── 3.2 Switch ─────────────────────────────────────────
-- Requirements: Smooth thumb movement, animated track, clear enabled/disabled, consistent dimensions
function UI.Switch(options)
    local theme = hyo.theme:colors()
    local isChecked = (options.value == true) or (options.checked == true) or (options.value == 1) or (options.checked == 1)
    local onChange = options.onChange or function() end
    local disabled = options.disabled or false

    return Switch({
        checked = isChecked,
        activeColor = disabled and theme.textMuted or (options.activeColor or theme.primary),
        inactiveColor = options.inactiveColor or theme.border,
        width = options.width or 52,
        height = options.height or 32,
        onChange = function()
            if not disabled then
                onChange(not isChecked)
            end
        end
    })
end

-- ─── 3.3 Slider ─────────────────────────────────────────
-- Requirements: Smooth thumb, accurate min/max/step clamping, value updates during drag
function UI.Slider(options)
    local theme = hyo.theme:colors()
    local minVal = options.min or 0
    local maxVal = options.max or 100
    local step = options.step or 1
    local currentVal = options.value or minVal
    local onChange = options.onChange or function() end

    return Slider({
        value = currentVal,
        min = minVal,
        max = maxVal,
        activeColor = options.activeColor or theme.primary,
        inactiveColor = options.inactiveColor or theme.border,
        height = options.height or 32,
        onChange = function(val)
            -- Apply step increment rounding
            if step > 0 then
                local stepped = math.floor((val - minVal) / step + 0.5) * step + minVal
                val = math.clamp and math.clamp(stepped, minVal, maxVal) or math.max(minVal, math.min(maxVal, stepped))
            end
            onChange(val)
        end
    })
end

-- ─── 3.4 RadioButton & RadioGroup ───────────────────────
-- Requirements: Single selection per group, animated indicator, disabled options, consistent spacing
function UI.RadioButton(options)
    local theme = hyo.theme:colors()
    local isSelected = options.selected or false
    local disabled = options.disabled or false
    local onClick = options.onClick or function() end

    local activeColor = disabled and theme.textMuted or (options.activeColor or theme.primary)

    return Container({
        padding = { top = 6, bottom = 6, left = 0, right = 0 },
        onClick = function()
            if not disabled then onClick() end
        end,
        children = {
            Row({
                spacing = 12,
                crossAlignment = "center",
                children = {
                    Container({
                        width = 22,
                        height = 22,
                        radius = 11,
                        border = { color = isSelected and activeColor or theme.textMuted, width = 2 },
                        background = isSelected and activeColor or "transparent",
                        alignment = "center",
                        crossAlignment = "center",
                        children = isSelected and {
                            Container({
                                width = 8,
                                height = 8,
                                radius = 4,
                                background = "#ffffff"
                            })
                        } or {}
                    }),
                    Text({
                        text = options.label or "",
                        size = 15,
                        color = disabled and theme.textMuted or theme.textPrimary
                    })
                }
            })
        }
    })
end

function UI.RadioGroup(options)
    local selectedValue = options.value
    local items = options.options or {}
    local onChange = options.onChange or function() end

    local groupChildren = {}
    for _, opt in ipairs(items) do
        local isSelected = (opt.value == selectedValue)
        table.insert(groupChildren, UI.RadioButton({
            label = opt.label or tostring(opt.value),
            selected = isSelected,
            disabled = opt.disabled,
            onClick = function()
                if not isSelected then
                    onChange(opt.value)
                end
            end
        }))
    end

    return Column({
        spacing = options.spacing or 8,
        children = groupChildren
    })
end

-- ─── 3.5 Dialog ─────────────────────────────────────────
-- Requirements: Modal overlay, background dimming, opening/closing, title, description, actions, backdrop click
function UI.Dialog(options)
    local theme = hyo.theme:colors()
    if options.visible == false then
        return Container({ width = 0, height = 0 })
    end

    local actionButtons = {}
    if options.actions then
        for _, act in ipairs(options.actions) do
            table.insert(actionButtons, Button({
                text = act.text or "Action",
                background = act.primary and theme.primary or "#334155",
                size = 13,
                radius = 10,
                padding = { top = 8, bottom = 8, left = 16, right = 16 },
                onClick = act.onClick or function() end
            }))
        end
    else
        table.insert(actionButtons, Button({
            text = options.cancelText or "Cancel",
            background = "#334155",
            size = 13,
            radius = 10,
            padding = { top = 8, bottom = 8, left = 14, right = 14 },
            onClick = options.onCancel or function() end
        }))
        table.insert(actionButtons, Button({
            text = options.confirmText or "Confirm",
            background = theme.primary,
            size = 13,
            radius = 10,
            padding = { top = 8, bottom = 8, left = 14, right = 14 },
            onClick = options.onConfirm or function() end
        }))
    end

    return Card({
        background = theme.surface,
        radius = 20,
        border = { color = theme.border, width = 1 },
        padding = 24,
        spacing = 16,
        shadow = { color = "#000000", blur = 32, x = 0, y = 8 },
        children = {
            Text({
                text = options.title or "Notice",
                size = 19,
                weight = "bold",
                color = theme.textPrimary
            }),
            Text({
                text = options.description or options.message or "",
                size = 14,
                color = theme.textSecondary
            }),
            Spacer({ height = 4 }),
            Row({
                alignment = "end",
                spacing = 10,
                children = actionButtons
            })
        }
    })
end

-- ─── NavigationBar ──────────────────────────────────────
function UI.NavigationBar(options)
    local items = options.items or {}
    local currentIndex = options.currentIndex or 1
    local onSelect = options.onSelect or function() end
    local theme = hyo.theme:colors()

    local rowChildren = {}
    for i, item in ipairs(items) do
        local isSelected = (i == currentIndex)
        local itemColor = isSelected and (options.activeColor or theme.primary) or (options.inactiveColor or theme.textMuted)

        table.insert(rowChildren, Container({
            padding = { top = 8, bottom = 12, left = 16, right = 16 },
            alignment = "center",
            crossAlignment = "center",
            onClick = function()
                onSelect(i)
            end,
            children = {
                Text({
                    text = item.icon or "●",
                    size = 20,
                    color = itemColor,
                    alignment = "center"
                }),
                Spacer({ height = 4 }),
                Text({
                    text = item.label or "",
                    size = 11,
                    weight = isSelected and "bold" or "normal",
                    color = itemColor,
                    alignment = "center"
                })
            }
        }))
    end

    return Container({
        background = options.background or theme.surface,
        border = { color = theme.border, width = 1 },
        padding = { top = 6, bottom = 12, left = 8, right = 8 },
        children = {
            Row({
                alignment = "spaceAround",
                crossAlignment = "center",
                children = rowChildren
            })
        }
    })
end

-- ─── SettingsRow ────────────────────────────────────────
function UI.SettingsRow(options)
    local theme = hyo.theme:colors()
    return Row({
        alignment = "spaceBetween",
        crossAlignment = "center",
        children = {
            Column({
                spacing = 2,
                children = {
                    Text({
                        text = options.title or "",
                        size = 15,
                        color = theme.textPrimary
                    }),
                    options.subtitle and Text({
                        text = options.subtitle,
                        size = 12,
                        color = theme.textMuted
                    }) or nil
                }
            }),
            options.trailing or Container({})
        }
    })
end

-- ─── ListView & GridView Helpers ─────────────────────────
function UI.ListView(options)
    local children = options.children or {}
    return ScrollView({
        background = options.background or "transparent",
        children = {
            Column({
                padding = options.padding or 0,
                spacing = options.spacing or 12,
                children = children
            })
        }
    })
end

function UI.GridView(options)
    local items = options.items or {}
    local columns = options.columns or 2
    local spacing = options.spacing or 12

    local rows = {}
    local currentRow = {}

    for i, item in ipairs(items) do
        table.insert(currentRow, item)
        if #currentRow == columns or i == #items then
            table.insert(rows, Row({
                spacing = spacing,
                children = currentRow
            }))
            currentRow = {}
        end
    end

    return Column({
        spacing = spacing,
        padding = options.padding or 0,
        children = rows
    })
end

return UI
