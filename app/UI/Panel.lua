--[[
    UI/Panel.lua — rectangle background that can hold child widgets.

    Children get update/draw called on them in order. Layout is manual
    — this is intentional. Use the panel to group related buttons,
    labels, or custom widgets, and pass their absolute positions
    to the children.
]]

local Class = require("core.Class")
local Color = require("Utils.color")

local Panel = Class:extend("Panel")

function Panel:new(opts)
    local instance = setmetatable({}, self)
    opts = opts or {}
    instance.x      = opts.x or 0
    instance.y      = opts.y or 0
    instance.w      = opts.w or 200
    instance.h      = opts.h or 100
    instance.color  = opts.color or { r = 0, g = 0, b = 0, a = 0.6 }
    instance.border = opts.border or { r = 1, g = 1, b = 1, a = 0.3 }
    instance.radius = opts.radius or 4
    instance.children = opts.children or {}
    return instance
end

function Panel:add(child)
    table.insert(self.children, child)
    return self
end

function Panel:update(dt)
    for _, c in ipairs(self.children) do
        if c.update then c:update(dt) end
    end
end

function Panel:draw()
    Color.loveSet(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)
    Color.loveSet(self.border)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)
    for _, c in ipairs(self.children) do
        if c.draw then c:draw() end
    end
end

return Panel
