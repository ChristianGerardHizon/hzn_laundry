<#
.SYNOPSIS
  Deploys the order_view/ static site to Cloudflare Pages via direct upload.

.DESCRIPTION
  Uses the Cloudflare Pages direct-upload API to deploy order_view/ to one or
  both Pages projects (hzn-order-view, hzn-order-view-staging).

  Reads CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_API_TOKEN, TURNSTILE_SITE_KEY,
  STAGING_URL, and PROD_URL from .env.

  Injects TURNSTILE_SITE_KEY and PUBLIC_ORDER_API_BASE into index.html via
  simple string replacement at deploy time (no build step).

.PARAMETER Target
  Which project to deploy: "staging", "prod", or "both" (default).

.EXAMPLE
  pwsh scripts/cloudflare/deploy.ps1 -Target both
  pwsh scripts/cloudflare/deploy.ps1 -Target staging
#>

param(
    [ValidateSet("staging", "prod", "both")]
    [string]$Target = "both"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot    = Resolve-Path (Join-Path $PSScriptRoot "../../")
$EnvFile     = Join-Path $RepoRoot ".env"
$OrderViewDir = Join-Path $RepoRoot "order_view"

# ── helpers ──────────────────────────────────────────────────────────────────

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

# ── load .env ────────────────────────────────────────────────────────────────

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

# ── build deployable directory ───────────────────────────────────────────────

function Build-DeployDir {
    param(
        [string]$ApiBaseUrl,
        [string]$SiteKey
    )
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "hzn-order-view-deploy-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    # Copy all files from order_view/
    Get-ChildItem -Path $OrderViewDir -Recurse | ForEach-Object {
        $dest = Join-Path $tmpDir $_.FullName.Substring($OrderViewDir.Length)
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        } else {
            Copy-Item $_.FullName $dest -Force
        }
    }

    # Inject env vars into index.html
    $indexPath = Join-Path $tmpDir "index.html"
    if (Test-Path $indexPath) {
        $html = Get-Content $indexPath -Raw
        $html = $html -replace '__TURNSTILE_SITE_KEY__', $SiteKey
        $html = $html -replace '__PUBLIC_ORDER_API_BASE__', $ApiBaseUrl
        Set-Content -Path $indexPath -Value $html -NoNewline
    }

    return $tmpDir
}

# ── deploy via wrangler ──────────────────────────────────────────────────────

function Deploy-Pages {
    param(
        [string]$ProjectName,
        [string]$DeployDir
    )
    Write-Host "`nDeploying $ProjectName from $DeployDir ..." -ForegroundColor Yellow

    $envVars = @{
        "CLOUDFLARE_ACCOUNT_ID" = $AccountId
        "CLOUDFLARE_API_TOKEN"  = $ApiToken
    }

    # Try wrangler first; fall back to npx
    $wrangler = Get-Command wrangler -ErrorAction SilentlyContinue
    $cmd = if ($wrangler) { "wrangler" } else { "npx wrangler" }

    $fullCmd = "$cmd pages deploy `"$DeployDir`" --project-name=$ProjectName --branch=main --commit-dirty=true"

    # Set env for the subprocess
    $originalAcct  = $Env:CLOUDFLARE_ACCOUNT_ID
    $originalToken = $Env:CLOUDFLARE_API_TOKEN
    try {
        $Env:CLOUDFLARE_ACCOUNT_ID = $AccountId
        $Env:CLOUDFLARE_API_TOKEN  = $ApiToken
        Invoke-Expression $fullCmd
        if ($LASTEXITCODE -ne 0) {
            Write-Error "wrangler deploy failed for $ProjectName (exit $LASTEXITCODE)"
        }
    }
    finally {
        $Env:CLOUDFLARE_ACCOUNT_ID = $originalAcct
        $Env:CLOUDFLARE_API_TOKEN  = $originalToken
    }

    Write-Host "  Deployed: https://$ProjectName.pages.dev" -ForegroundColor Green
}

# ── main ─────────────────────────────────────────────────────────────────────

Write-Host "`n=== HZN Laundry — Order View Pages Deploy ===" -ForegroundColor Cyan

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

Write-Host "`n=== Deploy complete ===" -ForegroundColor Cyan
