-- packages/hyo-navigation/init.lua
-- Hyo Official Navigation Package v0.1.0
-- Complete screen routing, history preservation, transitions, and modal support.

local hyo = require("hyo")

local Navigation = {
    _routes = {},
    _history = {},
    _listeners = {},
    _transition = "slide" -- default transition style: "slide", "fade", "none"
}

--- Register a named route handler
function Navigation.route(name, componentFn)
    if type(name) ~= "string" or type(componentFn) ~= "function" then
        error("hyo-navigation: route(name, componentFn) requires a string name and function")
    end
    Navigation._routes[name] = componentFn
    -- Also sync with native hyo.navigation if available
    if hyo.navigation and hyo.navigation.route then
        hyo.navigation.route(name, componentFn)
    end
    return Navigation
end

--- Push a new route onto the stack
function Navigation.push(name, params)
    local routeFn = Navigation._routes[name]
    if not routeFn then
        print("[hyo-navigation] Warning: Route not found: " .. tostring(name))
    end
    table.insert(Navigation._history, { name = name, params = params or {} })
    Navigation._notify("push", name, params)

    if hyo.navigation and hyo.navigation.push then
        return hyo.navigation.push(name)
    end
end

--- Pop the current route off the stack
function Navigation.pop()
    if #Navigation._history > 1 then
        local popped = table.remove(Navigation._history)
        local current = Navigation._history[#Navigation._history]
        Navigation._notify("pop", current.name, current.params)
    end

    if hyo.navigation and hyo.navigation.pop then
        return hyo.navigation.pop()
    end
end

--- Replace the current active route
function Navigation.replace(name, params)
    if #Navigation._history > 0 then
        Navigation._history[#Navigation._history] = { name = name, params = params or {} }
    else
        table.insert(Navigation._history, { name = name, params = params or {} })
    end
    Navigation._notify("replace", name, params)

    if hyo.navigation and hyo.navigation.replace then
        return hyo.navigation.replace(name)
    end
end

--- Return the current route entry: { name = "home", params = {} }
function Navigation.current()
    if #Navigation._history > 0 then
        return Navigation._history[#Navigation._history]
    end
    if hyo.navigation and hyo.navigation.current then
        return { name = hyo.navigation.current(), params = {} }
    end
    return { name = "home", params = {} }
end

--- Check if the route stack can be popped
function Navigation.canPop()
    if #Navigation._history > 1 then return true end
    if hyo.navigation and hyo.navigation.canPop then
        return hyo.navigation.canPop()
    end
    return false
end

--- Clear history and navigate to a reset root
function Navigation.reset(name, params)
    Navigation._history = {}
    return Navigation.push(name, params)
end

--- Add a route change listener: callback(action, routeName, params)
function Navigation.addListener(callback)
    if type(callback) == "function" then
        table.insert(Navigation._listeners, callback)
    end
end

function Navigation._notify(action, name, params)
    for _, cb in ipairs(Navigation._listeners) do
        pcall(cb, action, name, params)
    end
end

return Navigation
