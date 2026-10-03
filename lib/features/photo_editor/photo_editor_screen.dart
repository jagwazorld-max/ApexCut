import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../../shared/models/layer.dart';
import '../color/color_correction_panel.dart';
import '../effects/effects_panel.dart';
import '../graphics/text_tools_panel.dart';
import '../../shared/models/text_layer.dart';
import 'panels/crop_panel.dart';
import 'panels/cutout_panel.dart';
import 'panels/replace_panel.dart';
import '../cinematic/looks.dart';

class PhotoEditorScreen extends StatefulWidget {
  final String imagePath;

  const PhotoEditorScreen({super.key, required this.imagePath});

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  int _selectedTool = 0;
  Map<String, double> _colorGrade = {};
  List<TextLayer> _textLayers = [];
  TextLayer? _selectedTextLayer;
  List<EditorLayer> _layers = [];
  String _cropRatio = 'Free';
  double _rotation = 0;
  bool _flipH = false;
  bool _flipV = false;
  bool _hasCutout = false;
  String _lookId = 'teal-orange';

  // Simple undo stack
  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];

  final List<_ToolItem> _tools = [
    _ToolItem('Adjust', Icons.tune_rounded),
    _ToolItem('Color', Icons.palette_rounded),
    _ToolItem('Filters', Icons.filter_rounded),
    _ToolItem('Text', Icons.text_fields_rounded),
    _ToolItem('Cutout', Icons.content_cut_rounded),
    _ToolItem('Replace', Icons.find_replace_rounded),
    _ToolItem('Crop', Icons.crop_rounded),
    _ToolItem('Layers', Icons.layers_rounded),
  ];

  void _pushUndo() {
    _undoStack.add({
      'colorGrade': Map<String, double>.from(_colorGrade),
      'rotation': _rotation,
      'flipH': _flipH,
      'flipV': _flipV,
      'cropRatio': _cropRatio,
    });
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add({
      'colorGrade': Map<String, double>.from(_colorGrade),
      'rotation': _rotation,
      'flipH': _flipH,
      'flipV': _flipV,
      'cropRatio': _cropRatio,
    });
    final prev = _undoStack.removeLast();
    setState(() {
      _colorGrade = Map<String, double>.from(prev['colorGrade']);
      _rotation = prev['rotation'];
      _flipH = prev['flipH'];
      _flipV = prev['flipV'];
      _cropRatio = prev['cropRatio'];
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _pushUndo();
    final next = _redoStack.removeLast();
    setState(() {
      _colorGrade = Map<String, double>.from(next['colorGrade']);
      _rotation = next['rotation'];
      _flipH = next['flipH'];
      _flipV = next['flipV'];
      _cropRatio = next['cropRatio'];
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
            const Text('Photo Editor', style: TextStyle(fontSize: 16)),
            Text(Branding.byLine, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            onPressed: _undoStack.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            onPressed: _redoStack.isEmpty ? null : _redo,
          ),
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.surface,
                builder: (_) => _ExportSheet(),
              );
            },
            child: const Text('Export', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_rotation * 3.14159 / 180)
                  ..scale(_flipH ? -1.0 : 1.0, _flipV ? -1.0 : 1.0),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ColorFiltered(
                    colorFilter: CinematicLooks.byId(_lookId).filter,
                    child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 200, child: _buildPanel()),

          Container(
            height: 78,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = _selectedTool == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTool = index),
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: AppTheme.primary, width: 1.2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                        const SizedBox(height: 3),
                        Text(
                          tool.label,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildPanel() {
    switch (_selectedTool) {
      case 1:
        return ColorCorrectionPanel(
          initialValues: _colorGrade,
          onChanged: (v) {
            _pushUndo();
            setState(() => _colorGrade = v);
          },
        );
      case 2:
        return EffectsPanel(
          onEffectSelected: (effect) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filter: ${effect.name}')));
          },
        );
      case 3:
        return TextToolsPanel(
          selectedLayer: _selectedTextLayer,
          onChanged: (layer) {
            setState(() {
              _selectedTextLayer = layer;
              final idx = _textLayers.indexWhere((t) => t.id == layer.id);
              if (idx >= 0) _textLayers[idx] = layer;
            });
          },
          onAddText: () {
            final layer = TextLayer.create(text: 'New Text', startTime: Duration.zero);
            setState(() {
              _textLayers.add(layer);
              _selectedTextLayer = layer;
            });
          },
        );
      case 4: // Cutout
        return CutoutPanel(
          hasCutout: _hasCutout,
          onAutoCutout: () {
            setState(() => _hasCutout = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Auto Cutout applied (AI ready)')),
            );
          },
          onManualCutout: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manual brush cutout mode')),
            );
          },
          onInvertMask: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mask inverted')));
          },
          onFeather: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edges feathered')));
          },
        );
      case 5: // Replace
        return ReplacePanel(
          onReplaceBackground: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select new background image')));
          },
          onReplaceObject: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Object replace mode')));
          },
          onAddOverlay: () {
            final layer = EditorLayer.create(type: LayerType.image, name: 'Overlay');
            setState(() => _layers.add(layer));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Overlay layer added')));
          },
          onPictureInPicture: () {
            final layer = EditorLayer.create(type: LayerType.video, name: 'PiP');
            setState(() => _layers.add(layer));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Picture-in-Picture added')));
          },
        );
      case 6: // Crop
        return CropPanel(
          currentRatio: _cropRatio,
          onRatioSelected: (r) {
            _pushUndo();
            setState(() => _cropRatio = r);
          },
          onRotateLeft: () {
            _pushUndo();
            setState(() => _rotation -= 90);
          },
          onRotateRight: () {
            _pushUndo();
            setState(() => _rotation += 90);
          },
          onFlipHorizontal: () {
            _pushUndo();
            setState(() => _flipH = !_flipH);
          },
          onFlipVertical: () {
            _pushUndo();
            setState(() => _flipV = !_flipV);
          },
        );
      case 7: // Layers
        return Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Layers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Expanded(
                child: _layers.isEmpty
                    ? const Center(child: Text('No extra layers yet', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        itemCount: _layers.length,
                        itemBuilder: (context, index) {
                          final layer = _layers[index];
                          return ListTile(
                            dense: true,
                            title: Text(layer.name),
                            subtitle: Text(layer.type.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => setState(() => _layers.removeAt(index)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      default:
        return Container(
          color: AppTheme.surface,
          child: const Center(child: Text('Adjust tools', style: TextStyle(color: AppTheme.textSecondary))),
        );
    }
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  const _ToolItem(this.label, this.icon);
}

class _ExportSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Quality', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('High (1080p)'),
            trailing: const Icon(Icons.check, color: AppTheme.primary),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Medium (720p)'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Original'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
