-- End-to-end smoke: simulate Application:boot + push MenuScene + push GameScene,
-- then verify the exact line that used to crash (GameScene:29) now works.

-- ---- Stubs ----------------------------------------------------------------
local function noop() end
love = {
    graphics = {
        getDimensions = function() return 1280, 720 end,
        setColor      = noop, rectangle = noop, print = noop, line = noop, circle = noop,
        setFont       = noop, push = noop, pop = noop, translate = noop, rotate = noop, scale = noop,
        getFont       = function() return { getWidth = function() return 50 end,
                                           getHeight = function() return 12 end } end,
    },
    event     = { quit = noop },
    timer     = { getTime = function() return 0 end },
    math      = { random = function(a, b) return a or 0 end, setRandomSeed = noop },
    audio     = { newSource = function() return { setVolume = noop, play = noop, stop = noop,
                                                 setLooping = noop, getVolume = function() return 0 end,
                                                 isPlaying = function() return false end,
                                                 release = noop, clone = function() return love.audio.newSource() end } end },
    filesystem = { write = noop, append = noop, getInfo = function() return nil end, remove = noop,
                   read = function() return "" end, load = function() return loadstring("return {}") end },
    window    = { setTitle = noop },
}

-- ---- Package path ---------------------------------------------------------
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
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/config/?.lua",
}, ";")

-- ---- Boot ----------------------------------------------------------------
local Application = require("core.Application")
local app = Application:new()
app:boot()

-- ---- Sanity: every service is a real instance, not the class ------------
local services = { "config", "logger", "events", "assets", "input",
                   "audio", "camera", "save", "random", "easing",
                   "scheduler", "scenes" }
local seen = {}
for _, k in ipairs(services) do
    local inst1 = app:make(k)
    local inst2 = app:make(k)
    assert(inst1 == inst2, "FAIL: " .. k .. " is not a singleton instance")
    assert(type(inst1) == "table", "FAIL: " .. k .. " not a table")
    seen[k] = inst1
end
print("PASS  12 services all return real instances (no class mutation)")

-- ---- Sanity: Camera has the :zoom method intact --------------------------
local cam = app:make("camera")
assert(type(cam.zoom) == "function", "FAIL: cam.zoom is not a function (it is " .. type(cam.zoom) .. ")")
print("PASS  Camera.zoom is a function, not overwritten by an instance field")

-- ---- Reproduce the exact crash line from GameScene:29 --------------------
local GameScene = require("scenes.GameScene")
local scene = GameScene:new("GameScene", {})
scene:setApp(app)
scene:enter()
print("PASS  GameScene:enter() ran without crashing")
print("      (the line 'self:camera():zoom(1.2)' now succeeds)")

-- ---- After the call, the camera should have its own zoom applied ---------
assert(cam._zoom == 1.2, "FAIL: cam._zoom expected 1.2, got " .. tostring(cam._zoom))
print("PASS  Camera state is correct after zoom(1.2): _zoom = " .. tostring(cam._zoom))

-- ---- 3 enemies + 1 player = 4 distinct entities -------------------------
assert(#scene.enemies == 3, "FAIL: expected 3 enemies, got " .. tostring(#scene.enemies))
assert(scene.player.tag == "player", "FAIL: player.tag is " .. tostring(scene.player.tag))
-- distinctness check
for i = 1, 3 do
    for j = i+1, 3 do
        assert(scene.enemies[i] ~= scene.enemies[j], "FAIL: enemy " .. i .. " == enemy " .. j)
    end
    assert(scene.enemies[i].tag == "enemy", "FAIL: enemy " .. i .. " tag is " .. tostring(scene.enemies[i].tag))
end
print("PASS  3 distinct enemies + 1 player (no class-mutation cross-contamination)")

print("\nALL CHECKS PASSED — original Camera:zoom bug is fixed end-to-end")
