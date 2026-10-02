import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StickersPanel extends StatelessWidget {
  final ValueChanged<String> onStickerSelected;

  const StickersPanel({super.key, required this.onStickerSelected});

  static const stickers = [
    'emoji_smile',
    'emoji_fire',
    'emoji_heart',
    'emoji_star',
    'arrow_up',
    'arrow_right',
    'shape_circle',
    'shape_square',
    'badge_new',
    'badge_hot',
    'frame_polaroid',
    'frame_film',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stickers & Shapes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SligerGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                final s = stickers[index];
                return GestureDetector(
                  onTap: () => onStickerSelected(s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Center(
                      child: Text(
                        s.split('_').last,
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
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
