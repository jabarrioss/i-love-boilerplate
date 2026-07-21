--[[
    Utils/color.lua — color utilities. LÖVE colors are {r,g,b,a} in 0..1.
]]

local M = {}

function M.rgb(r, g, b, a)
    return { r = r / 255, g = g / 255, b = b / 255, a = a or 1 }
end

function M.lerp(c1, c2, t)
    return {
        r = c1.r + (c2.r - c1.r) * t,
        g = c1.g + (c2.g - c1.g) * t,
        b = c1.b + (c2.b - c1.b) * t,
        a = c1.a + (c2.a - c1.a) * t,
    }
end

function M.toLove(c)
    return c.r, c.g, c.b, c.a
end

function M.loveSet(c)
    love.graphics.setColor(c.r, c.g, c.b, c.a)
    return c
end

-- Common named colors
M.WHITE     = { r = 1,   g = 1,   b = 1,   a = 1 }
M.BLACK     = { r = 0,   g = 0,   b = 0,   a = 1 }
M.RED       = { r = 1,   g = 0,   b = 0,   a = 1 }
M.GREEN     = { r = 0,   g = 1,   b = 0,   a = 1 }
M.BLUE      = { r = 0,   g = 0,   b = 1,   a = 1 }
M.YELLOW    = { r = 1,   g = 1,   b = 0,   a = 1 }
M.CYAN      = { r = 0,   g = 1,   b = 1,   a = 1 }
M.MAGENTA   = { r = 1,   g = 0,   b = 1,   a = 1 }
M.GRAY      = { r = 0.5, g = 0.5, b = 0.5, a = 1 }
M.TRANSPARENT = { r = 0,  g = 0,   b = 0,   a = 0 }

return M
