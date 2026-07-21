-- config/game.lua — game-wide gameplay settings.
return {
    title  = "i-love-boilerplate",
    author = "Your Name",
    version = "0.1.0",

    -- Set to true to show the FPS/dt/scene overlay.
    debug  = true,

    -- Set to false when you ship a build.
    dev    = true,

    -- Time scale, used by systems that want to slow-mo or pause.
    timeScale = 1.0,

    window = {
        width  = 1280,
        height = 720,
        minWidth  = 640,
        minHeight = 360,
        resizable = true,
        vsync     = true,
    },

    -- Game-design knobs live here so designers can edit without code.
    gameplay = {
        startingHealth  = 3,
        lives           = 3,
        difficulty      = "normal",  -- "easy" | "normal" | "hard"
        spawnEnemies    = true,
        enemySpawnRate  = 2.0,
        scorePerKill    = 100,
    },
}
