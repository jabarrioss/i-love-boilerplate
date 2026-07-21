-- config/scenes.lua — scene registry and the boot scene.
-- The "boot" scene is pushed by the framework after Application:boot().
return {
    boot = "BootScene",

    -- Map logical names to module paths. Useful for renaming files later
    -- without breaking the rest of the game.
    registry = {
        BootScene     = "scenes.BootScene",
        MenuScene     = "scenes.MenuScene",
        GameScene     = "scenes.GameScene",
        GameOverScene = "scenes.GameOverScene",
    },

    -- If true, pushing an already-active scene swaps it; otherwise it
    -- becomes an overlay.
    swapOnPush = false,
}
