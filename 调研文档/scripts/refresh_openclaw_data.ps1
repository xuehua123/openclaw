param(
    [string]$RootPath = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = Split-Path -Parent $PSScriptRoot
}

$DataPath = Join-Path $RootPath "data"
New-Item -ItemType Directory -Force -Path $DataPath | Out-Null

function Save-Json {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )
    $Object | ConvertTo-Json -Depth 100 | Set-Content -Path $Path -Encoding UTF8
}

function Get-Json {
    param([Parameter(Mandatory = $true)][string]$Url)
    Invoke-RestMethod -Uri $Url
}

Write-Host "==> Fetching official OpenClaw data..."

Save-Json (Get-Json "https://api.github.com/orgs/openclaw") (Join-Path $DataPath "org_openclaw.json")
Save-Json (Get-Json "https://api.github.com/orgs/openclaw/repos?per_page=100&type=public") (Join-Path $DataPath "org_openclaw_repos.json")
Save-Json (Get-Json "https://api.github.com/repos/openclaw/openclaw") (Join-Path $DataPath "repo_openclaw_main.json")
Save-Json (Get-Json "https://api.github.com/repos/openclaw/openclaw/releases?per_page=30") (Join-Path $DataPath "repo_openclaw_releases_30.json")
Save-Json (Get-Json "https://api.github.com/repos/openclaw/openclaw/forks?per_page=100&sort=stargazers") (Join-Path $DataPath "repo_openclaw_forks_top100.json")

Write-Host "==> Fetching ecosystem search slices..."

$queryMap = @{
    "search_topic_openclaw_p1.json"            = "https://api.github.com/search/repositories?q=topic%3Aopenclaw&sort=stars&order=desc&per_page=100&page=1"
    "search_topic_openclaw_p2.json"            = "https://api.github.com/search/repositories?q=topic%3Aopenclaw&sort=stars&order=desc&per_page=100&page=2"
    "search_keyword_openclaw_p1.json"          = "https://api.github.com/search/repositories?q=openclaw%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100&page=1"
    "search_keyword_openclaw_p2.json"          = "https://api.github.com/search/repositories?q=openclaw%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100&page=2"
    "search_openclaw_plugin.json"              = "https://api.github.com/search/repositories?q=openclaw%20plugin%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100"
    "search_openclaw_skill.json"               = "https://api.github.com/search/repositories?q=openclaw%20skill%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100"
    "search_openclaw_panel_dashboard.json"     = "https://api.github.com/search/repositories?q=openclaw%20panel%20OR%20dashboard%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100"
    "search_openclaw_deploy_installer.json"    = "https://api.github.com/search/repositories?q=openclaw%20deploy%20OR%20deployment%20OR%20installer%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100"
    "search_openclaw_security.json"            = "https://api.github.com/search/repositories?q=openclaw%20security%20OR%20secure%20OR%20guard%20in%3Aname%2Cdescription%2Creadme%20fork%3Afalse&sort=stars&order=desc&per_page=100"
}

foreach ($kv in $queryMap.GetEnumerator()) {
    Save-Json (Get-Json $kv.Value) (Join-Path $DataPath $kv.Key)
}

Write-Host "==> Fetching web docs snapshots..."

$respHome = Invoke-WebRequest -UseBasicParsing "https://openclaw.ai"
$respDocs = Invoke-WebRequest -UseBasicParsing "https://docs.openclaw.ai/start/getting-started"
Set-Content -Path (Join-Path $DataPath "openclaw_ai_home.html") -Value $respHome.Content -Encoding UTF8
Set-Content -Path (Join-Path $DataPath "openclaw_docs_getting_started.html") -Value $respDocs.Content -Encoding UTF8

Write-Host "==> Building classified inventory..."

$searchFiles = @(
    "search_topic_openclaw_p1.json",
    "search_topic_openclaw_p2.json",
    "search_keyword_openclaw_p1.json",
    "search_keyword_openclaw_p2.json",
    "search_openclaw_plugin.json",
    "search_openclaw_skill.json",
    "search_openclaw_panel_dashboard.json",
    "search_openclaw_deploy_installer.json",
    "search_openclaw_security.json"
)

$allItems = @()
foreach ($f in $searchFiles) {
    $obj = Get-Content (Join-Path $DataPath $f) -Raw | ConvertFrom-Json
    if ($obj.items) {
        $allItems += $obj.items
    }
}

$dedup = $allItems | Group-Object full_name | ForEach-Object {
    $_.Group | Sort-Object stargazers_count -Descending | Select-Object -First 1
}

