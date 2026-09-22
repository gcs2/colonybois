$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Run tools\Setup.ps1 first.' }
Push-Location $projectRoot
try {
    New-Item -ItemType Directory -Force -Path artifacts | Out-Null
    foreach ($testPath in @('tests/test_simulation.gd', 'tests/test_ui.gd')) {
        $testOutput = & $enginePath --headless --path $projectRoot --script $testPath 2>&1
        $testExit = $LASTEXITCODE
        $testOutput | ForEach-Object { Write-Host $_ }
        if ($testExit -ne 0 -or ($testOutput -match 'SCRIPT ERROR:|ERROR:|FAIL:')) { throw "Failed: $testPath" }
    }
} finally { Pop-Location }
