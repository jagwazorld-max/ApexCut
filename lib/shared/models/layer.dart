import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum LayerType { image, video, text, sticker, shape, cutout }

class EditorLayer extends Equatable {
  final String id;
  final LayerType type;
  final String? assetPath;
  final String name;
  final double x;          // 0-1 relative
  final double y;
  final double scale;
  final double rotation;
  final double opacity;
  final bool isVisible;
  final bool isLocked;
  final int zIndex;

  const EditorLayer({
    required this.id,
    required this.type,
    this.assetPath,
    required this.name,
    this.x = 0.5,
    this.y = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.isVisible = true,
    this.isLocked = false,
    this.zIndex = 0,
  });

  factory EditorLayer.create({
    required LayerType type,
    required String name,
    String? assetPath,
  }) {
    return EditorLayer(
      id: const Uuid().v4(),
      type: type,
      name: name,
      assetPath: assetPath,
    );
  }

  EditorLayer copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
    double? opacity,
    bool? isVisible,
    bool? isLocked,
    int? zIndex,
    String? name,
  }) {
    return EditorLayer(
      id: id,
      type: type,
      assetPath: assetPath,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  @override
  List<Object?> get props => [id, type, x, y, scale, rotation, opacity, isVisible, zIndex];
}
