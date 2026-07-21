--[[
    UI/Label.lua — single line of text with a position and color.
]]

local Class = require("core.Class")
local Color = require("Utils.color")

local Label = Class:extend("Label")

function Label:new(opts)
    opts = opts or {}
    self.x       = opts.x or 0
    self.y       = opts.y or 0
    self.text    = opts.text or ""
    self.font    = opts.font
    self.color   = opts.color or Color.WHITE
    self.align   = opts.align or "left"   -- "left" | "center" | "right"
    self.anchorX = opts.anchorX or 0      -- 0..1 in screen space if you use it later
    self.anchorY = opts.anchorY or 0
    return self
end

function Label:setText(text)
    self.text = tostring(text)
    return self
end

function Label:draw()
    if self.font then love.graphics.setFont(self.font) end
    Color.loveSet(self.color)
    if self.align == "left" then
        love.graphics.print(self.text, self.x, self.y)
    else
        local w = (self.font or love.graphics.getFont()):getWidth(self.text)
        if self.align == "center" then
            love.graphics.print(self.text, self.x - w / 2, self.y)
        elseif self.align == "right" then
            love.graphics.print(self.text, self.x - w, self.y)
        end
    end
end

return Label
