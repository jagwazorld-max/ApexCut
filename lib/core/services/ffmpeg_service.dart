/// ApexCut FFmpeg Service
/// Command builder for Premiere-style processing.
class FFmpegService {
  static final FFmpegService _instance = FFmpegService._internal();
  factory FFmpegService() => _instance;
  FFmpegService._internal();

  bool get isAvailable => false;

  Future<String?> trim({
    required String input,
    required String output,
    required Duration start,
    required Duration end,
  }) async {
    final startStr = _formatDuration(start);
    final endStr = _formatDuration(end);
    final command = '-ss $startStr -to $endStr -i "$input" -c copy "$output"';
    return _execute(command, output);
  }

  Future<String?> changeSpeed({
    required String input,
    required String output,
    required double speed,
  }) async {
    final pts = (1 / speed).toStringAsFixed(4);
    final command =
        '-i "$input" -filter:v "setpts=$pts*PTS" -filter:a "atempo=$speed" "$output"';
    return _execute(command, output);
  }

  Future<String?> applyColorGrade({
    required String input,
    required String output,
    required Map<String, double> grade,
  }) async {
    final brightness = ((grade['exposure'] ?? 0) / 2).clamp(-1.0, 1.0);
    final contrast = 1 + ((grade['contrast'] ?? 0) / 100);
    final saturation = 1 + ((grade['saturation'] ?? 0) / 100);
    final command =
        '-i "$input" -vf "eq=brightness=$brightness:contrast=$contrast:saturation=$saturation" -c:a copy "$output"';
    return _execute(command, output);
  }

  Future<String?> applyBlur({
    required String input,
    required String output,
    double radius = 10,
  }) async {
    final command = '-i "$input" -vf "gblur=sigma=$radius" -c:a copy "$output"';
    return _execute(command, output);
  }

  Future<String?> applyTransition({
    required String clipA,
    required String clipB,
    required String output,
    String transition = 'fade',
    double duration = 0.5,
  }) async {
    final command =
        '-i "$clipA" -i "$clipB" -filter_complex "[0:v][1:v]xfade=transition=$transition:duration=$duration:offset=0[v]" -map "[v]" "$output"';
    return _execute(command, output);
  }

  Future<String?> addTextOverlay({
    required String input,
    required String output,
    required String text,
    required Duration start,
    required Duration duration,
    int fontSize = 36,
    String fontColor = 'white',
  }) async {
    final startSec = start.inMilliseconds / 1000.0;
    final endSec = (start + duration).inMilliseconds / 1000.0;
    final escaped = text
        .replaceAll('\\', '\\\\')
        .replaceAll(':', '\\:')
        .replaceAll("'", '');
    final command =
        '-i "$input" -vf "drawtext=text=\'$escaped\':fontsize=$fontSize:fontcolor=$fontColor:x=(w-text_w)/2:y=(h-text_h)/2:enable=\'between(t,$startSec,$endSec)\'" -c:a copy "$output"';
    return _execute(command, output);
  }

  Future<String?> scale({
    required String input,
    required String output,
    required int width,
    required int height,
  }) async {
    final command =
        '-i "$input" -vf "scale=$width:$height:force_original_aspect_ratio=decrease,pad=$width:$height:(ow-iw)/2:(oh-ih)/2" -c:a copy "$output"';
    return _execute(command, output);
  }

  Future<String?> mixVoiceover({
    required String picture,
    required String voice,
    required String output,
    double voiceGain = 1.0,
    double musicGain = 0.35,
  }) async {
    final command =
        '-i "$picture" -i "$voice" -filter_complex "[1:a]volume=$voiceGain[v];[0:a]volume=$musicGain[m];[m][v]amix=inputs=2:duration=longest[a]" -map 0:v -map "[a]" -c:v copy "$output"';
    return _execute(command, output);
  }

  Future<String?> exportProject({required String outputPath}) async {
    return null;
  }

  Future<String?> _execute(String command, String outputPath) async {
    // Ready for ffmpeg_kit_flutter: execute `command` and return outputPath.
    assert(command.isNotEmpty);
    return null;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}
