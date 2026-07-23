# Services reference

Every service is constructed by the framework and lives at
`app:make("key")` or via the convenience accessor (e.g. `app:scenes()`).

All services receive `app` in their constructor. You can pull other
services from it via `app:make(...)` or the accessors.

---

## Config  `app:config()`

Runtime configuration. Reads `config/*.lua` at boot and exposes
dot-paths:

```lua
config:get("game.title", "Default")
config:get("input.bindings.jump")
config:set("game.debug", true)
config:all("game")
config:reload()
```

`config:get` supports numeric indices: `config:get("game.players.1.name")`.

---

## Logger  `app:logger()`

Leveled log to stdout and `storage/logs/app.log`.

```lua
logger:debug("a debug message")
logger:info("player connected: %s", name)
logger:warn("low memory")
logger:error("save failed: %s", err)
logger:fatal("unrecoverable")
logger:setLevel("warn")
```

---

## Events  `app:events()`  /  `app:on()` / `app:emit()`

Pub/sub bus. See [ARCHITECTURE.md](ARCHITECTURE.md#the-event-bus) for details.

```lua
app:on("enemy:killed", function(enemy) ... end)
app:once("boot:first", function() ... end)
app:emit("player:died", player)
app:off("enemy:killed", handler)
```

---

## AssetManager  `app:assets()`

Central registry for images, sounds, music, fonts, data, video.

```lua
assets:load("image", "player", "assets/images/player.png")
assets:load("sound", "hit",    "assets/sounds/hit.wav")
assets:load("music", "theme",  "assets/music/theme.ogg")
assets:load("font",  "title",  "assets/fonts/title.ttf", 32)

local img  = assets:get("image", "player")
local font = assets:get("font", "title")
if assets:has("sound", "jump") then ...

assets:unload("image", "player")
assets:unloadAll()
```

For boot-time asset declarations, see `config/assets.lua` — the
`BootScene` reads it and loads everything automatically.

---

## InputManager  `app:input()`

Two layers: bindings (action → key) and handlers (action → callback).

```lua
-- Declarative (config/input.lua)
input.bindings = { jump = "space", moveLeft = "left" }

-- Imperative (anywhere in code)
input:defineAction("attack", { "mouse1", "f" })
input:bindPressed("jump", function() player:jump() end)
input:bindReleased("jump", function() end)

-- Polling
if input:down("moveLeft") then player.x = player.x - 200 * dt end

-- Single-frame query
if input:pressed("jump") then ... end

-- Mouse
local mx, my = input:mousePosition()
if input:mouseDown(1) then ... end
```

Bindings declared in `config/input.lua` are loaded during `InputManager:boot()`.

---

## AudioManager  `app:audio()`

Two virtual channels: `sfx` and `music`.

```lua
audio:playSound("hit", { volume = 0.7 })
audio:playMusic("theme", { loop = true, fadeIn = 1.5 })
audio:stopMusic(0.5)   -- fade out over 0.5s
audio:setChannelVolume("sfx", 0.5)
audio:setMasterVolume(0.8)
audio:mute(true)
```

---

## Camera  `app:camera()`

2D viewport with smooth follow, shake, and zoom.

```lua
camera:follow(player)
camera:followPoint(0, 0, 6)        -- lerp speed
camera:zoom(1.5)
camera:rotate(math.pi / 4)
camera:screenshake(8, 0.4)         -- magnitude, duration
camera:moveTo(100, 200)
camera:stopFollow()

camera:attach()                    -- call before drawing world
-- draw world
camera:detach()                    -- call before drawing UI
```

Camera updates are called by `Application:update` automatically.

---

## SaveManager  `app:save()`

Typed key/value store. Multiple slots, atomic writes.

```lua
save:set("settings.musicVolume", 0.6)
save:get("settings.musicVolume", 0.8)
save:save("profile1")
save:load("profile1")
save:delete("profile1")
save:exists("profile1")
save:flush()   -- write only if dirty
```

The default slot is auto-loaded on boot (`config/app.lua` → `save.slot`).

---

## Random  `app:random()`

Seedable RNG with helpers.

```lua
random:seed(os.time())
random:integer(1, 6)
random:number()              -- 0..1
random:chance(0.25)
random:pick({"a", "b", "c"})
random:weighted({{weight=1,value="common"},{weight=0.1,value="rare"}})
random:shuffle({1,2,3,4})
random:normal()              -- standard normal via Box-Muller
```

`config/app.lua` → `random.seed` lets you fix a seed for reproducible runs.

---

## Easing  `app:easing()`

Easing functions + tween helper.

```lua
easing:tween(0.5, player, "x", 200, "outQuad", function() print("done") end)
easing:tween(1.0, ui.fade, "alpha", 0, easing.inOutCubic)
easing:cancel(player)
```

Static functions: `linear`, `inQuad`, `outQuad`, `inOutQuad`, `inCubic`,
`outCubic`, `inOutCubic`, `inSine`, `outSine`, `inOutSine`, `inExpo`,
`outExpo`, `inOutExpo`, `inBack`, `outBack`, `inOutBack`, `inBounce`,
`outBounce`, `inOutBounce`, `inElastic`, `outElastic`, `inOutElastic`.

---

## Scheduler  `app:scheduler()`

Delayed and periodic callbacks.

```lua
scheduler:after(2.0, function() print("2s") end)
scheduler:every(0.5, function() print("tick") end, "tick-tag")
scheduler:stop("tick-tag")
scheduler:cancelAll()
scheduler:nextFrame(function() end)
```

Periodic callbacks need a `tag` so you can cancel them. Delayed ones
can be cancelled via tag too.

---

## SceneManager  `app:scenes()`

Stack-based scene control.

```lua
scenes:push("PauseScene")        -- overlay
scenes:pop()                     -- close overlay
scenes:swap("GameOverScene")     -- replace top, no history
scenes:replace("MenuScene")      -- clear stack, push this
scenes:register("MyName", "scenes.subfolder.MyName")
local top = scenes:current()
```
