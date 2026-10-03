import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class BackgroundSwapPanel extends StatefulWidget {
  final String? currentBgPath;
  final ValueChanged<String> onBackgroundSelected;
  final VoidCallback onRemoveBackground;
  final bool hasMask;

  const BackgroundSwapPanel({
    super.key,
    this.currentBgPath,
    required this.onBackgroundSelected,
    required this.onRemoveBackground,
    this.hasMask = false,
  });

  @override
  State<BackgroundSwapPanel> createState() => _BackgroundSwapPanelState();
}

class _BackgroundSwapPanelState extends State<BackgroundSwapPanel> {
  final _picker = ImagePicker();

  final presets = const [
    {'name': 'Solid Black', 'color': Color(0xFF000000)},
    {'name': 'Solid White', 'color': Color(0xFFFFFFFF)},
    {'name': 'Gradient Blue', 'color': Color(0xFF0A84FF)},
    {'name': 'Studio Gray', 'color': Color(0xFF2C2C2E)},
    {'name': 'Green Screen', 'color': Color(0xFF00C853)},
    {'name': 'Warm Sunset', 'color': Color(0xFFFF6B35)},
  ];

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) widget.onBackgroundSelected(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Background Swap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            widget.hasMask
                ? 'Mask ready — choose a new background'
                : 'Apply a cutout/mask first for best results',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('Choose Image Background'),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Presets', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: presets.length,
              itemBuilder: (context, i) {
                final p = presets[i];
                final color = p['color'] as Color;
                return GestureDetector(
                  onTap: () {
                    widget.onBackgroundSelected('color:${color.value}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Background: ${p['name']}')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      p['name'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          TextButton(
            onPressed: widget.onRemoveBackground,
            child: const Text('Remove Background Overlay'),
          ),
        ],
      ),
    );
  }
}
