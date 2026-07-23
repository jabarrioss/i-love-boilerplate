-- Reproduce the original bug: "attempt to call method 'zoom' (a number value)".
-- After the fix, Camera:new must return a real instance and :zoom must still
-- be a callable method on it.

package.path = table.concat({
    package.path,
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/core/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Services/?.lua",
    "C:/Users/Crystal/Documents/games/i-love-boilerplate/app/Utils/?.lua",
}, ";")

-- Stub love2d just enough for Camera:new to read screen dimensions.
love = {
    graphics = { getDimensions = function() return 1280, 720 end },
    math     = { random = function(a, b) return a or 0 end },
}

local Camera = require("Services.Camera")

-- 1) Two separate instantiations → two distinct instances.
local a = Camera:new({})
local b = Camera:new({})
assert(a ~= b,            "FAIL: Camera instances are not distinct")
assert(a.x == 640 and b.x == 640, "FAIL: starting x not centered")

-- 2) Setting zoom on 'a' must NOT leak into 'b' or the class itself.
a:zoom(2.0)
assert(a._zoom == 2.0,           "FAIL: a._zoom = " .. tostring(a._zoom))
assert(b._zoom == 1.0,           "FAIL: b._zoom leaked = " .. tostring(b._zoom))
assert(type(Camera.zoom) == "function",
       "FAIL: Camera.zoom was overwritten with " .. type(Camera.zoom) .. " (the original bug)")

-- 3) Smoke: the exact call from GameScene.lua:29 must work.
local c = Camera:new({})
c:follow({ x = 100, y = 200 })
c:zoom(1.2)
assert(c._zoom == 1.2, "FAIL: c._zoom = " .. tostring(c._zoom))
assert(c:zoom() == 1.2, "FAIL: c:zoom() getter returned " .. tostring(c:zoom()))
assert(c.following.x == 100 and c.following.y == 200, "FAIL: follow lost target")

print("PASS  Camera:zoom is a real method, not a number")
print("PASS  Two Camera instances are independent")
print("PASS  GameScene's call pattern (follow + zoom) works end-to-end")
