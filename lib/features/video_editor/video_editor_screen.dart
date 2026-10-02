import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/clip.dart';

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

  // Premiere-inspired tool set
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

  late MediaClip _mainClip;

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

    setState(() => _isInitialized = true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('ApexCut Editor'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export pipeline coming next')),
              );
            },
            child: const Text(
              'Export',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            flex: 3,
            child: _isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
          ),

          // Playback bar
          if (_isInitialized)
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
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
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

          // Timeline area (Premiere-style multi-track placeholder)
          Container(
            height: 100,
            color: AppTheme.surfaceLight,
            child: Column(
              children: [
                // Track labels + clips placeholder
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        color: AppTheme.surface,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('V1', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            SizedBox(height: 8),
                            Text('A1', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                          ),
                          child: Center(
                            child: Text(
                              'Clip • ${_format(_mainClip.duration)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Premiere-style tools
          Container(
            height: 84,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = _selectedTool == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTool = index),
                  child: Container(
                    width: 68,
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool.icon,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool.label,
                          style: TextStyle(
                            fontSize: 10,
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
