import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'clip.dart';

enum TrackType { video, audio, title }

class Track extends Equatable {
  final String id;
  final String name;
  final TrackType type;
  final List<MediaClip> clips;
  final bool isLocked;
  final bool isMuted;
  final bool isHidden;
  final double height; // UI height of the track

  const Track({
    required this.id,
    required this.name,
    required this.type,
    this.clips = const [],
    this.isLocked = false,
    this.isMuted = false,
    this.isHidden = false,
    this.height = 60,
  });

  factory Track.create({
    required String name,
    required TrackType type,
  }) {
    return Track(
      id: const Uuid().v4(),
      name: name,
      type: type,
    );
  }

  Track copyWith({
    String? name,
    List<MediaClip>? clips,
    bool? isLocked,
    bool? isMuted,
    bool? isHidden,
    double? height,
  }) {
    return Track(
      id: id,
      name: name ?? this.name,
      type: type,
      clips: clips ?? this.clips,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
      isHidden: isHidden ?? this.isHidden,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [id, name, type, clips, isLocked, isMuted, isHidden];
}
