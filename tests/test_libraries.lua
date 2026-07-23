--[[
    tests/test_libraries.lua — sanity check that every bundled
    third-party library can be required and exposes its expected
    top-level API. Doesn't test deep behavior (the upstream
    libraries have their own test suites) — just confirms the
    libraries are present, loadable, and roughly what we expect.
]]

local Test = require("tests.TestCase")

local TestLibraries = Test:extend("TestLibraries")

local function setupPath()
    local cwd = io.popen("cd"):read("*l") or "."
    cwd = cwd:gsub("\\", "/"):gsub("/$", "")
    package.path = table.concat({
        package.path,
        cwd .. "/?.lua",
        cwd .. "/lib/?.lua",
        cwd .. "/lib/?/init.lua",
    }, ";")
end

function TestLibraries:setUp()
    setupPath()
end

function TestLibraries:test_bump_loaded()
    local bump = require("bump")
    self:assertEquals(type(bump.newWorld), "function")
    -- bump's collision methods live on the world object, not the module.
    local world = bump.newWorld(64)
    self:assertNotNil(world)
    self:assertEquals(type(world.add), "function")
    self:assertEquals(type(world.queryRect), "function")
    self:assertEquals(type(world.queryPoint), "function")
    self:assertEquals(type(world.update), "function")
    self:assertEquals(type(world.remove), "function")
    self:assertEquals(type(world.project), "function")
    -- Functional sanity: add a rect, query a point
    world:add("a", 0, 0, 10, 10)
    local hits = world:queryRect(0, 0, 5, 5)
    self:assertNotNil(hits)
end

function TestLibraries:test_anim8_loaded()
    local anim8 = require("anim8")
    self:assertEquals(type(anim8.newAnimation), "function")
    self:assertEquals(type(anim8.newGrid), "function")
end

function TestLibraries:test_flux_loaded()
    local flux = require("flux")
    self:assertEquals(type(flux.to), "function")
    self:assertEquals(type(flux.update), "function")
    self:assertEquals(type(flux.remove), "function")
end

function TestLibraries:test_inspect_loaded()
    -- inspect is a module; the function is `inspect.inspect`
    local inspect = require("inspect")
    self:assertEquals(type(inspect), "table")
    self:assertEquals(type(inspect.inspect), "function")
    local s = inspect.inspect({ a = 1, b = "hi" })
    self:assertTrue(s:find("a = 1") ~= nil)
    self:assertTrue(s:find('b = "hi"') ~= nil)
end

function TestLibraries:test_lume_loaded()
    local lume = require("lume")
    self:assertEquals(type(lume.serialize), "function")
    self:assertEquals(type(lume.deserialize), "function")
    self:assertEquals(type(lume.random), "function")
    self:assertEquals(type(lume.clamp), "function")
    self:assertEquals(type(lume.lerp), "function")
    self:assertEquals(lume.clamp(5, 0, 10), 5)
    self:assertEquals(lume.clamp(-3, 0, 10), 0)
    self:assertApprox(lume.lerp(0, 100, 0.5), 50, 1e-6)
end

function TestLibraries:test_classic_loaded()
    local Classic = require("Classic")
    self:assertEquals(type(Classic.extend), "function")
    self:assertEquals(type(Classic.is), "function")
    -- Classic uses colon-syntax for extend, and () instead of :new().
    -- The constructor is the `new` method (not `init`).
    local Animal = Classic:extend()
    function Animal:new(name) self.name = name end
    function Animal:speak() return "..." end
    local Dog = Animal:extend()
    function Dog:speak() return self.name .. " says woof" end
    local d = Dog("Rex")
    self:assertEquals(d.name, "Rex")
    self:assertEquals(d:speak(), "Rex says woof")
end

function TestLibraries:test_hump_vector_loaded()
    local Vector = require("hump.vector")
    self:assertNotNil(Vector)
    local v = Vector(3, 4)
    self:assertApprox(v:len(), 5, 1e-6)
    -- hump's vector method is `normalized` (returns a new vec) or
    -- `normalizeInplace` (mutates). Use the safe one.
    local u = v:normalized()
    self:assertApprox(u:len(), 1, 1e-6)
end

function TestLibraries:test_hump_timer_loaded()
    local Timer = require("hump.timer")
    self:assertNotNil(Timer)
    self:assertEquals(type(Timer.new), "function")
    self:assertEquals(type(Timer.after), "function")
    self:assertEquals(type(Timer.every), "function")
    self:assertEquals(type(Timer.update), "function")
    self:assertEquals(type(Timer.clear), "function")
end

function TestLibraries:test_hump_signal_loaded()
    local Signal = require("hump.signal")
    self:assertNotNil(Signal)
    self:assertEquals(type(Signal.register), "function")
    self:assertEquals(type(Signal.emit), "function")
    self:assertEquals(type(Signal.remove), "function")
    -- Quick functional check
    local seen = 0
    local id = Signal.register("ping", function() seen = seen + 1 end)
    Signal.emit("ping")
    Signal.emit("ping")
    Signal.remove("ping", id)
    Signal.emit("ping")  -- should not fire after removal
    self:assertEquals(seen, 2)
end

function TestLibraries:test_hump_class_loaded()
    local Class = require("hump.class")
    self:assertNotNil(Class)
    self:assertEquals(type(Class.new), "function")
    self:assertEquals(type(Class.include), "function")
    -- Functional: create a class with a method
    local Greeter = Class.new()
    function Greeter:init(name) self.name = name end
    function Greeter:greet() return "Hi, " .. self.name end
    local g = Greeter("World")
    self:assertEquals(g.name, "World")
    self:assertEquals(g:greet(), "Hi, World")
end

function TestLibraries:test_lib_index_loaded()
    local libs = require("lib")
    self:assertNotNil(libs.bump)
    self:assertNotNil(libs.anim8)
    self:assertNotNil(libs.flux)
    self:assertNotNil(libs.inspect)
    self:assertNotNil(libs.lume)
    self:assertNotNil(libs.Classic)
    self:assertNotNil(libs.hump)
    self:assertNotNil(libs.hump.vector)
    self:assertNotNil(libs.hump.timer)
    self:assertNotNil(libs.hump.camera)
end

return TestLibraries
