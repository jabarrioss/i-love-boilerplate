--[[
    Scheduler.lua — delayed and repeating callbacks.

    Combines "do X in 2 seconds" with "do X every 0.5 seconds" with
    a fluent API. Backed by the global game clock (Application._time).

    Usage:
        scheduler:after(2.0, function() print("2s passed") end)
        scheduler:every(0.5, function() print("tick") end, "tick-tag")
        scheduler:stop("tick-tag")  -- cancel the repeat
        scheduler:update(dt)        -- called by Application every frame
]]

local Class = require("core.Class")

local Scheduler = Class:extend("Scheduler")

function Scheduler:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    instance._delayed  = {} -- { at = time, fn = fn, tag = tag, cancelled = false }
    instance._periodic = {} -- { every = sec, accumulator = 0, fn = fn, tag = tag, cancelled = false }
    return instance
end

function Scheduler:_now()
    if self.app then return self.app:time() end
    return love and love.timer and love.timer.getTime() or 0
end

-- Run once after `seconds`. Optional tag for cancellation.
function Scheduler:after(seconds, fn, tag)
    assert(type(fn) == "function", "Scheduler:after requires a function")
    table.insert(self._delayed, {
        at        = self:_now() + seconds,
        fn        = fn,
        tag       = tag,
        cancelled = false,
    })
    return self
end

-- Run every `seconds`. Tag required so you can stop it.
function Scheduler:every(seconds, fn, tag)
    assert(type(seconds) == "number" and seconds > 0, "Scheduler:every requires positive seconds")
    assert(type(fn) == "function", "Scheduler:every requires a function")
    assert(type(tag) == "string" and #tag > 0, "Scheduler:every requires a tag string")
    table.insert(self._periodic, {
        every      = seconds,
        accumulator = 0,
        fn          = fn,
        tag         = tag,
        cancelled   = false,
    })
    return self
end

function Scheduler:nextFrame(fn)
    return self:after(0, fn)
end

function Scheduler:stop(tag)
    if not tag then return self end
    for _, t in ipairs({ self._delayed, self._periodic }) do
        for _, item in ipairs(t) do
            if item.tag == tag then item.cancelled = true end
        end
    end
    return self
end

function Scheduler:cancelAll()
    for _, t in ipairs({ self._delayed, self._periodic }) do
        for _, item in ipairs(t) do item.cancelled = true end
    end
    return self
end

function Scheduler:update(dt)
    local now = self:_now()

    -- Delayed (one-shot)
    local stillDelayed = {}
    for _, item in ipairs(self._delayed) do
        if not item.cancelled and now >= item.at then
            local ok, err = pcall(item.fn)
            if not ok then
                io.stderr:write("[Scheduler:after] " .. tostring(err) .. "\n")
            end
            -- one-shot, don't re-add
        elseif not item.cancelled then
            table.insert(stillDelayed, item)
        end
    end
    self._delayed = stillDelayed

    -- Periodic
    for _, item in ipairs(self._periodic) do
        if not item.cancelled then
            item.accumulator = item.accumulator + dt
            while item.accumulator >= item.every and not item.cancelled do
                item.accumulator = item.accumulator - item.every
                local ok, err = pcall(item.fn)
                if not ok then
                    io.stderr:write("[Scheduler:every] " .. tostring(err) .. "\n")
                    item.cancelled = true
                end
            end
        end
    end
    -- Compact cancelled periodic entries occasionally (cheap)
    local stillPeriodic = {}
    for _, item in ipairs(self._periodic) do
        if not item.cancelled then table.insert(stillPeriodic, item) end
    end
    self._periodic = stillPeriodic
end

return Scheduler
