$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Run tools\Setup.ps1 first.' }
Push-Location $projectRoot
try {
    New-Item -ItemType Directory -Force -Path artifacts | Out-Null
    foreach ($testPath in @('tests/test_simulation.gd', 'tests/test_urban.gd', 'tests/test_landing.gd', 'tests/test_city.gd', 'tests/test_ui.gd', 'tests/test_encounter.gd', 'tests/test_expedition_session.gd', 'tests/test_interstellar_travel.gd', 'tests/test_space_commerce.gd', 'tests/test_expedition_diplomacy.gd', 'tests/test_expedition_colonies.gd', 'tests/test_equipment.gd', 'tests/test_energy.gd', 'tests/test_orbital_threat.gd', 'tests/test_orbital_combat.gd', 'tests/test_flight.gd', 'tests/test_flight_transitions.gd', 'tests/test_flight_hud.gd', 'tests/test_palette_capacity.gd', 'tests/test_flight_presentation.gd', 'tests/test_audio.gd', 'tests/test_planet_map.gd', 'tests/test_planet_generation.gd')) {
        $testOutput = & $enginePath --headless --path $projectRoot --script $testPath 2>&1
        $testExit = $LASTEXITCODE
        $testOutput | ForEach-Object { Write-Host $_ }
        if ($testExit -ne 0 -or ($testOutput -match 'SCRIPT ERROR:|ERROR:|FAIL:')) { throw "Failed: $testPath" }
    }
} finally { Pop-Location }
