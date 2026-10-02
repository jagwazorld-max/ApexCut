import '../shared/models/project.dart';

class AspectRatioHelper {
  static String label(AspectRatioPreset preset) {
    switch (preset) {
      case AspectRatioPreset.ratio9x16:
        return '9:16 (Reels / TikTok / Shorts)';
      case AspectRatioPreset.ratio1x1:
        return '1:1 (Square)';
      case AspectRatioPreset.ratio16x9:
        return '16:9 (YouTube / Landscape)';
      case AspectRatioPreset.ratio4x5:
        return '4:5 (Instagram Portrait)';
      case AspectRatioPreset.ratio3x4:
        return '3:4';
      case AspectRatioPreset.original:
        return 'Original';
    }
  }

  static double value(AspectRatioPreset preset) {
    switch (preset) {
      case AspectRatioPreset.ratio9x16:
        return 9 / 16;
      case AspectRatioPreset.ratio1x1:
        return 1.0;
      case AspectRatioPreset.ratio16x9:
        return 16 / 9;
      case AspectRatioPreset.ratio4x5:
        return 4 / 5;
      case AspectRatioPreset.ratio3x4:
        return 3 / 4;
      case AspectRatioPreset.original:
        return 9 / 16;
    }
  }

  static List<AspectRatioPreset> get contentPresets => [
        AspectRatioPreset.ratio9x16,
        AspectRatioPreset.ratio1x1,
        AspectRatioPreset.ratio16x9,
        AspectRatioPreset.ratio4x5,
      ];
}
