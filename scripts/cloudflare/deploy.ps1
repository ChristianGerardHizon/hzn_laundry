<#
.SYNOPSIS
  Deploys order_view/ to Cloudflare Pages project hznlaundry.

.DESCRIPTION
  One Pages project:
    prod    -> https://hznlaundry.pages.dev          (--branch=main)
    staging -> https://staging.hznlaundry.pages.dev  (--branch=staging)

  Injects TURNSTILE_SITE_KEY and PUBLIC_ORDER_API_BASE into index.html.

.PARAMETER Target
  staging | prod | both (default)

.EXAMPLE
  powershell -File scripts/cloudflare/deploy.ps1 -Target both
#>

param(
    [ValidateSet("staging", "prod", "both")]
    [string]$Target = "both"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot     = Resolve-Path (Join-Path $PSScriptRoot "../../")
$EnvFile      = Join-Path $RepoRoot ".env"
$OrderViewDir = Join-Path $RepoRoot "order_view"
$ProjectName  = "hznlaundry"

function Read-EnvFile {
    param([string]$Path)
    $vars = @{}
    if (-not (Test-Path $Path)) { return $vars }
    foreach ($line in Get-Content $Path) {
        $line = $line.Trim()
        if ($line -match '^\s*#' -or $line -eq '') { continue }
        if ($line -match '^([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            $vars[$Matches[1]] = $Matches[2]
        }
    }
    return $vars
}

if (-not (Test-Path $EnvFile)) {
    Write-Error ".env not found. Run provision.ps1 first."
}
$envVars = Read-EnvFile $EnvFile

$AccountId    = $envVars["CLOUDFLARE_ACCOUNT_ID"]
$ApiToken     = $envVars["CLOUDFLARE_API_TOKEN"]
$TurnstileKey = $envVars["TURNSTILE_SITE_KEY"]
$StagingApi   = $envVars["STAGING_URL"]
$ProdApi      = $envVars["PROD_URL"]

if (-not $AccountId -or -not $ApiToken) {
    Write-Error ".env missing CLOUDFLARE_ACCOUNT_ID or CLOUDFLARE_API_TOKEN."
}
if (-not $TurnstileKey) {
    Write-Error ".env missing TURNSTILE_SITE_KEY. Run provision.ps1 first."
}

function Build-DeployDir {
    param(
        [string]$ApiBaseUrl,
        [string]$SiteKey
    )
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("hznlaundry-deploy-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
    Copy-Item -Path (Join-Path $OrderViewDir "*") -Destination $tmpDir -Recurse -Force

    $indexPath = Join-Path $tmpDir "index.html"
    if (Test-Path $indexPath) {
        $html = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
        $html = $html.Replace("__TURNSTILE_SITE_KEY__", $SiteKey)
        $html = $html.Replace("__PUBLIC_ORDER_API_BASE__", $ApiBaseUrl)
        $bust = (Get-Date).ToUniversalTime().ToString("o")
        $html = $html.Replace("</title>", "</title><!-- deploy $bust -->")
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($indexPath, $html, $utf8NoBom)
    }

    return $tmpDir
}

function Deploy-Pages {
    param(
        [string]$Branch,
        [string]$DeployDir,
        [string]$PublicUrl
    )
    Write-Host ""
    Write-Host ("Deploying branch={0} -> {1} ..." -f $Branch, $PublicUrl) -ForegroundColor Yellow

    $wrangler = Get-Command wrangler -ErrorAction SilentlyContinue
    $originalAcct  = $env:CLOUDFLARE_ACCOUNT_ID
    $originalToken = $env:CLOUDFLARE_API_TOKEN
    try {
        $env:CLOUDFLARE_ACCOUNT_ID = $AccountId
        $env:CLOUDFLARE_API_TOKEN  = $ApiToken

        if ($wrangler) {
            & wrangler pages deploy $DeployDir --project-name=$ProjectName --branch=$Branch --commit-dirty=true
        } else {
            & npx --yes wrangler pages deploy $DeployDir --project-name=$ProjectName --branch=$Branch --commit-dirty=true
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Error ("wrangler deploy failed for branch {0} (exit {1})" -f $Branch, $LASTEXITCODE)
        }
    }
    finally {
        $env:CLOUDFLARE_ACCOUNT_ID = $originalAcct
        $env:CLOUDFLARE_API_TOKEN  = $originalToken
    }

    Write-Host ("  Deployed: {0}" -f $PublicUrl) -ForegroundColor Green
}

Write-Host ""
Write-Host "=== HZN Laundry - Order View Pages Deploy ===" -ForegroundColor Cyan
Write-Host ("Project: {0}" -f $ProjectName)

if ($Target -eq "staging" -or $Target -eq "both") {
    $apiBase = if ($StagingApi) { $StagingApi } else { "https://staging.hznlaundry.hznsystems.com" }
    $dir = Build-DeployDir -ApiBaseUrl $apiBase -SiteKey $TurnstileKey
    Deploy-Pages -Branch "staging" -DeployDir $dir -PublicUrl "https://staging.hznlaundry.pages.dev"
    Remove-Item $dir -Recurse -Force
}

if ($Target -eq "prod" -or $Target -eq "both") {
    $apiBase = if ($ProdApi) { $ProdApi } else { "https://hznlaundry.hznsystems.com" }
    $dir = Build-DeployDir -ApiBaseUrl $apiBase -SiteKey $TurnstileKey
    Deploy-Pages -Branch "main" -DeployDir $dir -PublicUrl "https://hznlaundry.pages.dev"
    Remove-Item $dir -Recurse -Force
}

Write-Host ""
Write-Host "=== Deploy complete ===" -ForegroundColor Cyan
