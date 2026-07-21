# Artisan CLI

`artisan.lua` is the project-level scaffolding tool, modeled after
Laravel's Artisan. It runs in plain Lua — no LÖVE required.

```bash
lua artisan.lua list
lua artisan.lua make:scene <Name>
lua artisan.lua make:entity <Name>
lua artisan.lua make:service <Name>
lua artisan.lua make:test <name>
lua artisan.lua make:ui <Name>
lua artisan.lua make:config <name>
```

## make:scene

```bash
lua artisan.lua make:scene InventoryScene
```

Creates `scenes/InventoryScene.lua` with a full `core.Scene`
subclass and all lifecycle hooks stubbed out. Open the file and
fill in `enter`/`update`/`draw`.

## make:entity

```bash
lua artisan.lua make:entity Bullet
```

Creates `app/Entities/Bullet.lua` extending `Entities.Entity` with
`super` calls set up correctly.

## make:service

```bash
lua artisan.lua make:service ScoreManager
```

Creates `app/Services/ScoreManager.lua` extending
`core.ServiceProvider` with `register` and `boot` stubs. Use it to
register bindings or hook up events at boot.

## make:test

```bash
lua artisan.lua make:test test_input
```

Creates `tests/test_input.lua` with two passing assertions and the
file's class wired up. Run with `lua tests/runner.lua`.

## make:ui

```bash
lua artisan.lua make:ui HealthBar
```

Creates `app/UI/HealthBar.lua` with `new`, `update`, and `draw`
stubs.

## make:config

```bash
lua artisan.lua make:config balance
```

Creates `config/balance.lua` with an empty table.

## Idempotency

If the target file already exists, the command prints `[skip]`
and exits without overwriting. No data loss.

## Adding your own commands

Edit `artisan.lua` and add an entry to the `commands` table:

```lua
commands.build = function(target)
    print("Building " .. (target or "all") .. " ...")
    os.execute("zip -9 -r build.love . -x '*.git*'")
end
```

Then call it:

```bash
lua artisan.lua make:build          # target = nil
lua artisan.lua make:build windows  # target = "windows"
```

Update the dispatcher to recognize it:

```lua
local makeType = cmd:match("^make:(.+)$")
if not makeType then
    -- non-make commands
    if commands[cmd] then return commands[cmd](arg1) end
end
```
