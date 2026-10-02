# ApexCut App Icon

## Official Logo

The official crest for **JagX + JRILICENSE** is the silver & gold tiger heraldic logo with the shield **JX | JR**.

### How to set the App Icon

1. Place the high-resolution logo (the one you provided) into:
   ```
   assets/icons/app_icon.png
   ```
   (recommended size: 1024x1024)

2. Install the Flutter launcher icons package:
   ```yaml
   # pubspec.yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   ```

3. Add configuration:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"
     adaptive_icon_background: "#0D0D0D"
     adaptive_icon_foreground: "assets/icons/app_icon.png"
     windows:
       generate: true
     macos:
       generate: true
   ```

4. Run:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

This will generate icons for Android, iOS, Windows, and macOS automatically.

### Branding Rules
- Always show **ApexCut**
- Always show **by JagX + JRILICENSE**
- Use the official JX | JR crest as the primary icon
