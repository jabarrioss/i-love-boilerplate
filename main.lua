--[[
    main.lua — entry point (analogous to public/index.php in Laravel).
    LÖVE loads this file by default. We bootstrap the Application
    and let it route every LÖVE callback to the appropriate service.
]]

-- ---------------------------------------------------------------------------
-- Module path setup
-- ---------------------------------------------------------------------------
local function setupPaths()
    local root = love.filesystem.getSourceBaseDirectory() or "."
    package.path = table.concat({
        package.path,
        root .. "/?.lua",
        root .. "/app/?.lua",
        root .. "/app/core/?.lua",
        root .. "/app/Services/?.lua",
        root .. "/app/Entities/?.lua",
        root .. "/app/UI/?.lua",
        root .. "/app/Utils/?.lua",
        root .. "/scenes/?.lua",
        root .. "/config/?.lua",
        root .. "/lib/?.lua",
        root .. "/lib/?/init.lua",
        root .. "/tests/?.lua",
    }, ";")
end
setupPaths()

-- ---------------------------------------------------------------------------
-- Boot the framework
-- ---------------------------------------------------------------------------
local Application = require("core.Application")
local app = Application:new()

-- Forward every LÖVE callback to the application. main.lua is intentionally
-- thin — all real work lives in app/* and scenes/*.
function love.load()
    app:boot()
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw()
end

function love.resize(w, h)
    app:resize(w, h)
end

function love.focus(f)
    app:focus(f)
end

function love.visible(v)
    app:visible(v)
end

function love.quit()
    return app:quit()
end

function love.keypressed(key, scancode, isrepeat)
    app:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    app:keyreleased(key, scancode)
end

function love.textedited(text, start, length)
    app:textedited(text, start, length)
end

function love.textinput(text)
    app:textinput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
    app:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
    app:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    app:mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    app:wheelmoved(x, y)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    app:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    app:touchmoved(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    app:touchreleased(id, x, y, dx, dy, pressure)
end

function love.gamepadpressed(joystick, button)
    app:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    app:gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
    app:gamepadaxis(joystick, axis, value)
end

function love.errorhandler(msg)
    app:error(msg)
end
