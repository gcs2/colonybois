[CmdletBinding()]
param(
    [string[]]$Tests,
    [switch]$List,
    [switch]$All,
    [string]$ProfileId
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'AgentProfile.ps1')

function Show-TestUsage {
    Write-Output 'Usage:'
    Write-Output '  tools\Test.ps1 -List'
    Write-Output '  tools\Test.ps1 -Tests test_flight_hud,test_ui -ProfileId luna-flight'
    Write-Output '  tools\Test.ps1 -All -ProfileId sol-integration'
    Write-Output 'No arguments runs nothing. Test runs are serial and report per-test elapsed time.'
}

$hasTests = $PSBoundParameters.ContainsKey('Tests')
$selectorCount = 0
if ($List) { $selectorCount++ }
if ($All) { $selectorCount++ }
if ($hasTests) { $selectorCount++ }
if ($selectorCount -gt 1) {
    throw 'Choose exactly one selector: -List, -Tests, or -All.'
}
if ($selectorCount -eq 0) {
    Show-TestUsage
    return
}

$testPaths = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'tests') -Filter 'test_*.gd' -File | Sort-Object Name | ForEach-Object { 'tests/' + $_.Name })
if ($List) {
    $testPaths | Write-Output
    return
}

if ($hasTests) {
    if ($null -eq $Tests -or $Tests.Count -eq 0) { throw '-Tests needs at least one test name.' }
    $selectedTests = [System.Collections.Generic.List[string]]::new()
    foreach ($test in $Tests) {
        $name = $test.Trim().Replace('\', '/')
        if ($name.StartsWith('tests/', [System.StringComparison]::OrdinalIgnoreCase)) { $name = $name.Substring(6) }
        if (-not $name.EndsWith('.gd', [System.StringComparison]::OrdinalIgnoreCase)) { $name += '.gd' }
        $match = $testPaths | Where-Object { [System.StringComparer]::OrdinalIgnoreCase.Equals((Split-Path $_ -Leaf), $name) } | Select-Object -First 1
        if (-not $match) { throw "Unknown test '$test'. Use -List to see available tests." }
        if (-not $selectedTests.Contains($match)) { $selectedTests.Add($match) }
    }
    $runTests = @($selectedTests)
} else {
    $runTests = $testPaths
}
if ([string]::IsNullOrWhiteSpace($ProfileId)) {
    throw 'A unique -ProfileId is required for test runs. Use a different id for each concurrently running worktree or game instance.'
}

$enginePath = Get-AgentGodotExecutable -ProjectRoot $projectRoot
if (-not $enginePath) { throw 'Run tools\Setup.ps1 in this worktree or another worktree of this repository first.' }
$profile = New-AgentProfileProject -ProjectRoot $projectRoot -ProfileId $ProfileId
$totalTimer = [System.Diagnostics.Stopwatch]::StartNew()
$results = [System.Collections.Generic.List[object]]::new()
Push-Location $profile.ProjectPath
try {
    foreach ($testPath in $runTests) {
        Write-Host "RUN  $testPath"
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        $output = @()
        & $enginePath --headless --path $profile.ProjectPath --script $testPath 2>&1 | Tee-Object -Variable output | ForEach-Object { Write-Host $_ }
        $exitCode = $LASTEXITCODE
        $timer.Stop()
        $failed = ($exitCode -ne 0) -or [bool]($output -match 'SCRIPT ERROR:|ERROR:|FAIL:')
        $status = if ($failed) { 'FAIL' } else { 'PASS' }
        $elapsed = $timer.Elapsed.ToString('hh\:mm\:ss\.fff')
        Write-Host ("{0} {1} ({2})" -f $status, $testPath, $elapsed)
        $results.Add([pscustomobject]@{ Test = $testPath; Status = $status; ExitCode = $exitCode; Elapsed = $elapsed })
    }
} finally {
    Pop-Location
}
$totalTimer.Stop()
$passed = @($results | Where-Object Status -eq 'PASS').Count
$failedCount = $results.Count - $passed
Write-Host ("TOTAL {0} passed, {1} failed, elapsed {2}" -f $passed, $failedCount, $totalTimer.Elapsed.ToString('hh\:mm\:ss\.fff'))
Write-Host "Profile: $($profile.ProjectPath)"
if ($failedCount -gt 0) { exit 1 }
