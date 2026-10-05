import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BeatPanel extends StatelessWidget {
  final double bpm;
  final ValueChanged<double> onBpm;
  final VoidCallback onCutToBeat;
  final int markerCount;

  const BeatPanel({
    super.key,
    required this.bpm,
    required this.onBpm,
    required this.onCutToBeat,
    required this.markerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Beat Grid', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            markerCount == 0
                ? 'Cut picture to the music. Music videos live here.'
                : '$markerCount beat markers on the cut',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('BPM', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Expanded(
                child: Slider(
                  value: bpm,
                  min: 60,
                  max: 180,
                  divisions: 24,
                  label: bpm.round().toString(),
                  onChanged: onBpm,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${bpm.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCutToBeat,
              icon: const Icon(Icons.music_note_rounded, size: 18),
              label: const Text('Cut picture to beat'),
            ),
          ),
        ],
      ),
    );
  }
}
