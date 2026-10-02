import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Replace objects / backgrounds in photo or video
class ReplacePanel extends StatelessWidget {
  final VoidCallback onReplaceBackground;
  final VoidCallback onReplaceObject;
  final VoidCallback onAddOverlay;
  final VoidCallback onPictureInPicture;

  const ReplacePanel({
    super.key,
    required this.onReplaceBackground,
    required this.onReplaceObject,
    required this.onAddOverlay,
    required this.onPictureInPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Replace & Overlay', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.wallpaper_rounded,
            title: 'Replace Background',
            subtitle: 'Swap the background with a new image',
            onTap: onReplaceBackground,
          ),
          _ActionTile(
            icon: Icons.category_rounded,
            title: 'Replace Object',
            subtitle: 'Remove and replace selected object',
            onTap: onReplaceObject,
          ),
          _ActionTile(
            icon: Icons.layers_rounded,
            title: 'Add Overlay',
            subtitle: 'Place image or video on top',
            onTap: onAddOverlay,
          ),
          _ActionTile(
            icon: Icons.picture_in_picture_alt_rounded,
            title: 'Picture in Picture',
            subtitle: 'Add secondary video/image',
            onTap: onPictureInPicture,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      onTap: onTap,
    );
  }
}
