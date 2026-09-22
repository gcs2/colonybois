@echo off
setlocal
set "ENGINE=%~dp0.tools\godot\Godot_v4.7.2-stable_win64.exe"
if exist "%~dp0build\FrontierWorlds.exe" (
    start "Frontier Worlds" "%~dp0build\FrontierWorlds.exe"
    exit /b
)
if exist "%ENGINE%" (
    start "Frontier Worlds" "%ENGINE%" --path "%~dp0."
    exit /b
)
echo Install Godot 4.7.2 and import project.godot, or run tools\Setup.ps1.
pause
