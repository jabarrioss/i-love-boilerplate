# Deployment

LÖVE games are distributed as a `.love` file (a ZIP of your project)
or as a fused executable that bundles the engine.

## Building a `.love` file

From the project root, on macOS / Linux:

```bash
zip -9 -r ../my-game.love . -x "*.git*" "storage/*" "tests/*" "docs/*"
```

On Windows with PowerShell:

```powershell
Compress-Archive -Path * -DestinationPath ..\my-game.love -Force
```

Then test it:

```bash
# macOS
/Applications/love.app/Contents/MacOS/love my-game.love

# Windows
& "C:\Program Files\LOVE\love.exe" my-game.love

# Linux
love my-game.love
```

## What's safe to exclude

```
storage/saves/    ← user saves, machine-specific
storage/logs/     ← debug output
tests/            ← not needed at runtime
docs/             ← optional, but doesn't hurt to include
.git/             ← obviously
build/            ← if you have one
```

`main.lua` must be at the root of the ZIP.

## Fusing with love.exe (Windows)

```bat
copy /b "C:\Program Files\LOVE\love.exe" + my-game.love my-game.exe
```

The result is a single `.exe` that runs without LÖVE installed.

## macOS .app

```bash
cp -r /Applications/love.app My-Game.app
cp my-game.love My-Game.app/Contents/Resources/
# Edit Info.plist to update CFBundleName, CFBundleIdentifier
```

## iOS

Building for iOS requires Xcode and the iOS build of LÖVE. See the
upstream guide: <https://love2d.org/wiki/Game_Distribution>

## Linux AppImage

Tools like [love-release](https://github.com/MisterDA/love-release)
or [makelove](https://github.com/pfirsich/makelove) handle this.

## Building a release

1. Set `config/game.lua → dev = false` and `debug = false`.
2. Set `config/app.lua → logging.level = "warn"` or `"error"`.
3. Strip unused LÖVE modules in `conf.lua`.
4. Strip your game's debug code.
5. Run the build commands above.

## CI pipeline

```yaml
# .github/workflows/build.yml
name: Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install LÖVE
        run: sudo apt-get install -y love
      - name: Run tests
        run: lua tests/runner.lua
      - name: Build .love
        run: |
          mkdir -p build
          zip -9 -r build/my-game.love . -x "*.git*" "storage/*" "tests/*" "docs/*"
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: my-game
          path: build/my-game.love
```

## Versioning

Keep `config/game.lua → version` in sync with git tags:

```bash
git tag v0.1.0
git push --tags
```

The `version` field is surfaced in the debug overlay so QA can
confirm what's running.
