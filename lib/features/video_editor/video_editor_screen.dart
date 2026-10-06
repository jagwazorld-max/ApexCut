import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../../core/services/project_storage.dart';
import '../../core/services/export_service.dart';
import '../../shared/models/clip.dart';
import '../../shared/models/text_layer.dart';
import '../audio/audio_panel.dart';
import 'panels/speed_panel.dart';
import 'panels/volume_panel.dart';

class VideoEditorScreen extends StatefulWidget {
  final String? initialVideoPath;
  final List<String>? initialVideoPaths;
  final String preset;

  const VideoEditorScreen({
    super.key,
    this.initialVideoPath,
    this.initialVideoPaths,
    this.preset = 'film',
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _exporting = false;
  int _tool = 0;

  List<MediaClip> _clips = [];
  int _selectedClipIndex = 0;
  List<TextLayer> _subtitles = [];
  List<String> _audioLabels = [];

  double _speed = 1.0;
  double _volume = 1.0;
  bool _muted = false;
  String _filterName = 'None';
  String _quality = '720P';

  final List<List<MediaClip>> _undo = [];
  final List<List<MediaClip>> _redo = [];
  final _picker = ImagePicker();

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

  List<String> get _incomingPaths {
    final list = <String>[];
    if (widget.initialVideoPaths != null) list.addAll(widget.initialVideoPaths!);
    if (widget.initialVideoPath != null) list.add(widget.initialVideoPath!);
    return list.toSet().toList();
  }

  Future<void> _boot() async {
    final paths = _incomingPaths;
    if (paths.isEmpty) {
      _clips = [
        MediaClip.create(path: 'demo', type: ClipType.video, sourceDuration: const Duration(seconds: 30)),
      ];
      if (mounted) setState(() => _ready = true);
      return;
    }

    final built = <MediaClip>[];
    for (final path in paths) {
      if (!File(path).existsSync()) continue;
      Duration d = const Duration(seconds: 5);
      try {
        final c = VideoPlayerController.file(File(path));
        await c.initialize();
        d = c.value.duration;
        await c.dispose();
      } catch (_) {}
      built.add(MediaClip.create(path: path, type: ClipType.video, sourceDuration: d));
    }

    if (built.isEmpty) {
      _clips = [
        MediaClip.create(path: 'demo', type: ClipType.video, sourceDuration: const Duration(seconds: 30)),
      ];
    } else {
      _clips = built;
      await _loadPlayer(_clips.first.path);
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _loadPlayer(String path) async {
    if (path == 'demo' || !File(path).existsSync()) return;
    await _controller?.dispose();
    _controller = VideoPlayerController.file(File(path));
    await _controller!.initialize();
    _controller!.addListener(() {
      if (mounted) setState(() {});
    });
    await _controller!.setPlaybackSpeed(_speed);
    await _controller!.setVolume(_muted ? 0 : _volume);
    await _controller!.play();
  }

  Future<void> _selectClip(int index) async {
    setState(() => _selectedClipIndex = index);
    final clip = _clips[index];
    if (clip.path != 'demo') {
      await _loadPlayer(clip.path);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Duration get _pos => _controller?.value.position ?? Duration.zero;
  Duration get _dur =>
      _clips.fold(Duration.zero, (a, c) => a + c.duration);

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

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    _pushUndo();
    setState(() {
      final item = _clips.removeAt(oldIndex);
      _clips.insert(newIndex, item);
      _selectedClipIndex = newIndex;
    });
    _toast('Clips reordered');
  }

  void _splitAtPlayhead() {
    if (_clips.isEmpty || _controller == null) {
      _toast('Import a video first');
      return;
    }
    final pos = _controller!.value.position;
    final clip = _selected!;
    if (pos <= const Duration(milliseconds: 200) ||
        pos >= clip.duration - const Duration(milliseconds: 200)) {
      _toast('Move playhead into the middle of the clip');
      return;
    }
    _pushUndo();
    final left = clip.copyWith(duration: pos);
    final right = MediaClip(
      id: const Uuid().v4(),
      path: clip.path,
      type: clip.type,
      startTime: clip.startTime + pos,
      duration: clip.duration - pos,
      sourceStart: clip.sourceStart + pos,
      sourceDuration: clip.sourceDuration,
      volume: clip.volume,
      speed: clip.speed,
    );
    setState(() {
      _clips = [
        ..._clips.sublist(0, _selectedClipIndex),
        left,
        right,
        ..._clips.sublist(_selectedClipIndex + 1),
      ];
    });
    _toast('Split → ${_clips.length} clips');
  }

  void _deleteSelected() {
    if (_clips.length <= 1) {
      _toast('Cannot delete the only clip');
      return;
    }
    _pushUndo();
    setState(() {
      _clips.removeAt(_selectedClipIndex);
      _selectedClipIndex = _selectedClipIndex.clamp(0, _clips.length - 1);
    });
    _selectClip(_selectedClipIndex);
    _toast('Deleted');
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
    _toast('Duplicated');
  }

  Future<void> _importMore() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    Duration d = const Duration(seconds: 5);
    try {
      final c = VideoPlayerController.file(File(file.path));
      await c.initialize();
      d = c.value.duration;
      await c.dispose();
    } catch (_) {}
    _pushUndo();
    setState(() {
      _clips = [
        ..._clips,
        MediaClip.create(path: file.path, type: ClipType.video, sourceDuration: d),
      ];
      _selectedClipIndex = _clips.length - 1;
    });
    await _loadPlayer(file.path);
    _toast('Imported video · ${_clips.length} clips');
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

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final result = await ExportService().exportTimeline(
        clips: _clips,
        speed: _speed,
        volume: _volume,
        quality: _quality,
      );
      if (!mounted) return;
      if (result.success && result.path != null) {
        _toast(result.message);
        try {
          await Share.shareXFiles([XFile(result.path!)], text: 'ApexCut by JagX + JRILICENSE');
        } catch (_) {
          _toast('Exported to:\n${result.path}');
        }
      } else {
        _toast(result.message);
      }
    } catch (e) {
      _toast('Export error: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('ApexCut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(Branding.byLine, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _quality,
              dropdownColor: const Color(0xFF1C1C1E),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              items: const [
                DropdownMenuItem(value: '480P', child: Text('480P')),
                DropdownMenuItem(value: '720P', child: Text('720P')),
                DropdownMenuItem(value: '1080P', child: Text('1080P')),
              ],
              onChanged: (v) => setState(() => _quality = v ?? '720P'),
            ),
          ),
          TextButton(onPressed: _saveProject, child: const Text('Save', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _exporting ? null : _export,
            child: _exporting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Done'),
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
    return const Center(
      child: Text('Import videos to start', style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _transport() {
    final playing = _controller?.value.isPlaying ?? false;
    return Container(
      color: const Color(0xFF121212),
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
          Text('${_fmt(_pos)} / ${_fmt(_selected?.duration ?? Duration.zero)}',
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _timeline() {
    return Container(
      height: 120,
      color: const Color(0xFF0E0E0E),
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _clips.length + 1,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex >= _clips.length) return;
                if (newIndex > _clips.length) newIndex = _clips.length;
                _onReorder(oldIndex, newIndex);
              },
              itemBuilder: (context, i) {
                if (i == _clips.length) {
                  return Padding(
                    key: const ValueKey('add'),
                    padding: const EdgeInsets.only(left: 4),
                    child: InkWell(
                      onTap: _importMore,
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
                  key: ValueKey(_clips[i].id),
                  onTap: () => _selectClip(i),
                  child: Container(
                    width: 96,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF00D4C8).withOpacity(0.2) : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? const Color(0xFF00D4C8) : Colors.white12,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Clip ${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        Text(_fmt(_clips[i].duration), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        const Icon(Icons.drag_handle, size: 14, color: Colors.white30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _audioLabels.isEmpty ? '+ Add audio' : _audioLabels.join(', '),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                Text(
                  _subtitles.isEmpty ? '+ Subtitle' : '${_subtitles.length} subs',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
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
      case 0:
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
              setState(() => _clips[_selectedClipIndex] = _selected!.copyWith(speed: v));
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
        return Center(child: Text('${_tools[_tool].$1}', style: const TextStyle(color: Colors.white54)));
    }
  }

  Widget _editPanel() {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _chip(Icons.content_cut, 'Split', _splitAtPlayhead),
              _chip(Icons.delete_outline, 'Delete', _deleteSelected),
              _chip(Icons.copy, 'Duplicate', _duplicateSelected),
              _chip(Icons.add, 'Import', _importMore),
              _chip(Icons.undo, 'Undo', _doUndo),
              _chip(Icons.redo, 'Redo', _doRedo),
              _chip(Icons.save, 'Save', _saveProject),
              _chip(Icons.ios_share, 'Export', _export),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_clips.length} clips · long-press & drag to reorder\nSplit cuts the selected clip at the playhead',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00D4C8), size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
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
            decoration: const InputDecoration(hintText: 'Subtitle text…', hintStyle: TextStyle(color: Colors.white38)),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              setState(() => _subtitles.add(TextLayer.create(text: t, startTime: _pos)));
              _toast('Subtitle added');
            },
            child: const Text('Add at playhead'),
          ),
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
            child: SizedBox(
              width: 64,
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
