import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class VolumePanel extends StatefulWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  const VolumePanel({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
    required this.isMuted,
    required this.onMuteChanged,
  });

  @override
  State<VolumePanel> createState() => _VolumePanelState();
}

class _VolumePanelState extends State<VolumePanel> {
  late double _volume;
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _volume = widget.currentVolume;
    _muted = widget.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Volume', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              IconButton(
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: AppTheme.primary),
                onPressed: () {
                  setState(() => _muted = !_muted);
                  widget.onMuteChanged(_muted);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.volume_mute, size: 18, color: AppTheme.textSecondary),
              Expanded(
                child: Slider(
                  value: _muted ? 0 : _volume,
                  min: 0,
                  max: 1,
                  onChanged: _muted
                      ? null
                      : (v) {
                          setState(() => _volume = v);
                          widget.onVolumeChanged(v);
                        },
                ),
              ),
              const Icon(Icons.volume_up, size: 18, color: AppTheme.textSecondary),
            ],
          ),
          Text(
            _muted ? 'Muted' : '${(_volume * 100).round()}%',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
