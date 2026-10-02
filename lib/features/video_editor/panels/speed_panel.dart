import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SpeedPanel extends StatefulWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedPanel({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  State<SpeedPanel> createState() => _SpeedPanelState();
}

class _SpeedPanelState extends State<SpeedPanel> {
  late double _speed;

  final List<double> _presets = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0];

  @override
  void initState() {
    super.initState();
    _speed = widget.currentSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Speed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0.25x', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text('${_speed.toStringAsFixed(2)}x', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const Text('4.0x', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          Slider(
            value: _speed,
            min: 0.25,
            max: 4.0,
            divisions: 15,
            onChanged: (v) {
              setState(() => _speed = v);
              widget.onSpeedChanged(v);
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final selected = (_speed - p).abs() < 0.05;
              return ChoiceChip(
                label: Text('${p}x'),
                selected: selected,
                onSelected: (_) {
                  setState(() => _speed = p);
                  widget.onSpeedChanged(p);
                },
                selectedColor: AppTheme.primary.withOpacity(0.25),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
