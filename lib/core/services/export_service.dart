import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../shared/models/clip.dart';

/// Builds and runs export / join for timeline clips.
/// Uses system ffmpeg when available; otherwise writes an EDL + copies best single clip.
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

    final dir = await getTemporaryDirectory();
    final outDir = Directory(p.join(dir.path, 'apexcut_export'));
    if (!await outDir.exists()) await outDir.create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = p.join(outDir.path, 'ApexCut_$stamp.mp4');

    // Only real file paths
    final realClips = clips.where((c) => c.path != 'demo' && File(c.path).existsSync()).toList();
    if (realClips.isEmpty) {
      return ExportResult.fail('Import real videos first (demo clip cannot export)');
    }

    // Write EDL always (project decision list)
    final edlPath = p.join(outDir.path, 'ApexCut_$stamp.edl.txt');
    final edl = StringBuffer()
      ..writeln('# ApexCut by JagX + JRILICENSE')
      ..writeln('# speed=$speed volume=$volume quality=$quality')
      ..writeln('# clips=${realClips.length}');
    for (var i = 0; i < realClips.length; i++) {
      final c = realClips[i];
      edl.writeln(
        '${i + 1}\t${c.path}\tin=${c.sourceStart.inMilliseconds}ms\tdur=${c.duration.inMilliseconds}ms\tspeed=${c.speed}',
      );
    }
    await File(edlPath).writeAsString(edl.toString());

    // Try ffmpeg concat demuxer
    final ffmpeg = await _findFfmpeg();
    if (ffmpeg != null) {
      try {
        final listFile = File(p.join(outDir.path, 'concat_$stamp.txt'));
        final buf = StringBuffer();
        for (final c in realClips) {
          // For full join we use whole files; trim requires re-encode
          final escaped = c.path.replaceAll("'", "'\\''");
          buf.writeln("file '$escaped'");
        }
        await listFile.writeAsString(buf.toString());

        final args = <String>[
          '-y',
          '-f',
          'concat',
          '-safe',
          '0',
          '-i',
          listFile.path,
          '-c',
          'copy',
          outputPath,
        ];
        final result = await Process.run(ffmpeg, args, runInShell: false);
        if (result.exitCode == 0 && File(outputPath).existsSync()) {
          return ExportResult.ok(outputPath, 'Joined ${realClips.length} clips with FFmpeg');
        }

        // Fallback re-encode join
        final args2 = <String>[
          '-y',
          '-f',
          'concat',
          '-safe',
          '0',
          '-i',
          listFile.path,
          '-c:v',
          'libx264',
          '-preset',
          'veryfast',
          '-crf',
          '23',
          '-c:a',
          'aac',
          outputPath,
        ];
        final result2 = await Process.run(ffmpeg, args2, runInShell: false);
        if (result2.exitCode == 0 && File(outputPath).existsSync()) {
          return ExportResult.ok(outputPath, 'Joined ${realClips.length} clips (re-encode)');
        }
      } catch (e) {
        // fall through to copy
      }
    }

    // No ffmpeg: copy first clip as export (honest partial)
    final first = realClips.first.path;
    final dest = File(outputPath);
    await File(first).copy(dest.path);
    return ExportResult.ok(
      outputPath,
      realClips.length == 1
          ? 'Exported 1 clip'
          : 'Saved first clip + EDL for ${realClips.length} clips (install FFmpeg for full join)',
    );
  }

  Future<String?> _findFfmpeg() async {
    for (final name in ['ffmpeg', 'ffmpeg.exe']) {
      try {
        final r = await Process.run(name, ['-version']);
        if (r.exitCode == 0) return name;
      } catch (_) {}
    }
    return null;
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
