# ApexCut

**Professional Photo & Video Editor**  
by **JagX + JRILICENSE**

Inspired by CapCut + Adobe Premiere Pro

---

## App Icon

Official ApexCut icon is ready.  
Place it as `assets/icons/app_icon.png` and run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This generates icons for **Android, iOS, Windows, and macOS**.

---

## Current Working Features

### Video Editor
- Multi-track timeline (V1 / A1)
- Play / Pause / Scrub
- Split at playhead
- Speed control (0.25x – 4x) with presets
- Volume control + Mute
- Color Correction panel
- Effects & Transitions library
- Keyframe system
- Text tools + animations
- Export button (FFmpeg ready)

### Photo Editor
- Live preview + zoom
- Color Correction
- Effects / Filters
- Text tools
- Shared panels with video editor

### Other
- Templates (12 presets: Reels, TikTok, Shorts, Stories, Cinematic, Food, Fitness, Beauty...)
- Project Save / Load + Recent list
- Settings screen
- Aspect ratio helpers
- Image filter service (brightness, contrast, saturation, grayscale, sepia, vignette)
- Multi-platform GitHub Actions builds

---

## How to Run

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```

### Build for phone

```bash
flutter build apk --release --split-per-abi
```

---

**ApexCut** by **JagX + JRILICENSE**
