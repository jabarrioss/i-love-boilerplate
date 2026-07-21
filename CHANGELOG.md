# Changelog

All notable changes to this boilerplate are documented here. The
format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

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
