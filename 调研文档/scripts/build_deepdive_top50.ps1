param(
    [string]$RootPath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = Split-Path -Parent $PSScriptRoot
}

$DataPath = Join-Path $RootPath "data"
$inFile = Join-Path $DataPath "openclaw_related_dedup_classified.json"

if (-not (Test-Path $inFile)) {
    throw "Missing input file: $inFile. Run refresh_openclaw_data.ps1 first."
}

$items = Get-Content $inFile -Raw | ConvertFrom-Json

function Get-DaysSince {
    param([string]$DateText)
    try {
        return [int]((Get-Date) - ([datetime]$DateText)).TotalDays
    }
    catch {
        return 9999
    }
}

function Get-RecencyScore {
    param([int]$Days)
    if ($Days -le 7) { return 100 }
    elseif ($Days -le 30) { return 88 }
    elseif ($Days -le 90) { return 74 }
    elseif ($Days -le 180) { return 60 }
    elseif ($Days -le 365) { return 42 }
    else { return 25 }
}

function Get-LicenseScore {
    param([string]$License)
    switch ($License) {
        "MIT" { return 100 }
        "Apache-2.0" { return 100 }
        "BSD-3-Clause" { return 95 }
        "BSD-2-Clause" { return 95 }
        "MPL-2.0" { return 90 }
        "AGPL-3.0" { return 72 }
        "GPL-3.0" { return 70 }
        "GPL-2.0" { return 65 }
        "CC0-1.0" { return 80 }
        "NOASSERTION" { return 35 }
        "" { return 30 }
        default { return 60 }
    }
}

function Get-RelevanceScore {
    param([string]$Tier)
    switch ($Tier) {
        "A-official" { return 100 }
        "A-high" { return 92 }
        "B-medium" { return 75 }
        "C-low" { return 55 }
        default { return 60 }
    }
}

function Get-CategoryWeight {
    param([string]$Category)
    switch ($Category) {
        "official" { return 100 }
        "deployment" { return 90 }
        "plugins-skills" { return 90 }
        "panel-ui" { return 85 }
        "security" { return 88 }
        "alternatives-forks" { return 70 }
        "docs-cases" { return 65 }
        "other" { return 60 }
        default { return 60 }
    }
}

function Get-CategoryLabel {
    param([string]$Category)
    switch ($Category) {
        "official" { return "official" }
        "deployment" { return "deployment" }
        "plugins-skills" { return "plugins-skills" }
        "panel-ui" { return "panel-ui" }
        "security" { return "security" }
        "alternatives-forks" { return "alternatives-forks" }
        "docs-cases" { return "docs-cases" }
        default { return "other" }
    }
}

function Get-RelevanceLabel {
    param([string]$Tier)
    switch ($Tier) {
        "A-official" { return "A-official" }
        "A-high" { return "A-high" }
        "B-medium" { return "B-medium" }
        default { return "C-low" }
    }
}

function Get-NormalizedStars {
    param([int]$Stars)
    if ($Stars -le 0) { return 0 }
    $max = 235000.0
    $s = [math]::Min($Stars, $max)
    return [int]([math]::Round((([math]::Log10($s + 1)) / ([math]::Log10($max + 1))) * 100))
}

function Get-RiskScore {
    param($Item, [int]$Days)
    $risk = 20
    if (($Item.license + "") -eq "" -or ($Item.license + "") -eq "NOASSERTION") { $risk += 18 }
    if ($Item.relevance_tier -eq "C-low") { $risk += 20 }
    elseif ($Item.relevance_tier -eq "B-medium") { $risk += 8 }
    if ($Days -gt 180) { $risk += 15 }
    elseif ($Days -gt 90) { $risk += 8 }
    if (($Item.category + "") -eq "alternatives-forks") { $risk += 12 }
    if (($Item.category + "") -eq "other") { $risk += 6 }
    if (($Item.description + "").ToLowerInvariant() -match "one-click|installer|deploy") { $risk += 4 }
    if ($risk -gt 100) { $risk = 100 }
    return $risk
}

