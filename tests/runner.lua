--[[
    tests/runner.lua — discover and run every test file in tests/.

    Usage:
        lua tests/runner.lua                  # run everything
        lua tests/runner.lua test_class       # run a specific file
        lua tests/runner.lua -v               # verbose

    Tests must be Lua files that return a TestCase subclass (extend
    tests.TestCase). All `test_*` methods are discovered and run.

    Exits with code 0 on success, 1 on failure (suitable for CI).
]]

local args = { ... }
local verbose = false
local filter  = nil
for _, a in ipairs(args) do
    if a == "-v" or a == "--verbose" then verbose = true
    elseif a:sub(1, 1) ~= "-" then filter = a end
end

-- Set up package path so the runner can require app/* and tests/* the
-- same way main.lua does.
package.path = package.path
    .. ";./?.lua;./app/?.lua;./app/core/?.lua;./app/Services/?.lua"
    ..  ";./app/Entities/?.lua;./app/UI/?.lua;./app/Utils/?.lua"
    ..  ";./scenes/?.lua;./config/?.lua;./lib/?.lua;./lib/?/init.lua;./tests/?.lua"

local TestCase = require("tests.TestCase")

-- Minimal harness with reporter hooks used by TestCase
local Runner = {}
Runner.__index = Runner
function Runner:new() return setmetatable({ files = {}, start = os.clock() }, self) end
function Runner:reportSuccess(_, name) if verbose then print(("  ✓ %s"):format(name)) end end
function Runner:reportFailure(_, name, err) print(("  ✗ %s: %s"):format(name, tostring(err))) end

local function discoverTests()
    local results = {}
    local p = io.popen('dir /b /a-d "tests" 2>NUL')
    if not p then return results end
    for filename in p:lines() do
        if filename:match("^test_.*%.lua$") and filename ~= "TestCase.lua" and filename ~= "runner.lua" then
            table.insert(results, "tests." .. filename:gsub("%.lua$", ""))
        end
    end
    p:close()
    return results
end

local tests = filter and { filter:match("^tests?%.") and filter or "tests." .. filter } or discoverTests()

if #tests == 0 then
    print("No test files found.")
    os.exit(0)
end

local runner = Runner:new()
local totalPassed, totalFailed = 0, 0
local totalElapsed = 0

for _, modName in ipairs(tests) do
    print(("Running %s ..."):format(modName))
    local ok, mod = pcall(require, modName)
    if not ok then
        print(("  ! could not load: %s"):format(tostring(mod)))
        totalFailed = totalFailed + 1
    else
        local instance = mod:new(runner)
        if not instance:is(TestCase) then
            print("  ! not a TestCase subclass")
            totalFailed = totalFailed + 1
        else
            local t0 = os.clock()
            instance:run()
            totalElapsed = totalElapsed + (os.clock() - t0)
            totalPassed = totalPassed + instance.passed
            totalFailed = totalFailed + instance.failed
        end
    end
end

print(("\n%d passed, %d failed (%.2fs)"):format(totalPassed, totalFailed, totalElapsed))
if totalFailed > 0 then os.exit(1) end
os.exit(0)
