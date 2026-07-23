-- Integration test: load the real MenuScene and verify enter() creates
-- 3 distinct buttons + a distinct title/hint. Stubs love2d globals.

-- ---- Stubs ----------------------------------------------------------------
love = {
    graphics = {
        getDimensions = function() return 1280, 720 end,
        setColor      = function() end,
        rectangle     = function() end,
        print         = function() end,
        getFont       = function() return { getWidth = function() return 50 end,
                                           getHeight = function() return 12 end } end,
        setFont       = function() end,
    },
    event = { quit = function() end },
}

-- Stub SceneManager: just record the replace call.
local replaced = {}
local fakeScenes = { replace = function(self, name) table.insert(replaced, name) end }

-- Stub app with only the surface MenuScene:enter() touches.
local fakeInput  = { mousePosition = function() return -1, -1 end, mouseDown = function() return false end }
local fakeLogger = { info = function() end }
local fakeApp = {
    scenes  = function() return fakeScenes end,
    input   = function() return fakeInput  end,
    logger  = function() return fakeLogger end,
}

-- ---- Boot the package path like main.lua does -----------------------------
package.path = table.concat({
    package.path,
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/core/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Services/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Entities/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/UI/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Utils/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/scenes/?.lua",
}, ";")

-- Stub the ServiceProvider / Config / Scheduler that scene requires don't
-- actually need, but BootScene does. MenuScene only requires core, UI, Panel.
local Scene   = require("core.Scene")
local Button  = require("UI.Button")
local Label   = require("UI.Label")
local Panel   = require("UI.Panel")
local MenuScene = require("scenes.MenuScene")

-- ---- Run ------------------------------------------------------------------
local scene = MenuScene:new("MenuScene", {})
scene:setApp(fakeApp)
scene:enter()

-- 1) Title and hint must be DIFFERENT objects.
assert(scene.title ~= scene.hint,    "FAIL: title and hint are the same Label instance")

-- 2) 3 distinct button instances.
local b1, b2, b3 = scene.buttons[1], scene.buttons[2], scene.buttons[3]
assert(b1 and b2 and b3, "FAIL: expected 3 buttons")
assert(b1 ~= b2 and b2 ~= b3 and b1 ~= b3, "FAIL: button instances are not distinct")

-- 3) Each button has its own y and text.
assert(b1.y == 200 and b1.text == "Play",    "FAIL: button 1 = y="..tostring(b1.y).." text="..tostring(b1.text))
assert(b2.y == 260 and b2.text == "Options", "FAIL: button 2 = y="..tostring(b2.y).." text="..tostring(b2.text))
assert(b3.y == 320 and b3.text == "Quit",    "FAIL: button 3 = y="..tostring(b3.y).." text="..tostring(b3.text))

-- 4) Title has the right text.
assert(scene.title.text == "i-love-boilerplate", "FAIL: title text = " .. tostring(scene.title.text))
assert(scene.hint.text:find("Press ESC"),        "FAIL: hint text = " .. tostring(scene.hint.text))

print("PASS  MenuScene creates 3 distinct buttons with correct positions")
print("PASS  Title and hint are different Label instances")
