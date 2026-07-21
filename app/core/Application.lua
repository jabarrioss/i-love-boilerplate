--[[
    Application.lua — service container + LÖVE callback router.

    Analogous to Laravel's Illuminate\Foundation\Application. It boots
    service providers, resolves registered services by name, and forwards
    every LÖVE callback to the appropriate subsystem (scene manager,
    input manager, scheduler, etc.).

    Public API:
        app = Application:new()
        app:boot()                  -- called from love.load
        app:update(dt)              -- every frame
        app:draw()                  -- every frame
        app:bind(name, value)       -- register a service
        app:singleton(name, fn)     -- lazy-create a service
        app:make(name)              -- resolve a service
        app:on(event, fn)           -- subscribe to a global event
        app:emit(event, ...)        -- publish a global event
]]

local Class = require("core.Class")

local Application = Class:extend("Application")

function Application:new()
    self._services  = {}      -- name -> value (eager bindings)
    self._singletons = {}     -- name -> { fn = factory }
    self._resolving = {}      -- circular-dependency guard
    self.providers = {}
    self.booted    = false
    self._dt       = 0
    self._time     = 0
    return self
end

-- ---------------------------------------------------------------------------
-- Service registration
-- ---------------------------------------------------------------------------
function Application:bind(name, value)
    if self._resolving[name] then
        error("Application:bind('" .. name .. "') while resolving — circular dependency")
    end
    self._services[name] = value
    return self
end

function Application:singleton(name, factory)
    self._singletons[name] = { fn = factory }
    return self
end

function Application:has(name)
    return self._services[name] ~= nil or self._singletons[name] ~= nil
end

function Application:make(name)
    if self._services[name] ~= nil then
        return self._services[name]
    end
    local def = self._singletons[name]
    if not def then
        error("Application:make('" .. name .. "') — service not registered")
    end
    if def.value ~= nil then return def.value end
    self._resolving[name] = true
    local ok, value = pcall(def.fn, self)
    self._resolving[name] = nil
    if not ok then
        error("Application:make('" .. name .. "') — factory failed: " .. tostring(value))
    end
    def.value = value
    if value and type(value) == "table" and value.setApp then
        value:setApp(self)
    end
    return value
end

function Application:register(provider)
    table.insert(self.providers, provider)
    return self
end

-- ---------------------------------------------------------------------------
-- Boot — like Laravel's bootstrap process
-- ---------------------------------------------------------------------------
function Application:boot()
    if self.booted then return end

    -- Register core services in dependency order
    self:registerCoreServices()

    -- Run register() on every provider
    for _, p in ipairs(self.providers) do
        if p.register then p:register(self) end
    end

    -- Resolve built-in services and call their boot() hook if present.
    local map = self:_serviceMap()
    local order = { "config", "logger", "events", "assets", "input", "audio",
                    "camera", "save", "random", "easing", "scheduler", "scenes" }
    for _, key in ipairs(order) do
        if map[key] then
            local service = self:make(key)
            if service and type(service.boot) == "function" and not service._booted then
                service:boot()
                service._booted = true
            end
        end
    end

    -- Run boot() on every provider after services exist
    for _, p in ipairs(self.providers) do
        if p.boot then p:boot(self) end
    end

    -- Apply config-driven window settings. conf.lua runs before
    -- main.lua so we can't read it from there; we override the title
    -- and other window details from config now that we have it.
    self:applyWindowConfig()

    self.booted = true
    self:emit("app:booted", self)

    -- Push the boot scene if one is configured
    local config = self:make("config")
    local boot = config:get("scenes.boot", "BootScene")
    if boot then
        self:make("scenes"):push(boot)
    end
end

-- Apply window-level settings from config/game.lua. Anything you put
-- there is treated as the source of truth at runtime.
function Application:applyWindowConfig()
    if not love or not love.window then return end
    local config = self:make("config")
    local title = config:get("game.title")
    if title and type(title) == "string" then
        love.window.setTitle(title)
    end
end

-- Map of service key -> Services file basename. Adjust this table to add
-- or remove built-in services. Each key becomes available via app:make(key).
function Application:_serviceMap()
    return {
        config    = "Config",
        logger    = "Logger",
        events    = "Event",
        assets    = "AssetManager",
        input     = "InputManager",
        audio     = "AudioManager",
        camera    = "Camera",
        save      = "SaveManager",
        random    = "Random",
        easing    = "Easing",
        scheduler = "Scheduler",
        scenes    = "SceneManager",
    }
end

function Application:registerCoreServices()
    for key, className in pairs(self:_serviceMap()) do
        local ok, Service = pcall(require, "Services." .. className)
        if ok then
            self:singleton(key, function(app)
                return Service:new(app)
            end)
        else
            io.stderr:write(("[Application] failed to load Services/%s.lua: %s\n")
                :format(className, tostring(Service)))
        end
    end
