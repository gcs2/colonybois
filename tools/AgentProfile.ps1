function New-AgentProfileProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$ProfileId
    )

    if ($ProfileId -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,47}$') {
        throw 'ProfileId must start with a letter or number and contain only letters, numbers, dot, underscore, or hyphen (48 characters max).'
    }
    $ProjectRoot = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $ProjectRoot).Path)
    $sourceProjectFile = Join-Path $ProjectRoot 'project.godot'
    if (-not (Test-Path -LiteralPath $sourceProjectFile -PathType Leaf)) {
        throw "No project.godot found under $ProjectRoot."
    }

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $rootBytes = [System.Text.Encoding]::UTF8.GetBytes($ProjectRoot.ToLowerInvariant())
        $worktreeTag = ([System.BitConverter]::ToString($sha.ComputeHash($rootBytes)) -replace '-', '').Substring(0, 12).ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
    $profileBase = Join-Path $ProjectRoot '.local\agent-profiles'
    $profileRoot = Join-Path (Join-Path $profileBase $worktreeTag) $ProfileId
    $customUserDirName = "Frontier Worlds/agent-runs/$worktreeTag/$ProfileId"
    $markerPath = Join-Path $profileRoot '.agent-profile.json'

    if (Test-Path -LiteralPath $profileRoot) {
        if (-not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
            throw "Refusing to reuse unmanaged profile directory: $profileRoot"
        }
        $marker = Get-Content -LiteralPath $markerPath -Raw | ConvertFrom-Json
        if (-not [System.StringComparer]::OrdinalIgnoreCase.Equals([string]$marker.ProjectRoot, $ProjectRoot) -or
            [string]$marker.ProfileId -cne $ProfileId -or [string]$marker.CustomUserDirName -cne $customUserDirName) {
            throw "Profile metadata does not match this worktree and id: $profileRoot"
        }
    } else {
        $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profileRoot)
        $stagingRoot = Join-Path (Split-Path -Parent $profileRoot) ('.' + $ProfileId + '.init-' + [guid]::NewGuid().ToString('N'))
        $null = New-Item -ItemType Directory -Path $stagingRoot
        $excludedDirectories = @('.git', '.godot', '.tools', '.local', 'artifacts', 'build')
        foreach ($entry in Get-ChildItem -LiteralPath $ProjectRoot -Force) {
            if ($entry.PSIsContainer) {
                if ($excludedDirectories -contains $entry.Name) { continue }
                $junctionPath = Join-Path $stagingRoot $entry.Name
                $null = New-Item -ItemType Junction -Path $junctionPath -Target $entry.FullName
                continue
            }
            if ($entry.Name -in @('.git', 'project.godot', '.agent-profile.json') -or $entry.Name.EndsWith('.tmp', [System.StringComparison]::OrdinalIgnoreCase)) { continue }
            Copy-Item -LiteralPath $entry.FullName -Destination (Join-Path $stagingRoot $entry.Name)
        }

        $marker = [pscustomobject]@{
            ProjectRoot = $ProjectRoot
            ProfileId = $ProfileId
            CustomUserDirName = $customUserDirName
        }
        [System.IO.File]::WriteAllText((Join-Path $stagingRoot '.agent-profile.json'), ($marker | ConvertTo-Json), [System.Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $stagingRoot -Destination $profileRoot
    }

    $projectText = [System.IO.File]::ReadAllText($sourceProjectFile)
    $newline = if ($projectText.Contains("`r`n")) { "`r`n" } else { "`n" }
    $projectText = [regex]::Replace($projectText, '(?m)^use_custom_user_dir\s*=.*(?:\r?\n|$)', '')
    $projectText = [regex]::Replace($projectText, '(?m)^custom_user_dir_name\s*=.*(?:\r?\n|$)', '')
    $applicationHeader = [regex]::Match($projectText, '(?m)^\[application\](?:\r?\n|$)')
    if (-not $applicationHeader.Success) {
        throw "The project has no [application] section: $sourceProjectFile"
    }
    $settings = 'use_custom_user_dir=true' + $newline + 'custom_user_dir_name="' + $customUserDirName + '"' + $newline
    $projectText = $projectText.Substring(0, $applicationHeader.Index) + '[application]' + $newline + $settings + $projectText.Substring($applicationHeader.Index + $applicationHeader.Length)
    [System.IO.File]::WriteAllText((Join-Path $profileRoot 'project.godot'), $projectText, [System.Text.UTF8Encoding]::new($false))

    $cacheBase = Join-Path (Join-Path $profileBase $worktreeTag) 'shared-godot-cache'
    $null = New-Item -ItemType Directory -Force -Path $cacheBase
    $profileCache = Join-Path $profileRoot '.godot'
    if (-not (Test-Path -LiteralPath $profileCache)) {
        $null = New-Item -ItemType Junction -Path $profileCache -Target $cacheBase
    }

    $artifactRoot = Join-Path $profileRoot 'artifacts'
    $null = New-Item -ItemType Directory -Force -Path $artifactRoot
    return [pscustomobject]@{
        ProjectRoot = $ProjectRoot
        ProjectPath = $profileRoot
        WorktreeTag = $worktreeTag
        ProfileId = $ProfileId
        CustomUserDirName = $customUserDirName
        GodotCachePath = $cacheBase
        ArtifactPath = $artifactRoot
    }
}

function Get-AgentGodotExecutable {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)

    $ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
    $relativeEngine = '.tools\godot\Godot_v4.7.2-stable_win64_console.exe'
    $localEngine = Join-Path $ProjectRoot $relativeEngine
    if (Test-Path -LiteralPath $localEngine -PathType Leaf) { return $localEngine }

    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCommand) { return $null }
    $worktreeOutput = @(& $gitCommand.Source -C $ProjectRoot worktree list --porcelain 2>$null)
    foreach ($line in $worktreeOutput) {
        if ($line -notmatch '^worktree (.+)$') { continue }
        $candidate = Join-Path $Matches[1] $relativeEngine
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $null
}
