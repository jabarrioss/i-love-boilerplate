-- config/assets.lua — declares every asset the game wants to load
-- at boot. Edit this file to add/remove assets.
--
-- The BootScene reads these declarations and asks the AssetManager
-- to load them. After load, access them by name from any scene:
--
--     local playerImg = self:assets():get("image", "player")
--     local titleFont = self:assets():get("font", "title")
--
-- Each entry is either a path string, or a table of { path, ...opts }
-- for asset kinds that need extra info (currently fonts need a size).
return {
    images = {
        -- player   = "assets/images/player.png",
        -- enemy    = "assets/images/enemy.png",
        -- tile     = "assets/images/tile.png",
    },
    sounds = {
        -- hit      = "assets/sounds/hit.wav",
        -- jump     = "assets/sounds/jump.wav",
        -- click    = "assets/sounds/click.wav",
    },
    music = {
        -- theme    = "assets/music/theme.ogg",
    },
    fonts = {
        -- title    = { "assets/fonts/title.ttf", 32 },
        -- body     = { "assets/fonts/body.ttf", 16 },
    },
}
