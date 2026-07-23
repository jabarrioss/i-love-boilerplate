--[[
    Services/Event.lua — service wrapper for the global event bus.

    Mostly a passthrough; exposes the same API as core.Event and
    gives the service a stable container key ("events").
]]

local Class   = require("core.Class")
local EventCtor = require("core.Event")

local EventService = Class:extend("EventService")

function EventService:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    instance._bus = EventCtor:new()
    return instance
end

function EventService:on(...)      return self._bus:on(...)      end
function EventService:once(...)    return self._bus:once(...)    end
function EventService:off(...)     return self._bus:off(...)     end
function EventService:emit(...)    return self._bus:emit(...)    end
function EventService:clear(...)   return self._bus:clear(...)   end
function EventService:count(...)   return self._bus:count(...)   end
function EventService:bus()        return self._bus              end

return EventService
