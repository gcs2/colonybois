[CmdletBinding()]
param(
    [switch]$Editor,
    [switch]$Headless,
    [string]$Profile,
    [string]$GodotPath,
    [string[]]$GodotArgs = @()
)

$ErrorActionPreference = 'Stop'
if ($Editor -and $Headless) { throw 'Choose either -Editor or -Headless.' }

$projectRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$engineDirectory = Join-Path $projectRoot '.tools\godot'
$engineName = if ($Headless) { 'Godot_v4.7.2-stable_win64_console.exe' } else { 'Godot_v4.7.2-stable_win64.exe' }
$enginePath = if ([string]::IsNullOrWhiteSpace($GodotPath)) { Join-Path $engineDirectory $engineName } else { [IO.Path]::GetFullPath($GodotPath) }
if (-not (Test-Path -LiteralPath $enginePath)) { throw 'Run tools\Setup.ps1 first.' }

$normalizedRoot = $projectRoot.Replace('\', '/').ToLowerInvariant()
$sha256 = [Security.Cryptography.SHA256]::Create()
try {
    $pathBytes = [Text.Encoding]::UTF8.GetBytes($normalizedRoot)
    $pathHash = [Convert]::ToHexString($sha256.ComputeHash($pathBytes)).Substring(0, 16).ToLowerInvariant()
} finally {
    $sha256.Dispose()
}

$profileSuffix = ''
if (-not [string]::IsNullOrWhiteSpace($Profile)) {
    $profileLabel = [regex]::Replace($Profile.Trim().ToLowerInvariant(), '[^a-z0-9]+', '-')
    $profileLabel = $profileLabel.Trim('-')
    if ([string]::IsNullOrWhiteSpace($profileLabel)) { throw 'Profile labels must contain at least one letter or number.' }
    if ($profileLabel.Length -gt 32) { $profileLabel = $profileLabel.Substring(0, 32).TrimEnd('-') }
    $profileSuffix = "-$profileLabel"
}
$profileName = "Frontier Worlds-Worktree-$pathHash$profileSuffix"
$overridePath = Join-Path $projectRoot 'override.cfg'
$overrideText = "[application]`r`nconfig/use_custom_user_dir=true`r`nconfig/custom_user_dir_name=`"$profileName`"`r`n"

# The override is deliberately exclusive and temporary. Never replace a developer's existing override.cfg.
$fileStream = $null
$createdOverride = $false
try {
    $fileStream = [IO.File]::Open($overridePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    $createdOverride = $true
    $overrideBytes = [Text.UTF8Encoding]::new($false).GetBytes($overrideText)
    $fileStream.Write($overrideBytes, 0, $overrideBytes.Length)
} catch [IO.IOException] {
    if ($null -ne $fileStream) { $fileStream.Dispose(); $fileStream = $null }
    if ($createdOverride -and (Test-Path -LiteralPath $overridePath)) { Remove-Item -LiteralPath $overridePath -Force }
    throw "Cannot apply isolated user-data profile because '$overridePath' already exists or cannot be created. It was left untouched."
} finally {
    if ($null -ne $fileStream) { $fileStream.Dispose() }
}

try {
    $cliArgs = @()
    if ($Headless) { $cliArgs += '--headless' }
    if ($Editor) { $cliArgs += '--editor' }
    $cliArgs += @('--path', $projectRoot)
    $cliArgs += $GodotArgs

    & $enginePath @cliArgs
    $engineExitCode = $LASTEXITCODE
    $global:LASTEXITCODE = $engineExitCode
    return
} finally {
    # Delete only the file whose exact contents this invocation wrote.
    if ((Test-Path -LiteralPath $overridePath) -and [IO.File]::ReadAllText($overridePath) -ceq $overrideText) {
        Remove-Item -LiteralPath $overridePath -Force
    }
}
