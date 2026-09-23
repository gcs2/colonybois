$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$specPath = Join-Path $projectRoot 'art\specs\space_stage_interface_v2.json'
$outputPath = Join-Path $projectRoot 'docs\ui-review\data.js'
$source = [System.IO.File]::ReadAllText($specPath, [System.Text.Encoding]::UTF8)
$specification = $source | ConvertFrom-Json
if ($specification.id -ne 'space_stage_interface_v2' -or $specification.states.Count -ne 10) {
    throw 'Expected the ten-state Space Stage interface specification.'
}
# Preserve the authored JSON exactly; it is data in a separate script, not inline HTML.
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputPath, ('const REVIEW = ' + $source.TrimEnd() + ';' + [Environment]::NewLine), $utf8)
Write-Host 'Updated docs/ui-review/data.js from the interface specification.'
