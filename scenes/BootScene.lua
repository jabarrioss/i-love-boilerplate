-- scenes/BootScene.lua — runs once at startup. Loads assets, then
-- transitions to the menu.
local Scene = require("core.Scene")

local BootScene = Scene:extend("BootScene")

function BootScene:enter()
    self.elapsed = 0
    self.minTime = 0.4 -- avoid a flash if loading is instant
    self:loadAssets()
end

function BootScene:loadAssets()
    local assets = self:assets()
    local cfg = self:config()

    for name, spec in pairs(cfg:get("audio.images", {}) or {}) do
        if type(spec) == "string" then
            assets:load("image", name, spec)
        elseif type(spec) == "table" then
            assets:load("image", name, spec[1])
        end
    end
    for name, spec in pairs(cfg:get("audio.sounds", {}) or {}) do
        if type(spec) == "string" then
            assets:load("sound", name, spec)
        end
    end
    for name, spec in pairs(cfg:get("audio.music", {}) or {}) do
        if type(spec) == "string" then
            assets:load("music", name, spec)
        end
    end
    for name, spec in pairs(cfg:get("audio.fonts", {}) or {}) do
        if type(spec) == "table" then
            assets:load("font", name, spec[1], spec[2])
        end
    end
end

function BootScene:update(dt)
    self.elapsed = self.elapsed + dt
    if self.elapsed < self.minTime then return end
    if not self:assets():isReady() then return end
    self:scenes():replace("MenuScene")
end

function BootScene:draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.07, 0.08, 0.10)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("Loading...", 0, h / 2 - 8, w, "center")
end

return BootScene
