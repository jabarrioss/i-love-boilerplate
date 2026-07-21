--[[
    Facade.lua — short, named aliases for frequently-used services.

    Analogous to Laravel's facades. Instead of writing
        app:make("scenes"):push("MenuScene")
    you can write
        Scene:push("MenuScene")
    after registering a facade.

    The Application is the underlying container; facades only forward
    method calls. They do not hold state.

    Usage:
        local Facade = require("core.Facade")
        local Scene = Facade:extend("Scene", "scenes", function(app) return app end)

        -- anywhere after app:boot()
        Scene:push("MenuScene")
]]

local Class = require("core.Class")

local Facade = Class:extend("Facade")
Facade.__app = nil

function Facade:setApp(app)
    Facade.__app = app
end

function Facade:extend(name, key, resolver)
    -- The subclass's metatable will route unknown lookups to the container.
    local facade = setmetatable({}, { __index = self, __call = function(_, ...) return ... end })
    facade.__key      = key or name:lower()
    facade.__resolver = resolver or function(app) return app end
    facade.__name     = name
    return setmetatable(facade, {
        __index = function(_, method)
            local app = Facade.__app
            if not app then error("Facade " .. name .. " used before Application:boot()") end
            local target = (facade.__resolver(app))[facade.__key]
            if target == nil then
                error("Facade " .. name .. " resolves to nil service '" .. facade.__key .. "'")
            end
            local fn = target[method]
            if type(fn) ~= "function" then
                error("Facade " .. name .. " has no method '" .. tostring(method) .. "'")
            end
            return function(_, ...) return fn(target, ...) end
        end,
        __tostring = function() return "Facade<" .. name .. ">" end,
    })
end

-- Helper: forward a static call to a method on the underlying service.
-- Use this for non-class-style access if you prefer not to use the
-- metatable trick above.
function Facade.call(facadeClass, method, ...)
    local app = Facade.__app
    if not app then error("Facade called before Application:boot()") end
    local key = facadeClass.__key or (type(facadeClass) == "string" and facadeClass:lower())
    local target = app:make(key)
    local fn = target[method]
    if not fn then error("Service '" .. key .. "' has no method '" .. tostring(method) .. "'") end
    return fn(target, ...)
end

return Facade
