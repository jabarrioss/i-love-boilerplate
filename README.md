# i-love-boilerplate

A Laravel-style boilerplate for [LÖVE 11.x](https://love2d.org/) — opinionated
project layout, service container, scene manager, asset pipeline, and CLI
scaffolding so you can start a 2D game without reinventing the architecture.

```
i-love-boilerplate/
├── main.lua              ← entry point (thin, delegates to Application)
├── conf.lua              ← window / module / identity config
├── artisan.lua           ← CLI: scaffolding + utility commands
├── app/
│   ├── core/             ← framework (Class, Application, Event, Scheduler, …)
│   ├── Services/         ← game services (Config, Asset, Input, Audio, …)
│   ├── Entities/         ← game entities (Entity base, Player, Enemy, …)
│   ├── UI/               ← UI widgets (Button, Label, Panel)
│   └── Utils/            ← pure helpers (math, table, string, color)
├── config/               ← runtime configuration files
├── scenes/               ← game states (Boot, Menu, Game, GameOver)
├── assets/               ← images, sounds, music, fonts, maps
├── storage/              ← saves + logs (gitignored)
├── lib/                  ← third-party Lua libraries
├── tests/                ← unit tests + runner
└── docs/                 ← additional documentation
```

## Quick start

1. Install LÖVE 11.x: <https://love2d.org/>
2. Drop the project folder anywhere.
3. Run it:

   ```bash
   # macOS / Linux
   /Applications/love.app/Contents/MacOS/love /path/to/i-love-boilerplate
   love /path/to/i-love-boilerplate

   # Windows
   "C:\Program Files\LOVE\love.exe" C:\path\to\i-love-boilerplate
   ```

4. Edit `config/game.lua` for window settings and gameplay knobs.
5. Add a new scene with `lua artisan.lua make:scene MyScene`.
6. Add an entity with `lua artisan.lua make:entity Bullet`.

## Why this layout

Laravel's design goals map surprisingly well to game development:

| Laravel concept          | LÖVE equivalent                            |
| ------------------------ | ------------------------------------------ |
| `public/index.php`       | `main.lua` (entry point, delegates)        |
| `bootstrap/app.php`      | `app/core/Application.lua`                 |
| Service container        | `Application:bind / :singleton / :make`    |
| Service providers        | `app/core/ServiceProvider.lua`             |
| Config files             | `config/*.lua` (loaded by Config service)  |
| Routes                   | Scene stack (`SceneManager`)               |
| Controllers              | `scenes/*.lua` (Scene subclasses)          |
| Models / Eloquent        | `app/Entities/*.lua` (Entity subclasses)   |
| Facades                  | `app/core/Facade.lua`                      |
| Artisan CLI              | `artisan.lua` (Lua, no LÖVE needed)        |
| Storage / logs           | `storage/saves/`, `storage/logs/`         |
| Tests                    | `tests/` + `tests/runner.lua`              |
| Composer                 | `lib/` (drop libraries here)               |

## Documentation

- [Getting started](docs/GETTING_STARTED.md)
- [Architecture overview](docs/ARCHITECTURE.md)
- [Services reference](docs/SERVICES.md)
- [Working with scenes](docs/SCENES.md)
- [Entities and the game loop](docs/ENTITIES.md)
- [Configuration](docs/CONFIGURATION.md)
- [Artisan CLI](docs/COMMANDS.md)
- [Testing](docs/TESTING.md)
- [Deploying / packaging](docs/DEPLOYMENT.md)

## License

MIT. See [LICENSE](LICENSE).
