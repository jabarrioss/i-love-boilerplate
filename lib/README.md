# lib

Bundled third-party libraries. Anything in this directory is on
`package.path` automatically, so you can `require("bump")` etc.
without any setup.

## What's included

| Library                                       | Use it for                              |
| --------------------------------------------- | --------------------------------------- |
| [`bump`](https://github.com/kikito/bump.lua)  | 2D collision detection (AABB)           |
| [`anim8`](https://github.com/kikito/anim8)    | Sprite-sheet animations                 |
| [`flux`](https://github.com/rxi/flux)         | Tweening/lerp helper                    |
| [`inspect`](https://github.com/kikito/inspect.lua) | Table pretty-printing for debugging  |
| [`lume`](https://github.com/rxi/lume)         | Utility belt (math, table, string)      |
| [`Classic`](https://github.com/rxi/classic)   | Alternative OOP base (your own classes) |
| [`hump`](https://github.com/vrld/hump)        | Vector math, camera, gamestate, timer   |

## Quick start

```lua
-- Single import for the whole collection:
local libs = require("lib")
local bump   = libs.bump
local anim8  = libs.anim8
local Vector = libs.hump.vector

-- Or pull one library directly:
local bump  = require("bump")
local Timer = require("hump.timer")
```

## How they fit the framework

The framework re-implements the *concepts* hump covers (scene stack,
timer, easing, camera, vector math) so you don't have to learn hump
just to start. These libraries are the escape hatches:

- You want **a tested, well-known collision system** → use `bump` in
  your entity/scene.
- You want **a standard sprite-animation library** → use `anim8`.
- You want **Lume's `lume.serialize` / `lume.format`** for logs →
  use it.

Everything is opt-in. The framework doesn't force any of them.

## License

Each library keeps its original license (see the upstream repos). Most
are MIT.
