-- config/audio.lua — runtime audio settings (no asset declarations;
-- those live in config/assets.lua).
return {
    master = 0.8,        -- 0..1, applied to both channels
    muted  = false,

    channels = {
        sfx   = 0.9,     -- one-shot sounds (hits, clicks, jumps)
        music = 0.5,     -- looping music
    },
}
