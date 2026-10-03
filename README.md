# ApexCut

**Professional Photo & Video Editor**  
by **JagX + JRILICENSE**

---

## Latest (this update)

### Audio
- **Real microphone recording** (record / stop / play, AAC)
- **Text-to-Speech** with **15 voices** (Male Deep, Female Soft, British, Spanish, French, Japanese, Robot, Child, …)
- Music library (12 tracks)
- SFX library (12 effects)

### Visual
- **Background swap** after mask (gallery image + solid presets)
- Mask painting (paint / erase / brush size)
- Canvas Studio: drag stickers + PiP positioning
- Cutout, Replace, Crop, Rotate, Flip, Layers, Undo/Redo

### 15 Pro Tools
Duplicate Clip, Freeze Frame, Reverse, Stabilize, Denoise, Sharpen, Vignette, Motion Blur, Chromatic Aberration, Glow, Mirror H/V, Watermark, Safe Area Guides, Beat Markers

### Workflows
Hardened GitHub Actions:
- Auto `flutter create` for missing platforms
- `continue-on-error` / `|| true` so one platform failure does not kill the run
- Artifact upload with `if-no-files-found: ignore`

---

## Run on your phone

```bash
git clone https://github.com/jagwazorld-max/ApexCut.git
cd ApexCut
flutter create --platforms=android,ios,windows,macos .
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release --split-per-abi
```

### Icon

Put official icon at `assets/icons/app_icon.png` then:

```bash
flutter pub run flutter_launcher_icons
```

---

**ApexCut** by **JagX + JRILICENSE**
