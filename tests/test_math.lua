-- tests/test_math.lua — tests for app/Utils/math.lua
local Test = require("tests.TestCase")
local M = require("Utils.math")

local TestMath = Test:extend("TestMath")

function TestMath:test_clamp()
    self:assertEquals(M.clamp(5, 0, 10), 5)
    self:assertEquals(M.clamp(-3, 0, 10), 0)
    self:assertEquals(M.clamp(99, 0, 10), 10)
end

function TestMath:test_lerp()
    self:assertApprox(M.lerp(0, 100, 0.5), 50)
    self:assertApprox(M.lerp(0, 100, 0), 0)
    self:assertApprox(M.lerp(0, 100, 1), 100)
end

function TestMath:test_distance()
    self:assertApprox(M.distance(0, 0, 3, 4), 5)
    self:assertApprox(M.distance(0, 0, 0, 0), 0)
end

function TestMath:test_sign()
    self:assertEquals(M.sign(5), 1)
    self:assertEquals(M.sign(-5), -1)
    self:assertEquals(M.sign(0), 0)
end

function TestMath:test_remap()
    self:assertApprox(M.remap(5, 0, 10, 0, 100), 50)
    self:assertApprox(M.remap(0, 0, 10, 0, 100), 0)
    self:assertApprox(M.remap(10, 0, 10, 0, 100), 100)
end

function TestMath:test_vec2Normalize()
    local x, y, l = M.vec2Normalize(3, 4)
    self:assertApprox(l, 5)
    self:assertApprox(x, 0.6)
    self:assertApprox(y, 0.8)
end

return TestMath
