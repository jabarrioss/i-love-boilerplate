--[[
    Easing.lua — easing functions and a tiny tween helper.

    Pure functions:

        easing.linear(t)
        easing.inQuad / outQuad / inOutQuad
        easing.inCubic / outCubic / inOutCubic
        easing.inSine / outSine / inOutSine
        easing.inExpo / outExpo / inOutExpo
        easing.inBack / outBack / inOutBack
        easing.inBounce / outBounce / inOutBounce
        easing.inElastic / outElastic / inOutElastic

    Tween helper:

        easing:tween(0.5, target, "x", 200, "outQuad", function() end)
        easing:tween(0.5, target, "alpha", 0,  "inOutQuad")
]]

local Class = require("core.Class")

local Easing = Class:extend("Easing")

function Easing:new(app)
    self.app = app
    self._tweens = {}
    return self
end

-- ----- Pure functions -----
function Easing.linear(t)        return t end
function Easing.inQuad(t)        return t * t end
function Easing.outQuad(t)       return t * (2 - t) end
function Easing.inOutQuad(t)     return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end
function Easing.inCubic(t)       return t * t * t end
function Easing.outCubic(t)      local p = t - 1; return p * p * p + 1 end
function Easing.inOutCubic(t)    return t < 0.5 and 4 * t * t * t or ((t - 1) * (2 * t - 2) * (2 * t - 2) + 2) end
function Easing.inSine(t)        return 1 - math.cos(t * math.pi / 2) end
function Easing.outSine(t)       return math.sin(t * math.pi / 2) end
function Easing.inOutSine(t)     return -(math.cos(math.pi * t) - 1) / 2 end
function Easing.inExpo(t)        return t == 0 and 0 or math.pow(2, 10 * (t - 1)) end
function Easing.outExpo(t)       return t == 1 and 1 or 1 - math.pow(2, -10 * t) end
function Easing.inOutExpo(t)
    if t == 0 then return 0
    elseif t == 1 then return 1
    elseif t < 0.5 then return math.pow(2, 20 * t - 10) / 2
    else return (2 - math.pow(2, -20 * t + 10)) / 2
    end
end
function Easing.inBack(t)        local s = 1.70158; return t * t * ((s + 1) * t - s) end
function Easing.outBack(t)       local s = 1.70158; t = t - 1; return t * t * ((s + 1) * t + s) + 1 end
function Easing.inOutBack(t)     local s = 1.70158 * 1.525; t = t * 2; if t < 1 then return (t * t * ((s + 1) * t - s)) / 2 end; t = t - 2; return (t * t * ((s + 1) * t + s) + 2) / 2 end

function Easing.outBounce(t)
    if t < 1 / 2.75 then return 7.5625 * t * t end
    if t < 2 / 2.75 then t = t - 1.5 / 2.75; return 7.5625 * t * t + 0.75 end
    if t < 2.5 / 2.75 then t = t - 2.25 / 2.75; return 7.5625 * t * t + 0.9375 end
    t = t - 2.625 / 2.75
    return 7.5625 * t * t + 0.984375
end

function Easing.inBounce(t)        return 1 - Easing.outBounce(1 - t) end
function Easing.inOutBounce(t)     return t < 0.5 and Easing.inBounce(t * 2) * 0.5 or 1 - Easing.inBounce((1 - t) * 2) * 0.5 end

function Easing.outElastic(t)
    if t == 0 or t == 1 then return t end
    local p = 0.3
    return math.pow(2, -10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
end

function Easing.inElastic(t)
    if t == 0 or t == 1 then return t end
    local p = 0.3
    return -(math.pow(2, 10 * (t - 1)) * math.sin((t - 1 - p / 4) * (2 * math.pi) / p))
end

function Easing.inOutElastic(t)
    if t == 0 or t == 1 then return t end
    local p = 0.3 * 1.5
    t = t * 2
    if t < 1 then return -0.5 * (math.pow(2, 10 * (t - 1)) * math.sin((t - 1 - p / 4) * (2 * math.pi) / p)) end
    t = t - 1
    return math.pow(2, -10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) * 0.5 + 1
end

-- ----- Tween helper -----

--- tween(duration, target, property, targetValue, easingFunc, onComplete)
function Easing:tween(duration, target, prop, to, ease, onComplete)
    assert(type(duration) == "number" and duration > 0, "Easing:tween requires positive duration")
    assert(type(target) == "table", "Easing:tween requires a target table")
    ease = ease or Easing.outQuad
    if type(ease) == "string" then
        ease = Easing[ease] or Easing.outQuad
    end
    local from = target[prop]
    if from == nil then from = 0 end
    table.insert(self._tweens, {
        elapsed = 0,
        duration = duration,
        target = target,
        prop = prop,
        from = from,
        to = to,
        ease = ease,
        onComplete = onComplete,
        cancelled = false,
    })
    return self
end

function Easing:cancel(target)
    for _, tw in ipairs(self._tweens) do
        if tw.target == target then tw.cancelled = true end
    end
    return self
end

function Easing:update(dt)
    local still = {}
    for _, tw in ipairs(self._tweens) do
        if not tw.cancelled then
            tw.elapsed = tw.elapsed + dt
            local t = math.min(1, tw.elapsed / tw.duration)
            local k = tw.ease(t)
            tw.target[tw.prop] = tw.from + (tw.to - tw.from) * k
            if t >= 1 then
                if tw.onComplete then
                    local ok, err = pcall(tw.onComplete)
                    if not ok then io.stderr:write("[Easing:tween] onComplete error: " .. tostring(err) .. "\n") end
                end
            else
                table.insert(still, tw)
            end
        end
    end
    self._tweens = still
    return self
end

return Easing
