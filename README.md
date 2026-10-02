# ApexCut 🎬

**Professional Photo & Video Editor**  
Inspired by **CapCut** + **Adobe Premiere Pro**

Multi-track timeline • Color correction • Effects & Transitions • Keyframes • Text Graphics • FFmpeg pipeline

Built with **Flutter** — runs on **Android, iOS, Windows, and macOS**.

---

## Features Implemented

### 1. Multi-Track Timeline (Premiere-style)
- Visual multi-track timeline widget
- Video + Audio tracks (V1, A1...)
- Playhead, time ruler, clip blocks
- Seek by dragging / clicking

### 2. Color Correction Panel
- Exposure, Contrast, Highlights, Shadows
- Saturation, Vibrance
- Temperature & Tint
- Reset functionality (Lumetri-inspired)

### 3. Effects & Transitions Library
- Cross Dissolve, Fade to Black/White, Wipes, Zoom, Slide
- Blur, Sharpen, Vignette, Film Grain, Glow, Glitch, Mirror
- Color looks (B&W, Sepia, Teal & Orange, Vintage)

### 4. Keyframe Animation System
- Property keyframes: Position, Scale, Rotation, Opacity, Volume, Speed
- Easing types (Linear, Ease In/Out, Bezier)
- Add / delete keyframes per property

### 5. Text & Essential Graphics Tools
- Add text layers
- Font size, scale, rotation
- Shadow & Bold toggles
- Animation presets (Fade In, Slide Up, Typewriter, Pop)

### 6. FFmpeg Service (Ready for integration)
- Trim, Speed change, Color grade, Blur
- Transitions (xfade), Text overlay (drawtext), Scale
- Full export pipeline placeholder

---

## Multi-Platform Support

| Platform   | Status          | Build Command                     |
|------------|-----------------|-----------------------------------|
| Android    | Fully supported | `flutter build apk --release`     |
| iOS        | Fully supported | `flutter build ios --release`     |
| Windows    | Fully supported | `flutter build windows --release` |
| macOS      | Fully supported | `flutter build macos --release`   |

---

## Automated Builds (GitHub Actions)

A complete CI workflow is included at `.github/workflows/build.yml`.

It automatically builds:
- Android APKs (split per ABI)
- iOS (no-codesign)
- Windows desktop
- macOS desktop

**Trigger:** Push to `main` or manual `workflow_dispatch`.

Artifacts are uploaded and available for download from the Actions tab.

---

## Getting Started

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```

### Enable FFmpeg (recommended)

In `pubspec.yaml` uncomment:
```yaml
ffmpeg_kit_flutter_min_gpl: ^6.0.3
```
Then run `flutter pub get`.

### Build for all platforms locally

```bash
# Android
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release

# Windows
flutter config --enable-windows-desktop
flutter build windows --release

# macOS
flutter config --enable-macos-desktop
flutter build macos --release
```

---

## Project Structure

```
lib/
├── features/
│   ├── video_editor/     # Main editor with integrated panels
│   ├── color/            # Color correction panel
│   ├── effects/          # Effects & transitions library
│   ├── keyframes/        # Keyframe editor
│   ├── graphics/         # Text tools (Essential Graphics style)
│   ├── photo_editor/
│   └── gallery/
├── shared/
│   ├── models/           # Project, Track, Clip, Effect, Keyframe, TextLayer
│   └── widgets/timeline/ # Multi-track timeline
└── core/services/        # FFmpeg service
```

---

**ApexCut** — Professional editing power on every platform.
