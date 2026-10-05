import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Cut around a picture / background removal style tools
class CutoutPanel extends StatelessWidget {
  final VoidCallback onAutoCutout;
  final VoidCallback onManualCutout;
  final VoidCallback onInvertMask;
  final VoidCallback onFeather;
  final bool hasCutout;

  const CutoutPanel({
    super.key,
    required this.onAutoCutout,
    required this.onManualCutout,
    required this.onInvertMask,
    required this.onFeather,
    this.hasCutout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cutout / Remove Background',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          const Text(
            'Cut around subjects or replace backgrounds',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAutoCutout,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: const Text('Auto Cutout'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onManualCutout,
                  icon: const Icon(Icons.brush_rounded, size: 18),
                  label: const Text('Manual'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ),
            ],
          ),
          if (hasCutout) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onInvertMask,
                  icon: const Icon(Icons.invert_colors, size: 16),
                  label: const Text('Invert'),
                ),
                TextButton.icon(
                  onPressed: onFeather,
                  icon: const Icon(Icons.blur_on, size: 16),
                  label: const Text('Feather'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
