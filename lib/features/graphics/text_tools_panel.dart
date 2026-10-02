import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/text_layer.dart';

/// Essential Graphics inspired text tools panel
class TextToolsPanel extends StatefulWidget {
  final TextLayer? selectedLayer;
  final ValueChanged<TextLayer> onChanged;
  final VoidCallback onAddText;

  const TextToolsPanel({
    super.key,
    this.selectedLayer,
    required this.onChanged,
    required this.onAddText,
  });

  @override
  State<TextToolsPanel> createState() => _TextToolsPanelState();
}

class _TextToolsPanelState extends State<TextToolsPanel> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedLayer != null) {
      _textController.text = widget.selectedLayer!.text;
    }
  }

  @override
  void didUpdateWidget(TextToolsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLayer != null &&
        widget.selectedLayer!.text != _textController.text) {
      _textController.text = widget.selectedLayer!.text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.selectedLayer;

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Text & Graphics',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              TextButton.icon(
                onPressed: widget.onAddText,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Text', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (layer == null)
            const Expanded(
              child: Center(
                child: Text(
                  'Select a text layer or add a new one',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            )
          else ...[
            TextField(
              controller: _textController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Enter text...',
                isDense: true,
              ),
              onChanged: (val) {
                widget.onChanged(layer.copyWith(text: val));
              },
            ),
            const SizedBox(height: 12),

            // Font size
            _buildSlider(
              'Size',
              layer.fontSize,
              12,
              120,
              (v) => widget.onChanged(layer.copyWith(fontSize: v)),
            ),

            // Scale
            _buildSlider(
              'Scale',
              layer.scale,
              0.2,
              3.0,
              (v) => widget.onChanged(layer.copyWith(scale: v)),
            ),

            // Rotation
            _buildSlider(
              'Rotation',
              layer.rotation,
              -180,
              180,
              (v) => widget.onChanged(layer.copyWith(rotation: v)),
            ),

            const SizedBox(height: 8),

            // Style toggles
            Row(
              children: [
                FilterChip(
                  label: const Text('Shadow'),
                  selected: layer.hasShadow,
                  onSelected: (v) => widget.onChanged(layer.copyWith(hasShadow: v)),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Bold'),
                  selected: layer.fontWeight == FontWeight.bold,
                  onSelected: (v) => widget.onChanged(
                    layer.copyWith(fontWeight: v ? FontWeight.bold : FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Animation presets
            const Text('Animation', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                'None',
                'Fade In',
                'Slide Up',
                'Typewriter',
                'Pop',
              ].map((anim) {
                final isSelected = (layer.animationId ?? 'None') == anim;
                return ChoiceChip(
                  label: Text(anim, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  onSelected: (_) {
                    widget.onChanged(layer.copyWith(
                      animationId: anim == 'None' ? null : anim,
                    ));
                  },
                );
              }).toList(),
            ),
          ],
        ],
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
