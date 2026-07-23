--[[
    InputManager.lua — keyboard, mouse, and gamepad abstraction with bindings.

    Bindings live in config/input.lua:

        bindings = {
            jump     = "space",
            moveLeft = "left",
            moveRight = "right",
            attack   = { "mouse1", "g" },
            pause    = "escape",
        }

    Use as:
        input:bindPressed("jump", function() player:jump() end)
        input:on("pause", function() self:scenes():push("PauseScene") end)
        if input:down("moveLeft") then player.x = player.x - 200 * dt end

    Polling vs events: bindPressed is event-style (one call per press);
    :down() is poll-style (true every frame the key is held).
]]

local Class = require("core.Class")

local InputManager = Class:extend("InputManager")

function InputManager:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    instance._bindings = {}      -- action -> { key1, key2, ... }
    instance._pressed  = {}      -- action -> [fn, fn, ...]
    instance._released = {}      -- action -> [fn, fn, ...]
    instance._held     = {}      -- action -> bool (polled in update)
    instance._justPressed = {}  -- action -> bool (true for one frame)
    instance._mouseX, instance._mouseY = 0, 0
    instance._mouseDown = {}     -- button (1/2/3) -> bool
    instance._consumed = false   -- if a global binding handled the key, stop routing
    return instance
end

function InputManager:boot()
    -- Pull bindings from config
    local cfg = self.app:config()
    for action, keys in pairs(cfg:get("input.bindings", {}) or {}) do
        if type(keys) == "string" then
            self:defineAction(action, { keys })
        elseif type(keys) == "table" then
            self:defineAction(action, keys)
        end
    end
end

function InputManager:defineAction(action, keys)
    self._bindings[action] = {}
    if type(keys) == "string" then keys = { keys } end
    for _, k in ipairs(keys) do
        self._bindings[action][k] = true
    end
    return self
end

function InputManager:bindPressed(action, fn)
    self._pressed[action] = self._pressed[action] or {}
    table.insert(self._pressed[action], fn)
    return self
end

function InputManager:bindReleased(action, fn)
    self._released[action] = self._released[action] or {}
    table.insert(self._released[action], fn)
    return self
end

function InputManager:on(action, fn)
    return self:bindPressed(action, fn)
end

-- True while the action is held (poll-style).
function InputManager:down(action)
    return self._held[action] == true
end

-- True for the single frame the action was pressed.
function InputManager:pressed(action)
    return self._justPressed[action] == true
end

function InputManager:_actionForKey(key)
    for action, map in pairs(self._bindings) do
        if map[key] then return action end
    end
    return nil
end

-- Return true to indicate the key was consumed (don't forward to scenes).
function InputManager:handleKey(phase, key, scancode, isrepeat)
    if isrepeat then return false end
    local action = self:_actionForKey(key)
    if not action then return false end
    if phase == "pressed" then
        self._held[action] = true
        self._justPressed[action] = true
        if self._pressed[action] then
            for _, fn in ipairs(self._pressed[action]) do
                local ok, err = pcall(fn, key, scancode)
                if not ok then
                    self.app:logger():error("Input binding '%s' error: %s", action, tostring(err))
                end
            end
        end
        return true
    elseif phase == "released" then
        self._held[action] = false
        if self._released[action] then
            for _, fn in ipairs(self._released[action]) do
                local ok, err = pcall(fn, key, scancode)
                if not ok then
                    self.app:logger():error("Input binding '%s' error: %s", action, tostring(err))
                end
            end
        end
        return true
    end
    return false
end

function InputManager:update(dt)
    -- Clear "just pressed" so each press is visible for exactly one frame.
    -- IMPORTANT: Application:update() intentionally calls this AFTER
    -- scenes:update(), so a scene can still read `input:pressed("jump")`
    -- during its own :update() on the same frame the key was pressed.
    self._justPressed = {}
end

function InputManager:mousemoved(x, y, dx, dy, istouch)
    self._mouseX, self._mouseY = x, y
end

function InputManager:mousepressed(x, y, button)
    self._mouseDown[button] = true
end

function InputManager:mousereleased(x, y, button)
    self._mouseDown[button] = false
end

function InputManager:wheelmoved(x, y) end

function InputManager:mousePosition()
    return self._mouseX, self._mouseY
end

function InputManager:mouseDown(button)
    return self._mouseDown[button or 1] == true
end

return InputManager
