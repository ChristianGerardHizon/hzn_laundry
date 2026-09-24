# Update OTP + auth-alert email templates (teal brand) and meta.appName per env.
# Usage (from repo root):
#   pwsh ./scripts/update-email-branding.ps1 local
#   pwsh ./scripts/update-email-branding.ps1 staging
#   pwsh ./scripts/update-email-branding.ps1 prod

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

function Get-AppDisplayName([string]$envTarget) {
  switch ($envTarget) {
    'local' { return '[Dev] HZN Laundry' }
    'staging' { return '[Staging] HZN Laundry' }
    'prod' { return 'HZN Laundry' }
  }
}

$envMap = Read-DotEnv (Join-Path $PSScriptRoot '..\.env')
$otpPath = Join-Path $PSScriptRoot '..\docs\email-templates\otp.html'
$alertPath = Join-Path $PSScriptRoot '..\docs\email-templates\auth-alert.html'
if (-not (Test-Path $otpPath)) { throw "Missing OTP template: $otpPath" }
if (-not (Test-Path $alertPath)) { throw "Missing auth-alert template: $alertPath" }
$otpHtml = [System.IO.File]::ReadAllText($otpPath).Trim()
$alertHtml = [System.IO.File]::ReadAllText($alertPath).Trim()
$appName = Get-AppDisplayName $Target

switch ($Target) {
  'local' {
    $baseRaw = $envMap['LOCAL_API_URL']
    $email = $envMap['LOCAL_EMAIL']
    $pass = $envMap['LOCAL_PASSWORD']
  }
  'staging' {
    $baseRaw = $envMap['STAGING_URL']
    $email = $envMap['STAGING_EMAIL']
    $pass = $envMap['STAGING_PASSWORD']
  }
  'prod' {
    $baseRaw = $envMap['PROD_URL']
    $email = $envMap['PROD_EMAIL']
    $pass = $envMap['PROD_PASSWORD']
  }
}

$base = "$baseRaw".TrimEnd('/')
if (-not $base -or -not $email -or -not $pass) {
  throw "Missing PocketBase URL/email/password in .env for '$Target'."
}

$authBodyPath = Join-Path $env:TEMP "pb_email_brand_auth_$Target.json"
$usersPatchPath = Join-Path $env:TEMP "pb_email_brand_users_$Target.json"
$settingsPatchPath = Join-Path $env:TEMP "pb_email_brand_settings_$Target.json"

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

  # Preserve existing OTP settings; only refresh the email template body/subject.
  $otpEnabled = $true
  $otpDuration = 180
  $otpLength = 6
  if ($users.otp) {
    if ($null -ne $users.otp.enabled) { $otpEnabled = [bool]$users.otp.enabled }
    if ($users.otp.duration) { $otpDuration = [int]$users.otp.duration }
    if ($users.otp.length) { $otpLength = [int]$users.otp.length }
  }
  $users.otp = [pscustomobject]@{
    enabled = $otpEnabled
    duration = $otpDuration
    length = $otpLength
    emailTemplate = [pscustomobject]@{
      subject = 'Your {APP_NAME} sign-in code'
      body = $otpHtml
    }
  }

  $alertEnabled = $true
  if ($users.authAlert -and $null -ne $users.authAlert.enabled) {
    $alertEnabled = [bool]$users.authAlert.enabled
  }
  $users.authAlert = [pscustomobject]@{
    enabled = $alertEnabled
    emailTemplate = [pscustomobject]@{
      subject = 'New sign-in to your {APP_NAME} account'
      body = $alertHtml
    }
  }

  $usersJson = $users | ConvertTo-Json -Depth 40 -Compress
  [System.IO.File]::WriteAllText(
    $usersPatchPath,
    $usersJson,
    (New-Object System.Text.UTF8Encoding $false)
  )

  Write-Host 'Patching users OTP + authAlert templates...'
  $usersPatchOut = curl.exe -s -X PATCH "$base/api/collections/users" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$usersPatchPath"
  $patchedUsers = $usersPatchOut | ConvertFrom-Json
  if (-not $patchedUsers.id) { throw "Users PATCH failed: $usersPatchOut" }

  Write-Host "Fetching settings (set meta.appName = '$appName')..."
  $settingsOut = curl.exe -s "$base/api/settings" -H "Authorization: $token"
  $settings = $settingsOut | ConvertFrom-Json
  if (-not $settings.meta) {
    throw "Failed to load settings: $settingsOut"
  }

  $settings.meta.appName = $appName
  $settingsJson = $settings | ConvertTo-Json -Depth 40 -Compress
  [System.IO.File]::WriteAllText(
    $settingsPatchPath,
    $settingsJson,
    (New-Object System.Text.UTF8Encoding $false)
  )

  Write-Host 'Patching settings meta.appName...'
  $settingsPatchOut = curl.exe -s -X PATCH "$base/api/settings" `
    -H "Authorization: $token" `
    -H 'Content-Type: application/json' `
    --data-binary "@$settingsPatchPath"
  $patchedSettings = $settingsPatchOut | ConvertFrom-Json
  if (-not $patchedSettings.meta) { throw "Settings PATCH failed: $settingsPatchOut" }

  $hasTeal = $patchedUsers.otp.emailTemplate.body -match '45A9AB'
  $hasGreen = $patchedUsers.otp.emailTemplate.body -match '02F268'
  $headerAppName = $patchedUsers.otp.emailTemplate.body -match '\{APP_NAME\}'
  Write-Host "OK ($Target): appName='$($patchedSettings.meta.appName)' otpTeal=$hasTeal otpGreen=$hasGreen headerUsesAppName=$headerAppName"
}
finally {
  Remove-Item $authBodyPath -ErrorAction SilentlyContinue
  Remove-Item $usersPatchPath -ErrorAction SilentlyContinue
  Remove-Item $settingsPatchPath -ErrorAction SilentlyContinue
}
