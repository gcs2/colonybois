$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineDirectory = Join-Path $projectRoot '.tools\godot'
$enginePath = Join-Path $engineDirectory 'Godot_v4.7.2-stable_win64_console.exe'
$outputDirectory = Join-Path $projectRoot ('build\versions\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Run tools\Setup.ps1 first.' }
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
# This local developer build uses the pinned engine as its executable. A public
# release should use Godot export templates to omit editor features and reduce size.
& $enginePath --headless --path $projectRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Import failed.' }
$packPath = Join-Path $outputDirectory 'FrontierWorlds.pck'
& $enginePath --headless --path $projectRoot --export-pack 'Windows Desktop' $packPath
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $packPath)) { throw 'Pack export failed.' }
Copy-Item -LiteralPath (Join-Path $engineDirectory 'Godot_v4.7.2-stable_win64.exe') -Destination (Join-Path $outputDirectory 'FrontierWorlds.exe') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $outputDirectory 'README.md') -Force
[System.IO.File]::WriteAllText((Join-Path $projectRoot 'build\current.txt'),(Join-Path $outputDirectory 'FrontierWorlds.exe'))
Write-Host "Built $outputDirectory\FrontierWorlds.exe. Keep its .pck file beside it."
