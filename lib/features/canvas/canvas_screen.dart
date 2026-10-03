import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import 'editor_canvas.dart';

/// Master canvas for stickers, PiP, and mask painting.
class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final List<CanvasItem> _items = [];
  bool _painting = false;
  double _brush = 28;
  bool _erase = false;

  void _addSticker(String label) {
    setState(() {
      _items.add(CanvasItem(
        id: const Uuid().v4(),
        label: label,
        position: const Offset(80, 120),
        color: AppTheme.accent,
      ));
    });
  }

  void _addPip() {
    setState(() {
      _items.add(CanvasItem(
        id: const Uuid().v4(),
        label: 'PiP',
        position: const Offset(180, 200),
        isPip: true,
        color: AppTheme.secondary,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            const Text('Canvas', style: TextStyle(fontSize: 16)),
            Text(Branding.byLine, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: EditorCanvas(
                  items: _items,
                  painting: _painting,
                  brushSize: _brush,
                  erase: _erase,
                  onChanged: (items) => setState(() {
                    _items
                      ..clear()
                      ..addAll(items);
                  }),
                ),
              ),
            ),
          ),
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(onPressed: () => _addSticker('Star'), child: const Text('Sticker')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _addPip, child: const Text('Add PiP')),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() => _painting = !_painting),
                      child: Text(_painting ? 'Stop Paint' : 'Paint Mask'),
                    ),
                  ],
                ),
                if (_painting)
                  Row(
                    children: [
                      const Text('Brush'),
                      Expanded(
                        child: Slider(
                          value: _brush,
                          min: 8,
                          max: 80,
                          onChanged: (v) => setState(() => _brush = v),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _erase = !_erase),
                        child: Text(_erase ? 'Erase' : 'Paint'),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                const Text(
                  'Drag stickers and PiP to position them. Paint mask to select areas for background replace.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
