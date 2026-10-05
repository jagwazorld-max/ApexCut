import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TransitionPreset {
  final String id;
  final String name;
  final IconData icon;
  const TransitionPreset(this.id, this.name, this.icon);
}

class TransitionsPanel extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const TransitionsPanel({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const presets = [
    TransitionPreset('cut', 'Hard Cut', Icons.content_cut),
    TransitionPreset('fade', 'Cross Fade', Icons.blur_on),
    TransitionPreset('dissolve', 'Dissolve', Icons.gradient),
    TransitionPreset('wipe', 'Wipe', Icons.swipe),
    TransitionPreset('slide', 'Slide', Icons.arrow_forward),
    TransitionPreset('zoom', 'Zoom', Icons.zoom_in),
    TransitionPreset('flash', 'Flash', Icons.flash_on),
    TransitionPreset('glitch', 'Glitch', Icons.broken_image),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transitions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Applied between picture clips on V1',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: presets.length,
              itemBuilder: (context, i) {
                final p = presets[i];
                final on = selected == p.id;
                return InkWell(
                  onTap: () => onSelected(p.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: on ? AppTheme.primary.withValues(alpha: 0.16) : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: on ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, color: on ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                        const SizedBox(height: 6),
                        Text(p.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
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
}
