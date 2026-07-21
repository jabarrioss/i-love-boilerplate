--[[
    Entities/Player.lua — example player entity.

    Demonstrates how to layer input + camera + entity. Replace the
    sprite/control scheme with whatever your game needs.
]]

local Entity = require("Entities.Entity")
local InputManager = require("Services.InputManager")

local Player = Entity:extend("Player")

Player.SPEED = 240

function Player:new(x, y, opts)
    Player.super.new(self, x, y, opts or {})
    self.tag     = "player"
    self.speed   = opts and opts.speed or Player.SPEED
    self.accel   = 1500
    self.friction = 0.85
    return self
end

function Player:update(dt)
    if not self.alive then return end
    local input = self.app:input()
    local ax, ay = 0, 0
    if input:down("moveLeft")  then ax = ax - 1 end
    if input:down("moveRight") then ax = ax + 1 end
    if input:down("moveUp")    then ay = ay - 1 end
    if input:down("moveDown")  then ay = ay + 1 end
    local len = math.sqrt(ax * ax + ay * ay)
    if len > 0 then
        ax, ay = ax / len, ay / len
        self.vx = self.vx + ax * self.accel * dt
        self.vy = self.vy + ay * self.accel * dt
    else
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction
    end
    -- clamp to max speed
    local sp = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    if sp > self.speed then
        self.vx = self.vx / sp * self.speed
        self.vy = self.vy / sp * self.speed
    end
    Player.super.update(self, dt)
end

return Player
