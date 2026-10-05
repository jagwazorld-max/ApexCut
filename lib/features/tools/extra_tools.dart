import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ExtraToolsPanel extends StatelessWidget {
  final void Function(String tool) onTool;

  const ExtraToolsPanel({super.key, required this.onTool});

  static const tools = [
    ('Ken Burns', Icons.motion_photos_on_rounded),
    ('Duplicate Clip', Icons.copy_all_rounded),
    ('Freeze Frame', Icons.pause_circle_outline),
    ('Reverse Clip', Icons.replay),
    ('Stabilize', Icons.videocam),
    ('Denoise', Icons.graphic_eq),
    ('Sharpen', Icons.details),
    ('Vignette Strength', Icons.vignette),
    ('Motion Blur', Icons.blur_on),
    ('Chromatic Aberration', Icons.filter_vintage),
    ('Glow', Icons.wb_iridescent),
    ('Mirror Horizontal', Icons.flip),
    ('Mirror Vertical', Icons.flip_camera_android),
    ('Add Watermark', Icons.branding_watermark),
    ('Safe Area Guides', Icons.crop_free),
    ('Beat Markers', Icons.music_note),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pro Tools', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: tools.length,
              itemBuilder: (context, i) {
                final t = tools[i];
                return InkWell(
                  onTap: () {
                    onTool(t.$1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${t.$1} applied')),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.$2, color: AppTheme.primary, size: 22),
                        const SizedBox(height: 6),
                        Text(t.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
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
