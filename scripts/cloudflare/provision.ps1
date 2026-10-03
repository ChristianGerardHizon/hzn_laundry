<#
.SYNOPSIS
  Provisions Cloudflare Turnstile + Pages project for HZN Laundry order-view.

.DESCRIPTION
  Reads CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN from .env.
  Creates/updates:
    1. Turnstile widget (managed + bot_fight_mode) for hznlaundrysystem.pages.dev
    2. One Pages project: hznlaundrysystem
       - prod:    https://hznlaundrysystem.pages.dev
       - staging: https://staging.hznlaundrysystem.pages.dev (branch alias)
  Writes TURNSTILE_* and ORDER_VIEW_BASE_URL_* into .env.

.NOTES
  powershell -ExecutionPolicy Bypass -File scripts\cloudflare\provision.ps1
  NEVER commit .env or print full secrets.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
$EnvFile = Join-Path $RepoRoot ".env"

$ProjectName = "hznlaundrysystem"
$ProdUrl     = "https://hznlaundrysystem.pages.dev"
$StagingUrl  = "https://staging.hznlaundrysystem.pages.dev"
$TurnstileDomains = @(
    "hznlaundrysystem.pages.dev",
    "staging.hznlaundrysystem.pages.dev",
    "localhost"
)

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
        Method      = $Method
        Uri         = $Uri
        Headers     = $headers
        ErrorAction = "Stop"
    }
    if ($Body) {
        $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
    }
    return Invoke-RestMethod @params
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

Write-Host ""
Write-Host "=== HZN Laundry - Cloudflare Order-View Provisioning ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $EnvFile)) {
    Write-Error ".env not found at $EnvFile."
}
$envVars = Read-EnvFile $EnvFile
$AccountId = $envVars["CLOUDFLARE_ACCOUNT_ID"]
$ApiToken  = $envVars["CLOUDFLARE_API_TOKEN"]
if (-not $AccountId -or -not $ApiToken) {
    Write-Error ".env must contain CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN."
}

$CfBase = "https://api.cloudflare.com/client/v4"

# ── 1. Turnstile widget (create or update) ───────────────────────────────────

Write-Host "[1/3] Ensuring Turnstile widget..." -ForegroundColor Yellow

$existingSiteKey = $envVars["TURNSTILE_SITE_KEY"]
# Note: Turnstile widget PUT rejects unknown fields (e.g. bot_fight_mode).
# Bot protection is Turnstile managed mode + noindex headers / robots.txt.
$widgetPayload = @{
    name    = "HZN Laundry Order View"
    domains = $TurnstileDomains
    mode    = "managed"
}

try {
    $siteKey = $null
    $secretKey = $null

    if ($existingSiteKey) {
        # List widgets and update the matching one
        $list = Invoke-CF -Method GET -Uri "$CfBase/accounts/$AccountId/challenges/widgets" -Token $ApiToken
        $match = $null
        if ($list.result) {
            foreach ($w in $list.result) {
                if ($w.sitekey -eq $existingSiteKey) { $match = $w; break }
            }
        }
        if ($match) {
            Write-Host "  Updating existing widget domains + bot_fight_mode..." -ForegroundColor Yellow
            $upd = Invoke-CF -Method PUT -Uri "$CfBase/accounts/$AccountId/challenges/widgets/$($match.sitekey)" -Token $ApiToken -Body $widgetPayload
            if (-not $upd.success) {
                Write-Error ("Turnstile update failed: " + ($upd.errors | ConvertTo-Json))
            }
            $siteKey = $upd.result.sitekey
            if ($upd.result.secret) { $secretKey = $upd.result.secret }
            Write-Host "  Turnstile widget updated." -ForegroundColor Green
        }
    }

    if (-not $siteKey) {
        $tsResult = Invoke-CF -Method POST -Uri "$CfBase/accounts/$AccountId/challenges/widgets" -Token $ApiToken -Body $widgetPayload
        if (-not $tsResult.success) {
            Write-Error ("Turnstile creation failed: " + ($tsResult.errors | ConvertTo-Json))
        }
        $siteKey = $tsResult.result.sitekey
        $secretKey = $tsResult.result.secret
        Write-Host "  Turnstile widget created." -ForegroundColor Green
    }

    Write-Host "  Site key: $siteKey"
    Append-EnvVar -Path $EnvFile -Key "TURNSTILE_SITE_KEY" -Value $siteKey
    if ($secretKey) {
        Append-EnvVar -Path $EnvFile -Key "TURNSTILE_SECRET_KEY" -Value $secretKey
    }
    Write-Host "  Keys written to .env" -ForegroundColor Green
}
catch {
    $msg = $_.Exception.Message
    if ($msg -match "403|401|forbidden|unauthorized|10000") {
        Write-Host "ERROR: Turnstile API call failed (likely missing scope)." -ForegroundColor Red
        Write-Host "Need: Account > Turnstile > Edit, Account > Cloudflare Pages > Edit" -ForegroundColor Red
    }
    throw
}

# ── 2. Pages project ─────────────────────────────────────────────────────────

Write-Host ""
Write-Host "[2/3] Ensuring Pages project '$ProjectName'..." -ForegroundColor Yellow

$body = @{
    name              = $ProjectName
    production_branch = "main"
}

try {
    $result = Invoke-CF -Method POST -Uri "$CfBase/accounts/$AccountId/pages/projects" -Token $ApiToken -Body $body
    if (-not $result.success) {
        $errCode = $null
        if ($result.errors) { $errCode = $result.errors[0].code }
        if ($errCode -eq 8000007) {
            Write-Host "  Project already exists - skipping create." -ForegroundColor DarkYellow
        } else {
            Write-Error ("Pages project creation failed: " + ($result.errors | ConvertTo-Json))
        }
    } else {
        Write-Host "  Created: $ProdUrl" -ForegroundColor Green
    }
}
catch {
    $msg = $_.Exception.Message
    if ($msg -match "already exists" -or $msg -match "8000007") {
        Write-Host "  Project already exists - skipping create." -ForegroundColor DarkYellow
    } else {
        if ($msg -match "403|401|forbidden|unauthorized") {
            Write-Host "ERROR: Pages API call failed (likely missing scope)." -ForegroundColor Red
        }
        throw
    }
}

# ── 3. Write URLs ────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "[3/3] Writing ORDER_VIEW URLs to .env..." -ForegroundColor Yellow

Append-EnvVar -Path $EnvFile -Key "ORDER_VIEW_BASE_URL_STAGING" -Value $StagingUrl
Append-EnvVar -Path $EnvFile -Key "ORDER_VIEW_BASE_URL_PROD"    -Value $ProdUrl
Append-EnvVar -Path $EnvFile -Key "ORDER_VIEW_ORIGINS" -Value "$ProdUrl,$StagingUrl,http://localhost:8788,http://127.0.0.1:8788"

Write-Host "  ORDER_VIEW_BASE_URL_STAGING = $StagingUrl" -ForegroundColor Green
Write-Host "  ORDER_VIEW_BASE_URL_PROD    = $ProdUrl" -ForegroundColor Green

Write-Host ""
Write-Host "=== Provisioning complete ===" -ForegroundColor Cyan
Write-Host "  Prod:    $ProdUrl"
Write-Host "  Staging: $StagingUrl  (deploy with --branch=staging)"
Write-Host "  Next: powershell -File scripts/cloudflare/deploy.ps1 -Target both"
Write-Host ""
Write-Host "Note: old hzn-order-view* projects can be deleted in the CF dashboard when ready."
