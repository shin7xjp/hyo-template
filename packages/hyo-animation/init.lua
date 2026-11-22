-- packages/hyo-animation/init.lua
-- Hyo Official Animation Package v0.1.0
-- Easing curves, spring physics, continuous interpolation, and frame schedulers.

local hyo = require("hyo")

local Animation = {
    _active = {},
    _idCounter = 0
}

-- Comprehensive mathematical easing curves
Animation.curves = {
    linear = function(t) return t end,
    ease = function(t) return t * t * (3 - 2 * t) end,
    easeIn = function(t) return t * t end,
    easeOut = function(t) return t * (2 - t) end,
    easeInOut = function(t)
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
    end,
    easeInCubic = function(t) return t * t * t end,
    easeOutCubic = function(t) return (t - 1) * (t - 1) * (t - 1) + 1 end,
    easeInOutCubic = function(t)
        return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
    end,
    spring = function(t)
        return (1 - math.cos(t * math.pi * 3.5)) * math.exp(-t * 3) + t
    end,
    bounce = function(t)
        if t < (1 / 2.75) then
            return 7.5625 * t * t
        elseif t < (2 / 2.75) then
            t = t - (1.5 / 2.75)
            return 7.5625 * t * t + 0.75
        elseif t < (2.5 / 2.75) then
            t = t - (2.25 / 2.75)
            return 7.5625 * t * t + 0.9375
        else
            t = t - (2.625 / 2.75)
            return 7.5625 * t * t + 0.984375
        end
    end
}

--- Animate a value from `from` to `to` over `duration` (in milliseconds)
-- options: { from = 0, to = 1, duration = 300, curve = "easeOut", onUpdate = fn, onComplete = fn }
function Animation.animate(options)
    if not options then return 0 end
    Animation._idCounter = Animation._idCounter + 1
    local id = Animation._idCounter

    local duration = (options.duration or 300) / 1000.0 -- seconds
    local curveFn = type(options.curve) == "function" and options.curve or
                    (Animation.curves[options.curve] or Animation.curves.easeOut)

    local anim = {
        id = id,
        from = options.from or 0.0,
        to = options.to or 1.0,
        duration = math.max(0.001, duration),
        elapsed = 0.0,
        curve = curveFn,
        onUpdate = options.onUpdate,
        onComplete = options.onComplete
    }
    Animation._active[id] = anim

    -- Sync with native hyo.animation if present
    if hyo.animation and hyo.animation.animate then
        hyo.animation:animate(options)
    end

    return id
end

--- Cancel an active animation
function Animation.stop(id)
    if id then
        Animation._active[id] = nil
        if hyo.animation and hyo.animation.stop then
            hyo.animation:stop(id)
        end
    end
end

--- Interpolate linearly between two values
function Animation.lerp(a, b, t)
    return a + (b - a) * math.clamp(t, 0.0, 1.0)
end

function math.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

return Animation
