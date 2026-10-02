import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/keyframe.dart';

/// Premiere-style keyframe editor panel
class KeyframePanel extends StatefulWidget {
  final List<Keyframe> keyframes;
  final ValueChanged<List<Keyframe>> onChanged;
  final Duration clipDuration;

  const KeyframePanel({
    super.key,
    required this.keyframes,
    required this.onChanged,
    required this.clipDuration,
  });

  @override
  State<KeyframePanel> createState() => _KeyframePanelState();
}

class _KeyframePanelState extends State<KeyframePanel> {
  KeyframeProperty _selectedProperty = KeyframeProperty.scale;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.keyframes
        .where((k) => k.property == _selectedProperty)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keyframes',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Property selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: KeyframeProperty.values.map((prop) {
                final isSelected = _selectedProperty == prop;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_label(prop), style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedProperty = prop),
                    selectedColor: AppTheme.primary.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Add keyframe button
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final newKf = Keyframe.create(
                    property: _selectedProperty,
                    time: Duration.zero,
                    value: 1.0,
                  );
                  final updated = [...widget.keyframes, newKf];
                  widget.onChanged(updated);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Keyframe', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Keyframe list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No keyframes for this property',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final kf = filtered[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${_format(kf.time)}  →  ${kf.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          kf.ease.name,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () {
                            final updated = widget.keyframes.where((k) => k.id != kf.id).toList();
                            widget.onChanged(updated);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _label(KeyframeProperty p) {
    switch (p) {
      case KeyframeProperty.positionX:
        return 'Pos X';
      case KeyframeProperty.positionY:
        return 'Pos Y';
      case KeyframeProperty.scale:
        return 'Scale';
      case KeyframeProperty.rotation:
        return 'Rotation';
      case KeyframeProperty.opacity:
        return 'Opacity';
      case KeyframeProperty.volume:
        return 'Volume';
      case KeyframeProperty.speed:
        return 'Speed';
    }
  }

  String _format(Duration d) {
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0');
    return '0:$s.$ms';
  }
}
