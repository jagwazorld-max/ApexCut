# ApexCut

**Professional Photo & Video Editor**  
Inspired by CapCut + Adobe Premiere Pro

**by JagX + JRILICENSE**

Multi-track timeline • Color correction • Effects & Transitions • Keyframes • Text Graphics • Templates • Project Save/Load • FFmpeg pipeline

Built with Flutter — Android, iOS, Windows, macOS.

---

## Branding

- App Name: **ApexCut**
- By: **JagX + JRILICENSE**
- Logo: Official JX | JR crest (silver & gold tigers)

---

## Working Features

### Core Editing
1. Multi-track visual timeline (V1 / A1)
2. Playhead + time ruler + seek
3. Clip selection on timeline
4. Video playback with scrubbing
5. Photo editor with live preview
6. Color Correction panel (Exposure, Contrast, Highlights, Shadows, Saturation, Vibrance, Temperature, Tint)
7. Effects & Transitions library (20+ effects)
8. Keyframe system (Scale, Rotation, Opacity, Volume, Speed, Position)
9. Text layers + Essential Graphics style tools
10. Animation presets for text (Fade, Slide, Typewriter, Pop)
11. Project Save / Load (JSON local storage)
12. Recent projects list
13. Aspect ratio presets (9:16, 1:1, 16:9, 4:5)
14. Export button ready for FFmpeg pipeline
15. Gallery + Camera import

### Templates
16. Ready-made templates for Reels / TikTok / Shorts / Stories
17. One-tap apply template structure

### Additional Working Tools
18. Speed control UI
19. Volume control per clip
20. Reset color grade
21. Add / delete keyframes
22. Add text layer at current playhead
23. Bold + Shadow toggles for text
24. Font size / scale / rotation controls
25. Effect application feedback
26. Track mute / lock model support
27. Dark professional theme
28. Responsive tool panels
29. Multi-platform build workflow (GitHub Actions)
30. Clean architecture ready for expansion

---

## Planned / Next Integration (FFmpeg)

- Real trim / split / ripple edit
- Real color grade application via FFmpeg
- Real transitions (xfade)
- Real text burn-in
- Full multi-clip export
- Audio mixing

Uncomment `ffmpeg_kit_flutter_min_gpl` in `pubspec.yaml` to activate.

---

## Getting Started

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```

### Build

```bash
# Android
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

GitHub Actions automatically builds all platforms on push to main.

---

**ApexCut** by **JagX + JRILICENSE**
