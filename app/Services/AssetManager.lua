--[[
    AssetManager.lua — central registry for images, sounds, music, and fonts.

    Use once at boot to declare what the game needs, then reference by name:

        assets:load("image", "player", "assets/images/player.png")
        assets:load("sound", "hit",   "assets/sounds/hit.wav")
        assets:load("font",  "title", "assets/fonts/title.ttf", 32)
        assets:load("music", "theme", "assets/music/theme.ogg")

        playerImg = assets:get("image", "player")
        titleFont = assets:get("font", "title")

    Loading is async-friendly: pass { async = true } for non-blocking loads.
]]

local Class = require("core.Class")

local AssetManager = Class:extend("AssetManager")

function AssetManager:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    instance._buckets = {
        image = {},
        sound = {},
        music = {},
        font  = {},
        data  = {},
        video = {},
    }
    instance._pendingLoads = 0
    return instance
end

local function loadImage(path)           return love.graphics.newImage(path) end
local function loadSound(path)           return love.audio.newSource(path, "static") end
local function loadMusic(path)           return love.audio.newSource(path, "stream") end
local function loadFont(path, size)      return love.graphics.newFont(path, size) end
local function loadData(path)            return love.filesystem.read(path) end

local LOADERS = {
    image = { fn = loadImage,  needsSize = false },
    sound = { fn = loadSound,  needsSize = false },
    music = { fn = loadMusic,  needsSize = false },
    font  = { fn = loadFont,   needsSize = true  },
    data  = { fn = loadData,   needsSize = false },
    video = { fn = function(p) return love.graphics.newVideo(p) end, needsSize = false },
}

function AssetManager:load(kind, name, path, size, opts)
    opts = opts or {}
    local def = LOADERS[kind]
    if not def then error("AssetManager:load — unknown kind '" .. tostring(kind) .. "'") end
    if self._buckets[kind][name] then
        self.app:logger():warn("AssetManager: '%s.%s' reloaded", kind, name)
    end
    local bucket = self._buckets[kind]

    local function doLoad()
        local ok, asset = pcall(def.fn, path, def.needsSize and size or nil)
        if not ok then
            self.app:logger():error("AssetManager: failed to load %s '%s' from %s: %s",
                kind, name, path, tostring(asset))
            return
        end
        bucket[name] = asset
    end

    if opts.async then
        self._pendingLoads = self._pendingLoads + 1
        -- Lua coroutine-free async: schedule on next frame
        if self.app and self.app:scheduler() then
            self.app:scheduler():nextFrame(function()
                doLoad()
                self._pendingLoads = self._pendingLoads - 1
            end)
        else
            doLoad()
        end
    else
        doLoad()
    end
    return self
end

function AssetManager:get(kind, name)
    return self._buckets[kind] and self._buckets[kind][name] or nil
end

function AssetManager:has(kind, name)
    return self:get(kind, name) ~= nil
end

function AssetManager:unload(kind, name)
    local asset = self:get(kind, name)
    if asset then
        if kind == "image" and asset.release then pcall(asset.release, asset) end
        if (kind == "sound" or kind == "music") and asset.release then pcall(function() asset:stop() asset:release() end) end
        if kind == "video" and asset.release then pcall(asset.release, asset) end
        self._buckets[kind][name] = nil
    end
    return self
end

function AssetManager:unloadAll()
    for kind, bucket in pairs(self._buckets) do
        for name in pairs(bucket) do self:unload(kind, name) end
    end
    return self
end

function AssetManager:isReady()
    return self._pendingLoads == 0
end

return AssetManager
