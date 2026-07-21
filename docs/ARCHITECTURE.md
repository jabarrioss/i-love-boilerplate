# Architecture overview

## Boot sequence

```
love.conf(t)             ← engine config (window, modules)
        ↓
love.load()              ← main.lua
        ↓
Application:boot()
   ├── register core services (config, logger, events, …)
   ├── run register() on every ServiceProvider
   ├── make every service (resolves lazy singletons)
   │      and call .boot() on services that have one
   ├── run boot() on every ServiceProvider
   ├── emit "app:booted"
   └── push config.scenes.boot (default: "BootScene")
```

After boot, the framework simply routes LÖVE callbacks:

```
love.update(dt)  →  Application:update(dt)
                       ├── input:update(dt)      (clear "just pressed")
                       ├── scheduler:update(dt)  (run timers)
                       ├── audio:update(dt)      (music fade, SFX reap)
                       ├── easing:update(dt)     (advance tweens)
                       ├── camera:update(dt)     (smooth follow, shake)
                       └── scenes:update(dt)     (top of stack)

love.draw()      →  Application:draw()
                       ├── scenes:draw()
                       └── optional debug overlay (FPS / dt / scene name)
```

## Service container

`Application` is a service container with three registration styles:

```lua
-- Eager value (already constructed):
app:bind("score", { value = 0, add = function(self, n) self.value = self.value + n end })

-- Lazy singleton (built on first make()):
app:singleton("scenes", function(app) return SceneManager:new(app) end)

-- Resolve (eager or lazy depending on registration):
local s = app:make("scenes")
```

Two ways to access services:

```lua
-- 1. Convenience accessor (preferred)
local scenes  = app:scenes()
local assets  = app:assets()
local input   = app:input()
local audio   = app:audio()
local camera  = app:camera()
local save    = app:save()
local logger  = app:logger()
local config  = app:config()
local random  = app:random()
local events  = app:events()
local scheduler = app:scheduler()
local easing  = app:easing()

-- 2. Generic lookup
local something = app:make("anything-i-registered")
```

## The scene stack

Scenes are push/pop/swap/replace on a stack:

```
push("GameOverScene")      ┌─ GameOverScene
                           ├─ GameScene         ← paused
                           └─ (root)
```

When a scene is pushed:
1. The new scene's `enter(prev)` is called.
2. The previous scene's `pause()` is called (if defined).

When popped:
1. The top scene's `exit()` is called.
2. The new top's `resume()` is called.

`s scenes:replace("X")` clears the stack and pushes `X`.
`scenes:swap("X")` replaces the top in place (no pause/resume).

Only the top scene receives input events (keystrokes, mouse, touch).
This is what allows a pause menu to live on top of gameplay without
both scenes fighting for `escape`.

## The event bus

Subscribers register; publishers emit. Handlers may filter, fire once,
or receive every event via the `*` wildcard.

```lua
-- Publish
app:emit("player:died", player)

-- Subscribe
app:on("player:died", function(p) print(p.name .. " died") end)

-- Filtered
app:on("score:changed", handler, function(amount) return amount > 100 end)

-- One-shot
app:once("first:boot", function() print("welcome") end)
```

Use it for cross-service communication that doesn't warrant a direct
dependency (e.g. achievement unlock on enemy killed, audio cue on
button click).

## Class system

`Class:extend("Name")` returns a subclass with `super` access and `is`
checks:

```lua
local Animal = Class:extend("Animal")
function Animal:new(name) self.name = name end

local Dog = Animal:extend("Dog")
function Dog:new(name)
    Dog.super.new(self, name)
    self.loyal = true
end
function Dog:fetch() print(self.name .. " fetches") end

local d = Dog:new("Rex")
d:fetch()             -- "Rex fetches"
d:is(Dog)             -- true
d:is(Animal)          -- true
d:is(Class)           -- false
```

## Service providers

Wrap your game's custom setup logic in providers. Useful when you
have more than a few `app:bind` calls, or when you want a place to
register event listeners for app-wide events.

```lua
local ServiceProvider = require("core.ServiceProvider")
local Achievements = ServiceProvider:extend("Achievements")

function Achievements:register(app)
    self:bind("achievements", { list = {} })
end

function Achievements:boot(app)
    self:on("enemy:killed", function(enemy)
        local a = self:make("achievements")
        table.insert(a.list, "killed:" .. enemy.tag)
    end)
end

-- In main.lua or a provider file:
app:register(require("Providers.Achievements"))
```

## Directory map

```
app/
├── core/                framework internals
│   ├── Class.lua        OOP base
│   ├── Application.lua  service container + LÖVE router
│   ├── ServiceProvider.lua
│   ├── Event.lua        pub/sub
│   ├── Facade.lua       short static accessors
│   ├── Scene.lua        scene base class
│   └── Scheduler.lua    delayed + periodic callbacks
│
├── Services/            stateful game services
│   ├── Config.lua
│   ├── Logger.lua
│   ├── Event.lua        (event bus wrapper for the container)
│   ├── AssetManager.lua
│   ├── InputManager.lua
│   ├── AudioManager.lua
│   ├── Camera.lua
│   ├── SaveManager.lua
│   ├── Random.lua
│   ├── Easing.lua
│   ├── Scheduler.lua
│   └── SceneManager.lua
│
├── Entities/            game-object classes
├── UI/                  widgets
└── Utils/               pure helpers

scenes/                  scene implementations
config/                  config files (returned as Lua tables)
```

## Lifecycle at a glance

| When                        | What happens                                         |
| --------------------------- | ---------------------------------------------------- |
| Engine starts               | `love.conf(t)` runs                                  |
| `love.load`                 | `Application:boot()` then push `scenes.boot`         |
| Every frame, before draw    | `Application:update(dt)` → services → scene         |
| Every frame, after update   | `Application:draw()` → scene (top of stack)         |
| User pushes a scene         | new scene `enter(prev)`, old scene `pause()`         |
| User pops a scene           | old scene `exit()`, new top `resume()`               |
| Window resized              | every service `resize(w, h)` is called               |
| User quits                  | `save:flush()`, then engine shuts down               |
