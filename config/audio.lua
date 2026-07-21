-- config/audio.lua — audio levels, channels, and asset declarations.
return {
    master = 0.8,        -- 0..1
    muted  = false,

    channels = {
        sfx   = 0.9,
        music = 0.5,
    },

    -- Asset list. Loaded at boot by services that want them.
    -- The format is: kind -> { name = "path" or { path, opts } }
    sounds = {
        -- hit  = "assets/sounds/hit.wav",
        -- jump = "assets/sounds/jump.wav",
    },
    music = {
        -- theme = "assets/music/theme.ogg",
    },
    fonts = {
        -- title = { "assets/fonts/title.ttf", 32 },
        -- body  = { "assets/fonts/body.ttf", 16 },
    },
    images = {
        -- player = "assets/images/player.png",
    },
}
