import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';

/// Real microphone recording panel.
class MicRecorderPanel extends StatefulWidget {
  final ValueChanged<String>? onRecordingSaved;

  const MicRecorderPanel({super.key, this.onRecordingSaved});

  @override
  State<MicRecorderPanel> createState() => _MicRecorderPanelState();
}

class _MicRecorderPanelState extends State<MicRecorderPanel> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _lastPath;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<bool> _ensurePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _start() async {
    if (!await _ensurePermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/apexcut_${const Uuid().v4()}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _lastPath = path;
      _startedAt = DateTime.now();
      _elapsed = Duration.zero;
    });

    // simple timer tick
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      setState(() {
        _elapsed = DateTime.now().difference(_startedAt!);
      });
      return true;
    });
  }

  Future<void> _stop() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      if (path != null) _lastPath = path;
    });
    if (path != null) widget.onRecordingSaved?.call(path);
  }

  Future<void> _play() async {
    if (_lastPath == null || !File(_lastPath!).existsSync()) return;
    setState(() => _isPlaying = true);
    await _player.play(DeviceFileSource(_lastPath!));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _stopPlay() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Microphone Recording', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Record real voiceovers from your device mic', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _fmt(_elapsed),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isRecording ? _stop : _start,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop' : 'Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? AppTheme.secondary : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              if (_lastPath != null)
                OutlinedButton.icon(
                  onPressed: _isPlaying ? _stopPlay : _play,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Stop' : 'Play'),
                ),
            ],
          ),
          if (_lastPath != null) ...[
            const SizedBox(height: 12),
            Text('Saved: ${_lastPath!.split('/').last}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}
