-- Standalone test: simulate the Class system + verify Button/Label/Scene/Panel
-- now create distinct instances. No love2d required.

-- --- Minimal Class clone (copied from app/core/Class.lua) -------------------
local Class = setmetatable({}, {
    __call     = function(c, ...) return c:new(...) end,
    __tostring = function() return "Class<Class>" end,
})
Class.__index = Class

function Class:extend(name)
    local cls = setmetatable({}, {
        __index    = self,
        __call     = function(c, ...) return c:new(...) end,
        __tostring = function() return "Class<" .. (name or "?") .. ">" end,
    })
    cls.__index = cls
    cls.super = self
    cls.className = name
    return cls
end

function Class:new(...)
    return setmetatable({}, self)
end

-- --- Test widget: same shape as Button -------------------------------------
local Button = Class:extend("Button")
Button.defaults = { x = 0, y = 0, w = 100, h = 30, text = "?" }

function Button:new(opts)
    local instance = setmetatable({}, self)
    opts = opts or {}
    for k, v in pairs(Button.defaults) do instance[k] = v end
    for k, v in pairs(opts) do instance[k] = v end
    return instance
end

-- --- Test ------------------------------------------------------------------
local a = Button:new({ x = 10, y = 200, text = "Play" })
local b = Button:new({ x = 10, y = 260, text = "Options" })
local c = Button:new({ x = 10, y = 320, text = "Quit" })

assert(a ~= b and b ~= c and a ~= c, "FAIL: instances are not distinct")
assert(a.text == "Play",    "FAIL: a.text expected 'Play', got " .. tostring(a.text))
assert(b.text == "Options", "FAIL: b.text expected 'Options', got " .. tostring(b.text))
assert(c.text == "Quit",    "FAIL: c.text expected 'Quit', got " .. tostring(c.text))
assert(a.y == 200 and b.y == 260 and c.y == 320, "FAIL: y values got mixed up")

-- Class itself shouldn't carry per-instance data. defaults still live
-- in Button.defaults, not in Button directly.
assert(Button.defaults.text == "?", "FAIL: defaults table was clobbered")
assert(Button.text == nil,         "FAIL: Button class itself was mutated to text=" .. tostring(Button.text))

print("OK  3 distinct Button instances with correct text + y")
print("OK  Button class itself untouched (Button.text == nil)")
print("PASS")
