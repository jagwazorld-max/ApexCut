import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

/// Low-level FFmpeg helpers used across ApexCut.
class FFmpegService {
  static final FFmpegService _instance = FFmpegService._internal();
  factory FFmpegService() => _instance;
  FFmpegService._internal();

  bool get isAvailable => true;

  Future<String?> trim({
    required String input,
    required String output,
    required Duration start,
    required Duration end,
  }) async {
    final ss = start.inMilliseconds / 1000.0;
    final to = end.inMilliseconds / 1000.0;
    final cmd =
        '-y -ss $ss -to $to -i "$input" -c copy "$output"';
    return _run(cmd, output);
  }

  Future<String?> changeSpeed({
    required String input,
    required String output,
    required double speed,
  }) async {
    final pts = (1 / speed).toStringAsFixed(4);
    final cmd =
        '-y -i "$input" -filter:v "setpts=$pts*PTS" -filter:a "atempo=$speed" "$output"';
    return _run(cmd, output);
  }

  Future<String?> applyColorGrade({
    required String input,
    required String output,
    required Map<String, double> grade,
  }) async {
    final brightness = ((grade['exposure'] ?? 0) / 2).clamp(-1.0, 1.0);
    final contrast = 1 + ((grade['contrast'] ?? 0) / 100);
    final saturation = 1 + ((grade['saturation'] ?? 0) / 100);
    final cmd =
        '-y -i "$input" -vf "eq=brightness=$brightness:contrast=$contrast:saturation=$saturation" -c:a copy "$output"';
    return _run(cmd, output);
  }

  Future<String?> _run(String command, String outputPath) async {
    final session = await FFmpegKit.execute(command);
    final code = await session.getReturnCode();
    if (ReturnCode.isSuccess(code)) return outputPath;
    return null;
  }
}
