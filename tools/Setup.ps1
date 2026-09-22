$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineDirectory = Join-Path $projectRoot '.tools\godot'
$downloadPath = Join-Path $projectRoot '.tools\godot.zip'
$enginePath = Join-Path $engineDirectory 'Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $enginePath)) {
    New-Item -ItemType Directory -Force -Path $engineDirectory | Out-Null
    Invoke-WebRequest -Uri 'https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip' -OutFile $downloadPath
    Expand-Archive -LiteralPath $downloadPath -DestinationPath $engineDirectory -Force
}
& $enginePath --headless --path $projectRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
Write-Host 'Ready. Double-click Play.cmd, or open project.godot in Godot 4.7.2.'