function Is-RelevantRepo {
    param($repo)
    $name = ((($repo.full_name + " " + $repo.name) + "").ToLowerInvariant())
    $desc = (("" + $repo.description).ToLowerInvariant())
    $topics = (((($repo.topics -join " ") + "")).ToLowerInvariant())

    if ($repo.owner.login -eq "openclaw") { return $true }
    if ($name -match "openclaw|clawdbot|moltbot|clawd") { return $true }
    if ($desc -match "openclaw|clawdbot|moltbot|clawd") { return $true }
    if ($topics -match "openclaw|clawdbot|moltbot|clawd") { return $true }
    return $false
}

function Get-Category {
    param($repo)
    $txt = (((($repo.full_name + " " + $repo.description + " " + ($repo.topics -join " ")) + "")).ToLowerInvariant())

    if ($repo.owner.login -eq "openclaw") { return "official" }
    if ($txt -match "security|secure|guard|owasp|red[- ]?team|sandbox|hardene") { return "security" }
    if ($txt -match "panel|dashboard|webui|gui|mission-control|mission control|desktop|visual") { return "panel-ui" }
    if ($txt -match "plugin|extension|connector|mcp|integration|skill|skills|clawhub|addon") { return "plugins-skills" }
    if ($txt -match "deploy|deployment|installer|install|docker|ansible|nix|kubernetes|k8s|helm|termux|worker|cloudflare|homebrew|umbrel|host|hosting") { return "deployment" }
    if ($txt -match "awesome|guide|tutorial|usecase|usecases|translation|docs|chinese|zh") { return "docs-cases" }
    if ($txt -match "alternative|fork|clone|lightweight|tiny|nano|ultra-lightweight|openfang|nanoclaw|picoclaw|zeroclaw|nullclaw|openmozi|mimiclaw|moltis") { return "alternatives-forks" }
    return "other"
}

function Get-RelevanceTier {
    param($repo)
    $name = ((($repo.full_name + " " + $repo.name) + "").ToLowerInvariant())
    $desc = (("" + $repo.description).ToLowerInvariant())
    $topics = (((($repo.topics -join " ") + "")).ToLowerInvariant())
    if ($repo.owner.login -eq "openclaw") { return "A-official" }
    if ($name -match "openclaw|clawdbot|moltbot|clawd") { return "A-high" }
    if ($desc -match "openclaw|clawdbot|moltbot|clawd") { return "B-medium" }
    if ($topics -match "openclaw|clawdbot|moltbot|clawd") { return "B-medium" }
    return "C-low"
}

$related = $dedup | Where-Object { Is-RelevantRepo $_ } | ForEach-Object {
    [PSCustomObject]@{
        full_name      = $_.full_name
        url            = $_.html_url
        stars          = [int]$_.stargazers_count
        forks          = [int]$_.forks_count
        updated_at     = $_.updated_at
        language       = $_.language
        license        = if ($_.license) { $_.license.spdx_id } else { "" }
        category       = Get-Category $_
        relevance_tier = Get-RelevanceTier $_
        description    = $_.description
    }
} | Sort-Object stars -Descending

$related | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $DataPath "openclaw_related_dedup_classified.json") -Encoding UTF8
$related | Export-Csv (Join-Path $DataPath "openclaw_related_dedup_classified.csv") -NoTypeInformation -Encoding UTF8
$related | Select-Object -First 200 | Export-Csv (Join-Path $DataPath "openclaw_related_top200.csv") -NoTypeInformation -Encoding UTF8

$org = Get-Content (Join-Path $DataPath "org_openclaw.json") -Raw | ConvertFrom-Json
$main = Get-Content (Join-Path $DataPath "repo_openclaw_main.json") -Raw | ConvertFrom-Json
$releases = Get-Content (Join-Path $DataPath "repo_openclaw_releases_30.json") -Raw | ConvertFrom-Json
$topic = Get-Content (Join-Path $DataPath "search_topic_openclaw_p1.json") -Raw | ConvertFrom-Json
$keyword = Get-Content (Join-Path $DataPath "search_keyword_openclaw_p1.json") -Raw | ConvertFrom-Json

$summary = [PSCustomObject]@{
    generated_at             = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    org_public_repos         = $org.public_repos
    org_followers            = $org.followers
    main_stars               = $main.stargazers_count
    main_forks               = $main.forks_count
    main_open_issues         = $main.open_issues_count
    latest_release_tag       = ($releases | Select-Object -First 1).tag_name
    latest_release_published = ($releases | Select-Object -First 1).published_at
    topic_openclaw_total     = $topic.total_count
    keyword_openclaw_total   = $keyword.total_count
    related_dedup_total      = $related.Count
    related_ge_100_stars     = ($related | Where-Object { $_.stars -ge 100 }).Count
    related_ge_500_stars     = ($related | Where-Object { $_.stars -ge 500 }).Count
    related_ge_1000_stars    = ($related | Where-Object { $_.stars -ge 1000 }).Count
}

Save-Json $summary (Join-Path $DataPath "summary.json")

Write-Host "Done. Output path: $RootPath"
