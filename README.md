# ApexCut 🎬

**Professional Photo & Video Editor**  
Inspired by **CapCut** + **Adobe Premiere Pro**

A powerful mobile content creation studio with multi-track timeline, effects, color tools, keyframes, text graphics, and audio mixing.

> Built with Flutter + FFmpeg for high-quality mobile editing.

---

## Why ApexCut?

| CapCut Strength          | Premiere Strength             | ApexCut Goal                     |
|--------------------------|-------------------------------|----------------------------------|
| Fast mobile UX           | Multi-track timeline          | Best of both                     |
| Templates & effects      | Color tools & keyframes       | Professional yet accessible      |
| Content-first presets    | Precise editing tools         | Perfect for creators & editors   |

---

## Core Features (Foundation + Roadmap)

### Timeline & Editing (Premiere-style)
- [x] Multi-clip project architecture
- [x] Video + Audio track models
- [ ] Visual multi-track timeline UI
- [ ] Ripple edit, roll edit, slip & slide
- [ ] Nested sequences (advanced)
- [ ] Markers & In/Out points

### Effects & Transitions
- [ ] Video transitions (dissolve, wipe, zoom, etc.)
- [ ] Video effects panel
- [ ] Speed ramping & reverse
- [ ] Keyframe animation system

### Color & Look
- [ ] Basic color correction (exposure, contrast, saturation, temperature)
- [ ] Lumetri-style basic tools
- [ ] LUT support (planned)
- [ ] Filters library

### Graphics & Text (Essential Graphics inspired)
- [x] Text layer model with animation support
- [ ] Advanced text tools (fonts, stroke, shadow, background)
- [ ] Lower thirds & titles
- [ ] Stickers & overlays

### Audio
- [ ] Multi-audio tracks
- [ ] Volume keyframes
- [ ] Music library integration
- [ ] Voice-over recording

### Export & Content Creation
- [ ] Aspect ratio presets (9:16, 1:1, 16:9, 4:5)
- [ ] Quality presets (720p / 1080p / 4K)
- [ ] Templates for Reels, TikTok, YouTube Shorts, Stories

---

## Tech Stack

- **Flutter 3.24+**
- **Riverpod** (state management)
- **video_player** + **ffmpeg_kit_flutter**
- Clean Architecture + Feature-first
- Material 3 dark theme (professional look)

---

## Getting Started

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```

Build release APK:
```bash
flutter build apk --release
# or
flutter build apk --split-per-abi --release
```

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   ├── constants/
│   ├── services/          # FFmpeg, permissions, storage
│   └── utils/
├── features/
│   ├── home/
│   ├── gallery/
│   ├── photo_editor/
│   ├── video_editor/      # Timeline, preview, tools
│   ├── effects/
│   ├── color/
│   ├── graphics/         # Text & titles
│   ├── audio/
│   └── export/
├── shared/
│   ├── models/            # Project, Track, Clip, Effect, Keyframe
│   ├── widgets/
│   └── providers/
└── generated/
```

---

**ApexCut** — Professional editing power, mobile-first experience.
