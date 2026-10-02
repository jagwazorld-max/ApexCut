import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Basic real image processing using the `image` package
class ImageFilterService {
  static final ImageFilterService _instance = ImageFilterService._internal();
  factory ImageFilterService() => _instance;
  ImageFilterService._internal();

  Future<img.Image?> loadImage(String path) async {
    final bytes = await File(path).readAsBytes();
    return img.decodeImage(bytes);
  }

  /// Apply brightness (-1.0 to 1.0)
  img.Image adjustBrightness(img.Image src, double amount) {
    return img.adjustColor(src, brightness: 1.0 + amount);
  }

  /// Apply contrast
  img.Image adjustContrast(img.Image src, double amount) {
    return img.adjustColor(src, contrast: 1.0 + (amount / 100));
  }

  /// Apply saturation
  img.Image adjustSaturation(img.Image src, double amount) {
    return img.adjustColor(src, saturation: 1.0 + (amount / 100));
  }

  /// Grayscale
  img.Image toGrayscale(img.Image src) {
    return img.grayscale(src);
  }

  /// Sepia-like
  img.Image sepia(img.Image src) {
    return img.sepia(src);
  }

  /// Invert
  img.Image invert(img.Image src) {
    return img.invert(src);
  }

  /// Simple vignette approximation (darken edges)
  img.Image vignette(img.Image src) {
    // Basic implementation - darken corners
    final result = img.Image.from(src);
    final cx = result.width / 2;
    final cy = result.height / 2;
    final maxDist = (cx + cy) / 1.5;

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final dx = x - cx;
        final dy = y - cy;
        final dist = (dx * dx + dy * dy) / (maxDist * maxDist);
        final factor = (1.0 - dist.clamp(0.0, 1.0) * 0.6).clamp(0.3, 1.0);
        final pixel = result.getPixel(x, y);
        result.setPixelRgba(
          x,
          y,
          (pixel.r * factor).round(),
          (pixel.g * factor).round(),
          (pixel.b * factor).round(),
          pixel.a.toInt(),
        );
      }
    }
    return result;
  }

  Future<Uint8List?> encodeJpg(img.Image image, {int quality = 90}) async {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  Future<String?> saveToTemp(img.Image image) async {
    // Caller should handle path_provider for real save
    return null;
  }
}
