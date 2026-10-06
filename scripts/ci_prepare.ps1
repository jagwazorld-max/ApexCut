param(
  [Parameter(Mandatory = $true)]
  [string]$Platform
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

New-Item -ItemType Directory -Force -Path assets/icons, assets/filters, assets/stickers, assets/fonts, assets/music, assets/luts, assets/templates | Out-Null
if (Test-Path scripts/generate_icon.py) {
  try { python scripts/generate_icon.py } catch { Write-Host "icon gen skipped" }
}

$bak = Join-Path $env:TEMP ("apexcut-lib-" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Force -Path $bak | Out-Null
Copy-Item -Recurse -Force lib (Join-Path $bak "lib")
Copy-Item -Force pubspec.yaml (Join-Path $bak "pubspec.yaml")
if (Test-Path analysis_options.yaml) {
  Copy-Item -Force analysis_options.yaml (Join-Path $bak "analysis_options.yaml")
}
if (Test-Path assets) {
  Copy-Item -Recurse -Force assets (Join-Path $bak "assets")
}

switch ($Platform) {
  "windows" { flutter config --enable-windows-desktop }
  "macos" { flutter config --enable-macos-desktop }
  "linux" { flutter config --enable-linux-desktop }
  "web" { flutter config --enable-web }
}

if (-not (Test-Path $Platform)) {
  flutter create --project-name apex_cut --org com.jagx.apexcut --platforms=$Platform .
} else {
  flutter create --project-name apex_cut --org com.jagx.apexcut --platforms=$Platform . | Out-Null
}

if (Test-Path lib) { Remove-Item -Recurse -Force lib }
Copy-Item -Recurse -Force (Join-Path $bak "lib") lib
Copy-Item -Force (Join-Path $bak "pubspec.yaml") pubspec.yaml
$ao = Join-Path $bak "analysis_options.yaml"
if (Test-Path $ao) { Copy-Item -Force $ao analysis_options.yaml }
$as = Join-Path $bak "assets"
if (Test-Path $as) {
  if (Test-Path assets) { Remove-Item -Recurse -Force assets }
  Copy-Item -Recurse -Force $as assets
}

flutter pub get
Write-Host "prepared platform=$Platform"
