--[[
    Event.lua — lightweight pub/sub event bus.

    Used for cross-service communication without hard dependencies.
    Subscribers are called in registration order; throwing in a
    subscriber is caught and logged so one bad handler can't break
    the others.

    Usage:
        events = Event:new()
        events:on("player:died", function() ... end)
        events:emit("player:died", killer)

        -- one-shot
        events:once("first:run", function() print("hi") end)

        -- filtered
        events:on("score:changed", function(amount)
            print("scored " .. amount)
        end, function(amount) return amount > 100 end)
]]

local Class = require("core.Class")

local Event = Class:extend("Event")

function Event:new()
    self._handlers = {}      -- event -> [{ fn, filter, once }, ...]
    self._wildcard = {}      -- '*' subscribers
    return self
end

function Event:_add(name, fn, filter, once)
    assert(type(fn) == "function", "Event handler must be a function")
    if name == "*" then
        table.insert(self._wildcard, { fn = fn, filter = filter, once = once })
    else
        self._handlers[name] = self._handlers[name] or {}
        table.insert(self._handlers[name], { fn = fn, filter = filter, once = once })
    end
    return self
end

function Event:on(name, fn, filter)
    return self:_add(name, fn, filter, false)
end

function Event:once(name, fn, filter)
    return self:_add(name, fn, filter, true)
end

function Event:off(name, fn)
    local list = name == "*" and self._wildcard or self._handlers[name]
    if not list then return self end
    for i = #list, 1, -1 do
        if list[i].fn == fn then table.remove(list, i) end
    end
    return self
end

function Event:emit(name, ...)
    -- Direct handlers
    local list = self._handlers[name]
    if list then
        local kept = {}
        for _, h in ipairs(list) do
            local pass = true
            if h.filter then pass = h.filter(...) end
            if pass then
                local ok, err = pcall(h.fn, ...)
                if not ok then
                    io.stderr:write(("[Event:%s] handler error: %s\n"):format(name, tostring(err)))
                end
                if not h.once then table.insert(kept, h) end
            else
                table.insert(kept, h)
            end
        end
        self._handlers[name] = kept
    end

    -- Wildcard subscribers receive (eventName, ...) — useful for debug/log
    if #self._wildcard > 0 then
        local kept = {}
        for _, h in ipairs(self._wildcard) do
            local ok, err = pcall(h.fn, name, ...)
            if not ok then
                io.stderr:write(("[Event:*] handler error: %s\n"):format(tostring(err)))
            end
            if not h.once then table.insert(kept, h) end
        end
        self._wildcard = kept
    end

    return self
end

function Event:clear(name)
    if name then
        self._handlers[name] = nil
    else
        self._handlers = {}
        self._wildcard = {}
    end
    return self
end

function Event:count(name)
    if name == "*" then return #self._wildcard end
    return self._handlers[name] and #self._handlers[name] or 0
end

return Event
