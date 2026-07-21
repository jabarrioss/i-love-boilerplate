#!/usr/bin/env bash
# run.sh — boots the project with LÖVE 2D on Linux/macOS.
# Usage: ./run.sh [--console]

set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

LOVE_BIN="$(command -v love || true)"
if [ -z "$LOVE_BIN" ] && [ -d "/Applications/love.app" ]; then
    LOVE_BIN="/Applications/love.app/Contents/MacOS/love"
fi

if [ -z "$LOVE_BIN" ]; then
    echo "[run.sh] Could not find love. Install Love2D 11.x from https://love2d.org/"
    exit 1
fi

if [ "$1" = "--console" ]; then
    exec "$LOVE_BIN" --console .
else
    exec "$LOVE_BIN" .
fi
