import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../shared/models/clip.dart';

/// On-device export using FFmpeg Kit (Android/iOS/desktop).
class ExportService {
  Future<ExportResult> exportTimeline({
    required List<MediaClip> clips,
    required double speed,
    required double volume,
    String quality = '720p',
  }) async {
    if (clips.isEmpty) {
      return ExportResult.fail('No clips to export');
    }

    final realClips =
        clips.where((c) => c.path != 'demo' && File(c.path).existsSync()).toList();
    if (realClips.isEmpty) {
      return ExportResult.fail('Import real videos first');
    }

    final dir = await getTemporaryDirectory();
    final outDir = Directory(p.join(dir.path, 'apexcut_export'));
    if (!await outDir.exists()) await outDir.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(outDir.path, 'ApexCut_$stamp.mp4');

    // EDL for debugging / project restore
    final edlPath = p.join(outDir.path, 'ApexCut_$stamp.edl.txt');
    final edl = StringBuffer()
      ..writeln('# ApexCut by JagX + JRILICENSE')
      ..writeln('# speed=$speed volume=$volume quality=$quality');
    for (var i = 0; i < realClips.length; i++) {
      final c = realClips[i];
      edl.writeln(
        '${i + 1}\t${c.path}\tin=${c.sourceStart.inMilliseconds}\tdur=${c.duration.inMilliseconds}',
      );
    }
    await File(edlPath).writeAsString(edl.toString());

    final scale = _scaleFilter(quality);

    try {
      if (realClips.length == 1) {
        final c = realClips.first;
        final ok = await _exportSingle(c, outputPath, speed, volume, scale);
        if (ok) {
          return ExportResult.ok(outputPath, 'Exported 1 clip with FFmpeg');
        }
        return ExportResult.fail('FFmpeg export failed for single clip');
      }

      // Multi-clip: trim each segment then concat
      final parts = <String>[];
      for (var i = 0; i < realClips.length; i++) {
        final c = realClips[i];
        final partPath = p.join(outDir.path, 'part_${stamp}_$i.mp4');
        final ok = await _exportSingle(c, partPath, c.speed, volume, scale);
        if (!ok || !File(partPath).existsSync()) {
          return ExportResult.fail('Failed encoding clip ${i + 1}');
        }
        parts.add(partPath);
      }

      final listFile = File(p.join(outDir.path, 'concat_$stamp.txt'));
      final buf = StringBuffer();
      for (final part in parts) {
        final escaped = part.replaceAll("'", "'\\''");
        buf.writeln("file '$escaped'");
      }
      await listFile.writeAsString(buf.toString());

      final cmd =
          "-y -f concat -safe 0 -i '${listFile.path}' -c copy '$outputPath'";
      final session = await FFmpegKit.execute(cmd);
      final code = await session.getReturnCode();
      if (ReturnCode.isSuccess(code) && File(outputPath).existsSync()) {
        return ExportResult.ok(
          outputPath,
          'Joined ${realClips.length} clips with on-device FFmpeg',
        );
      }

      // Re-encode concat fallback
      final cmd2 =
          "-y -f concat -safe 0 -i '${listFile.path}' -c:v libx264 -preset veryfast -crf 23 -c:a aac '$outputPath'";
      final session2 = await FFmpegKit.execute(cmd2);
      final code2 = await session2.getReturnCode();
      if (ReturnCode.isSuccess(code2) && File(outputPath).existsSync()) {
        return ExportResult.ok(
          outputPath,
          'Joined ${realClips.length} clips (re-encode)',
        );
      }

      final failLog = await session2.getAllLogsAsString();
      return ExportResult.fail('Join failed: ${failLog ?? 'unknown'}');
    } catch (e) {
      return ExportResult.fail('Export error: $e');
    }
  }

  Future<bool> _exportSingle(
    MediaClip c,
    String outputPath,
    double speed,
    double volume,
    String scale,
  ) async {
    final ss = _fmt(c.sourceStart);
    final t = _fmt(c.duration);
    final spd = speed <= 0 ? 1.0 : speed;
    final pts = (1.0 / spd).toStringAsFixed(4);
    final atempo = _atempoChain(spd);
    final vol = volume.clamp(0.0, 2.0);

    // Trim + optional scale + speed + volume
    final vf = [
      if (scale.isNotEmpty) scale,
      if (spd != 1.0) 'setpts=$pts*PTS',
    ].join(',');

    final af = [
      if (spd != 1.0) atempo,
      'volume=$vol',
    ].where((e) => e.isNotEmpty).join(',');

    final filters = StringBuffer();
    if (vf.isNotEmpty) filters.write('-vf "$vf" ');
    if (af.isNotEmpty) filters.write('-af "$af" ');

    final cmd =
        "-y -ss $ss -t $t -i '${c.path}' ${filters}-c:v libx264 -preset veryfast -crf 23 -c:a aac -movflags +faststart '$outputPath'";

    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    return ReturnCode.isSuccess(code) && File(outputPath).existsSync();
  }

  String _scaleFilter(String quality) {
    switch (quality.toLowerCase()) {
      case '480p':
        return 'scale=-2:480';
      case '1080p':
        return 'scale=-2:1080';
      case '720p':
      default:
        return 'scale=-2:720';
    }
  }

  /// atempo only accepts 0.5–2.0; chain for wider range.
  String _atempoChain(double speed) {
    var s = speed;
    final parts = <String>[];
    while (s > 2.0) {
      parts.add('atempo=2.0');
      s /= 2.0;
    }
    while (s < 0.5) {
      parts.add('atempo=0.5');
      s /= 0.5;
    }
    parts.add('atempo=${s.toStringAsFixed(3)}');
    return parts.join(',');
  }

  String _fmt(Duration d) {
    final s = d.inMilliseconds / 1000.0;
    return s.toStringAsFixed(3);
  }
}

class ExportResult {
  final bool success;
  final String? path;
  final String message;

  ExportResult.ok(this.path, this.message) : success = true;
  ExportResult.fail(this.message)
      : success = false,
        path = null;
}
