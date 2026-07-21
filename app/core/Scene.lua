--[[
    Scene.lua — base class for game states (menu, gameplay, game over, etc.).

    A scene is a self-contained state. The SceneManager keeps a stack of
    them: push/pop for modal flows, swap for instant transitions, replace
    to clear the stack.

    Override only what you need. The default implementations are no-ops
    so empty scenes are valid.

    Lifecycle (in order):
        :new()          -- constructed (rarely called directly)
        :enter(prev)    -- pushed onto the stack
        :exit()         -- popped off the stack
        :pause()        -- covered by another scene
        :resume()       -- uncovered
        :update(dt)
        :draw()
        ...
]]

local Class = require("core.Class")

local Scene = Class:extend("Scene")

function Scene:new(name, opts)
    self.name = name or "Scene"
    self.app  = nil
    self.opts = opts or {}
    self.alive = true
    return self
end

function Scene:setApp(app)
    self.app = app
    return self
end

-- Convenience accessors
function Scene:scenes()    return self.app:scenes()   end
function Scene:assets()    return self.app:assets()   end
function Scene:input()     return self.app:input()    end
function Scene:audio()     return self.app:audio()    end
function Scene:camera()    return self.app:camera()   end
function Scene:save()      return self.app:save()     end
function Scene:logger()    return self.app:logger()   end
function Scene:config()    return self.app:config()   end
function Scene:random()    return self.app:random()   end
function Scene:scheduler() return self.app:scheduler() end

-- Lifecycle hooks — override in subclasses
function Scene:enter(prev) end
function Scene:exit()      end
function Scene:pause()     end
function Scene:resume()    end

-- Frame hooks
function Scene:update(dt)  end
function Scene:draw()      end

-- Input hooks (forwarded by SceneManager)
function Scene:keypressed(key, scancode, isrepeat) end
function Scene:keyreleased(key, scancode) end
function Scene:textinput(text) end
function Scene:textedited(text, start, length) end
function Scene:mousemoved(x, y, dx, dy, istouch) end
function Scene:mousepressed(x, y, button, istouch, presses) end
function Scene:mousereleased(x, y, button, istouch, presses) end
function Scene:wheelmoved(x, y) end
function Scene:touchpressed(id, x, y, dx, dy, pressure) end
function Scene:touchmoved(id, x, y, dx, dy, pressure) end
function Scene:touchreleased(id, x, y, dx, dy, pressure) end
function Scene:gamepadpressed(joystick, button) end
function Scene:gamepadreleased(joystick, button) end
function Scene:gamepadaxis(joystick, axis, value) end

-- Window hooks
function Scene:resize(w, h) end
function Scene:focus(focused) end
function Scene:visible(v) end

return Scene
