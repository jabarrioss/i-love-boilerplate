# Working with scenes

A scene is a self-contained game state: a menu, a level, a pause
overlay, a game-over screen, an inventory. Each scene is a subclass
of `core.Scene` and lives in `scenes/`.

## Lifecycle

```
            push("X")
                ↓
        ┌─────────────┐
   ────▶│   X:enter   │◀──── create + push
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │  X:update   │◀──── every frame (top of stack only)
        │  X:draw     │
        └──────┬──────┘
               │ pop
        ┌──────▼──────┐
        │   X:exit    │
        └─────────────┘
```

If a scene is covered (another scene pushed on top of it), its
`pause()` is called. When uncovered (the top pops), `resume()` runs.

## Boilerplate

The fastest way to start a scene is the artisan CLI:

```bash
lua artisan.lua make:scene InventoryScene
```

That writes `scenes/InventoryScene.lua` with the standard skeleton.

## Anatomy of a scene

```lua
local Scene = require("core.Scene")

local InventoryScene = Scene:extend("InventoryScene")

function InventoryScene:enter(prev)
    -- One-time setup. Build UI, load data, register event handlers.
    self.title = "Inventory"
end

function InventoryScene:exit()
    -- One-time teardown. Save state, free resources.
end

function InventoryScene:update(dt)
    -- Called every frame while on top of the stack.
    -- Use self:input(), self:assets(), etc. for services.
end

function InventoryScene:draw()
    -- Render the scene.
end

function InventoryScene:keypressed(key, scancode, isrepeat)
    -- Top of stack only.
    if key == "escape" then self:scenes():pop() end
end

return InventoryScene
```

## Convenience accessors

Every scene has shortcuts to all services:

```lua
self:scenes()    -- scene manager
self:assets()    -- asset manager
self:input()     -- input manager
self:audio()     -- audio manager
self:camera()    -- camera
self:save()      -- save manager
self:logger()    -- logger
self:config()    -- config
self:random()    -- random
self:scheduler() -- scheduler
self:easing()    -- easing (no convenience on Scene; use app:easing())
```

`self.app` is the Application instance. Use it for `self.app:emit(...)`
or for any service without a convenience accessor.

## Navigation

From inside any scene:

```lua
-- Push overlay (current scene pauses)
self:scenes():push("PauseScene")

-- Pop the top scene (current becomes the previous)
self:scenes():pop()

-- Replace top scene (no history)
self:scenes():swap("GameOverScene")

-- Clear the stack and start fresh
self:scenes():replace("MenuScene")
```

## Receiving events

```lua
function MyScene:enter()
    self._onScoreChanged = function(amount)
        self.score = self.score + amount
    end
    self.app:on("score:changed", self._onScoreChanged)
end

function MyScene:exit()
    -- Always unsubscribe or you'll leak handlers across restarts
    self.app:off("score:changed", self._onScoreChanged)
end
```

## Layout tips

Get the screen size once on enter, recompute on resize:

```lua
function MyScene:enter()
    self:recompute()
end

function MyScene:resize(w, h)
    Scene.resize(self, w, h)
    self:recompute()
end

function MyScene:recompute()
    local w, h = love.graphics.getDimensions()
    self.centerX, self.centerY = w / 2, h / 2
end
```

## Putting scenes in subfolders

If you have many scenes, group them:

```
scenes/
├── BootScene.lua
├── menu/
│   ├── MainMenuScene.lua
│   └── OptionsScene.lua
└── game/
    ├── LevelOneScene.lua
    └── PauseScene.lua
```

Then register the path in `config/scenes.lua`:

```lua
return {
    boot = "BootScene",
    registry = {
        MainMenuScene = "scenes.menu.MainMenuScene",
        OptionsScene  = "scenes.menu.OptionsScene",
        LevelOneScene = "scenes.game.LevelOneScene",
        PauseScene    = "scenes.game.PauseScene",
    },
}
```

## Common patterns

### Pause overlay

```lua
function GameScene:keypressed(key)
    if key == "escape" then
        self:scenes():push("PauseScene")
    end
end

-- PauseScene has its own keypress: ESC again → pop
function PauseScene:keypressed(key)
    if key == "escape" then
        self:scenes():pop()
    end
end
```

### Modal dialog

Same as pause: push a scene, the underlying scene is paused.
Pop to close.

### Death/respawn

```lua
function GameScene:onDeath()
    self:scenes():push("GameOverScene", { score = self.score })
end
```

The second arg becomes `self.opts` in the new scene.
