import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CropPanel extends StatelessWidget {
  final String currentRatio;
  final ValueChanged<String> onRatioSelected;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;

  const CropPanel({
    super.key,
    required this.currentRatio,
    required this.onRatioSelected,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
  });

  static const ratios = ['Free', '1:1', '4:5', '9:16', '16:9', '3:4', '4:3'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop & Transform', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ratios.map((r) {
                final selected = currentRatio == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => onRatioSelected(r),
                    selectedColor: AppTheme.primary.withOpacity(0.25),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(icon: Icons.rotate_left, label: 'Left', onTap: onRotateLeft),
              _ToolButton(icon: Icons.rotate_right, label: 'Right', onTap: onRotateRight),
              _ToolButton(icon: Icons.flip, label: 'Flip H', onTap: onFlipHorizontal),
              _ToolButton(icon: Icons.flip_camera_android, label: 'Flip V', onTap: onFlipVertical),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
