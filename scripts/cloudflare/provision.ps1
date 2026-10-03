<#
.SYNOPSIS
  Provisions Cloudflare Turnstile widget + Pages projects for the HZN Laundry
  public order-view feature.

.DESCRIPTION
  Reads CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN from the repo .env file.
  Creates:
    1. A Turnstile widget (managed mode) for *.pages.dev + localhost
    2. Two Cloudflare Pages projects: hzn-order-view (prod) and hzn-order-view-staging
  Appends new keys to .env (TURNSTILE_SITE_KEY, TURNSTILE_SECRET_KEY,
  ORDER_VIEW_BASE_URL_STAGING, ORDER_VIEW_BASE_URL_PROD).

  Fails clearly when the API token lacks required scopes.

.NOTES
  Run from the repo root:
    powershell -ExecutionPolicy Bypass -File scripts\cloudflare\provision.ps1
  NEVER commit .env or print full secrets.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
$EnvFile = Join-Path $RepoRoot ".env"

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

function Invoke-CF {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$Token,
        [object]$Body = $null
    )
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
    $params = @{
        Method  = $Method
        Uri     = $Uri
        Headers = $headers
    }
    if ($Body) {
        $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
    }
    $resp = Invoke-RestMethod @params -ErrorAction Stop
    return $resp
}

function Append-EnvVar {
    param([string]$Path, [string]$Key, [string]$Value)
    $content = if (Test-Path $Path) { Get-Content $Path -Raw } else { "" }
    if ($content -match "(?m)^$Key=") {
        $content = $content -replace "(?m)^$Key=.*$", "$Key=$Value"
        Set-Content -Path $Path -Value $content -NoNewline
    } else {
        Add-Content -Path $Path -Value "$Key=$Value"
    }
}

# ── load .env ────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== HZN Laundry - Cloudflare Order-View Provisioning ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $EnvFile)) {
    Write-Error ".env not found at $EnvFile. Create it with CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN."
}
$envVars = Read-EnvFile $EnvFile

$AccountId = $envVars["CLOUDFLARE_ACCOUNT_ID"]
$ApiToken  = $envVars["CLOUDFLARE_API_TOKEN"]

if (-not $AccountId -or -not $ApiToken) {
    Write-Error ".env must contain CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN."
}

$CfBase = "https://api.cloudflare.com/client/v4"

# ── 1. Turnstile widget ─────────────────────────────────────────────────────

Write-Host "[1/3] Creating Turnstile widget..." -ForegroundColor Yellow

$turnstilePayload = @{
    name     = "HZN Laundry Order View"
    domains  = @(
        "hzn-order-view.pages.dev",
        "hzn-order-view-staging.pages.dev",
        "localhost"
    )
    mode     = "managed"
    bot_fight_mode = $false
}

try {
    $tsResult = Invoke-CF -Method POST -Uri "$CfBase/accounts/$AccountId/challenges/widgets" -Token $ApiToken -Body $turnstilePayload

    if (-not $tsResult.success) {
        Write-Error ("Turnstile creation failed: " + ($tsResult.errors | ConvertTo-Json))
    }

    $siteKey   = $tsResult.result.sitekey
    $secretKey = $tsResult.result.secret

    Write-Host "  Turnstile widget created." -ForegroundColor Green
    Write-Host "  Site key: $siteKey"
    Write-Host "  Widget name: $($tsResult.result.name)"

    Append-EnvVar -Path $EnvFile -Key "TURNSTILE_SITE_KEY" -Value $siteKey
    Append-EnvVar -Path $EnvFile -Key "TURNSTILE_SECRET_KEY" -Value $secretKey
    Write-Host "  Keys appended to .env" -ForegroundColor Green
}
catch {
    $msg = $_.Exception.Message
    if ($msg -match "403|401|forbidden|unauthorized|10000") {
        Write-Host ""
        Write-Host "ERROR: Turnstile API call failed (likely missing scope)." -ForegroundColor Red
        Write-Host "Ensure your CLOUDFLARE_API_TOKEN has:" -ForegroundColor Red
        Write-Host "  Account > Turnstile > Edit" -ForegroundColor Red
        Write-Host "  Account > Cloudflare Pages > Edit" -ForegroundColor Red
        Write-Host "Error: $msg" -ForegroundColor Red
    }
    throw
}

