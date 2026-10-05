import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CanvasItem {
  String id;
  String label;
  Offset position;
  double scale;
  double rotation;
  Color color;
  bool isPip;

  CanvasItem({
    required this.id,
    required this.label,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0,
    this.color = AppTheme.primary,
    this.isPip = false,
  });
}

/// Interactive canvas for sticker placement and PiP positioning.
class EditorCanvas extends StatefulWidget {
  final List<CanvasItem> items;
  final ValueChanged<List<CanvasItem>> onChanged;
  final bool painting;
  final double brushSize;
  final bool erase;

  const EditorCanvas({
    super.key,
    required this.items,
    required this.onChanged,
    this.painting = false,
    this.brushSize = 30,
    this.erase = false,
  });

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  String? _draggingId;
  final List<Offset> _maskPoints = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (d) => _onPanStart(d.localPosition),
          onPanUpdate: (d) => _onPanUpdate(d.localPosition),
          onPanEnd: (_) => _draggingId = null,
          child: CustomPaint(
            painter: _MaskPainter(_maskPoints, widget.brushSize, widget.erase),
            child: Stack(
              children: widget.items.map((item) {
                return Positioned(
                  left: item.position.dx,
                  top: item.position.dy,
                  child: Transform.rotate(
                    angle: item.rotation,
                    child: Transform.scale(
                      scale: item.scale,
                      child: Container(
                        width: item.isPip ? 120 : 72,
                        height: item.isPip ? 80 : 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(item.isPip ? 8 : 20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _onPanStart(Offset local) {
    if (widget.painting) {
      setState(() => _maskPoints.add(local));
      return;
    }
    for (final item in widget.items.reversed) {
      final rect = Rect.fromLTWH(item.position.dx, item.position.dy, item.isPip ? 120 : 72, item.isPip ? 80 : 48);
      if (rect.contains(local)) {
        _draggingId = item.id;
        break;
      }
    }
  }

  void _onPanUpdate(Offset local) {
    if (widget.painting) {
      setState(() => _maskPoints.add(local));
      return;
    }
    if (_draggingId == null) return;
    final updated = widget.items.map((item) {
      if (item.id != _draggingId) return item;
      item.position = local - const Offset(36, 24);
      return item;
    }).toList();
    widget.onChanged(updated);
  }
}

class _MaskPainter extends CustomPainter {
  final List<Offset> points;
  final double brush;
  final bool erase;

  _MaskPainter(this.points, this.brush, this.erase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = erase ? Colors.transparent : AppTheme.primary.withOpacity(0.35)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brush
      ..style = PaintingStyle.stroke
      ..blendMode = erase ? BlendMode.clear : BlendMode.srcOver;

    for (final p in points) {
      canvas.drawCircle(p, brush / 2, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter old) => true;
}
