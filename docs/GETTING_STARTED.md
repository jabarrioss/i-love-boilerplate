# Getting started

This document walks you from `git clone` to a running game in 5 minutes.

## 1. Install LÖVE

Grab LÖVE 11.x for your platform:

- macOS — `brew install love`
- Windows — `https://love2d.org/` (installer)
- Linux — `apt install love` or your distro's equivalent

Verify with `love --version`. Should report `11.x`.

## 2. Run the boilerplate

From the project root:

```bash
# macOS / Linux
love .

# Windows (PowerShell)
& "C:\Program Files\LOVE\love.exe" .
```

Or use the helper scripts (auto-detect LÖVE's install path):

```bash
# Windows
.\run.bat             # normal mode
.\run.bat --console   # with console output

# macOS / Linux
./run.sh
```

You should see a black window with "Loading..." briefly, then the
main menu with three buttons: Play, Options, Quit.

> **Note on `lovec`**: Some Windows builds of the LÖVE console binary
> (`lovec.exe`) report the source base one level too high when given a
> relative path. `main.lua` probes several candidate roots and picks
> the one that actually contains the framework, so the project still
> boots — but if you hit the same issue, use `love.exe` directly or
> pass an absolute path:
>
> ```powershell
> & "C:\Program Files\LOVE\love.exe" .
> # or
> lovec "C:\path\to\i-love-boilerplate"
> ```

## 3. Open it in your editor

The whole project is plain Lua. Any editor works (VS Code with
`lua-language-server` is recommended).

## 4. Make a tiny change

Open `config/game.lua`. Change `title` to your game's name:

```lua
title = "Pocket Dungeon",
```

Run again. The window title bar updates to "Pocket Dungeon".

> **Why this works**: `conf.lua` sets a default title early, but the
> framework re-applies `config/game.lua.title` on boot via
> `love.window.setTitle(...)`. So `config/game.lua` is the source of
> truth for runtime display, while `conf.lua` is only for engine-level
> setup that has to happen before `main.lua`.

## 5. Add a new scene

Use the artisan CLI to scaffold without writing boilerplate:

```bash
lua artisan.lua make:scene InventoryScene
```

Open `scenes/InventoryScene.lua` and edit. To navigate to it from
`MenuScene.lua`, add a button:

```lua
Button:new({
    x = cx - 110, y = 380, w = 220, h = 48,
    text = "Inventory",
    onClick = function() self:scenes():push("InventoryScene") end,
    app = self.app,
}),
```

## 6. Add an entity

```bash
lua artisan.lua make:entity Coin
```

Edit `app/Entities/Coin.lua` to inherit position, draw, and update.
Spawn one from any scene:

```lua
local Coin = require("Entities.Coin")
local coin = Coin:new(400, 300, { w = 16, h = 16 })
coin.app = self.app
table.insert(self.coins, coin)
```

## 7. Run the tests

```bash
lua tests/runner.lua
```

You should see 3 files run, all green.

## 8. Build a distributable

See [docs/DEPLOYMENT.md](DEPLOYMENT.md) for `.love` files and
per-platform packaging.

## Directory cheat sheet

| Where                  | What goes here                                |
| ---------------------- | --------------------------------------------- |
| `main.lua`             | LÖVE entry point — keep it thin               |
| `conf.lua`             | Window settings (run before `main.lua`)       |
| `app/core/`            | Framework — don't touch unless extending      |
| `app/Services/`        | Stateful game services (asset, audio, etc.)   |
| `app/Entities/`        | Game-object classes (Player, Enemy, Bullet)   |
| `app/UI/`              | Reusable UI widgets                           |
| `app/Utils/`           | Pure helpers (no LÖVE dependency)             |
| `scenes/`              | Game states (Menu, Game, Pause, …)            |
| `config/`              | Runtime configuration                        |
| `assets/images`        | PNG, JPG                                      |
| `assets/sounds`        | Short SFX (WAV/OGG)                          |
| `assets/music`         | Looping music (OGG/MP3)                      |
| `assets/fonts`         | TTF/OTF                                       |
| `assets/maps`          | Tile maps, level data                         |
| `lib/`                 | Third-party Lua libraries                     |
| `storage/saves/`       | Player saves (gitignored)                     |
| `storage/logs/`        | Application log (gitignored)                  |
| `tests/`               | Test files (`test_*.lua`)                     |
| `docs/`                | Additional documentation                      |

## Next steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand how the pieces
  fit together.
- Read [SERVICES.md](SERVICES.md) for the full list of services and
  their APIs.
- Read [SCENES.md](SCENES.md) to learn the scene lifecycle.
