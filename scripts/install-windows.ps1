# Installs BASILISK Browser's policy-based hardening onto an existing
# Firefox install on Windows (tier 1 — no compiling, works today).
# Run from an elevated (Administrator) PowerShell prompt.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$policiesSrc = Join-Path $repoRoot "policy\policies.json"
$userJsSrc = Join-Path $repoRoot "pref\user.js"

Write-Host "BASILISK Browser -- tier 1 hardening installer (policy + pref overrides)"
Write-Host ""

$candidates = @(
  "$Env:ProgramFiles\Mozilla Firefox",
  "${Env:ProgramFiles(x86)}\Mozilla Firefox"
)

$installed = $false
foreach ($dir in $candidates) {
  if (Test-Path $dir) {
    $distDir = Join-Path $dir "distribution"
    New-Item -ItemType Directory -Force -Path $distDir | Out-Null
    Copy-Item $policiesSrc -Destination (Join-Path $distDir "policies.json") -Force
    Write-Host "installed: $distDir\policies.json"
    $installed = $true
  }
}

if (-not $installed) {
  Write-Warning "couldn't find a Firefox install under Program Files -- copy $policiesSrc to <your-firefox-dir>\distribution\policies.json manually."
}

Write-Host ""
# Firefox's enterprise Preferences policy only accepts an allowlist of prefs.
# Ten of the hardening prefs this project cares about (resistFingerprinting,
# firstparty.isolate, donottrackheader, and others) are rejected with
# "Preference not allowed for stability reasons" and were silently dropped,
# so user.js is not an optional extra: it is the only thing that applies
# them. Default to yes accordingly.
$reply = Read-Host "Copy pref/user.js into your Firefox profile? [Y/n]"
if ($reply -notmatch '^[Nn]') {
  $profilesIni = "$Env:APPDATA\Mozilla\Firefox\Profiles"
  $profileDir = Get-ChildItem -Path $profilesIni -Directory -Filter "*.default*" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $profileDir) {
    Write-Host "no default profile found under $profilesIni -- find yours via about:support -> Profile Folder, then copy $userJsSrc there yourself."
  } else {
    Copy-Item $userJsSrc -Destination (Join-Path $profileDir.FullName "user.js") -Force
    Write-Host "installed: $($profileDir.FullName)\user.js"
  }
}

Write-Host ""
Write-Host "Done. Restart Firefox for policies.json to take effect (check about:policies to confirm it loaded)."
Write-Host "This is tier 1 (policy/pref hardening on stock Firefox) -- see the repo README for tier 2 (a fully rebranded, source-patched build)."