function Get-Grade {
    param([int]$ValueScore, [int]$RiskScore)
    if ($ValueScore -ge 88 -and $RiskScore -le 35) { return "S-priority" }
    elseif ($ValueScore -ge 78 -and $RiskScore -le 50) { return "A-recommended" }
    elseif ($ValueScore -ge 68 -and $RiskScore -le 65) { return "B-usable" }
    elseif ($ValueScore -ge 58) { return "C-cautious" }
    else { return "D-watch" }
}

$scored = $items | ForEach-Object {
    $days = Get-DaysSince $_.updated_at
    $recency = Get-RecencyScore $days
    $license = Get-LicenseScore $_.license
    $relevance = Get-RelevanceScore $_.relevance_tier
    $categoryWeight = Get-CategoryWeight $_.category
    $adoption = (0.75 * (Get-NormalizedStars $_.stars)) + (0.25 * [math]::Min(100, [int]([math]::Round($_.forks / 120))))
    $maintainability = (0.45 * $recency) + (0.35 * $license) + (0.20 * $relevance)
    $fit = (0.65 * $relevance) + (0.35 * $categoryWeight)
    $risk = Get-RiskScore $_ $days
    $value = [int]([math]::Round((0.45 * $adoption) + (0.35 * $maintainability) + (0.20 * $fit)))

    [PSCustomObject]@{
        repo                 = $_.full_name
        url                  = $_.url
        category             = $_.category
        category_label       = Get-CategoryLabel $_.category
        relevance            = $_.relevance_tier
        relevance_label      = Get-RelevanceLabel $_.relevance_tier
        stars                = [int]$_.stars
        forks                = [int]$_.forks
        language             = $_.language
        license              = $_.license
        updated_at           = $_.updated_at
        days_since_update    = $days
        adoption_score       = [int]([math]::Round($adoption))
        maintainability_score = [int]([math]::Round($maintainability))
        fit_score            = [int]([math]::Round($fit))
        value_score          = $value
        risk_score           = [int]([math]::Round($risk))
        grade                = Get-Grade $value $risk
        description          = $_.description
    }
} | Sort-Object -Property @{ Expression = "value_score"; Descending = $true }, @{ Expression = "stars"; Descending = $true }

$top50 = $scored | Select-Object -First 50
$ranked = @()
$rank = 1
foreach ($r in $top50) {
    $ranked += [PSCustomObject]@{
        rank                  = $rank
        repo                  = $r.repo
        url                   = $r.url
        category_label        = $r.category_label
        relevance_label       = $r.relevance_label
        stars                 = $r.stars
        forks                 = $r.forks
        language              = $r.language
        license               = $r.license
        days_since_update     = $r.days_since_update
        adoption_score        = $r.adoption_score
        maintainability_score = $r.maintainability_score
        fit_score             = $r.fit_score
        value_score           = $r.value_score
        risk_score            = $r.risk_score
        grade                 = $r.grade
        description           = $r.description
    }
    $rank++
}

$categorySummary = $scored | Group-Object category_label | ForEach-Object {
    [PSCustomObject]@{
        category_label = $_.Name
        count       = $_.Count
        avg_value   = [int]([math]::Round(($_.Group | Measure-Object value_score -Average).Average))
        avg_risk    = [int]([math]::Round(($_.Group | Measure-Object risk_score -Average).Average))
    }
} | Sort-Object avg_value -Descending

$ranked | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $DataPath "openclaw_deepdive_top50_scored.json") -Encoding UTF8
$ranked | Export-Csv (Join-Path $DataPath "openclaw_deepdive_top50_scored.csv") -NoTypeInformation -Encoding UTF8
$categorySummary | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $DataPath "openclaw_deepdive_category_summary.json") -Encoding UTF8

Write-Host "Deep dive outputs updated under: $DataPath"
