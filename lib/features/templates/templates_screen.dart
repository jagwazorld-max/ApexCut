import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../gallery/gallery_screen.dart';

class TemplateItem {
  final String id;
  final String name;
  final String description;
  final String aspect;
  final IconData icon;
  final Color color;

  const TemplateItem({
    required this.id,
    required this.name,
    required this.description,
    required this.aspect,
    required this.icon,
    required this.color,
  });
}

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  static final List<TemplateItem> templates = [
    TemplateItem(
      id: 'reels',
      name: 'Instagram Reels',
      description: '9:16 • Fast cuts • Trending text',
      aspect: '9:16',
      icon: Icons.video_library_rounded,
      color: AppTheme.secondary,
    ),
    TemplateItem(
      id: 'tiktok',
      name: 'TikTok / Shorts',
      description: '9:16 • Dynamic transitions • Captions',
      aspect: '9:16',
      icon: Icons.music_note_rounded,
      color: AppTheme.primary,
    ),
    TemplateItem(
      id: 'youtube',
      name: 'YouTube Shorts',
      description: '9:16 • Clean intro • End screen',
      aspect: '9:16',
      icon: Icons.play_circle_rounded,
      color: Colors.redAccent,
    ),
    TemplateItem(
      id: 'story',
      name: 'Stories',
      description: '9:16 • Quick photo + text',
      aspect: '9:16',
      icon: Icons.auto_stories_rounded,
      color: AppTheme.accent,
    ),
    TemplateItem(
      id: 'square',
      name: 'Instagram Post',
      description: '1:1 • Photo focused',
      aspect: '1:1',
      icon: Icons.crop_square_rounded,
      color: Colors.purpleAccent,
    ),
    TemplateItem(
      id: 'cinematic',
      name: 'Cinematic',
      description: '16:9 • Color grade • Slow motion',
      aspect: '16:9',
      icon: Icons.movie_rounded,
      color: Colors.amber,
    ),
    TemplateItem(
      id: 'promo',
      name: 'Promo / Ad',
      description: '9:16 • Bold text • Call to action',
      aspect: '9:16',
      icon: Icons.campaign_rounded,
      color: Colors.greenAccent,
    ),
    TemplateItem(
      id: 'vlog',
      name: 'Vlog Intro',
      description: '16:9 • Lower third • Music',
      aspect: '16:9',
      icon: Icons.mic_rounded,
      color: Colors.lightBlueAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose a template to start quickly\n${Branding.byLine}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final t = templates[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GalleryScreen(isVideoMode: true),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(t.icon, color: t.color, size: 24),
                        ),
                        const Spacer(),
                        Text(
                          t.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.aspect,
                            style: const TextStyle(fontSize: 10, color: AppTheme.primary),
                          ),
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
}
