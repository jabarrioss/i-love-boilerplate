# Entities and the game loop

`Entities/Entity.lua` is the recommended base for any game object:
player, enemy, bullet, pickup, platform. It already provides
position, velocity, dimensions, an AABB, and collision helpers.

## Quick start

```bash
lua artisan.lua make:entity Bullet
```

Edit the generated stub:

```lua
local Entity = require("Entities.Entity")

local Bullet = Entity:extend("Bullet")

function Bullet:new(x, y, dir)
    Bullet.super.new(self, x, y, { w = 6, h = 6 })
    self.vx = math.cos(dir) * 600
    self.vy = math.sin(dir) * 600
    self.tag = "bullet"
    self.lifetime = 2.0
    return self
end

function Bullet:update(dt)
    Bullet.super.update(self, dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then self:kill() end
end

return Bullet
```

## Spawning

In any scene, after `app:boot()`:

```lua
local Bullet = require("Entities.Bullet")
local b = Bullet:new(player.x, player.y, player.angle)
b.app = self.app   -- gives it access to services
table.insert(self.bullets, b)
```

`self.app` is required if the entity calls `app:emit` or uses any
service. Pass it in after construction.

## Updating

In the scene's `update`:

```lua
function MyScene:update(dt)
    for _, e in ipairs(self.entities) do e:update(dt) end
    -- compact dead ones
    self.entities = table.filter(self.entities, function(e) return e:isAlive() end)
end
```

(`Utils.table.filter` is in the framework, but you can write your own.)

## Drawing

The base `Entity:draw()` uses `self.image` if set, otherwise a
placeholder rectangle. Override it for custom rendering:

```lua
function Bullet:draw()
    love.graphics.setColor(1, 0.9, 0.3)
    love.graphics.circle("fill", self.x, self.y, self.w / 2)
end
```

Wrap in `camera:attach()` / `camera:detach()` to draw with the
world camera (see [SERVICES.md](SERVICES.md#camera--appcamera)).

## Collision

The base `Entity:overlaps(other)` does AABB:

```lua
if player:overlaps(enemy) then
    player:damage(1)
end
```

For tilemap or pixel-perfect collision, drop in a third-party
library like [bump.lua](https://github.com/kikito/bump.lua) in `lib/`.

## Tags

`self.tag` is a free-form string for filtering:

```lua
for _, e in ipairs(self.entities) do
    if e.tag == "enemy" and e:isAlive() then
        e:setTarget(player)
    end
end
```

## Cleanup

The `Entity:kill()` method sets `alive = false`. The scene's update
loop should compact dead entities so they don't accumulate.

If you want automatic cleanup, use a small helper:

```lua
function compact(list)
    local out, n = {}, 0
    for _, e in ipairs(list) do
        if e:isAlive() then out[#out + 1] = e end
    end
    return out
end
```

## Event-driven

Emit an event when something happens, listen from the scene:

```lua
function Bullet:update(dt)
    Bullet.super.update(self, dt)
    if self:overlaps(player) and player:isAlive() then
        self.app:emit("bullet:hit", self, player)
        self:kill()
    end
end
```

```lua
-- in a scene
self.app:on("bullet:hit", function(bullet, target)
    target:damage(10)
    self:audio():playSound("hit")
end)
```

## Performance

- Avoid creating new closures in `update` — they allocate. Cache
  frequently-used functions in the entity's `new`.
- Don't `require` inside `update`/`draw`. Require at the top of the
  file or inside the scene.
- For many entities (hundreds+), use a spatial index (`bump.lua`)
  instead of pairwise collision.

## Composition vs inheritance

For most cases, extending `Entity` is the simplest path. For
complex objects (a Player with Inventory + Abilities + Equipment),
prefer composition: a `Player` entity that holds references to
smaller `Inventory`, `Abilities`, and `Equipment` tables, each
with their own `update`/`draw` methods.
