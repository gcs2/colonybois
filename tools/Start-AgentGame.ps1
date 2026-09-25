[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProfileId,
    [string]$Scene,
    [ValidatePattern('^\d{3,5}x\d{3,5}$')][string]$Resolution = '1600x900',
    [switch]$Maximized
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'AgentProfile.ps1')
$profile = New-AgentProfileProject -ProjectRoot $projectRoot -ProfileId $ProfileId
$enginePath = Get-AgentGodotExecutable -ProjectRoot $projectRoot
if (-not $enginePath) {
    throw 'Run tools\Setup.ps1 in this worktree first.'
}

$arguments = @('--path', ('"' + $profile.ProjectPath + '"'), '--resolution', $Resolution, '--log-file', ('"' + (Join-Path $profile.ArtifactPath 'game.log') + '"'))
if (-not [string]::IsNullOrWhiteSpace($Scene)) {
    $arguments += @('--scene', ('"' + $Scene + '"'))
}
if ($Maximized) { $arguments += '--maximized' }
$process = Start-Process -FilePath $enginePath -ArgumentList $arguments -WorkingDirectory $profile.ProjectPath -PassThru
Write-Output "Started Godot PID $($process.Id)"
Write-Output "Project profile: $($profile.ProjectPath)"
Write-Output "Save profile: $($profile.CustomUserDirName)"
Write-Output "Artifacts: $($profile.ArtifactPath)"
