import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum KeyframeProperty {
  positionX,
  positionY,
  scale,
  rotation,
  opacity,
  volume,
  speed,
  // Color properties can be added later
}

enum EaseType {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  bezier,
}

class Keyframe extends Equatable {
  final String id;
  final KeyframeProperty property;
  final Duration time;          // Relative to clip start
  final double value;
  final EaseType ease;

  const Keyframe({
    required this.id,
    required this.property,
    required this.time,
    required this.value,
    this.ease = EaseType.linear,
  });

  factory Keyframe.create({
    required KeyframeProperty property,
    required Duration time,
    required double value,
    EaseType ease = EaseType.linear,
  }) {
    return Keyframe(
      id: const Uuid().v4(),
      property: property,
      time: time,
      value: value,
      ease: ease,
    );
  }

  Keyframe copyWith({
    Duration? time,
    double? value,
    EaseType? ease,
  }) {
    return Keyframe(
      id: id,
      property: property,
      time: time ?? this.time,
      value: value ?? this.value,
      ease: ease ?? this.ease,
    );
  }

  @override
  List<Object?> get props => [id, property, time, value, ease];
}
