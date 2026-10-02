import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Premiere-style basic color correction panel (Lumetri-inspired)
class ColorCorrectionPanel extends StatefulWidget {
  final Map<String, double> initialValues;
  final ValueChanged<Map<String, double>> onChanged;

  const ColorCorrectionPanel({
    super.key,
    this.initialValues = const {},
    required this.onChanged,
  });

  @override
  State<ColorCorrectionPanel> createState() => _ColorCorrectionPanelState();
}

class _ColorCorrectionPanelState extends State<ColorCorrectionPanel> {
  late double exposure;
  late double contrast;
  late double highlights;
  late double shadows;
  late double saturation;
  late double temperature;
  late double tint;
  late double vibrance;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValues;
    exposure = v['exposure'] ?? 0.0;
    contrast = v['contrast'] ?? 0.0;
    highlights = v['highlights'] ?? 0.0;
    shadows = v['shadows'] ?? 0.0;
    saturation = v['saturation'] ?? 0.0;
    temperature = v['temperature'] ?? 0.0;
    tint = v['tint'] ?? 0.0;
    vibrance = v['vibrance'] ?? 0.0;
  }

  void _notify() {
    widget.onChanged({
      'exposure': exposure,
      'contrast': contrast,
      'highlights': highlights,
      'shadows': shadows,
      'saturation': saturation,
      'temperature': temperature,
      'tint': tint,
      'vibrance': vibrance,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Color Correction',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildSlider('Exposure', exposure, -2.0, 2.0, (v) {
              setState(() => exposure = v);
              _notify();
            }),
            _buildSlider('Contrast', contrast, -100, 100, (v) {
              setState(() => contrast = v);
              _notify();
            }),
            _buildSlider('Highlights', highlights, -100, 100, (v) {
              setState(() => highlights = v);
              _notify();
            }),
            _buildSlider('Shadows', shadows, -100, 100, (v) {
              setState(() => shadows = v);
              _notify();
            }),
            _buildSlider('Saturation', saturation, -100, 100, (v) {
              setState(() => saturation = v);
              _notify();
            }),
            _buildSlider('Vibrance', vibrance, -100, 100, (v) {
              setState(() => vibrance = v);
              _notify();
            }),
            _buildSlider('Temperature', temperature, -100, 100, (v) {
              setState(() => temperature = v);
              _notify();
            }),
            _buildSlider('Tint', tint, -100, 100, (v) {
              setState(() => tint = v);
              _notify();
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      exposure = 0;
                      contrast = 0;
                      highlights = 0;
                      shadows = 0;
                      saturation = 0;
                      temperature = 0;
                      tint = 0;
                      vibrance = 0;
                    });
                    _notify();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
