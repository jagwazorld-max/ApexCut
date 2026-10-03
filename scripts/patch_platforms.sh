#!/usr/bin/env bash
# Add media/mic permissions after `flutter create` scaffolds a platform.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f android/app/src/main/AndroidManifest.xml ]]; then
  MAN=android/app/src/main/AndroidManifest.xml
  for perm in \
    android.permission.RECORD_AUDIO \
    android.permission.CAMERA \
    android.permission.INTERNET \
    android.permission.READ_MEDIA_IMAGES \
    android.permission.READ_MEDIA_VIDEO \
    android.permission.READ_MEDIA_AUDIO \
    android.permission.READ_EXTERNAL_STORAGE \
    android.permission.MODIFY_AUDIO_SETTINGS
  do
    if ! grep -q "$perm" "$MAN"; then
      python3 - "$MAN" "$perm" <<'PY'
import sys
from pathlib import Path
path = Path(sys.argv[1])
perm = sys.argv[2]
text = path.read_text()
needle = "<application"
insert = f'    <uses-permission android:name="{perm}"/>\n    '
if needle in text:
    text = text.replace(needle, insert + needle, 1)
    path.write_text(text)
PY
    fi
  done
fi

if [[ -f ios/Runner/Info.plist ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path("ios/Runner/Info.plist")
text = p.read_text()
keys = {
    "NSMicrophoneUsageDescription": "ApexCut records voiceovers and narration onto your timeline.",
    "NSCameraUsageDescription": "ApexCut captures photos and video for editing.",
    "NSPhotoLibraryUsageDescription": "ApexCut imports photos and videos from your library.",
    "NSPhotoLibraryAddUsageDescription": "ApexCut saves exported films and photos to your library.",
    "NSSpeechRecognitionUsageDescription": "ApexCut can turn speech into captions.",
}
for k, v in keys.items():
    if k in text:
        continue
    blob = f"\t<key>{k}</key>\n\t<string>{v}</string>\n"
    text = text.replace("</dict>", blob + "</dict>", 1)
p.write_text(text)
PY
fi

if [[ -f macos/Runner/Info.plist ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path("macos/Runner/Info.plist")
text = p.read_text()
keys = {
    "NSMicrophoneUsageDescription": "ApexCut records voiceovers and narration onto your timeline.",
    "NSCameraUsageDescription": "ApexCut captures photos and video for editing.",
    "NSPhotoLibraryUsageDescription": "ApexCut imports photos and videos from your library.",
}
for k, v in keys.items():
    if k in text:
        continue
    blob = f"\t<key>{k}</key>\n\t<string>{v}</string>\n"
    text = text.replace("</dict>", blob + "</dict>", 1)
p.write_text(text)
PY
fi

echo "platform permissions patched"
