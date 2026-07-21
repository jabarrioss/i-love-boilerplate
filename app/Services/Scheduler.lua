--[[
    Services/Scheduler.lua — service wrapper for the scheduler.

    Mirrors Scheduler's API and gives the service a stable container key.
]]

local Class = require("core.Class")
local SchedulerCtor = require("core.Scheduler")

local Scheduler = Class:extend("Scheduler")

function Scheduler:new(app)
    self.app = app
    self._core = SchedulerCtor:new(app)
    return self
end

function Scheduler:boot()
    -- nothing yet
end

-- Forward the public API
function Scheduler:after(seconds, fn, tag)      return self._core:after(seconds, fn, tag) end
function Scheduler:every(seconds, fn, tag)      return self._core:every(seconds, fn, tag) end
function Scheduler:nextFrame(fn)                return self._core:nextFrame(fn) end
function Scheduler:stop(tag)                    return self._core:stop(tag) end
function Scheduler:cancelAll()                  return self._core:cancelAll() end
function Scheduler:update(dt)                   return self._core:update(dt) end

return Scheduler
