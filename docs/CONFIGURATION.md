# Configuration

All runtime configuration lives in `config/*.lua`. Files return a
table; values are looked up with dotted paths.

## File map

| File                 | Purpose                                |
| -------------------- | -------------------------------------- |
| `config/app.lua`     | Framework/runtime settings             |
| `config/game.lua`    | Game-wide gameplay settings            |
| `config/input.lua`   | Key bindings                           |
| `config/audio.lua`   | Audio runtime settings (volumes, channels) |
| `config/assets.lua`  | Asset declarations (paths to images / sounds / music / fonts) |
| `config/scenes.lua`  | Boot scene + scene registry            |

Add your own files by listing them in `Config:_files`:

```lua
-- app/Services/Config.lua
self._files = { "app", "game", "input", "audio", "assets", "scenes", "balance" }
```

Or just place new tables inside an existing file.

## Where do I declare assets?

`config/assets.lua`. The `BootScene` reads it on startup and asks
the `AssetManager` to load each entry.

```lua
-- config/assets.lua
return {
    images = {
        player = "assets/images/player.png",
    },
    sounds = {
        hit = "assets/sounds/hit.wav",
    },
    music = {
        theme = "assets/music/theme.ogg",
    },
    fonts = {
        title = { "assets/fonts/title.ttf", 32 },
    },
}
```

After boot, access them by name:

```lua
local img  = self:assets():get("image", "player")
local font = self:assets():get("font", "title")
```

`config/audio.lua` is reserved for runtime audio settings (master
volume, channel levels, mute). It no longer carries asset paths.

## Reading

```lua
local title       = config:get("game.title", "Untitled")
local jumpBinding = config:get("input.bindings.jump")
local startingHP  = config:get("game.gameplay.startingHealth", 3)
local levelOne    = config:get("levels.1.name", "Default")
```

`get` returns the default if any segment of the path is missing.
Numeric segments are looked up as array indices: `levels.1.name`
reads `config._store.levels[1].name`.

## Writing at runtime

```lua
config:set("game.debug", true)
config:set("game.window.width", 1024)
config:set("player.progress.levels.1.stars", 3)
```

`set` doesn't persist — pair it with `save:set` to write to disk.

## Reloading

```lua
config:reload()   -- re-require every config file
```

Handy during development. Production builds probably don't need it.

## Example: balance sheet

`config/balance.lua`:

```lua
return {
    player = {
        maxHealth = 100,
        moveSpeed = 240,
        jumpForce = 600,
    },
    enemies = {
        zombie = { health = 20, damage = 10, speed = 60 },
        skeleton = { health = 15, damage = 15, speed = 90 },
    },
    waves = {
        { time = 0,  spawn = { type = "zombie",  count = 5 } },
        { time = 30, spawn = { type = "skeleton", count = 8 } },
    },
}
```

```lua
local cfg = self:config()
local zombieHealth = cfg:get("balance.enemies.zombie.health")
```

## Overriding at runtime

`config:set` is a runtime override only. To make it persistent:

```lua
config:set("game.window.width", 1024)
self:save():set("overrides.window.width", 1024)

-- On next boot, load and apply overrides
local overrides = self:save():get("overrides", {})
for path, value in pairs(overrides) do
    config:set(path, value)
end
```

## Boot order

1. `Application:boot()` calls `Config:new` and `Config:load`.
2. `Config:load` requires every file in `self._files` and stores them
   in `self._store`. The first segment of a dotted path is the file
   basename.

If you add a new config file, list it in `self._files` so it loads.
