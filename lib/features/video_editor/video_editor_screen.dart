import 'package:flutter/material.dart';
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
import '../audio/audio_panel.dart';
import '../tools/extra_tools.dart';
import '../cinematic/looks.dart';
import '../cinematic/looks_panel.dart';
import 'panels/speed_panel.dart';
import 'panels/volume_panel.dart';
import 'panels/transitions_panel.dart';
import 'panels/captions_panel.dart';
import 'panels/beat_panel.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoEditorScreen extends StatefulWidget {
  final String? initialVideoPath;
  final String preset;

  const VideoEditorScreen({super.key, this.initialVideoPath, this.preset = 'film'});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  int _selectedTool = 0;
  String _lookId = 'teal-orange';

  late MediaClip _mainClip;
  late List<Track> _tracks;
  List<TextLayer> _textLayers = [];
  TextLayer? _selectedTextLayer;
  Map<String, double> _colorGrade = {
    'exposure': 0,
    'contrast': 12,
    'saturation': 8,
    'temperature': 0,
  };
  List<Keyframe> _keyframes = [];
  final List<String> _voiceoverLog = [];

  double _speed = 1.0;
  double _volume = 1.0;
  bool _isMuted = false;
  bool _safeArea = false;
  bool _mirrorH = false;
  double _vignette = 0.4;
  String _transition = 'fade';
  String _captionScript =
      'The city never sleeps. Tonight we cut through the rain. Hold the quiet underneath.';
  double _bpm = 96;
  int _beatMarkers = 0;
  bool _kenBurns = true;
  bool _reverse = false;
  bool _stabilize = false;

  late final AnimationController _demoPulse;

  final List<_ToolItem> _tools = const [
    _ToolItem('Trim', Icons.content_cut_rounded),
    _ToolItem('Looks', Icons.movie_filter_rounded),
    _ToolItem('Effects', Icons.auto_awesome_rounded),
    _ToolItem('Color', Icons.palette_rounded),
    _ToolItem('Text', Icons.text_fields_rounded),
    _ToolItem('Voice', Icons.mic_rounded),
    _ToolItem('Speed', Icons.speed_rounded),
    _ToolItem('Volume', Icons.volume_up_rounded),
    _ToolItem('Keyframes', Icons.timeline_rounded),
    _ToolItem('Pro', Icons.handyman_rounded),
    _ToolItem('Trans', Icons.animation_rounded),
    _ToolItem('Caps', Icons.subtitles_rounded),
    _ToolItem('Beat', Icons.audiotrack_rounded),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preset == 'music-video') {
      _lookId = 'night-drive';
      _bpm = 118;
      _captionScript = 'One light. One voice. Hold the note until the room forgets the dark.';
    } else if (widget.preset == 'voiceover') {
      _lookId = 'arctic';
      _captionScript =
          'From the river to the ridge, the land keeps a slower clock. We only visit. The mist stays.';
    }
    _demoPulse = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final path = widget.initialVideoPath;
    final duration = path == null ? const Duration(seconds: 24) : Duration.zero;

    if (path != null) {
      _controller = VideoPlayerController.file(File(path));
      await _controller!.initialize();
    }

    final sourceDuration = _controller?.value.duration ?? duration;
    _mainClip = MediaClip.create(
      path: path ?? 'demo://cinematic',
      type: ClipType.video,
      sourceDuration: sourceDuration,
    );

    _tracks = [
      Track.create(name: 'V1', type: TrackType.video).copyWith(clips: [_mainClip]),
      Track.create(name: 'VO', type: TrackType.audio),
      Track.create(name: 'MX', type: TrackType.audio),
    ];

    final title = widget.preset == 'music-video'
        ? 'LIVE FROM THE FLOOR'
        : (path == null ? 'APEXCUT' : 'TITLE');
    _textLayers = [
      TextLayer.create(text: title, startTime: Duration.zero),
    ];
    _selectedTextLayer = _textLayers.first;

    if (mounted) {
      setState(() => _isInitialized = true);
      _controller?.play();
      _controller?.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _demoPulse.dispose();
    super.dispose();
  }

  Duration get _position {
    if (_controller != null) return _controller!.value.position;
    return Duration(milliseconds: (_demoPulse.value * 24000).round());
  }

  Duration get _duration {
    if (_controller != null) return _controller!.value.duration;
    return const Duration(seconds: 24);
  }

  void _splitClip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Split at ${_format(_position)} — both sides stay on V1')),
    );
  }

  void _applyProTool(String tool) {
    setState(() {
      switch (tool) {
        case 'Mirror Horizontal':
          _mirrorH = !_mirrorH;
          break;
        case 'Safe Area Guides':
          _safeArea = !_safeArea;
          break;
        case 'Vignette Strength':
          _vignette = _vignette > 0.5 ? 0.15 : 0.55;
          break;
        case 'Duplicate Clip':
          _tracks[0] = _tracks[0].copyWith(clips: [..._tracks[0].clips, _mainClip]);
          break;
        case 'Ken Burns':
          _kenBurns = !_kenBurns;
          break;
        case 'Reverse Clip':
          _reverse = !_reverse;
          break;
        case 'Stabilize':
          _stabilize = !_stabilize;
          break;
        case 'Beat Markers':
          _cutToBeat();
          return;
        default:
          break;
      }
    });
  }

  void _burnCaptions() {
    final sentences = _captionScript
        .split(RegExp(r'[.!?\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return;
    final slice = _duration.inMilliseconds / sentences.length;
    setState(() {
      _textLayers = [
        for (var i = 0; i < sentences.length; i++)
          TextLayer.create(
            text: sentences[i],
            startTime: Duration(milliseconds: (slice * i).round()),
            duration: Duration(milliseconds: slice.round().clamp(800, 8000)),
          ),
      ];
      _selectedTextLayer = _textLayers.first;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Laid ${sentences.length} caption cards under the VO')),
    );
  }

  void _cutToBeat() {
    final beatMs = (60000 / _bpm).round();
    final count = (_duration.inMilliseconds / beatMs).floor().clamp(1, 64);
    setState(() => _beatMarkers = count);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cut picture on $count beats at ${_bpm.round()} BPM')),
    );
  }

  ColorFilter get _liveFilter {
    final look = CinematicLooks.byId(_lookId);
    final exposure = (_colorGrade['exposure'] ?? 0) / 100;
    final contrast = 1 + (_colorGrade['contrast'] ?? 0) / 200;
    final sat = 1 + (_colorGrade['saturation'] ?? 0) / 200;
    final m = List<double>.from(look.matrix);
    m[0] *= contrast * sat * (1 + exposure);
    m[6] *= contrast * sat * (1 + exposure);
    m[12] *= contrast * (1 + exposure);
    return ColorFilter.matrix(m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            const Text('ApexCut Studio', style: TextStyle(fontSize: 16)),
            Text(Branding.byLine, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.content_cut, size: 20), onPressed: _splitClip),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export queued · ${_format(_duration)} · ${CinematicLooks.byId(_lookId).name} · ${_voiceoverLog.length} VO · $_transition · $_beatMarkers beats',
                  ),
                ),
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
            child: _isInitialized ? _buildPreview() : const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          ),
          if (_isInitialized) _buildTransport(),
          if (_isInitialized)
            SizedBox(
              height: 100,
              child: MultiTrackTimeline(
                tracks: _tracks,
                totalDuration: _duration,
                currentPosition: _position,
                onSeek: (pos) => _controller?.seekTo(pos),
              ),
            ),
          SizedBox(height: 200, child: _buildToolPanel()),
          _buildToolDock(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final look = CinematicLooks.byId(_lookId);
    Widget picture;
    if (_controller != null && _controller!.value.isInitialized) {
      picture = AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    } else {
      picture = AnimatedBuilder(
        animation: _demoPulse,
        builder: (context, _) {
          final kb = _kenBurns ? 1.0 + _demoPulse.value * 0.08 : 1.0;
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Transform.scale(
              scale: kb,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _demoPulse.value, -0.4),
                    end: Alignment(1 - _demoPulse.value, 0.6),
                    colors: const [
                      Color(0xFF14161C),
                      Color(0xFF2A3340),
                      Color(0xFF0E2A2A),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _textLayers.isEmpty ? 'ApexCut' : _textLayers.first.text,
                    style: const TextStyle(
                      fontSize: 42,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8EAED),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(
          colorFilter: _liveFilter,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(_mirrorH ? -1.0 : 1.0, 1.0),
            child: picture,
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: look.vignette * _vignette),
                ],
                radius: 0.95,
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (_safeArea)
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x66E8EAED), width: 1),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (_textLayers.isNotEmpty)
          Positioned(
            bottom: 28,
            left: 24,
            right: 24,
            child: Text(
              _textLayers.first.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          ),
        if (_beatMarkers > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Text(
              '$_beatMarkers beats · ${_bpm.round()} BPM${_stabilize ? ' · STAB' : ''}${_reverse ? ' · REV' : ''}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ),
      ],
    );
  }

  Widget _buildTransport() {
    final playing = _controller?.value.isPlaying ?? true;
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                if (_controller == null) return;
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
                  playedColor: AppTheme.primary,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            )
          else
            const Expanded(child: LinearProgressIndicator(color: AppTheme.primary)),
          const SizedBox(width: 8),
          Text(
            '${_format(_position)} / ${_format(_duration)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildToolDock() {
    return Container(
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
                color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
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
    );
  }

  Widget _buildToolPanel() {
    switch (_selectedTool) {
      case 1:
        return LooksPanel(
          selectedId: _lookId,
          onSelected: (look) => setState(() {
            _lookId = look.id;
            _vignette = look.vignette;
          }),
        );
      case 2:
        return EffectsPanel(onEffectSelected: (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied: ${e.name}')));
        });
      case 3:
        return ColorCorrectionPanel(
          initialValues: _colorGrade,
          onChanged: (v) => setState(() => _colorGrade = v),
        );
      case 4:
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
            final layer = TextLayer.create(text: 'New Text', startTime: _position);
            setState(() {
              _textLayers.add(layer);
              _selectedTextLayer = layer;
            });
          },
        );
      case 5:
        return const AudioPanel();
      case 6:
        return SpeedPanel(
          currentSpeed: _speed,
          onSpeedChanged: (v) {
            setState(() => _speed = v);
            _controller?.setPlaybackSpeed(v);
          },
        );
      case 7:
        return VolumePanel(
          currentVolume: _volume,
          isMuted: _isMuted,
          onVolumeChanged: (v) {
            setState(() {
              _volume = v;
              _isMuted = v <= 0;
            });
            _controller?.setVolume(_isMuted ? 0 : v);
          },
          onMuteChanged: (m) {
            setState(() => _isMuted = m);
            _controller?.setVolume(m ? 0 : _volume);
          },
        );
      case 8:
        return KeyframePanel(
          keyframes: _keyframes,
          clipDuration: _mainClip.duration,
          onChanged: (kfs) => setState(() => _keyframes = kfs),
        );
      case 9:
        return ExtraToolsPanel(onTool: _applyProTool);
      case 10:
        return TransitionsPanel(
          selected: _transition,
          onSelected: (id) => setState(() => _transition = id),
        );
      case 11:
        return CaptionsPanel(
          script: _captionScript,
          onScriptChanged: (s) => _captionScript = s,
          onBurnCaptions: _burnCaptions,
          captionCount: _textLayers.length,
        );
      case 12:
        return BeatPanel(
          bpm: _bpm,
          onBpm: (v) => setState(() => _bpm = v),
          onCutToBeat: _cutToBeat,
          markerCount: _beatMarkers,
        );
      default:
        return Container(
          color: AppTheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_tools[_selectedTool].label, style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
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
