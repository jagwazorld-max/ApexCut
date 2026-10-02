# ApexCut App Icon Setup

## Official App Icon

Use the official ApexCut icon (the dark icon with gold "A" blade + cyan play triangle + film strip).

### Steps to apply on all devices:

1. Save the official icon as:
   ```
   assets/icons/app_icon.png
   ```
   (Recommended: 1024×1024 PNG)

2. Run these commands:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate icons for:

- Android (including adaptive icons)
- iOS
- Windows
- macOS

3. Rebuild the app:

```bash
flutter clean
flutter pub get
flutter run
```

The icon is now ready for every platform.
