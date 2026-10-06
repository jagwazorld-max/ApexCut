#!/usr/bin/env bash
# Scaffold one Flutter platform without clobbering Dart sources.
set -euo pipefail
PLATFORM="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p assets/icons assets/filters assets/stickers assets/fonts assets/music assets/luts assets/templates
if [[ -f scripts/generate_icon.py ]]; then
  python3 scripts/generate_icon.py || true
fi

BAK="$(mktemp -d)"
trap 'rm -rf "$BAK"' EXIT

cp -a lib "$BAK/lib"
cp -a pubspec.yaml "$BAK/pubspec.yaml"
[[ -f analysis_options.yaml ]] && cp -a analysis_options.yaml "$BAK/analysis_options.yaml"
[[ -d assets ]] && cp -a assets "$BAK/assets" || true

if [[ -n "$PLATFORM" ]]; then
  case "$PLATFORM" in
    windows) flutter config --enable-windows-desktop || true ;;
    macos) flutter config --enable-macos-desktop || true ;;
    linux) flutter config --enable-linux-desktop || true ;;
    web) flutter config --enable-web || true ;;
  esac

  # Create platform folder; keep existing if create fails partially
  if [[ ! -d "$PLATFORM" ]]; then
    flutter create --project-name apex_cut --org com.jagx.apexcut --platforms="$PLATFORM" .
  else
    # Refresh platform only
    flutter create --project-name apex_cut --org com.jagx.apexcut --platforms="$PLATFORM" . || true
  fi

  # Restore our sources (flutter create may overwrite lib/main.dart)
  rm -rf lib
  cp -a "$BAK/lib" lib
  cp "$BAK/pubspec.yaml" pubspec.yaml
  [[ -f "$BAK/analysis_options.yaml" ]] && cp "$BAK/analysis_options.yaml" analysis_options.yaml
  if [[ -d "$BAK/assets" ]]; then
    rm -rf assets
    cp -a "$BAK/assets" assets
  fi
fi

if [[ -f scripts/patch_platforms.sh ]]; then
  bash scripts/patch_platforms.sh || true
fi

flutter pub get
echo "prepared platform=${PLATFORM:-none}"
