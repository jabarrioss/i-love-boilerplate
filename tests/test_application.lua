--[[
    tests/test_application.lua — integration test that boots the
    whole Application with a stubbed `love` global and verifies
    that every service can be resolved.

    This is the closest we can get to a LÖVE-runtime check without
    actually opening a window.
]]

local Test = require("tests.TestCase")

-- Spy table shared across tests that exercise the window title.
local TitleSpy = { value = nil }

-- Build a minimal `love` global so require()s during boot don't crash.
local function stubLove()
    local saved = {}
    for k, v in pairs(_G) do if k:sub(1, 4) == "love" then saved[k] = v end end

    _G.love = {
        graphics = {
            getDimensions = function() return 1280, 720 end,
            newImage      = function(p) return { _kind = "image", _path = p } end,
            newFont       = function(p, s) return { _kind = "font", _path = p, _size = s } end,
            setColor      = function() end,
            setBackgroundColor = function() end,
            rectangle     = function() end,
            circle        = function() end,
            print         = function() end,
            printf        = function() end,
            line          = function() end,
            draw          = function() end,
            push          = function() end,
            pop           = function() end,
            translate     = function() end,
            scale         = function() end,
            rotate        = function() end,
            getFont       = function() return { getWidth = function() return 8 end, getHeight = function() return 12 end } end,
            isActive      = function() return true end,
        },
        audio = {
            newSource = function(p, t) return { _kind = t or "static", _path = p, setVolume = function() end, setLooping = function() end, play = function() end, stop = function() end, isPlaying = function() return false end, clone = function(s) return s end, release = function() end } end,
        },
        filesystem = {
            getSourceBaseDirectory = function() return "." end,
            read  = function() return "return {}" end,
            write = function() return true end,
            append = function() return true end,
            load  = function(p) return loadstring("return {}") end,
            getInfo = function() return nil end,
            remove  = function() return true end,
        },
        timer    = { getDelta = function() return 0.016 end, getTime = function() return 0 end, getFPS = function() return 60 end, step = function() return 0 end },
        window   = { setMode = function() return true end, getMode = function() return 800, 600 end, getDimensions = function() return 1280, 720 end, setTitle = function(t) TitleSpy.value = t end, getTitle = function() return TitleSpy.value end },
        keyboard = { isDown = function() return false end, getKeyRepeat = function() return false end },
        mouse    = { isDown = function() return false end, getPosition = function() return 0, 0 end, isVisible = function() return true end },
        math     = { random = function(a, b) if a and b then return math.random(a, b) elseif a then return math.random() * a else return math.random() end end, setRandomSeed = function() end },
        event    = { pump = function() end, poll = function() return function() end end, quit = function() end },
        image    = {},
        sound    = {},
        font     = {},
        video    = {},
        joystick = {},
        touch    = {},
        thread   = {},
        system   = { getOS = function() return "Windows" end },
    }
    return saved
end

local function restoreLove(saved)
    for k, _ in pairs(_G) do if k:sub(1, 4) == "love" then _G[k] = nil end end
    for k, v in pairs(saved) do _G[k] = v end
end

-- Test class
local TestApplication = Test:extend("TestApplication")

function TestApplication:setUp()
    self.savedLove = stubLove()
    TitleSpy.value = nil
    package.loaded["Application"] = nil
    package.loaded["core.Application"] = nil
    -- Force re-require so the stubbed love is picked up.
    for k in pairs(package.loaded) do
        if k:sub(1, 4) == "core." or k:sub(1, 9) == "Services." or k:sub(1, 9) == "Entities." or k:sub(1, 3) == "UI." or k:sub(1, 6) == "Utils." or k:sub(1, 7) == "config." or k:sub(1, 6) == "scenes." then
            package.loaded[k] = nil
        end
    end
end

function TestApplication:tearDown()
    restoreLove(self.savedLove)
    for k in pairs(package.loaded) do
        if k:sub(1, 4) == "core." or k:sub(1, 9) == "Services." or k:sub(1, 9) == "Entities." or k:sub(1, 3) == "UI." or k:sub(1, 6) == "Utils." or k:sub(1, 7) == "config." or k:sub(1, 6) == "scenes." then
            package.loaded[k] = nil
        end
    end
end

function TestApplication:test_boot_creates_application()
    local Application = require("core.Application")
    local app = Application:new()
    self:assertNotNil(app)
end

function TestApplication:test_boot_resolves_all_services()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    -- Every service should be resolvable
    self:assertNotNil(app:make("config"))
    self:assertNotNil(app:make("logger"))
    self:assertNotNil(app:make("events"))
    self:assertNotNil(app:make("assets"))
    self:assertNotNil(app:make("input"))
    self:assertNotNil(app:make("audio"))
    self:assertNotNil(app:make("camera"))
    self:assertNotNil(app:make("save"))
    self:assertNotNil(app:make("random"))
    self:assertNotNil(app:make("easing"))
    self:assertNotNil(app:make("scheduler"))
    self:assertNotNil(app:make("scenes"))
end

function TestApplication:test_config_loaded_from_files()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    local config = app:config()
    self:assertNotNil(config:get("game"))
    self:assertNotNil(config:get("input"))
    self:assertNotNil(config:get("audio"))
    self:assertNotNil(config:get("scenes"))
    self:assertNotNil(config:get("app"))
end

function TestApplication:test_scenes_registered()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    local scenes = app:scenes()
    -- BootScene is registered in config/scenes.lua
    self:assertTrue(scenes:resolve("BootScene") ~= nil)
end

function TestApplication:test_push_and_pop_scene()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    local scenes = app:scenes()
    -- boot already pushed BootScene, clear it
    while scenes:current() do scenes:pop() end
    scenes:push("MenuScene")
    self:assertNotNil(scenes:current())
    self:assertEquals(scenes:current().name, "MenuScene")
    scenes:pop()
    self:assertNil(scenes:current())
end

function TestApplication:test_event_bus_works()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    local seen = 0
    app:on("test:event", function() seen = seen + 1 end)
    app:emit("test:event")
    app:emit("test:event")
    self:assertEquals(seen, 2)
end

function TestApplication:test_bind_and_make()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    app:bind("custom", { hello = "world" })
    local c = app:make("custom")
    self:assertEquals(c.hello, "world")
end

function TestApplication:test_window_title_applied_from_config()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    -- config/game.lua has `title = "i-love-boilerplate"` by default
    local expected = app:config():get("game.title")
    self:assertEquals(TitleSpy.value, expected)
end

function TestApplication:test_window_title_changes_with_config()
    local Application = require("core.Application")
    local app = Application:new()
    app:boot()
    -- Simulate a user editing config/game.lua
    app:config():set("game.title", "Pocket Dungeon")
    app:applyWindowConfig()
    self:assertEquals(TitleSpy.value, "Pocket Dungeon")
end

return TestApplication
