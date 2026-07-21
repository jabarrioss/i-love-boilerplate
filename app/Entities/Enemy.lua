--[[
    Entities/Enemy.lua — example enemy that chases the player.
]]

local Entity = require("Entities.Entity")

local Enemy = Entity:extend("Enemy")

Enemy.SPEED = 80

function Enemy:new(x, y, opts)
    Enemy.super.new(self, x, y, opts or {})
    self.tag    = "enemy"
    self.speed  = opts and opts.speed or Enemy.SPEED
    self.target = nil
    self.health = opts and opts.health or 1
    return self
end

function Enemy:setTarget(target)
    self.target = target
    return self
end

function Enemy:update(dt)
    if not self.alive then return end
    if self.target and self.target:isAlive() then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local d  = math.sqrt(dx * dx + dy * dy)
        if d > 0 then
            self.vx = (dx / d) * self.speed
            self.vy = (dy / d) * self.speed
        end
    end
    Enemy.super.update(self, dt)
end

function Enemy:damage(amount)
    self.health = self.health - (amount or 1)
    if self.health <= 0 then
        self:kill()
        self.app:emit("enemy:killed", self)
    end
    return self
end

return Enemy
