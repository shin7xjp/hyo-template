-- packages/hyo-network/init.lua
-- Hyo Official Network Package v0.1.0
-- Asynchronous REST API, fetch client, query parsing, and network state.

local hyo = require("hyo")

local Network = {}

--- Asynchronous HTTP Request
-- options: { method = "GET"|"POST"|"PUT"|"DELETE", headers = {}, body = string, timeout = 10000 }
-- callback: function(response: { status = 200, body = "...", error = nil })
function Network.fetch(url, options, callback)
    options = options or {}
    options.method = options.method or "GET"
    options.headers = options.headers or {}

    -- Delegate to native Hyo HTTP runtime
    if hyo.network and hyo.network.fetch then
        return hyo.network.fetch(url, options, callback)
    elseif hyo.http and hyo.http.fetch then
        return hyo.http.fetch(url, options, callback)
    end

    -- Fallback error handling if runtime has no network driver
    if callback then
        callback({
            status = 500,
            body = "",
            error = "Network backend not initialized or permission not granted"
        })
    end
end

--- Convenience GET request
function Network.get(url, callback)
    return Network.fetch(url, { method = "GET" }, callback)
end

--- Convenience POST request with JSON payload support
function Network.post(url, body, callback)
    local headers = {}
    local postBody = body
    if type(body) == "table" then
        headers["Content-Type"] = "application/json"
        -- Quick JSON encoder fallback if cjson is not loaded
        local ok, cjson = pcall(require, "cjson")
        if ok and cjson then
            postBody = cjson.encode(body)
        else
            postBody = tostring(body)
        end
    end
    return Network.fetch(url, { method = "POST", headers = headers, body = postBody }, callback)
end

--- Build query string from key-value table
function Network.buildQuery(params)
    if not params or type(params) ~= "table" then return "" end
    local query = {}
    for k, v in pairs(params) do
        table.insert(query, tostring(k) .. "=" .. tostring(v))
    end
    return table.concat(query, "&")
end

return Network
