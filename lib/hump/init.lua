-- lib/hump/init.lua — re-exports hump's modules.
-- Usage:
--   local Vector      = require("hump.vector")
--   local VectorLight = require("hump.vector-light")
--   local Camera      = require("hump.camera")
--   local GameState   = require("hump.gamestate")
--   local Timer       = require("hump.timer")
--   local Signal      = require("hump.signal")
--   local Class       = require("hump.class")
return {
    vector       = require("hump.vector"),
    ["vector-light"] = require("hump.vector-light"),
    camera       = require("hump.camera"),
    gamestate    = require("hump.gamestate"),
    timer        = require("hump.timer"),
    signal       = require("hump.signal"),
    class        = require("hump.class"),
}
