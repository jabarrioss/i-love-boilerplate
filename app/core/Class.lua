--[[
    Class.lua — minimal OOP base for the whole framework.

    Inspired by hump.class, YaciClass, and the @rxi/class Lua port.
    Provides single-inheritance with `super` access and `is` checks.

    Usage:
        local Animal = Class:extend("Animal")
        function Animal:new(name) self.name = name end
        function Animal:speak() return "..." end

        local Dog = Animal:extend("Dog")
        function Dog:new(name) Dog.super.new(self, name); self.bone = 1 end
        function Dog:speak() return self.name .. " says woof" end

        local d = Dog:new("Rex")
        d:speak()       -- "Rex says woof"
        d:is(Dog)       -- true
        d:is(Animal)    -- true
]]

local Class = {}
Class.__index = Class

function Class:extend(name)
    local cls = setmetatable({}, { __index = self, __call = function(c, ...) return c:new(...) end })
    cls.__index      = cls
    cls.__tostring   = function() return "Class<" .. (name or "?") .. ">" end
    cls.super        = self
    cls.className    = name
    setmetatable(cls, { __index = self, __call = cls })
    return cls
end

function Class:new(...)
    -- The default constructor is a no-op. Subclasses should override.
    return setmetatable({}, self)
end

function Class:is(other)
    -- Walk from self's class up the hierarchy looking for `other`.
    -- Works for both instances and class tables.
    local node = self
    while type(node) == "table" do
        if node == other then return true end
        local mt = getmetatable(node)
        if not mt then return false end
        if mt == other then return true end
        node = mt.__index
    end
    return false
end

function Class:instanceof(other)
    return self:is(other)
end

-- Static helper: copy fields from one or more tables into target.
function Class.mixin(target, ...)
    for _, src in ipairs({ ... }) do
        if type(src) == "table" then
            for k, v in pairs(src) do target[k] = v end
        end
    end
    return target
end

return Class
