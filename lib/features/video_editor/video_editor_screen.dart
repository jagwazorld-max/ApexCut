import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../../core/services/project_storage.dart';
import '../../shared/models/clip.dart';
import '../../shared/models/track.dart';
import '../../shared/models/text_layer.dart';
import '../audio/audio_panel.dart';
import 'panels/speed_panel.dart';
import 'panels/volume_panel.dart';

/// CapCut-style video editor with real split / delete / speed / volume / save.
class VideoEditorScreen extends StatefulWidget {
  final String? initialVideoPath;
  final String preset;

  const VideoEditorScreen({super.key, this.initialVideoPath, this.preset = 'film'});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  int _tool = 0;

  // Timeline state — real list of clips
  List<MediaClip> _clips = [];
  int _selectedClipIndex = 0;
  List<TextLayer> _subtitles = [];
  List<String> _audioLabels = [];

  double _speed = 1.0;
  double _volume = 1.0;
  bool _muted = false;
  String _filterName = 'None';

  // Undo stack (clip lists)
  final List<List<MediaClip>> _undo = [];
  final List<List<MediaClip>> _redo = [];

  final _tools = const [
    ('Edit', Icons.content_cut),
    ('Audio', Icons.music_note),
    ('Subtitles', Icons.subtitles),
    ('Effects', Icons.auto_awesome),
    ('Overlay', Icons.layers),
    ('Filter', Icons.filter),
    ('Stickers', Icons.emoji_emotions),
    ('Speed', Icons.speed),
    ('Volume', Icons.volume_up),
    ('Adjust', Icons.tune),
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final path = widget.initialVideoPath;
    if (path != null && File(path).existsSync()) {
      _controller = VideoPlayerController.file(File(path));
      await _controller!.initialize();
      final d = _controller!.value.duration;
      _clips = [
        MediaClip.create(path: path, type: ClipType.video, sourceDuration: d),
      ];
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });
      await _controller!.play();
    } else {
      // Demo clip so UI is usable without media
      _clips = [
        MediaClip.create(
          path: 'demo',
          type: ClipType.video,
          sourceDuration: const Duration(seconds: 30),
        ),
      ];
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Duration get _pos => _controller?.value.position ?? Duration.zero;
  Duration get _dur {
    if (_clips.isEmpty) return Duration.zero;
    return _clips.fold(Duration.zero, (a, c) => a + c.duration);
  }

  MediaClip? get _selected =>
      _clips.isEmpty ? null : _clips[_selectedClipIndex.clamp(0, _clips.length - 1)];

  void _pushUndo() {
    _undo.add(_clips.map((c) => c.copyWith()).toList());
    _redo.clear();
  }

  void _doUndo() {
    if (_undo.isEmpty) return;
    _redo.add(_clips.map((c) => c.copyWith()).toList());
    setState(() {
      _clips = _undo.removeLast();
      _selectedClipIndex = _selectedClipIndex.clamp(0, _clips.length - 1);
    });
  }

  void _doRedo() {
    if (_redo.isEmpty) return;
    _undo.add(_clips.map((c) => c.copyWith()).toList());
    setState(() {
      _clips = _redo.removeLast();
      _selectedClipIndex = _selectedClipIndex.clamp(0, _clips.length - 1);
    });
  }

  /// REAL SPLIT at playhead — divides selected clip into two.
  void _splitAtPlayhead() {
    if (_clips.isEmpty || _controller == null) {
      _toast('Import a video first');
      return;
    }
    final pos = _controller!.value.position;
    if (pos <= Duration.zero || pos >= _dur) {
      _toast('Move playhead into the clip to split');
      return;
    }

    // Find which clip contains playhead (simple sequential layout)
    Duration cursor = Duration.zero;
    int idx = 0;
    for (var i = 0; i < _clips.length; i++) {
      final end = cursor + _clips[i].duration;
      if (pos > cursor && pos < end) {
        idx = i;
        break;
      }
      cursor = end;
    }

    final clip = _clips[idx];
    final local = pos - cursor; // offset inside this clip
    if (local <= const Duration(milliseconds: 100) ||
        local >= clip.duration - const Duration(milliseconds: 100)) {
      _toast('Playhead too close to edge');
      return;
    }

    _pushUndo();

    final left = clip.copyWith(
      duration: local,
    );
    final right = MediaClip(
      id: const Uuid().v4(),
      path: clip.path,
      type: clip.type,
      startTime: clip.startTime + local,
      duration: clip.duration - local,
      sourceStart: clip.sourceStart + local,
      sourceDuration: clip.sourceDuration,
      volume: clip.volume,
      speed: clip.speed,
      scale: clip.scale,
      rotation: clip.rotation,
      opacity: clip.opacity,
      filterId: clip.filterId,
      effects: clip.effects,
      keyframes: clip.keyframes,
      colorGrade: clip.colorGrade,
    );

    setState(() {
      _clips = [
        ..._clips.sublist(0, idx),
        left,
        right,
        ..._clips.sublist(idx + 1),
      ];
      _selectedClipIndex = idx;
    });
    _toast('Split → ${_clips.length} clips');
  }

  void _deleteSelected() {
    if (_clips.isEmpty) return;
    if (_clips.length == 1) {
      _toast('Cannot delete the only clip');
      return;
    }
    _pushUndo();
    setState(() {
      _clips.removeAt(_selectedClipIndex);
      _selectedClipIndex = _selectedClipIndex.clamp(0, _clips.length - 1);
    });
    _toast('Clip deleted');
  }

  void _duplicateSelected() {
    if (_selected == null) return;
    _pushUndo();
    final copy = MediaClip(
      id: const Uuid().v4(),
      path: _selected!.path,
      type: _selected!.type,
      startTime: _selected!.endTime,
      duration: _selected!.duration,
      sourceStart: _selected!.sourceStart,
      sourceDuration: _selected!.sourceDuration,
      volume: _selected!.volume,
      speed: _selected!.speed,
    );
    setState(() {
      _clips = [..._clips, copy];
      _selectedClipIndex = _clips.length - 1;
    });
    _toast('Clip duplicated');
  }

  Future<void> _saveProject() async {
    final name = 'Project_${DateTime.now().millisecondsSinceEpoch}';
    await ProjectStorage().saveProject({
      'id': const Uuid().v4(),
      'name': name,
      'clips': _clips.length,
      'durationMs': _dur.inMilliseconds,
      'filter': _filterName,
      'speed': _speed,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    _toast('Saved: $name');
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), duration: const Duration(seconds: 2)),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(flex: 3, child: _preview()),
            _transport(),
            _timeline(),
            Expanded(child: _toolBody()),
            _bottomTools(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('ApexCut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(Branding.byLine, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          TextButton(
            onPressed: _doUndo,
            child: Text('Undo', style: TextStyle(color: _undo.isEmpty ? Colors.white24 : Colors.white70)),
          ),
          TextButton(
            onPressed: _saveProject,
            child: const Text('Save', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => _toast('Export ${_fmt(_dur)} · ${_clips.length} clips · $_filterName'),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_controller != null && _controller!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text('Import a video to start editing',
          style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _transport() {
    final playing = _controller?.value.isPlaying ?? false;
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
            onPressed: () {
              if (_controller == null) return;
              setState(() {
                playing ? _controller!.pause() : _controller!.play();
              });
            },
          ),
          if (_controller != null)
            Expanded(
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00D4C8),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          Text(
            '${_fmt(_pos)} / ${_fmt(_dur)}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _timeline() {
    return Container(
      height: 110,
      color: const Color(0xFF0E0E0E),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Clip strip
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _clips.length + 1,
              itemBuilder: (context, i) {
                if (i == _clips.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => _toast('Pick more media from gallery'),
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.add, color: Colors.white70),
                      ),
                    ),
                  );
                }
                final selected = i == _selectedClipIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedClipIndex = i),
                  child: Container(
                    width: 88,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF00D4C8).withOpacity(0.25) : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? const Color(0xFF00D4C8) : Colors.white12,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Clip ${i + 1}\n${_fmt(_clips[i].duration)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // Audio / subtitle rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 14, color: Colors.white38),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _audioLabels.isEmpty ? '+ Add audio' : _audioLabels.join(', '),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                const Icon(Icons.subtitles, size: 14, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  _subtitles.isEmpty ? '+ Add Subtitle' : '${_subtitles.length} subs',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBody() {
    switch (_tool) {
      case 0: // Edit
        return _editPanel();
      case 1:
        return const AudioPanel();
      case 2:
        return _subtitlePanel();
      case 7:
        return SpeedPanel(
          currentSpeed: _speed,
          onSpeedChanged: (v) {
            setState(() => _speed = v);
            _controller?.setPlaybackSpeed(v);
            if (_selected != null) {
              _pushUndo();
              setState(() {
                _clips[_selectedClipIndex] = _selected!.copyWith(speed: v);
              });
            }
          },
        );
      case 8:
        return VolumePanel(
          currentVolume: _volume,
          isMuted: _muted,
          onVolumeChanged: (v) {
            setState(() {
              _volume = v;
              _muted = v <= 0;
            });
            _controller?.setVolume(_muted ? 0 : v);
          },
          onMuteChanged: (m) {
            setState(() => _muted = m);
            _controller?.setVolume(m ? 0 : _volume);
          },
        );
      case 5:
        return _filterPanel();
      default:
        return Center(
          child: Text(
            '${_tools[_tool].$1} tools',
            style: const TextStyle(color: Colors.white54),
          ),
        );
    }
  }

  Widget _editPanel() {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('Clip tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _actionChip(Icons.content_cut, 'Split', _splitAtPlayhead),
              _actionChip(Icons.delete_outline, 'Delete', _deleteSelected),
              _actionChip(Icons.copy, 'Duplicate', _duplicateSelected),
              _actionChip(Icons.undo, 'Undo', _doUndo),
              _actionChip(Icons.redo, 'Redo', _doRedo),
              _actionChip(Icons.save, 'Save', _saveProject),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_clips.length} clips · selected #${_selectedClipIndex + 1}\nPlayhead ${_fmt(_pos)} — split divides the clip here',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00D4C8), size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _subtitlePanel() {
    final ctrl = TextEditingController();
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Type subtitle…',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              setState(() {
                _subtitles.add(TextLayer.create(text: t, startTime: _pos));
              });
              _toast('Subtitle added');
            },
            child: const Text('Add at playhead'),
          ),
          Text('${_subtitles.length} subtitles', style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _filterPanel() {
    final filters = ['None', 'Cinematic', 'Warm', 'Cool', 'B&W', 'Vivid', 'Fade', 'Night'];
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: filters.map((f) {
          final sel = _filterName == f;
          return GestureDetector(
            onTap: () => setState(() => _filterName = f),
            child: Container(
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF00D4C8).withOpacity(0.2) : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? const Color(0xFF00D4C8) : Colors.transparent),
              ),
              alignment: Alignment.center,
              child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomTools() {
    return Container(
      height: 72,
      color: const Color(0xFF121212),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tools.length,
        itemBuilder: (context, i) {
          final t = _tools[i];
          final sel = _tool == i;
          return GestureDetector(
            onTap: () => setState(() => _tool = i),
            child: Container(
              width: 64,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.$2, color: sel ? const Color(0xFF00D4C8) : Colors.white54, size: 22),
                  const SizedBox(height: 4),
                  Text(t.$1,
                      style: TextStyle(
                        fontSize: 10,
                        color: sel ? const Color(0xFF00D4C8) : Colors.white54,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
