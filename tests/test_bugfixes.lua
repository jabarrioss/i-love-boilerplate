--[[
    tests/test_bugfixes.lua — regression tests for the issues fixed in
    the bug-bash pass. Each test_* method maps to one bug.

    The runner expects a single TestCase subclass per file, so this
    file declares multiple `local ... = Test:extend(...)` blocks at
    module scope and returns one outer class whose test_* methods
    instantiate and run them.
]]

local Test   = require("tests.TestCase")
local Class  = require("core.Class")
local Entity = require("Entities.Entity")

-- Stub love for services that touch it.
local function stubLove()
    local saved = {}
    for k, v in pairs(_G) do if k:sub(1, 4) == "love" then saved[k] = v end end
    _G.love = {
        graphics = {
            getDimensions = function() return 1280, 720 end,
            newImage      = function(p) return { _kind = "image", _path = p } end,
            newFont       = function(p, s) return { _kind = "font", _path = p } end,
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
        audio = { newSource = function(p, t) return { _kind = t or "static", setVolume = function() end, setLooping = function() end, play = function() end, stop = function() end, isPlaying = function() return false end, clone = function(s) return s end, release = function() end } end },
        filesystem = { getSourceBaseDirectory = function() return "." end, read = function() return "return {}" end, write = function() return true end, append = function() return true end, load = function(p) return loadstring("return {}") end, getInfo = function() return nil end, remove = function() return true end },
        timer    = { getDelta = function() return 0.016 end, getTime = function() return 0 end, getFPS = function() return 60 end, step = function() return 0 end },
        window   = { setMode = function() return true end, getMode = function() return 800, 600 end, getDimensions = function() return 1280, 720 end, setTitle = function() end, getTitle = function() return "" end },
        keyboard = { isDown = function() return false end, getKeyRepeat = function() return false end },
        mouse    = { isDown = function() return false end, getPosition = function() return 0, 0 end, isVisible = function() return true end },
        math     = { random = function(a, b) if a and b then return math.random(a, b) elseif a then return math.random() * a else return math.random() end end, setRandomSeed = function() end },
        event    = { pump = function() end, poll = function() return function() end end, quit = function() end },
        image = {}, sound = {}, font = {}, video = {}, joystick = {}, touch = {}, thread = {},
        system = { getOS = function() return "Windows" end },
    }
    return saved
end

local function clearRequireCache()
    for k in pairs(package.loaded) do
        if k:sub(1, 4) == "core." or k:sub(1, 9) == "Services."
        or k:sub(1, 9) == "Entities." or k:sub(1, 3) == "UI."
        or k:sub(1, 6) == "Utils." or k:sub(1, 7) == "config."
        or k:sub(1, 6) == "scenes." then
            package.loaded[k] = nil
        end
    end
end

-- -----------------------------------------------------------------------
-- Bug 2: Class() and MyClass(args) used to fail / infinite-recurse
-- because Class:extend set `__call = cls`. They should call :new(args).
-- -----------------------------------------------------------------------
local TestClassCall = Test:extend("TestClassCall")

function TestClassCall:test_base_class_call_returns_instance()
    local inst = Class()
    self:assertNotNil(inst)
    self:assertTrue(getmetatable(inst) == Class)
end

function TestClassCall:test_subclass_call_invokes_new()
    local Foo = Class:extend("FooCallTest")
    function Foo:new(x) self.x = x or 42; return self end

    local a = Foo()
    self:assertEquals(a.x, 42)

    local b = Foo(7)
    self:assertEquals(b.x, 7)
end

-- -----------------------------------------------------------------------
-- Bug 1: input:pressed() must be readable from a scene's update(),
-- meaning the clear must happen AFTER scenes:update(), not before.
-- -----------------------------------------------------------------------
local TestInputPressedTiming = Test:extend("TestInputPressedTiming")

function TestInputPressedTiming:setUp()
    self.saved = stubLove()
    clearRequireCache()
    self.Application = require("core.Application")
    self.app = self.Application:new()
    self.app:boot()
    self.input = self.app:input()
    -- Reset bindings so the test isn't affected by config/input.lua
    -- (which also binds "space" to "confirm"). We pick a key that no
    -- built-in action uses, to make the test independent of config.
    self.input._bindings = {}
    self.input._pressed = {}
    self.input._released = {}
    self.input._held = {}
    self.input._justPressed = {}
    self.input:defineAction("jump", { "f12" })
    while self.app:scenes():current() do self.app:scenes():pop() end
    self.app:scenes():register("Probe", "tests.ProbeScene")
    self.ProbeScene = require("tests.ProbeScene")
    self.ProbeScene.recorder = nil
end

function TestInputPressedTiming:tearDown()
    if self.ProbeScene then self.ProbeScene.recorder = nil end
    for k, _ in pairs(_G) do if k:sub(1, 4) == "love" then _G[k] = nil end end
    for k, v in pairs(self.saved) do _G[k] = v end
    clearRequireCache()
end

function TestInputPressedTiming:test_pressed_visible_in_scene_update()
    local result
    self.ProbeScene.recorder = function(scene, dt)
        result = scene:input():pressed("jump")
    end
    self.app:scenes():push("Probe")

    self.input:handleKey("pressed", "f12", "f12", false)
    self.app:update(0.016)

    self:assertTrue(result == true,
        ("expected scene's :update() to see input:pressed('jump') = true on the same frame, got %s"):format(tostring(result)))
end

function TestInputPressedTiming:test_pressed_clears_next_frame()
    local frames = {}
    self.ProbeScene.recorder = function(scene, dt)
        table.insert(frames, scene:input():pressed("jump"))
    end
    self.app:scenes():push("Probe")

    self.input:handleKey("pressed", "f12", "f12", false)
    self.app:update(0.016)   -- frame 1
    self.app:update(0.016)   -- frame 2
    self.app:update(0.016)   -- frame 3

    self:assertTrue(frames[1] == true,
        ("frame 1 should see pressed=true, got %s"):format(tostring(frames[1])))
    self:assertTrue(frames[2] == false,
        ("frame 2 should see pressed=false, got %s"):format(tostring(frames[2])))
    self:assertTrue(frames[3] == false,
        ("frame 3 should see pressed=false, got %s"):format(tostring(frames[3])))
end

-- -----------------------------------------------------------------------
-- Bug 5: Entity must expose setApp so subclasses (Player, Enemy) don't
-- have to know to assign self.app = self.app from outside.
-- -----------------------------------------------------------------------
local TestEntitySetApp = Test:extend("TestEntitySetApp")

function TestEntitySetApp:test_setApp_stores_app_and_returns_self()
    local e = Entity:new(0, 0)
    self:assertNil(e.app)
    local fakeApp = { name = "fake" }
    local result = e:setApp(fakeApp)
    self:assertEquals(e.app, fakeApp)
    self:assertEquals(result, e)
end

-- -----------------------------------------------------------------------
-- Bug 6: TestCase.run() must walk the class chain (not just pairs(self))
-- and not run the same test_ method twice.
-- -----------------------------------------------------------------------
local TestTestCaseRun = Test:extend("TestTestCaseRun")

function TestTestCaseRun:test_runs_inherited_tests_exactly_once()
    local base = Test:extend("InheritBase")
    function base:test_inherited() self._seen = (self._seen or 0) + 1 end
    function base:test_own()      self._ownCount = (self._ownCount or 0) + 1 end

    local child = base:extend("InheritChild")
    function child:test_own()     self._ownOverride = (self._ownOverride or 0) + 1 end

    local runner = { reportSuccess = function() end, reportFailure = function() end }
    local inst = child:new(runner)
    inst:run()

    self:assertEquals(inst._seen, 1,         "inherited test should run once")
    self:assertEquals(inst._ownCount, nil,   "overridden test should NOT call parent")
    self:assertEquals(inst._ownOverride, 1,  "subclass override should run once")
    self:assertEquals(inst.passed, 2)
end

-- -----------------------------------------------------------------------
-- Single outer class: instantiate each of the above, run them, and
-- copy their counts into the outer instance so the runner reports one
-- combined pass/fail line for this file.
-- -----------------------------------------------------------------------
local TestBugfixes = Test:extend("TestBugfixes")

function TestBugfixes:test_class_call()
    local inst = TestClassCall:new({ reportSuccess = function() end, reportFailure = function() end })
    inst:run()
    self:assertEquals(inst.failed, 0, "Class call bugs regressed")
end

function TestBugfixes:test_input_pressed_timing()
    local inst = TestInputPressedTiming:new({ reportSuccess = function() end, reportFailure = function() end })
    inst:setUp(); inst:run(); inst:tearDown()
    if inst.failed > 0 then
        for _, e in ipairs(inst.errors) do
            io.stderr:write(("    [inner] %s: %s\n"):format(e.name, e.message))
        end
    end
    self:assertEquals(inst.failed, 0, "Input pressed timing regressed")
end

function TestBugfixes:test_entity_set_app()
    local inst = TestEntitySetApp:new({ reportSuccess = function() end, reportFailure = function() end })
    inst:run()
    self:assertEquals(inst.failed, 0, "Entity setApp regressed")
end

function TestBugfixes:test_testcase_run()
    local inst = TestTestCaseRun:new({ reportSuccess = function() end, reportFailure = function() end })
    inst:run()
    self:assertEquals(inst.failed, 0, "TestCase.run regressed")
end

return TestBugfixes
