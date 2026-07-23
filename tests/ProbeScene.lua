--[[
    tests/ProbeScene.lua — minimal scene used by test_bugfixes to verify
    that `input:pressed("jump")` is visible inside a scene's :update()
    on the same frame the key was pressed.

    Production code never references this. It is registered into the
    SceneManager under the name "Probe" at test time.
]]

local Scene = require("core.Scene")

local ProbeScene = Scene:extend("Probe")

-- Test hook: a function the test sets to capture update timing.
ProbeScene.recorder = nil

function ProbeScene:enter()
    self.records = {}
end

function ProbeScene:update(dt)
    if ProbeScene.recorder then
        ProbeScene.recorder(self, dt)
    end
end

return ProbeScene
