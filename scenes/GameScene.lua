-- scenes/GameScene.lua — actual gameplay. Spawns a player, an enemy,
-- demonstrates the camera, input, and entity update loop. Replace
-- with your own mechanics.
local Scene = require("core.Scene")
local Player = require("Entities.Player")
local Enemy  = require("Entities.Enemy")
local Label  = require("UI.Label")
local Button = require("UI.Button")
local M = require("Utils.math")
local Color = require("Utils.color")

local GameScene = Scene:extend("GameScene")

function GameScene:enter()
    local w, h = love.graphics.getDimensions()
    self.player = Player:new(w / 2, h / 2, { w = 28, h = 28, speed = 240 })
    self.player.app = self.app

    self.enemies = {}
    for i = 1, 3 do
        local e = Enemy:new(100 + i * 200, 100 + (i % 2) * 200, { w = 24, h = 24, speed = 80 })
        e.app = self.app
        e:setTarget(self.player)
        table.insert(self.enemies, e)
    end

    self:save():set("game.lastScene", "GameScene")

    self:camera():follow(self.player)
    self:camera():zoom(1.2)

    self.score = 0
    self.ui = {
        scoreLabel = Label:new({
            x = 16, y = 12,
            text = "Score: 0",
            color = Color.WHITE,
        }),
        pauseButton = Button:new({
            x = w - 90, y = 10, w = 80, h = 32,
            text = "Pause",
            onClick = function() self:scenes():push("MenuScene") end,
            app = self.app,
        }),
    }

    self.app:on("enemy:killed", function(enemy)
        self.score = self.score + self:config():get("game.gameplay.scorePerKill", 100)
        self.ui.scoreLabel:setText("Score: " .. self.score)
    end)
end

function GameScene:exit()
    -- Detach listeners when leaving to avoid stacking across scene restarts.
    -- (For a one-shot enemy:killed handler, you can leave it; for menu reloads, do this.)
end

function GameScene:update(dt)
    self.player:update(dt)
    for _, e in ipairs(self.enemies) do e:update(dt) end

    -- Keep enemies alive; respawn on the edges if they die.
    for i, e in ipairs(self.enemies) do
        if not e:isAlive() then
            local w, h = love.graphics.getDimensions()
            local side = self:random():integer(1, 4)
            local nx, ny = 0, 0
            if side == 1 then nx, ny = 0, self:random():number(0, h)
            elseif side == 2 then nx, ny = w, self:random():number(0, h)
            elseif side == 3 then nx, ny = self:random():number(0, w), 0
            else nx, ny = self:random():number(0, w), h end
            local fresh = Enemy:new(nx, ny, { w = 24, h = 24, speed = 80 })
            fresh.app = self.app
            fresh:setTarget(self.player)
            self.enemies[i] = fresh
        end
    end
end

function GameScene:draw()
    self:camera():attach()
    self:_drawWorld()
    self:camera():detach()
    self:_drawHUD()
end

function GameScene:_drawWorld()
    love.graphics.setColor(0.12, 0.13, 0.18)
    local w, h = love.graphics.getDimensions()
    love.graphics.rectangle("fill", -w, -h, w * 4, h * 4)

    -- Some scenery (placeholder grid)
    love.graphics.setColor(1, 1, 1, 0.05)
    for x = -1000, 1000, 64 do
        love.graphics.line(x, -1000, x, 1000)
    end
    for y = -1000, 1000, 64 do
        love.graphics.line(-1000, y, 1000, y)
    end

    -- Player
    if self.player:isAlive() then
        love.graphics.setColor(0.4, 0.85, 1)
        love.graphics.circle("fill", self.player.x, self.player.y, self.player.w / 2)
    end

    -- Enemies
    love.graphics.setColor(1, 0.4, 0.4)
    for _, e in ipairs(self.enemies) do
        if e:isAlive() then
            love.graphics.circle("fill", e.x, e.y, e.w / 2)
        end
    end
end

function GameScene:_drawHUD()
    self.ui.scoreLabel:draw()
    self.ui.pauseButton:update(0)
    self.ui.pauseButton:draw()
end

function GameScene:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self:scenes():push("MenuScene")
    elseif key == "f1" then
        local cur = self:config():get("game.debug", false)
        self:config():set("game.debug", not cur)
    end
end

function GameScene:mousepressed(x, y, button)
    self.ui.pauseButton:mousepressed(x, y, button)
end

function GameScene:mousereleased(x, y, button)
    self.ui.pauseButton:mousereleased(x, y, button)
end

return GameScene
