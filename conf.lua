--[[
    conf.lua — runs BEFORE main.lua.
    Window, identity, and module toggles.
    Most "game" configuration lives in config/game.lua and is loaded at runtime.
]]

function love.conf(t)
    -- Engine
    t.version  = "11.5"
    t.console  = false   -- set true on Windows to see print() output
    t.identity = "iloveboilerplate"

    -- Window
    t.window.title       = "i-love-boilerplate"
    t.window.icon        = nil
    t.window.width       = 1280
    t.window.height      = 720
    t.window.minwidth    = 640
    t.window.minheight   = 360
    t.window.borderless  = false
    t.window.resizable   = true
    t.window.minwidth    = 320
    t.window.minheight   = 180
    t.window.fullscreen  = false
    t.window.fullscreentype = "desktop"
    t.window.vsync       = 1
    t.window.msaa        = 0
    t.window.depth       = nil
    t.window.stencil     = nil
    t.window.display     = 1
    t.window.highdpi     = false
    t.window.usedpiscale = true
    t.window.x           = nil
    t.window.y           = nil

    -- Modules (toggle off the ones you don't need for faster startup)
    t.modules.audio    = true
    t.modules.data     = true
    t.modules.event    = true
    t.modules.font     = true
    t.modules.graphics = true
    t.modules.image    = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math     = true
    t.modules.mouse    = true
    t.modules.physics  = false  -- enable in config/physics.lua if you need Box2D
    t.modules.sound    = true
    t.modules.system   = true
    t.modules.thread   = true
    t.modules.timer    = true
    t.modules.touch    = true
    t.modules.video    = false
    t.modules.window   = true
end
