-- scenes/MenuScene.lua — main menu with three buttons.
local Scene = require("core.Scene")
local Button = require("UI.Button")
local Label  = require("UI.Label")
local Panel  = require("UI.Panel")

local MenuScene = Scene:extend("MenuScene")

function MenuScene:enter()
    local w, h = love.graphics.getDimensions()
    self.title = Label:new({
        x = w / 2, y = 80,
        text = "i-love-boilerplate",
        align = "center",
        color = { r = 1, g = 1, b = 1, a = 1 },
    })
    local cx = w / 2
    self.buttons = {
        Button:new({ x = cx - 110, y = 200, w = 220, h = 48,
            text = "Play",
            onClick = function() self:scenes():replace("GameScene") end,
            app = self.app,
        }),
        Button:new({ x = cx - 110, y = 260, w = 220, h = 48,
            text = "Options",
            onClick = function() self:logger():info("Options not implemented") end,
            app = self.app,
        }),
        Button:new({ x = cx - 110, y = 320, w = 220, h = 48,
            text = "Quit",
            onClick = function() love.event.quit() end,
            app = self.app,
        }),
    }
    self.hint = Label:new({
        x = w / 2, y = h - 40,
        text = "Press ESC to pause  •  F1 to toggle debug overlay",
        align = "center",
        color = { r = 1, g = 1, b = 1, a = 0.55 },
    })
end

function MenuScene:exit() end

function MenuScene:update(dt)
    for _, b in ipairs(self.buttons) do b:update(dt) end
end

function MenuScene:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.07, 0.08, 0.10)
    love.graphics.rectangle("fill", 0, 0, w, h)
    self.title:draw()
    for _, b in ipairs(self.buttons) do b:draw() end
    self.hint:draw()
end

function MenuScene:mousepressed(x, y, button)
    for _, b in ipairs(self.buttons) do b:mousepressed(x, y, button) end
end

function MenuScene:mousereleased(x, y, button)
    for _, b in ipairs(self.buttons) do b:mousereleased(x, y, button) end
end

function MenuScene:keypressed(key, scancode, isrepeat)
    if key == "return" or key == "space" then
        self:scenes():replace("GameScene")
    elseif key == "escape" then
        love.event.quit()
    end
end

return MenuScene
