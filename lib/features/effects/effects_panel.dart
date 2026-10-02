import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/effect.dart';

/// Effects & Transitions library panel (Premiere + CapCut style)
class EffectsPanel extends StatelessWidget {
  final ValueChanged<Effect> onEffectSelected;
  final EffectCategory? filterCategory;

  const EffectsPanel({
    super.key,
    required this.onEffectSelected,
    this.filterCategory,
  });

  static final List<Effect> _allEffects = [
    // Transitions
    Effect.crossDissolve(),
    Effect.fadeToBlack(),
    Effect.create(name: 'Fade to White', category: EffectCategory.transition),
    Effect.create(name: 'Wipe Left', category: EffectCategory.transition),
    Effect.create(name: 'Wipe Right', category: EffectCategory.transition),
    Effect.create(name: 'Zoom In', category: EffectCategory.transition),
    Effect.create(name: 'Slide Up', category: EffectCategory.transition),

    // Video Effects
    Effect.gaussianBlur(),
    Effect.create(name: 'Motion Blur', category: EffectCategory.blur),
    Effect.create(name: 'Sharpen', category: EffectCategory.videoEffect),
    Effect.create(name: 'Vignette', category: EffectCategory.stylize),
    Effect.create(name: 'Film Grain', category: EffectCategory.stylize),
    Effect.create(name: 'Glow', category: EffectCategory.stylize),
    Effect.create(name: 'Mirror', category: EffectCategory.distort),
    Effect.create(name: 'Glitch', category: EffectCategory.stylize),

    // Color
    Effect.brightnessContrast(),
    Effect.create(name: 'Black & White', category: EffectCategory.color),
    Effect.create(name: 'Sepia', category: EffectCategory.color),
    Effect.create(name: 'Teal & Orange', category: EffectCategory.color),
    Effect.create(name: 'Vintage', category: EffectCategory.color),
  ];

  @override
  Widget build(BuildContext context) {
    final effects = filterCategory == null
        ? _allEffects
        : _allEffects.where((e) => e.category == filterCategory).toList();

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Effects & Transitions',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: effects.length,
              itemBuilder: (context, index) {
                final effect = effects[index];
                return GestureDetector(
                  onTap: () => onEffectSelected(effect),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconForCategory(effect.category),
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          effect.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  IconData _iconForCategory(EffectCategory cat) {
    switch (cat) {
      case EffectCategory.transition:
        return Icons.swap_horiz_rounded;
      case EffectCategory.blur:
        return Icons.blur_on_rounded;
      case EffectCategory.color:
        return Icons.palette_rounded;
      case EffectCategory.stylize:
        return Icons.auto_awesome_rounded;
      case EffectCategory.distort:
        return Icons.waves_rounded;
      default:
        return Icons.movie_filter_rounded;
    }
  }
}
