import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../../shared/models/clip.dart';
import '../../shared/models/track.dart';
import '../../shared/models/text_layer.dart';
import '../../shared/models/keyframe.dart';
import '../../shared/widgets/timeline/multi_track_timeline.dart';
import '../color/color_correction_panel.dart';
import '../effects/effects_panel.dart';
import '../keyframes/keyframe_panel.dart';
import '../graphics/text_tools_panel.dart';
import 'panels/speed_panel.dart';
import 'panels/volume_panel.dart';

class VideoEditorScreen extends StatefulWidget {
  final String initialVideoPath;

  const VideoEditorScreen({super.key, required this.initialVideoPath});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  int _selectedTool = 0;

  late MediaClip _mainClip;
  late List<Track> _tracks;
  List<TextLayer> _textLayers = [];
  TextLayer? _selectedTextLayer;
  Map<String, double> _colorGrade = {};
  List<Keyframe> _keyframes = [];

  double _speed = 1.0;
  double _volume = 1.0;
  bool _isMuted = false;

  final List<_ToolItem> _tools = [
    _ToolItem('Trim', Icons.content_cut_rounded),
    _ToolItem('Effects', Icons.auto_awesome_rounded),
    _ToolItem('Color', Icons.palette_rounded),
    _ToolItem('Text', Icons.text_fields_rounded),
    _ToolItem('Audio', Icons.music_note_rounded),
    _ToolItem('Speed', Icons.speed_rounded),
    _ToolItem('Keyframes', Icons.timeline_rounded),
    _ToolItem('Transition', Icons.swap_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.file(File(widget.initialVideoPath));
    await _controller.initialize();

    final duration = _controller.value.duration;
    _mainClip = MediaClip.create(
      path: widget.initialVideoPath,
      type: ClipType.video,
      sourceDuration: duration,
    );

    _tracks = [
      Track.create(name: 'V1', type: TrackType.video).copyWith(clips: [_mainClip]),
      Track.create(name: 'A1', type: TrackType.audio),
    ];

    setState(() => _isInitialized = true);
    _controller.play();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _splitClip() {
    if (!_isInitialized) return;
    final pos = _controller.value.position;
    if (pos <= Duration.zero || pos >= _mainClip.duration) return;

    // Simple split: create two clips conceptually
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Split at ${_format(pos)} (ready for FFmpeg)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            const Text('ApexCut', style: TextStyle(fontSize: 16)),
            Text(Branding.byLine, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_cut, size: 20),
            tooltip: 'Split',
            onPressed: _splitClip,
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export ready – enable FFmpeg for real render')),
              );
            },
            child: const Text('Export', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          ),

          if (_isInitialized)
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppTheme.primary,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_format(_controller.value.position)} / ${_format(_controller.value.duration)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

          if (_isInitialized)
            SizedBox(
              height: 110,
              child: MultiTrackTimeline(
                tracks: _tracks,
                totalDuration: _controller.value.duration,
                currentPosition: _controller.value.position,
                onSeek: (pos) => _controller.seekTo(pos),
              ),
            ),

          SizedBox(
            height: 190,
            child: _buildToolPanel(),
          ),

          Container(
            height: 76,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = _selectedTool == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTool = index),
                  child: Container(
                    width: 62,
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                        const SizedBox(height: 3),
                        Text(
                          tool.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolPanel() {
    switch (_selectedTool) {
      case 1:
        return EffectsPanel(
          onEffectSelected: (effect) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied: ${effect.name}')));
          },
        );
      case 2:
        return ColorCorrectionPanel(
          initialValues: _colorGrade,
          onChanged: (v) => setState(() => _colorGrade = v),
        );
      case 3:
        return TextToolsPanel(
          selectedLayer: _selectedTextLayer,
          onChanged: (layer) {
            setState(() {
              _selectedTextLayer = layer;
              final idx = _textLayers.indexWhere((t) => t.id == layer.id);
              if (idx >= 0) _textLayers[idx] = layer;
            });
          },
          onAddText: () {
            final layer = TextLayer.create(text: 'New Text', startTime: _controller.value.position);
            setState(() {
              _textLayers.add(layer);
              _selectedTextLayer = layer;
            });
          },
        );
      case 4: // Audio / Volume
        return VolumePanel(
          currentVolume: _volume,
          isMuted: _isMuted,
          onVolumeChanged: (v) {
            setState(() => _volume = v);
            _controller.setVolume(_isMuted ? 0 : v);
          },
          onMuteChanged: (muted) {
            setState(() => _isMuted = muted);
            _controller.setVolume(muted ? 0 : _volume);
          },
        );
      case 5: // Speed
        return SpeedPanel(
          currentSpeed: _speed,
          onSpeedChanged: (v) {
            setState(() => _speed = v);
            // Note: real speed change needs FFmpeg or advanced player
          },
        );
      case 6:
        return KeyframePanel(
          keyframes: _keyframes,
          clipDuration: _mainClip.duration,
          onChanged: (kfs) => setState(() => _keyframes = kfs),
        );
      default:
        return Container(
          color: AppTheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${_tools[_selectedTool].label} tools', style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                if (_selectedTool == 0)
                  ElevatedButton.icon(
                    onPressed: _splitClip,
                    icon: const Icon(Icons.content_cut, size: 16),
                    label: const Text('Split at Playhead'),
                  ),
              ],
            ),
          ),
        );
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  const _ToolItem(this.label, this.icon);
}
