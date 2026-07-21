--[[
    main.lua — entry point (analogous to public/index.php in Laravel).
    LÖVE loads this file by default. We bootstrap the Application
    and let it route every LÖVE callback to the appropriate service.
]]

-- ---------------------------------------------------------------------------
-- Module path setup
-- ---------------------------------------------------------------------------
-- Some LÖVE builds (notably `lovec` on certain Windows installs) report
-- a source base one level too high when given a relative path. We probe
-- multiple candidates and pick the first one that actually contains the
-- framework. This makes the project robust regardless of how it was
-- invoked.
local function fileExists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

local function setupPaths()
    local candidates = {}

    -- 1) LÖVE's own source base.
    local sb = love.filesystem.getSourceBaseDirectory()
    if sb then
        sb = sb:gsub("\\", "/"):gsub("/$", "")
        table.insert(candidates, sb)
        -- 1a) Sometimes `lovec .` reports the parent dir; try one level up.
        table.insert(candidates, sb .. "/..")
    end

    -- 2) Directory of main.lua (always correct in normal cases).
    local info = debug.getinfo(1, "S")
    if info and info.source then
        local src = info.source:sub(2) -- strip leading '@'
        src = src:gsub("\\", "/"):gsub("/main%.lua$", ""):gsub("/main$", "")
        if src and #src > 0 and src ~= sb then
            table.insert(candidates, src)
        end
    end

    -- 3) OS-level cwd (handles `lovec .` from a parent directory).
    local pipe = io.popen("cd")
    if pipe then
        local cwd = pipe:read("*l")
        pipe:close()
        if cwd and #cwd > 0 then
            cwd = cwd:gsub("\\", "/"):gsub("/$", "")
            table.insert(candidates, cwd)
            -- 3a) Convenience: if the cwd is the parent of a single
            -- project folder, point at it directly.
            if fileExists(cwd .. "/i-love-boilerplate/app/core/Application.lua") then
                table.insert(candidates, cwd .. "/i-love-boilerplate")
            end
        end
    end

    -- Pick the first candidate that actually has our framework file.
    local root = nil
    for _, candidate in ipairs(candidates) do
        if fileExists(candidate .. "/app/core/Application.lua") then
            root = candidate
            break
        end
    end
    if not root then root = sb or "." end

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
