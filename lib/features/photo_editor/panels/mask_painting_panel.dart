import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Real mask painting tools for cutout / background removal
class MaskPaintingPanel extends StatefulWidget {
  final ValueChanged<double> onBrushSizeChanged;
  final ValueChanged<bool> onEraseModeChanged;
  final VoidCallback onClearMask;
  final VoidCallback onApplyMask;

  const MaskPaintingPanel({
    super.key,
    required this.onBrushSizeChanged,
    required this.onEraseModeChanged,
    required this.onClearMask,
    required this.onApplyMask,
  });

  @override
  State<MaskPaintingPanel> createState() => _MaskPaintingPanelState();
}

class _MaskPaintingPanelState extends State<MaskPaintingPanel> {
  double _brushSize = 30;
  bool _isErase = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mask Painting', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text(
            'Paint to select areas for cutout or background replacement',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Paint'),
                selected: !_isErase,
                onSelected: (_) {
                  setState(() => _isErase = false);
                  widget.onEraseModeChanged(false);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Erase'),
                selected: _isErase,
                onSelected: (_) {
                  setState(() => _isErase = true);
                  widget.onEraseModeChanged(true);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Brush size: ${_brushSize.round()}', style: const TextStyle(fontSize: 12)),
          Slider(
            value: _brushSize,
            min: 5,
            max: 100,
            onChanged: (v) {
              setState(() => _brushSize = v);
              widget.onBrushSizeChanged(v);
            },
          ),
          Row(
            children: [
              TextButton(onPressed: widget.onClearMask, child: const Text('Clear')),
              const Spacer(),
              ElevatedButton(
                onPressed: widget.onApplyMask,
                child: const Text('Apply Mask'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
