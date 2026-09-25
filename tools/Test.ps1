[CmdletBinding()]
param(
    [string[]]$Tests,
    [switch]$All,
    [switch]$List,
    [string]$Profile,
    [string]$GodotPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$launcherPath = Join-Path $PSScriptRoot 'RunGodot.ps1'
$registeredTests = @(
    'tests/test_simulation.gd',
    'tests/test_urban.gd',
    'tests/test_landing.gd',
    'tests/test_city.gd',
    'tests/test_ui.gd',
    'tests/test_encounter.gd',
    'tests/test_expedition_session.gd',
    'tests/test_interstellar_travel.gd',
    'tests/test_galaxy.gd',
    'tests/test_system_chart.gd',
    'tests/test_navigation_fullscreen.gd',
    'tests/test_space_commerce.gd',
    'tests/test_progression.gd',
    'tests/test_space_signals.gd',
    'tests/test_empire_conflict.gd',
    'tests/test_territories.gd',
    'tests/test_ship_capacity.gd',
    'tests/test_ship_support.gd',
    'tests/test_repair_supplies.gd',
    'tests/test_dock_repair.gd',
    'tests/test_expedition_diplomacy.gd',
    'tests/test_contact_presentation.gd',
    'tests/test_expedition_colonies.gd',
    'tests/test_expedition_freight.gd',
    'tests/test_freight_piracy.gd',
    'tests/test_equipment.gd',
    'tests/test_energy.gd',
    'tests/test_orbital_threat.gd',
    'tests/test_orbital_combat.gd',
    'tests/test_orbital_encounters.gd',
    'tests/test_surface_combat.gd',
    'tests/test_allied_fleet.gd',
    'tests/test_planet_climate.gd',
    'tests/test_planet_biosphere.gd',
    'tests/test_flight.gd',
    'tests/test_flight_transitions.gd',
    'tests/test_flight_hud.gd',
    'tests/test_palette_capacity.gd',
    'tests/test_flight_presentation.gd',
    'tests/test_scout.gd',
    'tests/test_audio.gd',
    'tests/test_planet_map.gd',
    'tests/test_planet_generation.gd'
)

function Show-Usage {
    Write-Host 'Usage: Test.ps1 -Tests <name-or-path> [, <name-or-path> ...] [-Profile <label>] [-GodotPath <exe>]'
    Write-Host '       Test.ps1 -All [-Profile <label>] [-GodotPath <exe>]'
    Write-Host '       Test.ps1 -List'
    Write-Host 'No arguments runs nothing. Use -List to inspect the registered tests.'
}

if ($PSBoundParameters.Count -eq 0) {
    Show-Usage
    return
}

if (($List -and ($All -or $PSBoundParameters.ContainsKey('Tests') -or $PSBoundParameters.ContainsKey('Profile') -or $PSBoundParameters.ContainsKey('GodotPath'))) -or
    ($All -and $PSBoundParameters.ContainsKey('Tests')) -or
    (-not $List -and -not $All -and -not $PSBoundParameters.ContainsKey('Tests'))) {
    Show-Usage
    throw 'Choose exactly one of -Tests, -All, or -List. -Profile and -GodotPath can only be used with -Tests or -All.'
}

if ($List) {
    $registeredTests | ForEach-Object { Write-Host $_ }
    return
}

$selectedTests = @()
if ($All) {
    $selectedTests = $registeredTests
} else {
    if ($null -eq $Tests -or $Tests.Count -eq 0) {
        Show-Usage
        throw '-Tests requires at least one test name or path.'
    }

    $requestedStems = @()
    foreach ($requested in $Tests) {
        $normalized = $requested.Trim().Replace('\', '/')
        if ([string]::IsNullOrWhiteSpace($normalized)) {
            throw 'Test names and paths cannot be empty.'
        }
        if ([IO.Path]::IsPathRooted($normalized)) {
            $normalizedFullPath = [IO.Path]::GetFullPath($normalized)
            $candidate = $registeredTests | Where-Object {
                [string]::Equals([IO.Path]::GetFullPath((Join-Path $projectRoot $_)), $normalizedFullPath, [StringComparison]::OrdinalIgnoreCase)
            } | Select-Object -First 1
            if ($null -eq $candidate) { throw "Unknown test: $requested" }
            $requestedStems += [IO.Path]::GetFileNameWithoutExtension($candidate)
            continue
        }
        $normalized = $normalized.TrimStart('./')
        $stem = [IO.Path]::GetFileNameWithoutExtension($normalized)
        $candidate = $registeredTests | Where-Object {
            $registeredStem = [IO.Path]::GetFileNameWithoutExtension($_)
            [string]::Equals($_, $normalized, [StringComparison]::OrdinalIgnoreCase) -or
                [string]::Equals($registeredStem, $stem, [StringComparison]::OrdinalIgnoreCase)
        } | Select-Object -First 1
        if ($null -eq $candidate) { throw "Unknown test: $requested" }
        $requestedStems += [IO.Path]::GetFileNameWithoutExtension($candidate)
    }
    $requestedSet = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($stem in $requestedStems) { [void]$requestedSet.Add($stem) }
    $selectedTests = @($registeredTests | Where-Object { $requestedSet.Contains([IO.Path]::GetFileNameWithoutExtension($_)) })
}

$enginePath = if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    Join-Path $projectRoot '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
} else {
    [IO.Path]::GetFullPath($GodotPath)
}
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Run tools\Setup.ps1 first.' }
if (-not (Test-Path -LiteralPath $launcherPath)) { throw 'tools\RunGodot.ps1 is missing.' }

Push-Location $projectRoot
$totalTimer = [Diagnostics.Stopwatch]::StartNew()
try {
    New-Item -ItemType Directory -Force -Path artifacts | Out-Null
    foreach ($testPath in $selectedTests) {
        $testTimer = [Diagnostics.Stopwatch]::StartNew()
        Write-Host "`n=== $testPath ==="
        try {
            $launcherArgs = @{
                Headless = $true
                GodotArgs = @('--script', $testPath)
            }
            if (-not [string]::IsNullOrWhiteSpace($Profile)) { $launcherArgs.Profile = $Profile }
            if (-not [string]::IsNullOrWhiteSpace($GodotPath)) { $launcherArgs.GodotPath = $enginePath }
            $testOutput = & $launcherPath @launcherArgs 2>&1
            $testExit = $LASTEXITCODE
            $testOutput | ForEach-Object { Write-Host $_ }
            if ($testExit -ne 0 -or ($testOutput -match 'SCRIPT ERROR:|ERROR:|FAIL:')) {
                throw "Failed: $testPath (exit $testExit)"
            }
        } finally {
            $testTimer.Stop()
            Write-Host ('Elapsed {0}: {1:N2}s' -f $testPath, $testTimer.Elapsed.TotalSeconds)
        }
    }
} finally {
    $totalTimer.Stop()
    Write-Host ('Total elapsed: {0:N2}s' -f $totalTimer.Elapsed.TotalSeconds)
    Pop-Location
}
