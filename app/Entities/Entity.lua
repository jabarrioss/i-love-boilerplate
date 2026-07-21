--[[
    Entities/Entity.lua — base class for any game object that has a
    position, velocity, dimensions, and needs to participate in
    update/draw cycles.

    Extend it freely:

        local Bullet = Entity:extend("Bullet")
        function Bullet:new(x, y, dir)
            Bullet.super.new(self, x, y, { w = 8, h = 8, speed = 400 })
            self.vx = math.cos(dir) * self.speed
            self.vy = math.sin(dir) * self.speed
        end

    The base update() applies velocity, the base draw() is a placeholder
    (you'll override for sprites). Collision bounds are kept as a
    helper that returns AABB.
]]

local Class = require("core.Class")
local M = require("Utils.math")

local Entity = Class:extend("Entity")

function Entity:new(x, y, opts)
    opts = opts or {}
    self.x       = x or 0
    self.y       = y or 0
    self.vx      = opts.vx or 0
    self.vy      = opts.vy or 0
    self.w       = opts.w or 16
    self.h       = opts.h or 16
    self.angle   = opts.angle or 0
    self.speed   = opts.speed or 0
    self.alive   = opts.alive ~= false
    self.solid   = opts.solid ~= false
    self.tag     = opts.tag or "entity"
    self.color   = opts.color
    self.image   = opts.image
    self.ox      = opts.ox or 0  -- origin offset for drawing
    self.oy      = opts.oy or 0
    self.scaleX  = opts.scaleX or 1
    self.scaleY  = opts.scaleY or 1
    return self
end

function Entity:update(dt)
    if not self.alive then return end
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Entity:draw()
    if not self.alive then return end
    if self.image then
        love.graphics.draw(
            self.image, self.x, self.y, self.angle,
            self.scaleX, self.scaleY,
            self.ox, self.oy
        )
    else
        love.graphics.rectangle("line", self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
    end
end

function Entity:kill()
    self.alive = false
    return self
end

function Entity:isAlive()
    return self.alive
end

function Entity:bounds()
    return self.x - self.w / 2, self.y - self.h / 2, self.w, self.h
end

function Entity:center()
    return self.x, self.y
end

function Entity:moveBy(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
    return self
end

function Entity:moveTo(x, y)
    self.x = x
    self.y = y
    return self
end

function Entity:setVelocity(vx, vy)
    self.vx, self.vy = vx, vy
    return self
end

function Entity:overlaps(other)
    local ax, ay, aw, ah = self:bounds()
    local bx, by, bw, bh = other:bounds()
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

function Entity:distanceTo(other)
    return M.distance(self.x, self.y, other.x, other.y)
end

function Entity:angleTo(other)
    return M.angleTo(self.x, self.y, other.x, other.y)
end

return Entity
