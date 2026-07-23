--[[
    tests/TestCase.lua — base class for a single test file.

    Each file returns a TestCase subclass whose methods starting with
    "test_" are run by the runner. Use the assertion helpers to
    produce useful error output.

    Example:
        local Test = require("tests.TestCase")
        local Math = Test:extend("Math")

        function Math:test_clamp()
            self:assertEquals(Util.clamp(5, 0, 10), 5)
            self:assertEquals(Util.clamp(-3, 0, 10), 0)
        end

        return Math
]]

local Class = require("core.Class")

local TestCase = Class:extend("TestCase")

function TestCase:new(runner)
    -- Build a fresh instance with the class as its metatable, then
    -- initialize per-test counters on the instance. (Earlier versions
    -- did `self.runner = runner` directly, which mutated the *class*
    -- because `self` in a `Class:new` is the class itself — every test
    -- then shared the same counters, and the runner had to keep
    -- indirecting through getmetatable to find any test methods.)
    local inst = setmetatable({}, self)
    inst.runner  = runner
    inst.passed  = 0
    inst.failed  = 0
    inst.errors  = {}
    return inst
end

function TestCase:setUp()    end
function TestCase:tearDown() end

function TestCase:_runMethod(name, fn)
    self:setUp()
    local ok, err = pcall(fn, self)
    if not ok then
        self.failed = self.failed + 1
        table.insert(self.errors, { name = name, message = tostring(err) })
        self.runner:reportFailure(self, name, tostring(err))
    else
        self.passed = self.passed + 1
        self.runner:reportSuccess(self, name)
    end
    self:tearDown()
end

function TestCase:run()
    -- Walk the class chain from the most-derived class up to (but not
    -- including) TestCase itself. For each class, run any test_*
    -- methods we haven't already seen. We use `seen` so a subclass
    -- that overrides a parent's test gets the override, not both.
    local seen = {}
    local node = getmetatable(self)        -- the most-derived class
    while node and node ~= TestCase do
        for name, method in pairs(node) do
            if type(method) == "function"
               and name:sub(1, 5) == "test_"
               and not seen[name] then
                seen[name] = true
                self:_runMethod(name, method)
            end
        end
        local mt = getmetatable(node)
        node = mt and mt.__index or nil     -- parent class
    end
    return self
end

-- Assertions -----------------------------------------------------------

function TestCase:assertTrue(cond, msg)
    if cond ~= true then error(msg or "expected true, got " .. tostring(cond), 2) end
end

function TestCase:assertFalse(cond, msg)
    if cond ~= false then error(msg or "expected false, got " .. tostring(cond), 2) end
end

function TestCase:assertNil(value, msg)
    if value ~= nil then error(msg or "expected nil, got " .. tostring(value), 2) end
end

function TestCase:assertNotNil(value, msg)
    if value == nil then error(msg or "expected non-nil value", 2) end
end

function TestCase:assertEquals(actual, expected, msg)
    if actual ~= expected then
        error(msg or ("expected %s, got %s"):format(tostring(expected), tostring(actual)), 2)
    end
end

function TestCase:assertNotEquals(actual, unexpected, msg)
    if actual == unexpected then
        error(msg or ("expected value not equal to %s"):format(tostring(unexpected)), 2)
    end
end

function TestCase:assertDeepEquals(actual, expected, msg)
    local function deepEq(a, b)
        if type(a) ~= type(b) then return false end
        if type(a) ~= "table" then return a == b end
        for k, v in pairs(a) do if not deepEq(v, b[k]) then return false end end
        for k in pairs(b) do if a[k] == nil then return false end end
        return true
    end
    if not deepEq(actual, expected) then
        error(msg or "values are not deeply equal", 2)
    end
end

function TestCase:assertApprox(actual, expected, eps, msg)
    eps = eps or 1e-6
    if math.abs(actual - expected) > eps then
        error(msg or ("expected ~%s, got %s"):format(tostring(expected), tostring(actual)), 2)
    end
end

function TestCase:assertError(fn, msg)
    local ok = pcall(fn)
    if ok then error(msg or "expected error, got none", 2) end
end

function TestCase:assertNoError(fn, msg)
    local ok, err = pcall(fn)
    if not ok then error(msg or ("unexpected error: " .. tostring(err)), 2) end
end

function TestCase:assertMatch(s, pattern, msg)
    if type(s) ~= "string" or not s:find(pattern) then
        error(msg or ("expected '%s' to match '%s'"):format(tostring(s), tostring(pattern)), 2)
    end
end

return TestCase
