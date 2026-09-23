$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$inventory = Get-Content (Join-Path $projectRoot 'docs/parity/reference_inventory.json') -Raw | ConvertFrom-Json
$progression = Get-Content (Join-Path $projectRoot 'docs/parity/reference_progression.json') -Raw | ConvertFrom-Json
$board = Get-Content (Join-Path $projectRoot 'docs/TASK_BOARD.md') -Raw
$owners = @([regex]::Matches($board, '(?m)^\| ([A-Z]\d\d) \|') | ForEach-Object { $_.Groups[1].Value })

function Assert-Unique($values, [string]$label) {
    $seen = @{}
    foreach ($value in $values) {
        if ([string]::IsNullOrWhiteSpace([string]$value) -or $seen.ContainsKey([string]$value)) {
            throw "Empty or duplicate ${label}: $value"
        }
        $seen[[string]$value] = $true
    }
}
function Assert-Owner([string]$owner) {
    if ($owner -notin $owners) { throw "Missing task board owner: $owner" }
}
function Assert-Mapping($mapping) {
    if ($mapping) {
        $path = ([string]$mapping -split ':', 2)[0]
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $path) -PathType Leaf)) {
            throw "Missing implementation reference: $path"
        }
    }
}
function Assert-Url([string]$url) {
    $uri = $null
    if (-not [uri]::TryCreate($url, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
        throw "Invalid source URL: $url"
    }
}

if ($inventory.schema -ne 1 -or $progression.schema -ne 1) { throw 'Unsupported manifest schema.' }
Assert-Unique $owners 'task owner'
Assert-Unique $inventory.families.id 'tool family'
Assert-Unique $inventory.open_questions.id 'open question'
foreach ($source in $inventory.sources.PSObject.Properties) { Assert-Url $source.Value.url }
foreach ($source in $progression.sources.PSObject.Properties) { Assert-Url $source.Value }
foreach ($question in $inventory.open_questions) { Assert-Owner $question.owner }
foreach ($family in $inventory.families) {
    Assert-Owner $family.owner
    if (@($family.variants).Count -eq 0) { throw "Empty family: $($family.id)" }
    Assert-Unique $family.variants "variant in $($family.id)"
    if ($family.source -notin $inventory.sources.PSObject.Properties.Name) { throw "Missing source: $($family.id)" }
    if ($family.decision -notin @('retain', 'adapt', 'deferred')) { throw "Invalid decision: $($family.id)" }
    foreach ($questionId in $family.open) {
        if ($questionId -notin $inventory.open_questions.id) { throw "Unknown audit question: $questionId" }
    }
    Assert-Mapping $family.mapping
}
Assert-Owner $progression.owner
Assert-Owner $progression.consequence_traits.owner
Assert-Unique $progression.badges.id 'badge'
Assert-Unique $progression.achievements.name 'achievement'
Assert-Unique $progression.master_ranks.names 'rank'
Assert-Unique $progression.consequence_traits.names 'trait'
foreach ($badge in $progression.badges) {
    if ($badge.tiers -notin @(1, 5)) { throw "Unrecognized tier count: $($badge.id)" }
    Assert-Mapping $badge.mapping
}
foreach ($achievement in $progression.achievements) {
    if ($achievement.source -notin $progression.sources.PSObject.Properties.Name) { throw "Missing achievement source: $($achievement.name)" }
    Assert-Mapping $achievement.mapping
}
if ($progression.master_ranks.points.Count -ne $progression.master_ranks.names.Count) { throw 'Rank names/points mismatch.' }
$previousPoints = 0
foreach ($points in $progression.master_ranks.points) {
    if ($points -le $previousPoints) { throw 'Rank points must increase.' }
    $previousPoints = $points
}

Write-Output "Reference inventory dated $($inventory.as_of), compared with $($inventory.implementation_commit)"
$inventory.families | Group-Object category | ForEach-Object {
    [pscustomobject]@{
        Category = $_.Name
        Owners = ($_.Group.owner | Sort-Object -Unique) -join ', '
        Families = $_.Count
        Variants = @($_.Group | ForEach-Object { $_.variants }).Count
    }
} | Format-Table -AutoSize
$variantCount = @($inventory.families | ForEach-Object { $_.variants }).Count
$tierCount = ($progression.badges | Measure-Object -Property tiers -Sum).Sum
Write-Output "$($inventory.families.Count) families / $variantCount variant entries; $($inventory.open_questions.Count) open audit questions."
Write-Output "$($progression.badges.Count) badge families / $tierCount listed tiers; $($progression.master_ranks.names.Count) ranks; $($progression.achievements.Count) achievements; $($progression.consequence_traits.names.Count) traits."
Write-Output $inventory.closure
Write-Output $progression.closure
Write-Output 'Structure and references valid. Counts are research coverage, not completion or runtime verification.'
