param(
  [Parameter(Mandatory = $true)]
  [string]$Platform
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

New-Item -ItemType Directory -Force -Path assets/icons, assets/filters, assets/stickers, assets/fonts, assets/music, assets/luts, assets/templates | Out-Null
python scripts/generate_icon.py

$bak = Join-Path $env:TEMP ("apexcut-lib-" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Force -Path $bak | Out-Null
Copy-Item -Recurse -Force lib (Join-Path $bak "lib")
Copy-Item -Force pubspec.yaml (Join-Path $bak "pubspec.yaml")
if (Test-Path analysis_options.yaml) {
  Copy-Item -Force analysis_options.yaml (Join-Path $bak "analysis_options.yaml")
}

if (Test-Path $Platform) { Remove-Item -Recurse -Force $Platform }

switch ($Platform) {
  "windows" { flutter config --enable-windows-desktop }
  "macos" { flutter config --enable-macos-desktop }
  "linux" { flutter config --enable-linux-desktop }
  "web" { flutter config --enable-web }
}

flutter create --project-name apex_cut --org com.jagx.apexcut --platforms=$Platform .

if (Test-Path lib) { Remove-Item -Recurse -Force lib }
Copy-Item -Recurse -Force (Join-Path $bak "lib") lib
Copy-Item -Force (Join-Path $bak "pubspec.yaml") pubspec.yaml
$ao = Join-Path $bak "analysis_options.yaml"
if (Test-Path $ao) { Copy-Item -Force $ao analysis_options.yaml }

flutter pub get
Write-Host "prepared platform=$Platform"