# ── 2. Pages projects ───────────────────────────────────────────────────────

function New-PagesProject {
    param([string]$ProjectName)

    Write-Host "  Creating Pages project: $ProjectName ..." -ForegroundColor Yellow

    $body = @{
        name = $ProjectName
        production_branch = "main"
    }

    try {
        $result = Invoke-CF -Method POST -Uri "$CfBase/accounts/$AccountId/pages/projects" -Token $ApiToken -Body $body

        if (-not $result.success) {
            $errCode = $null
            if ($result.errors) {
                $errCode = $result.errors[0].code
            }
            if ($errCode -eq 8000007) {
                Write-Host "  Project '$ProjectName' already exists - skipping." -ForegroundColor DarkYellow
                return
            }
            Write-Error ("Pages project creation failed: " + ($result.errors | ConvertTo-Json))
        }
        Write-Host "  Created: https://$ProjectName.pages.dev" -ForegroundColor Green
    }
    catch {
        $msg = $_.Exception.Message
        if ($msg -match "already exists" -or $msg -match "8000007") {
            Write-Host "  Project '$ProjectName' already exists - skipping." -ForegroundColor DarkYellow
            return
        }
        if ($msg -match "403|401|forbidden|unauthorized") {
            Write-Host "ERROR: Pages API call failed (likely missing scope)." -ForegroundColor Red
            Write-Host "Ensure CLOUDFLARE_API_TOKEN has: Account > Cloudflare Pages > Edit" -ForegroundColor Red
            Write-Host "Error: $msg" -ForegroundColor Red
        }
        throw
    }
}

Write-Host ""
Write-Host "[2/3] Creating Cloudflare Pages projects..." -ForegroundColor Yellow

New-PagesProject -ProjectName "hzn-order-view"
New-PagesProject -ProjectName "hzn-order-view-staging"

# ── 3. Write URLs to .env ───────────────────────────────────────────────────

Write-Host ""
Write-Host "[3/3] Writing ORDER_VIEW URLs to .env..." -ForegroundColor Yellow

Append-EnvVar -Path $EnvFile -Key "ORDER_VIEW_BASE_URL_STAGING" -Value "https://hzn-order-view-staging.pages.dev"
Append-EnvVar -Path $EnvFile -Key "ORDER_VIEW_BASE_URL_PROD"    -Value "https://hzn-order-view.pages.dev"

Write-Host "  ORDER_VIEW_BASE_URL_STAGING = https://hzn-order-view-staging.pages.dev" -ForegroundColor Green
Write-Host "  ORDER_VIEW_BASE_URL_PROD    = https://hzn-order-view.pages.dev" -ForegroundColor Green

# ── done ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== Provisioning complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resources created:"
Write-Host "  Turnstile widget : HZN Laundry Order View"
Write-Host "  Pages (prod)     : hzn-order-view.pages.dev"
Write-Host "  Pages (staging)  : hzn-order-view-staging.pages.dev"
Write-Host ""
Write-Host ".env keys added:"
Write-Host "  TURNSTILE_SITE_KEY, TURNSTILE_SECRET_KEY,"
Write-Host "  ORDER_VIEW_BASE_URL_STAGING, ORDER_VIEW_BASE_URL_PROD"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Deploy order_view/ to Pages (see scripts/cloudflare/deploy.ps1)"
Write-Host "  2. Add PocketBase migration for viewToken fields"
Write-Host "  3. Wire email hooks to use ORDER_VIEW_BASE_URL"
