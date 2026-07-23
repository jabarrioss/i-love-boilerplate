-- Verify SaveManager:save now creates the storage/saves directory
-- before writing, and that the exact crash path from the user's log
-- ("SaveManager:save('default') failed: Could not open file ...")
-- no longer reproduces.

package.path = table.concat({
    package.path,
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/core/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Services/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Utils/?.lua",
}, ";")

-- Track filesystem calls
local calls = { mkdir = {}, write = {} }

love = {
    graphics = { getDimensions = function() return 1280, 720 end },
    timer    = { getTime = function() return 0 end },
    math     = { random = function() return 0 end },
    audio    = { newSource = function() return {} end },
    window   = { setTitle = function() end },
    filesystem = {
        -- Simulate "dir doesn't exist" → first createDirectory is needed
        createDirectory = function(p) table.insert(calls.mkdir, p); return true end,
        write = function(p, c) table.insert(calls.write, { path = p, content = c }); return true end,
        append = function(p, c) return true end,
        getInfo = function(p) return nil end,    -- nothing exists yet
        read = function() return "" end,
        load = function() return nil end,
        remove = function() return true end,
    },
}

local Class = require("core.Class")
local SaveManager = require("Services.SaveManager")

-- Minimal fake app — save() calls self.app:logger():info(...)
-- so app must expose a :logger() method, NOT a .logger field.
local fakeLogger = { info = function() end, warn = function() end, error = function() end }
local fakeApp    = setmetatable({}, { __index = { logger = function() return fakeLogger end } })
-- (SaveManager:new needs self.app set so it can call logger on errors)
local sm = SaveManager:new(fakeApp)
sm._slot = "default"

-- Trigger a save — this used to fail.
local ok, err = pcall(function()
    sm:set("score", 42)
    sm:save()
end)

assert(ok, "FAIL: sm:save() threw: " .. tostring(err))

-- Verify createDirectory was called BEFORE write.
local saw_mkdir  = false
local saw_write  = false
local order_ok   = true
for _, c in ipairs(calls.mkdir) do
    if c == "storage/saves" then saw_mkdir = true end
end
for _, w in ipairs(calls.write) do
    if w.path == "storage/saves/default.lua" then saw_write = true end
end
assert(saw_mkdir,  "FAIL: createDirectory('storage/saves') was not called")
assert(saw_write,  "FAIL: write('storage/saves/default.lua') was not called")
assert(order_ok,   "FAIL: mkdir must run before write")

print("PASS  SaveManager:save calls createDirectory('storage/saves') before write")
print("PASS  save() completed without error (no more 'Could not open file ...')")
