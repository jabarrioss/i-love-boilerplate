# Changelog

All notable changes to this boilerplate are documented here. The
format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Fixed
- `input:pressed("jump")` polled from a scene's `update(dt)` always
  returned `false` because `Application:update` cleared the
  "just pressed" state BEFORE the scene's update ran. The clear
  is now performed at the end of the frame so the documented
  single-frame query actually works.
- `GameScene` registered a fresh `enemy:killed` listener every time
  it re-entered the stack, so the score would tick up multiple
  times per kill after a restart. The handler is now stored on
  the scene and removed in `exit()`.
- `Entity` had no `setApp` hook, so every scene that spawned a
  `Player` or `Enemy` had to remember to assign `e.app = self.app`
  manually. Added `Entity:setApp(app)` (chainable) and switched
  the sample scenes to use it.
- `Class:extend` set `__call = cls` on the new class's metatable
  (a leftover from a previous edit that overwrote a working
  function-form `__call`). `MyClass(args)` would either error
  ("attempt to call a table value") or recurse forever depending
  on the Lua version. The metatable now installs a proper
  function-form `__call`, and the base `Class` table itself
  receives a metatable so `Class()` works too.
- `Facade:extend` had the same double-`setmetatable` / dead-code
  pattern. Collapsed into a single metatable install.
- `TestCase:new` mutated the class itself instead of creating a
  fresh instance — every test file shared the same `passed` /
  `failed` counters and the runner had to detour through
  `getmetatable` to find any test methods. Fixed; the runner
  now operates on a real per-instance state.

### Changed
- `TestCase:run` rewritten to walk the class chain explicitly
  with a `seen` set, so subclass overrides of inherited tests
  take precedence and each test runs exactly once.
- `artisan.lua` no longer carries a dead `pascalToSnake` helper
  that nothing called.
- `docs/ARCHITECTURE.md` updated to reflect the new
  `Application:update` order (input clear runs last).

### Added
- `tests/test_bugfixes.lua` and `tests/ProbeScene.lua` —
  regression tests covering the fixes above. The probe scene
  is registered under the name "Probe" and is otherwise inert.

## [0.1.0] - 2026-07-21

### Added
- Initial boilerplate structure modeled on Laravel.
- Service container with eager / lazy / factory bindings.
- Service providers with `register` / `boot` phases.
- Built-in services: Config, Logger, Event bus, AssetManager,
  InputManager, AudioManager, Camera, SaveManager, Random, Easing,
  Scheduler, SceneManager.
- Facade base for short static accessors.
- Class system with `super` and `is` checks.
- Event bus with `on` / `once` / `off` / `emit` / `*` wildcard / filters.
- Scene stack with `push` / `pop` / `swap` / `replace`.
- `Entity` base class for game objects.
- `Button`, `Label`, `Panel` UI components.
- `math`, `table`, `string`, `color` utility modules.
- `artisan.lua` CLI for scaffolding scenes, entities, services,
  tests, UI components, and config files.
- Test runner + base `TestCase` class.
- Sample tests for Class, Event, and math utilities.
- Sample scenes: Boot, Menu, Game, GameOver.
- Sample entities: Player, Enemy.
- Documentation: README + GETTING_STARTED, ARCHITECTURE, SERVICES,
  SCENES, ENTITIES, CONFIGURATION, COMMANDS, TESTING, DEPLOYMENT.

[Unreleased]: https://example.com/i-love-boilerplate
