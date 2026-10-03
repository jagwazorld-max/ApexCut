import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'looks.dart';

class LooksPanel extends StatelessWidget {
  final String selectedId;
  final ValueChanged<CinematicLook> onSelected;

  const LooksPanel({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: CinematicLooks.looks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final look = CinematicLooks.looks[i];
          final selected = look.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(look),
            child: Container(
              width: 108,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary.withOpacity(0.16) : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    look.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    look.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
