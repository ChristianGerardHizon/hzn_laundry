# Enable users OTP + Google OAuth2 on a PocketBase environment.
# Usage (from repo root):
#   pwsh ./scripts/enable-otp-google-auth.ps1 staging
#   pwsh ./scripts/enable-otp-google-auth.ps1 local
#   pwsh ./scripts/enable-otp-google-auth.ps1 prod
#
# Google Cloud Console → OAuth client → Authorized redirect URIs:
#   Android (PocketBase all-in-one):
#     http://127.0.0.1:8090/api/oauth2-redirect
#     https://staging.hznlaundry.hznsystems.com/api/oauth2-redirect
#     https://hznlaundry.hznsystems.com/api/oauth2-redirect
#   Web (custom page web/oauth2-redirect.html):
#     http://127.0.0.1:8090/oauth2-redirect.html
#     https://staging.hznlaundry.hznsystems.com/oauth2-redirect.html
#     https://hznlaundry.hznsystems.com/oauth2-redirect.html
# Keep both sets registered — Android still uses /api/oauth2-redirect.

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidateSet('local', 'staging', 'prod')]
  [string]$Target
)

$ErrorActionPreference = 'Stop'

function Read-DotEnv([string]$path) {
  $map = @{}
  if (-not (Test-Path $path)) { return $map }
  Get-Content $path | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $k, $v = $_ -split '=', 2
    $map[$k.Trim()] = $v.Trim().Trim('"').Trim("'")
  }
  return $map
}

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
$otpPath = Join-Path $PSScriptRoot '..\docs\email-templates\otp.html'
if (-not (Test-Path $otpPath)) { throw "Missing OTP template: $otpPath" }
$otpHtml = [System.IO.File]::ReadAllText($otpPath).Trim()

switch ($Target) {
  'local' {
    $baseRaw = $envMap['LOCAL_API_URL']
    $email = $envMap['LOCAL_EMAIL']
    $pass = $envMap['LOCAL_PASSWORD']
    $clientId = $envMap['GOOGLE_OAUTH_CLIENT_ID']
    $clientSecret = $envMap['GOOGLE_OAUTH_CLIENT_SECRET']
  }
  'staging' {
    $baseRaw = $envMap['STAGING_URL']
    $email = $envMap['STAGING_EMAIL']
    $pass = $envMap['STAGING_PASSWORD']
    $clientId = $envMap['GOOGLE_OAUTH_STAGING_CLIENT_ID']
    if (-not $clientId) { $clientId = $envMap['GOOGLE_OAUTH_CLIENT_ID'] }
    $clientSecret = $envMap['GOOGLE_OAUTH_STAGING_CLIENT_SECRET']
    if (-not $clientSecret) { $clientSecret = $envMap['GOOGLE_OAUTH_CLIENT_SECRET'] }
  }
  'prod' {
    $baseRaw = $envMap['PROD_URL']
    $email = $envMap['PROD_EMAIL']
    $pass = $envMap['PROD_PASSWORD']
    $clientId = $envMap['GOOGLE_OAUTH_PROD_CLIENT_ID']
    if (-not $clientId) { $clientId = $envMap['GOOGLE_OAUTH_CLIENT_ID'] }
    $clientSecret = $envMap['GOOGLE_OAUTH_PROD_CLIENT_SECRET']
    if (-not $clientSecret) { $clientSecret = $envMap['GOOGLE_OAUTH_CLIENT_SECRET'] }
  }
}

$base = "$baseRaw".TrimEnd('/')
if (-not $base -or -not $email -or -not $pass) {
  throw "Missing PocketBase URL/email/password in .env for '$Target'."
}
if (-not $clientId -or -not $clientSecret) {
  throw "Missing GOOGLE_OAUTH_* client id/secret in .env for '$Target'."
}

$authBodyPath = Join-Path $env:TEMP "pb_oauth_auth_$Target.json"
$patchBodyPath = Join-Path $env:TEMP "pb_oauth_patch_$Target.json"

[System.IO.File]::WriteAllText(
  $authBodyPath,
  (@{ identity = $email; password = $pass } | ConvertTo-Json -Compress),
  (New-Object System.Text.UTF8Encoding $false)
)

try {
  Write-Host "Authenticating against $base ($Target)..."
  $authOut = curl.exe -s -X POST "$base/api/collections/_superusers/auth-with-password" `
    -H 'Content-Type: application/json' `
    --data-binary "@$authBodyPath"
  $auth = $authOut | ConvertFrom-Json
  if (-not $auth.token) { throw "Auth failed: $authOut" }
  $token = $auth.token

  Write-Host 'Fetching users collection...'
  $usersOut = curl.exe -s "$base/api/collections/users" -H "Authorization: $token"
  $users = $usersOut | ConvertFrom-Json
  if (-not $users.id) { throw "Failed to load users: $usersOut" }

  $users.otp = [pscustomobject]@{
    enabled = $true
    duration = 180
    length = 6
    emailTemplate = [pscustomobject]@{
      subject = 'Your {APP_NAME} sign-in code'
      body = $otpHtml
    }
  }

  $googleProvider = [pscustomobject]@{
    name = 'google'
    clientId = $clientId
    clientSecret = $clientSecret
    authURL = ''
    tokenURL = ''
    userInfoURL = ''
    displayName = 'Google'
    pkce = $null
  }

  $providers = @()
  if ($users.oauth2 -and $users.oauth2.providers) {
    foreach ($p in @($users.oauth2.providers)) {
      if ($p.name -ne 'google') { $providers += $p }
    }
  }
  $providers += $googleProvider

  $mapped = [pscustomobject]@{
    id = ''
    name = ''
    username = ''
    avatarURL = ''
  }
  if ($users.oauth2 -and $users.oauth2.mappedFields) {
    $mapped = $users.oauth2.mappedFields
  }

  $users.oauth2 = [pscustomobject]@{
    enabled = $true
    mappedFields = $mapped
    providers = $providers
  }

  $json = $users | ConvertTo-Json -Depth 40 -Compress
  [System.IO.File]::WriteAllText(
    $patchBodyPath,
    $json,
    (New-Object System.Text.UTF8Encoding $false)
  )

  Write-Host 'Patching users OTP + Google OAuth...'
  $patchOut = curl.exe -s -X PATCH "$base/api/collections/users" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$patchBodyPath"

  $patched = $patchOut | ConvertFrom-Json
  if (-not $patched.id) { throw "PATCH failed: $patchOut" }

  Write-Host "OK ($Target): otp.enabled=$($patched.otp.enabled) otp.length=$($patched.otp.length) oauth2.enabled=$($patched.oauth2.enabled) providers=$($patched.oauth2.providers.Count)"
}
finally {
  Remove-Item $authBodyPath -ErrorAction SilentlyContinue
  Remove-Item $patchBodyPath -ErrorAction SilentlyContinue
}
