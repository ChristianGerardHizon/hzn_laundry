<#
.SYNOPSIS
  Deploys the order_view/ static site to Cloudflare Pages via direct upload.

.DESCRIPTION
  Uses wrangler pages deploy to upload order_view/ to one or both Pages
  projects (hzn-order-view, hzn-order-view-staging).

  Reads CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_API_TOKEN, TURNSTILE_SITE_KEY,
  STAGING_URL, and PROD_URL from .env.

  Injects TURNSTILE_SITE_KEY and PUBLIC_ORDER_API_BASE into index.html via
  simple string replacement at deploy time (no build step).

.PARAMETER Target
  Which project to deploy: "staging", "prod", or "both" (default).

.EXAMPLE
  powershell -File scripts/cloudflare/deploy.ps1 -Target both
  powershell -File scripts/cloudflare/deploy.ps1 -Target staging
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
$StagingUrl   = $envVars["STAGING_URL"]
$ProdUrl      = $envVars["PROD_URL"]

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
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("hzn-order-view-deploy-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    Copy-Item -Path (Join-Path $OrderViewDir "*") -Destination $tmpDir -Recurse -Force

    $indexPath = Join-Path $tmpDir "index.html"
    if (Test-Path $indexPath) {
        $html = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
        $html = $html.Replace("__TURNSTILE_SITE_KEY__", $SiteKey)
        $html = $html.Replace("__PUBLIC_ORDER_API_BASE__", $ApiBaseUrl)
        # Cache-bust so wrangler always uploads a new asset hash.
        $bust = (Get-Date).ToUniversalTime().ToString("o")
        $html = $html.Replace("</title>", "</title><!-- deploy $bust -->")
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($indexPath, $html, $utf8NoBom)
    }

    return $tmpDir
}

function Deploy-Pages {
    param(
        [string]$ProjectName,
        [string]$DeployDir
    )
    Write-Host ""
    Write-Host ("Deploying {0} from {1} ..." -f $ProjectName, $DeployDir) -ForegroundColor Yellow

    $wrangler = Get-Command wrangler -ErrorAction SilentlyContinue
    $useNpx = -not $wrangler

    $originalAcct  = $env:CLOUDFLARE_ACCOUNT_ID
    $originalToken = $env:CLOUDFLARE_API_TOKEN
    try {
        $env:CLOUDFLARE_ACCOUNT_ID = $AccountId
        $env:CLOUDFLARE_API_TOKEN  = $ApiToken

        if ($useNpx) {
            & npx --yes wrangler pages deploy $DeployDir --project-name=$ProjectName --branch=main --commit-dirty=true
        } else {
            & wrangler pages deploy $DeployDir --project-name=$ProjectName --branch=main --commit-dirty=true
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Error ("wrangler deploy failed for {0} (exit {1})" -f $ProjectName, $LASTEXITCODE)
        }
    }
    finally {
        $env:CLOUDFLARE_ACCOUNT_ID = $originalAcct
        $env:CLOUDFLARE_API_TOKEN  = $originalToken
    }

    Write-Host ("  Deployed: https://{0}.pages.dev" -f $ProjectName) -ForegroundColor Green
}

Write-Host ""
Write-Host "=== HZN Laundry - Order View Pages Deploy ===" -ForegroundColor Cyan

if ($Target -eq "staging" -or $Target -eq "both") {
    $apiBase = if ($StagingUrl) { $StagingUrl } else { "https://staging.hznlaundry.hznsystems.com" }
    $dir = Build-DeployDir -ApiBaseUrl $apiBase -SiteKey $TurnstileKey
    Deploy-Pages -ProjectName "hzn-order-view-staging" -DeployDir $dir
    Remove-Item $dir -Recurse -Force
}

if ($Target -eq "prod" -or $Target -eq "both") {
    $apiBase = if ($ProdUrl) { $ProdUrl } else { "https://hznlaundry.hznsystems.com" }
    $dir = Build-DeployDir -ApiBaseUrl $apiBase -SiteKey $TurnstileKey
    Deploy-Pages -ProjectName "hzn-order-view" -DeployDir $dir
    Remove-Item $dir -Recurse -Force
}

Write-Host ""
Write-Host "=== Deploy complete ===" -ForegroundColor Cyan
