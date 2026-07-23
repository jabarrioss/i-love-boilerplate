--[[
    SceneManager.lua — push/pop/swap/replace stack of active scenes.

    Most games use a single active scene (current), but a stack model
    supports overlays like pause menus and inventory screens without
    ripping the previous scene out.

        scenes:push("PauseScene")      -- overlay above current
        scenes:pop()                   -- close the overlay
        scenes:swap("GameOverScene")   -- replace top, no history kept
        scenes:replace("MenuScene")    -- clear stack, push this

    Scenes can be registered by class name in config/scenes.lua so the
    manager can require() them lazily.
]]

local Class = require("core.Class")

local SceneManager = Class:extend("SceneManager")

function SceneManager:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    instance._stack = {}
    instance._registry = {} -- name -> module path
    return instance
end

function SceneManager:boot()
    local cfg = self.app:config()
    for name, path in pairs(cfg:get("scenes.registry", {}) or {}) do
        self._registry[name] = path
    end
end

function SceneManager:register(name, modulePath)
    self._registry[name] = modulePath or ("scenes." .. name)
    return self
end

function SceneManager:resolve(name)
    local modPath = self._registry[name] or ("scenes." .. name)
    local ok, scene = pcall(require, modPath)
    if not ok then
        error("SceneManager:resolve('" .. name .. "') failed: " .. tostring(scene))
    end
    return scene
end

function SceneManager:current()
    return self._stack[#self._stack]
end

function SceneManager:stack()
    return self._stack
end

function SceneManager:push(name, opts)
    local scene = self:resolve(name)
    local instance = scene:new(name, opts or {})
    instance:setApp(self.app)
    local prev = self:current()
    table.insert(self._stack, instance)
    if prev and prev.pause then prev:pause() end
    if instance.enter then instance:enter(prev) end
    self.app:emit("scene:pushed", name, instance)
    return instance
end

function SceneManager:pop()
    local top = table.remove(self._stack)
    if not top then return nil end
    if top.exit then top:exit() end
    local new = self:current()
    if new and new.resume then new:resume() end
    self.app:emit("scene:popped", top.name, new)
    return top
end

function SceneManager:swap(name, opts)
    -- Replace the top scene without going through pause/resume.
    local top = table.remove(self._stack)
    if top and top.exit then top:exit() end
    local scene = self:resolve(name)
    local instance = scene:new(name, opts or {})
    instance:setApp(self.app)
    table.insert(self._stack, instance)
    if instance.enter then instance:enter(top) end
    self.app:emit("scene:swapped", name, instance)
    return instance
end

function SceneManager:replace(name, opts)
    -- Empty the stack and start fresh.
    while #self._stack > 0 do
        local s = table.remove(self._stack)
        if s and s.exit then s:exit() end
    end
    local scene = self:resolve(name)
    local instance = scene:new(name, opts or {})
    instance:setApp(self.app)
    table.insert(self._stack, instance)
    if instance.enter then instance:enter() end
    self.app:emit("scene:replaced", name, instance)
    return instance
end

function SceneManager:update(dt)
    for _, s in ipairs(self._stack) do
        if s.update then s:update(dt) end
    end
end

function SceneManager:draw()
    for _, s in ipairs(self._stack) do
        if s.draw then s:draw() end
    end
end

-- Forward input events to top of stack only.
function SceneManager:_top()
    return self:current()
end

function SceneManager:keypressed(...)    local s = self:_top(); if s and s.keypressed    then s:keypressed(...)    end end
function SceneManager:keyreleased(...)   local s = self:_top(); if s and s.keyreleased   then s:keyreleased(...)   end end
function SceneManager:textinput(...)     local s = self:_top(); if s and s.textinput     then s:textinput(...)     end end
function SceneManager:textedited(...)    local s = self:_top(); if s and s.textedited    then s:textedited(...)    end end
function SceneManager:mousemoved(...)    local s = self:_top(); if s and s.mousemoved    then s:mousemoved(...)    end end
function SceneManager:mousepressed(...)  local s = self:_top(); if s and s.mousepressed  then s:mousepressed(...)  end end
function SceneManager:mousereleased(...) local s = self:_top(); if s and s.mousereleased then s:mousereleased(...) end end
function SceneManager:wheelmoved(...)    local s = self:_top(); if s and s.wheelmoved    then s:wheelmoved(...)    end end
function SceneManager:touchpressed(...)  local s = self:_top(); if s and s.touchpressed  then s:touchpressed(...)  end end
function SceneManager:touchmoved(...)    local s = self:_top(); if s and s.touchmoved    then s:touchmoved(...)    end end
function SceneManager:touchreleased(...) local s = self:_top(); if s and s.touchreleased then s:touchreleased(...) end end
function SceneManager:gamepadpressed(...)  local s = self:_top(); if s and s.gamepadpressed  then s:gamepadpressed(...)  end end
function SceneManager:gamepadreleased(...) local s = self:_top(); if s and s.gamepadreleased then s:gamepadreleased(...) end end
function SceneManager:gamepadaxis(...)     local s = self:_top(); if s and s.gamepadaxis     then s:gamepadaxis(...)     end end
function SceneManager:resize(w, h)  local s = self:_top(); if s and s.resize  then s:resize(w, h) end end
function SceneManager:focus(f)     local s = self:_top(); if s and s.focus   then s:focus(f)     end end
function SceneManager:visible(v)   local s = self:_top(); if s and s.visible then s:visible(v)   end end

return SceneManager
