import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'keyframe.dart';
import 'effect.dart';

enum ClipType { video, image, audio }

class MediaClip extends Equatable {
  final String id;
  final String path;
  final ClipType type;
  final Duration startTime;       // Position on timeline
  final Duration duration;        // Visible duration on timeline
  final Duration sourceStart;     // In-point in source
  final Duration sourceDuration;  // Original media length
  final double volume;
  final double speed;
  final double scale;
  final double rotation;
  final double opacity;
  final String? filterId;
  final List<Effect> effects;
  final List<Keyframe> keyframes; // Premiere-style keyframes
  final Map<String, dynamic> colorGrade; // Per-clip color

  const MediaClip({
    required this.id,
    required this.path,
    required this.type,
    required this.startTime,
    required this.duration,
    required this.sourceStart,
    required this.sourceDuration,
    this.volume = 1.0,
    this.speed = 1.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.filterId,
    this.effects = const [],
    this.keyframes = const [],
    this.colorGrade = const {},
  });

  factory MediaClip.create({
    required String path,
    required ClipType type,
    required Duration sourceDuration,
    Duration startTime = Duration.zero,
  }) {
    return MediaClip(
      id: const Uuid().v4(),
      path: path,
      type: type,
      startTime: startTime,
      duration: sourceDuration,
      sourceStart: Duration.zero,
      sourceDuration: sourceDuration,
    );
  }

  MediaClip copyWith({
    Duration? startTime,
    Duration? duration,
    Duration? sourceStart,
    double? volume,
    double? speed,
    double? scale,
    double? rotation,
    double? opacity,
    String? filterId,
    List<Effect>? effects,
    List<Keyframe>? keyframes,
    Map<String, dynamic>? colorGrade,
  }) {
    return MediaClip(
      id: id,
      path: path,
      type: type,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      sourceStart: sourceStart ?? this.sourceStart,
      sourceDuration: sourceDuration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      filterId: filterId ?? this.filterId,
      effects: effects ?? this.effects,
      keyframes: keyframes ?? this.keyframes,
      colorGrade: colorGrade ?? this.colorGrade,
    );
  }

  Duration get endTime => startTime + duration;

  @override
  List<Object?> get props => [
        id, path, type, startTime, duration, sourceStart,
        volume, speed, scale, opacity, effects, keyframes,
      ];
}
