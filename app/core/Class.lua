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

local Class
-- Class itself is a "root" — no parent to inherit from above. We only
-- install __call (so `Class()` works as a constructor shortcut) and
-- __tostring. Subclasses get their own metatable via Class:extend.
Class = setmetatable({}, {
    __call     = function(c, ...) return c:new(...) end,
    __tostring = function() return "Class<Class>" end,
})
Class.__index = Class    -- own field; instances created via setmetatable({}, Class)
                          -- will resolve field lookups starting here

function Class:extend(name)
    -- Two pieces are important here:
    --
    --   1. The metatable's __index is `self` (the parent class), so lookups
    --      on the class fall through to inherited methods.
    --   2. `cls.__index` is set as an OWN field on the class (not the
    --      metatable). When an instance is constructed with
    --      `setmetatable({}, cls)`, the class's __index becomes the
    --      instance's lookup chain — so instance lookups start at `cls`
    --      before walking up to the parent.
    --
    -- The metatable also installs a __call so `MyClass(...)` is shorthand
    -- for `MyClass:new(...)`. This must be a function (not the class
    -- itself), otherwise calling it would invoke the class's __call again
    -- and recurse forever.
    local cls = setmetatable({}, {
        __index    = self,
        __call     = function(c, ...) return c:new(...) end,
        __tostring = function() return "Class<" .. (name or "?") .. ">" end,
    })
    cls.__index   = cls
    cls.super     = self
    cls.className = name
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
