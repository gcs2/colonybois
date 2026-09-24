@echo off
setlocal
set "TAVI_PROOF=%~dp0"
for %%I in ("%~dp0..\..\..") do set "TAVI_REPO=%%~fI"
set "TAVI_PYTHON=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
set "TAVI_GODOT=%TAVI_REPO%\.tools\godot\Godot_v4.7.2-stable_win64.exe"
if not exist "%TAVI_PYTHON%" (
  echo Python with NumPy and Pillow is required. See README.md.
  pause
  exit /b 1
)
if not exist "%TAVI_GODOT%" (
  echo The pinned Godot 4.7.2 runtime was not found. See README.md.
  pause
  exit /b 1
)
"%TAVI_PYTHON%" "%TAVI_PROOF%skin_texture.py"
if errorlevel 1 exit /b 1
"%TAVI_GODOT%" --headless --path "%TAVI_PROOF%." --editor --import --quit --log-file "%TAVI_PROOF%import.log"
if errorlevel 1 exit /b 1
start "Tavi - actual 3D maquette" "%TAVI_GODOT%" --path "%TAVI_PROOF%." --audio-driver Dummy -- --inspect
exit /b 0
