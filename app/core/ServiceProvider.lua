--[[
    ServiceProvider.lua — base class for app-specific providers.

    Analogous to Laravel's ServiceProvider. A provider has two phases:

        register(app)  -- bind values into the container (no resolving!)
        boot(app)      -- safe to resolve other services

    Example:
        local ScoreProvider = ServiceProvider:extend("ScoreProvider")
        function ScoreProvider:register(app)
            self:bind("score", { value = 0, add = function(self, n) self.value = self.value + n end })
        end
        function ScoreProvider:boot(app)
            app:on("enemy:killed", function(reward) app:make("score"):add(reward) end)
        end
]]

local Class = require("core.Class")

local ServiceProvider = Class:extend("ServiceProvider")

function ServiceProvider:new()
    self.app = nil
    return self
end

function ServiceProvider:setApp(app)
    self.app = app
    return self
end

function ServiceProvider:bind(name, value)   self.app:bind(name, value)            return self end
function ServiceProvider:singleton(name, fn) self.app:singleton(name, fn)          return self end
function ServiceProvider:make(name)          return self.app:make(name)            end
function ServiceProvider:on(event, fn)       self.app:on(event, fn)               return self end
function ServiceProvider:emit(event, ...)    self.app:emit(event, ...)            return self end

-- Override these in subclasses
function ServiceProvider:register(app) end
function ServiceProvider:boot(app)     end

return ServiceProvider