end

-- ---------------------------------------------------------------------------
-- Convenience accessors
-- ---------------------------------------------------------------------------
function Application:scenes()    return self:make("scenes")   end
function Application:assets()    return self:make("assets")   end
function Application:input()     return self:make("input")    end
function Application:audio()     return self:make("audio")    end
function Application:camera()    return self:make("camera")   end
function Application:save()      return self:make("save")     end
function Application:logger()    return self:make("logger")   end
function Application:config()    return self:make("config")   end
function Application:random()    return self:make("random")   end
function Application:scheduler() return self:make("scheduler") end
function Application:events()    return self:make("events")   end

-- ---------------------------------------------------------------------------
-- Global event helpers (shortcut for self:events())
-- ---------------------------------------------------------------------------
function Application:on(event, fn)
    self:make("events"):on(event, fn)
    return self
end

function Application:off(event, fn)
    self:make("events"):off(event, fn)
    return self
end

function Application:emit(event, ...)
    self:make("events"):emit(event, ...)
    return self
end

-- ---------------------------------------------------------------------------
-- LÖVE callback routing
-- ---------------------------------------------------------------------------
function Application:update(dt)
    self._dt   = dt
    self._time = self._time + dt

    self:make("input"):update(dt)
    self:make("scheduler"):update(dt)
    self:make("audio"):update(dt)
    self:make("easing"):update(dt)
    self:make("camera"):update(dt)
    self:make("scenes"):update(dt)
end

function Application:draw()
    self:make("scenes"):draw()
    if self:make("config"):get("game.debug", false) then
        self:drawDebugOverlay()
    end
end

function Application:drawDebugOverlay()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print(
        ("FPS %d  dt %.4f  scene %s"):format(
            love.timer.getFPS(),
            self._dt,
            tostring(self:make("scenes"):current())
        ),
        8, 8
    )
    love.graphics.setColor(1, 1, 1, 1)
end

function Application:resize(w, h)
    self:emit("app:resize", w, h)
    self:make("scenes"):resize(w, h)
    self:make("camera"):resize(w, h)
end

function Application:focus(focused)
    self:emit("app:focus", focused)
    self:make("scenes"):focus(focused)
end

function Application:visible(v)
    self:emit("app:visible", v)
    self:make("scenes"):visible(v)
end

function Application:quit()
    self:emit("app:quit")
    self:make("save"):flush()
    return false -- allow quit
end

function Application:error(msg)
    self:make("logger"):error("LÖVE error: " .. tostring(msg))
end

function Application:keypressed(key, scancode, isrepeat)
    if self:make("input"):handleKey("pressed", key, scancode, isrepeat) then return end
    self:make("scenes"):keypressed(key, scancode, isrepeat)
end

function Application:keyreleased(key, scancode)
    if self:make("input"):handleKey("released", key, scancode, false) then return end
    self:make("scenes"):keyreleased(key, scancode)
end

function Application:textinput(text)        self:make("scenes"):textinput(text)        end
function Application:textedited(text, s, l) self:make("scenes"):textedited(text, s, l) end

function Application:mousemoved(x, y, dx, dy, istouch)
    self:make("input"):mousemoved(x, y, dx, dy, istouch)
    self:make("scenes"):mousemoved(x, y, dx, dy, istouch)
end

function Application:mousepressed(x, y, button, istouch, presses)
    self:make("input"):mousepressed(x, y, button)
    self:make("scenes"):mousepressed(x, y, button, istouch, presses)
end

function Application:mousereleased(x, y, button, istouch, presses)
    self:make("input"):mousereleased(x, y, button)
    self:make("scenes"):mousereleased(x, y, button, istouch, presses)
end

function Application:wheelmoved(x, y)
    self:make("input"):wheelmoved(x, y)
    self:make("scenes"):wheelmoved(x, y)
end

function Application:touchpressed(id, x, y, dx, dy, pressure)
    self:make("scenes"):touchpressed(id, x, y, dx, dy, pressure)
end

function Application:touchmoved(id, x, y, dx, dy, pressure)
    self:make("scenes"):touchmoved(id, x, y, dx, dy, pressure)
end

function Application:touchreleased(id, x, y, dx, dy, pressure)
    self:make("scenes"):touchreleased(id, x, y, dx, dy, pressure)
end

function Application:gamepadpressed(j, b)  self:make("scenes"):gamepadpressed(j, b)  end
function Application:gamepadreleased(j, b) self:make("scenes"):gamepadreleased(j, b) end
function Application:gamepadaxis(j, a, v)  self:make("scenes"):gamepadaxis(j, a, v)  end

-- ---------------------------------------------------------------------------
-- Time helpers
-- ---------------------------------------------------------------------------
function Application:dt()       return self._dt   end
function Application:time()     return self._time end
function Application:fps()      return love.timer.getFPS() end

return Application
