#!/usr/bin/env bash
# Scaffold one Flutter platform without clobbering Dart sources.
set -euo pipefail
PLATFORM="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p assets/icons assets/filters assets/stickers assets/fonts assets/music assets/luts assets/templates
python3 scripts/generate_icon.py

BAK="$(mktemp -d)"
cp -a lib "$BAK/lib"
cp -a pubspec.yaml "$BAK/pubspec.yaml"
[[ -f analysis_options.yaml ]] && cp -a analysis_options.yaml "$BAK/analysis_options.yaml"

if [[ -n "$PLATFORM" ]]; then
  rm -rf "$PLATFORM"
  case "$PLATFORM" in
    windows) flutter config --enable-windows-desktop ;;
    macos) flutter config --enable-macos-desktop ;;
    linux) flutter config --enable-linux-desktop ;;
    web) flutter config --enable-web ;;
  esac
  flutter create --project-name apex_cut --org com.jagx.apexcut --platforms="$PLATFORM" .
  rm -rf lib
  cp -a "$BAK/lib" lib
  cp "$BAK/pubspec.yaml" pubspec.yaml
  [[ -f "$BAK/analysis_options.yaml" ]] && cp "$BAK/analysis_options.yaml" analysis_options.yaml
fi

bash scripts/patch_platforms.sh || true
flutter pub get
echo "prepared platform=${PLATFORM:-none}"
