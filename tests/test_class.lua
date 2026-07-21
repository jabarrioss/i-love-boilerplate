-- tests/test_class.lua — smoke tests for core.Class.
local Test = require("tests.TestCase")
local Class = require("core.Class")

local Animal = Class:extend("Animal")
function Animal:new(name) self.name = name; return self end
function Animal:speak() return "..." end

local Dog = Animal:extend("Dog")
function Dog:new(name) Dog.super.new(self, name); self.bone = 1; return self end
function Dog:speak() return self.name .. " woofs" end

local TestClass = Test:extend("TestClass")

function TestClass:test_extend_returns_subclass()
    self:assertEquals(Dog.className, "Dog")
end

function TestClass:test_subclass_calls_parent_constructor()
    local d = Dog:new("Rex")
    self:assertEquals(d.name, "Rex")
    self:assertEquals(d.bone, 1)
end

function TestClass:test_method_override()
    local d = Dog:new("Rex")
    self:assertEquals(d:speak(), "Rex woofs")
end

function TestClass:test_is_relationship()
    local d = Dog:new("Rex")
    self:assertTrue(d:is(Dog))
    self:assertTrue(d:is(Animal))
    -- Every class in this framework transitively extends Class.
    self:assertTrue(d:is(Class))
    -- Unrelated classes should still return false.
    local Unrelated = Class:extend("Unrelated")
    self:assertFalse(d:is(Unrelated))
end

function TestClass:test_mixin()
    local target = {}
    Class.mixin(target, { a = 1 }, { b = 2 })
    self:assertEquals(target.a, 1)
    self:assertEquals(target.b, 2)
end

return TestClass
