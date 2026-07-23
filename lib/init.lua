--[[
    lib/init.lua — single import point for the bundled third-party
    libraries. Not loaded automatically — pull what you need in one
    shot:

        local libs = require("lib")
        local bump   = libs.bump
        local anim8  = libs.anim8
        local Vector = libs.hump.vector

    Note: hump.gamestate is LÖVE-only and would crash outside a
    LÖVE runtime, so it's not preloaded here. Require it directly
    if you need it: `require("hump.gamestate")`.
]]

return {
    -- Single-file libraries (no LÖVE dependency)
    bump      = require("bump"),
    anim8     = require("anim8"),
    flux      = require("flux"),
    inspect   = require("inspect"),
    lume      = require("lume"),
    Classic   = require("Classic"),

    -- hump modules that work without LÖVE at load time
    hump = {
        vector       = require("hump.vector"),
        ["vector-light"] = require("hump.vector-light"),
        camera       = require("hump.camera"),
        timer        = require("hump.timer"),
        signal       = require("hump.signal"),
        class        = require("hump.class"),
    },
}
