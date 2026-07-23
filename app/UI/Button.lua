--[[
    UI/Button.lua — clickable label with hover and press states.
]]

local Class = require("core.Class")
local Color = require("Utils.color")

local Button = Class:extend("Button")

Button.defaults = {
    x = 0, y = 0, w = 220, h = 48,
    text = "Button",
    font = nil,
    onClick = function() end,
    align = "center",   -- "left" | "center" | "right"
    padding = 12,
    colors = {
        idle    = { r = 0.18, g = 0.18, b = 0.22, a = 0.9 },
        hover   = { r = 0.25, g = 0.25, b = 0.30, a = 0.95 },
        pressed = { r = 0.10, g = 0.10, b = 0.14, a = 1.0  },
        text    = { r = 1,    g = 1,    b = 1,    a = 1    },
        border  = { r = 0.6,  g = 0.6,  b = 0.7,  a = 0.8  },
    },
}

function Button:new(opts)
    local instance = setmetatable({}, self)
    opts = opts or {}
    for k, v in pairs(Button.defaults) do instance[k] = v end
    for k, v in pairs(opts) do instance[k] = v end
    instance.hovered = false
    instance.pressed = false
    return instance
end

function Button:update(dt)
    local input = self.app and self.app:input()
    if not input then return end
    local mx, my = input:mousePosition()
    self.hovered = mx >= self.x and mx <= self.x + self.w
                and my >= self.y and my <= self.y + self.h
    if self.hovered and input:mouseDown(1) then
        if not self.pressed then
            self.pressed = true
        end
    elseif not input:mouseDown(1) then
        if self.pressed and self.hovered and self.onClick then
            self.onClick()
        end
        self.pressed = false
    end
end

function Button:draw()
    local bg
    if self.pressed then bg = self.colors.pressed
    elseif self.hovered then bg = self.colors.hover
    else bg = self.colors.idle end
    Color.loveSet(bg)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 6, 6)
    Color.loveSet(self.colors.border)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 6, 6)

    if self.font then love.graphics.setFont(self.font) end
    Color.loveSet(self.colors.text)
    local textW = (self.font or love.graphics.getFont()):getWidth(self.text)
    local textH = (self.font or love.graphics.getFont()):getHeight()
    local tx
    if self.align == "left" then tx = self.x + self.padding
    elseif self.align == "right" then tx = self.x + self.w - self.padding - textW
    else tx = self.x + (self.w - textW) / 2 end
    local ty = self.y + (self.h - textH) / 2
    love.graphics.print(self.text, tx, ty)
end

function Button:mousepressed(x, y, button)
    if button == 1 and self:_contains(x, y) then
        self.pressed = true
    end
end

function Button:mousereleased(x, y, button)
    if button == 1 and self.pressed and self:_contains(x, y) then
        if self.onClick then self.onClick() end
    end
    self.pressed = false
end

function Button:_contains(x, y)
    return x >= self.x and x <= self.x + self.w
       and y >= self.y and y <= self.y + self.h
end

return Button
