-- config/input.lua — key bindings and input behavior.
-- Each action can map to one key or a list of keys.
return {
    bindings = {
        moveUp    = { "up",    "w" },
        moveDown  = { "down",  "s" },
        moveLeft  = { "left",  "a" },
        moveRight = { "right", "d" },
        jump      = "space",
        shoot     = { "mouse1", "f" },
        pause     = "escape",
        confirm   = { "return", "space" },
        back      = "escape",
        fullscreen = "f11",
        debug     = "f1",
        quit      = "q",
    },

    -- Sensitivity and deadzones
    mouse = {
        sensitivity = 1.0,
    },
    gamepad = {
        deadzone = 0.2,
        vibration = true,
    },
}
