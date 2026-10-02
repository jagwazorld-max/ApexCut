import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../color/color_correction_panel.dart';
import '../effects/effects_panel.dart';
import '../graphics/text_tools_panel.dart';
import '../../shared/models/text_layer.dart';
import '../../shared/models/effect.dart';

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

  final List<_ToolItem> _tools = [
    _ToolItem('Adjust', Icons.tune_rounded),
    _ToolItem('Color', Icons.palette_rounded),
    _ToolItem('Filters', Icons.filter_rounded),
    _ToolItem('Text', Icons.text_fields_rounded),
    _ToolItem('Effects', Icons.auto_awesome_rounded),
    _ToolItem('Crop', Icons.crop_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            const Text('Photo Editor', style: TextStyle(fontSize: 16)),
            Text(
              Branding.byLine,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo export ready for FFmpeg / image package')),
              );
            },
            child: const Text(
              'Export',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
            ),
          ),

          // Dynamic panel
          SizedBox(
            height: 210,
            child: _buildPanel(),
          ),

          // Toolbar
          Container(
            height: 78,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = _selectedTool == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTool = index),
                  child: Container(
                    width: 68,
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: AppTheme.primary, width: 1.2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                        const SizedBox(height: 3),
                        Text(
                          tool.label,
                          style: TextStyle(
                            fontSize: 10,
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
      case 1: // Color
        return ColorCorrectionPanel(
          initialValues: _colorGrade,
          onChanged: (v) => setState(() => _colorGrade = v),
        );
      case 2: // Filters / Effects
      case 4:
        return EffectsPanel(
          onEffectSelected: (effect) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Effect: ${effect.name}')),
            );
          },
        );
      case 3: // Text
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
      default:
        return Container(
          color: AppTheme.surface,
          child: Center(
            child: Text(
              '${_tools[_selectedTool].label} tools',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        );
    }
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  const _ToolItem(this.label, this.icon);
}
