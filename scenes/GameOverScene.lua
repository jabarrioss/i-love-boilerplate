-- scenes/GameOverScene.lua — overlays at the end of a run. Press
-- Enter to return to the menu or R to restart.
local Scene = require("core.Scene")
local Button = require("UI.Button")
local Label  = require("UI.Label")
local Color  = require("Utils.color")

local GameOverScene = Scene:extend("GameOverScene")

function GameOverScene:enter()
    local w, h = love.graphics.getDimensions()
    self.title = Label:new({
        x = w / 2, y = 120,
        text = "Game Over",
        align = "center",
        color = { r = 1, g = 0.6, b = 0.6, a = 1 },
    })
    self.hint = Label:new({
        x = w / 2, y = 200,
        text = "Press ENTER to return to the menu  •  R to retry",
        align = "center",
        color = { r = 1, g = 1, b = 1, a = 0.7 },
    })
    self.menuButton = Button:new({
        x = w / 2 - 110, y = 280, w = 220, h = 48,
        text = "Main Menu",
        onClick = function() self:scenes():replace("MenuScene") end,
        app = self.app,
    })
    self.retryButton = Button:new({
        x = w / 2 - 110, y = 340, w = 220, h = 48,
        text = "Retry",
        onClick = function() self:scenes():replace("GameScene") end,
        app = self.app,
    })
end

function GameOverScene:update(dt)
    self.menuButton:update(dt)
    self.retryButton:update(dt)
end

function GameOverScene:draw()
    local w, h = love.graphics.getDimensions()
    Color.loveSet({ r = 0, g = 0, b = 0, a = 0.7 })
    love.graphics.rectangle("fill", 0, 0, w, h)
    self.title:draw()
    self.hint:draw()
    self.menuButton:draw()
    self.retryButton:draw()
end

function GameOverScene:keypressed(key)
    if key == "return" then self:scenes():replace("MenuScene")
    elseif key == "r"  then self:scenes():replace("GameScene") end
end

function GameOverScene:mousepressed(x, y, button)
    self.menuButton:mousepressed(x, y, button)
    self.retryButton:mousepressed(x, y, button)
end

function GameOverScene:mousereleased(x, y, button)
    self.menuButton:mousereleased(x, y, button)
    self.retryButton:mousereleased(x, y, button)
end

return GameOverScene
