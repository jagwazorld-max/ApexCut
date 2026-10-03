# ApexCut

**Cinematic photo, film, and voiceover studio**  
by **JagX + JRILICENSE**

CapCut-style timeline + Photoshop-style stills. Record voice over picture, grade with film looks, caption, mix music, and export.

---

## What works in 1.0

### Video
- Multi-track timeline (picture, voiceover, music)
- Trim / split at playhead
- 10 cinematic looks (Teal & Orange, Noir, Bleach Bypass, Night Drive, Golden Hour, Arctic, Print Film, Undergrowth, Super 8 Fade, Clean)
- Lumetri-style color: exposure, contrast, saturation, temperature
- Text titles, keyframes, speed ramps, volume / mute
- Pro tools: duplicate, freeze, reverse, vignette, mirror, safe area, beat markers
- Start a **Voiceover Film** with no media — grade a cinematic bed, then drop VO on top

### Voice
- Microphone recording (AAC) onto the VO track
- Text-to-speech with 15 voices (deep narrator, soft, British, Spanish, French, Japanese, robot, child…)
- Music library + SFX bed

### Photo
- Crop, rotate, flip, layers, undo/redo
- Cutout, replace, mask paint, background swap
- Same cinematic looks as the film room

---

## Installable apps (GitHub Actions)

Every push to `main` builds:

| Platform | Artifact |
|---|---|
| Android | split-per-ABI APKs |
| iOS | unsigned `Runner.app` zip |
| Windows | release zip |
| macOS | `.app` zip |
| Linux | tar.gz bundle |

Download them from the **Actions** run → **Artifacts**.

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter pub get
flutter run
```

### Local APK

```bash
flutter create --project-name apex_cut --org com.jagx.apexcut --platforms=android .
python3 scripts/generate_icon.py
flutter build apk --release --split-per-abi
```

---

**ApexCut** by **JagX + JRILICENSE**
