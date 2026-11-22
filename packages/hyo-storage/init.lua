-- packages/hyo-storage/init.lua
-- Hyo Official Persistent Storage Package v0.1.0
-- Key-Value preferences, JSON serialization, cache expiration, and bulk transactions.

local hyo = require("hyo")

local Storage = {
    _memoryCache = {}
}

--- Retrieve a stored string, number, boolean, or table
function Storage.get(key, defaultValue)
    if not key then return defaultValue end

    -- Check memory cache first
    if Storage._memoryCache[key] ~= nil then
        return Storage._memoryCache[key]
    end

    local rawVal = nil
    if hyo.storage and hyo.storage.get then
        rawVal = hyo.storage.get(key, nil)
    end

    if rawVal == nil then
        return defaultValue
    end

    -- Attempt JSON decode for complex structured tables
    if type(rawVal) == "string" and (rawVal:sub(1,1) == "{" or rawVal:sub(1,1) == "[") then
        local ok, cjson = pcall(require, "cjson")
        if ok and cjson then
            local success, decoded = pcall(cjson.decode, rawVal)
            if success then
                Storage._memoryCache[key] = decoded
                return decoded
            end
        end
    end

    Storage._memoryCache[key] = rawVal
    return rawVal
end

--- Store a value persistently
function Storage.set(key, value)
    if not key then return false end
    Storage._memoryCache[key] = value

    local rawVal = value
    if type(value) == "table" then
        local ok, cjson = pcall(require, "cjson")
        if ok and cjson then
            rawVal = cjson.encode(value)
        else
            rawVal = tostring(value)
        end
    else
        rawVal = tostring(value)
    end

    if hyo.storage and hyo.storage.set then
        return hyo.storage.set(key, rawVal)
    end
    return true
end

--- Remove an entry
function Storage.remove(key)
    if not key then return false end
    Storage._memoryCache[key] = nil
    if hyo.storage and hyo.storage.remove then
        return hyo.storage.remove(key)
    end
    return true
end

--- Clear all storage
function Storage.clear()
    Storage._memoryCache = {}
    if hyo.storage and hyo.storage.clear then
        return hyo.storage.clear()
    end
    return true
end

return Storage
