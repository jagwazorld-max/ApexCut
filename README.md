# ApexCut

**Cinematic photo, film, and voiceover studio**  
by **JagX + JRILICENSE**

CapCut-style timeline + Photoshop-style stills. Record voice over picture, grade with film looks, caption, mix music, cut to the beat, and export.

---

## What works

### Video
- Multi-track timeline (picture, voiceover, music)
- Trim / split at playhead
- 13 cinematic looks (Teal & Orange, Noir, Bleach Bypass, Night Drive, Golden Hour, Arctic, Print Film, Undergrowth, Super 8 Fade, Tungsten, Chrome, Romance, Clean)
- Lumetri-style color: exposure, contrast, saturation, temperature
- Text titles, keyframes, speed ramps, volume / mute
- Transitions (cut, fade, dissolve, wipe, slide, zoom, flash, glitch)
- Auto captions from a voiceover script
- Beat grid + cut-to-BPM for music videos
- Ken Burns on stills, reverse, stabilize, mirror, safe area
- Start **Voiceover Film** or **Music Video** with no media

### Voice
- Microphone recording onto the VO track
- Text-to-speech with 20 voices (narrator, whisper, news, British, Spanish, French, Japanese, Korean, Arabic…)
- Music library + SFX bed
- Mix voice over picture (duck the score)

### Photo
- Crop, rotate, flip, layers, undo/redo
- Cutout, replace, mask paint, background swap
- Same cinematic looks as the film room

---

## Installable apps (GitHub Actions)

Every push to `main` builds and, when all native jobs pass, publishes a **GitHub Release**:

| Platform | Artifact |
|---|---|
| Android | split-per-ABI APKs, universal APK, Play `.aab` |
| iOS | unsigned `Runner.app` zip |
| Windows | release zip |
| macOS | `.app` zip |
| Linux | tar.gz bundle |
| Web | static site (best-effort) |

Download from **Actions → Artifacts** or the matching **Release**.

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```
