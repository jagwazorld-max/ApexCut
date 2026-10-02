import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../models/track.dart';
import '../../models/clip.dart';

/// Premiere-style multi-track timeline widget
class MultiTrackTimeline extends StatefulWidget {
  final List<Track> tracks;
  final Duration totalDuration;
  final Duration currentPosition;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<MediaClip>? onClipSelected;
  final double pixelsPerSecond;

  const MultiTrackTimeline({
    super.key,
    required this.tracks,
    required this.totalDuration,
    required this.currentPosition,
    this.onSeek,
    this.onClipSelected,
    this.pixelsPerSecond = 50,
  });

  @override
  State<MultiTrackTimeline> createState() => _MultiTrackTimelineState();
}

class _MultiTrackTimelineState extends State<MultiTrackTimeline> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  double get _timelineWidth {
    final seconds = widget.totalDuration.inMilliseconds / 1000;
    return (seconds * widget.pixelsPerSecond).clamp(300, 5000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceLight,
      child: Column(
        children: [
          // Time ruler
          _buildTimeRuler(),
          // Tracks
          Expanded(
            child: Row(
              children: [
                // Track headers (V1, A1, etc.)
                _buildTrackHeaders(),
                // Scrollable clips area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _timelineWidth,
                      child: Stack(
                        children: [
                          // Track rows
                          Column(
                            children: widget.tracks.map((track) {
                              return _buildTrackRow(track);
                            }).toList(),
                          ),
                          // Playhead
                          _buildPlayhead(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler() {
    final totalSeconds = widget.totalDuration.inSeconds;
    final markers = <Widget>[];

    for (int i = 0; i <= totalSeconds; i += 1) {
      final left = i * widget.pixelsPerSecond;
      markers.add(
        Positioned(
          left: left,
          child: Column(
            children: [
              Container(width: 1, height: 8, color: AppTheme.border),
              Text(
                _formatTime(Duration(seconds: i)),
                style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 28,
      color: AppTheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 52),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _timelineWidth,
                height: 28,
                child: Stack(children: markers),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackHeaders() {
    return Container(
      width: 52,
      color: AppTheme.surface,
      child: Column(
        children: widget.tracks.map((track) {
          return Container(
            height: track.height,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                if (track.isMuted)
                  const Icon(Icons.volume_off, size: 12, color: AppTheme.textSecondary),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackRow(Track track) {
    return Container(
      height: track.height,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Stack(
        children: track.clips.map((clip) {
          final left = (clip.startTime.inMilliseconds / 1000) * widget.pixelsPerSecond;
          final width = (clip.duration.inMilliseconds / 1000) * widget.pixelsPerSecond;

          return Positioned(
            left: left,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: () => widget.onClipSelected?.call(clip),
              child: Container(
                width: width.clamp(20, double.infinity),
                decoration: BoxDecoration(
                  color: track.type == TrackType.video
                      ? AppTheme.primary.withOpacity(0.35)
                      : AppTheme.accent.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: track.type == TrackType.video
                        ? AppTheme.primary
                        : AppTheme.accent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.centerLeft,
                child: Text(
                  clip.type == ClipType.video ? 'Video' : 'Audio',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayhead() {
    final left = (widget.currentPosition.inMilliseconds / 1000) * widget.pixelsPerSecond;
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: AppTheme.secondary,
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
