@echo off
REM run.bat — boots the project with LÖVE 2D on Windows.
REM Auto-detects the LÖVE install path and always runs from this folder.

setlocal

set "LOVE_EXE=%ProgramFiles%\LOVE\love.exe"
if not exist "%LOVE_EXE%" set "LOVE_EXE=%ProgramW6432%\LOVE\love.exe"
if not exist "%LOVE_EXE%" set "LOVE_EXE=%LOCALAPPDATA%\Programs\LOVE\love.exe"
if not exist "%LOVE_EXE%" (
    echo [run.bat] Could not find love.exe. Install Love2D 11.x from https://love2d.org/
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%"

if "%1"=="--console" (
    shift
    "%LOVE_EXE%" --console .
) else (
    "%LOVE_EXE%" .
)

popd
endlocal
