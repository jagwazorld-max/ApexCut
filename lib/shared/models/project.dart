import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'track.dart';
import 'text_layer.dart';

enum ProjectType { photo, video, mixed }

enum AspectRatioPreset {
  original,
  ratio9x16, // TikTok / Reels / Shorts
  ratio1x1,
  ratio16x9,
  ratio4x5,
  ratio3x4,
}

class Project extends Equatable {
  final String id;
  final String name;
  final ProjectType type;
  final AspectRatioPreset aspectRatio;
  final List<Track> tracks;           // Premiere-style multi-track
  final List<TextLayer> textLayers;
  final String? musicPath;
  final double musicVolume;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailPath;
  final Duration duration;
  final Map<String, dynamic> colorGrade; // Global color settings

  const Project({
    required this.id,
    required this.name,
    required this.type,
    this.aspectRatio = AspectRatioPreset.ratio9x16,
    this.tracks = const [],
    this.textLayers = const [],
    this.musicPath,
    this.musicVolume = 1.0,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailPath,
    this.duration = Duration.zero,
    this.colorGrade = const {},
  });

  factory Project.create({
    required String name,
    required ProjectType type,
    AspectRatioPreset aspectRatio = AspectRatioPreset.ratio9x16,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      type: type,
      aspectRatio: aspectRatio,
      createdAt: now,
      updatedAt: now,
      tracks: [
        Track.create(name: 'V1', type: TrackType.video),
        Track.create(name: 'A1', type: TrackType.audio),
      ],
    );
  }

  Project copyWith({
    String? name,
    ProjectType? type,
    AspectRatioPreset? aspectRatio,
    List<Track>? tracks,
    List<TextLayer>? textLayers,
    String? musicPath,
    double? musicVolume,
    DateTime? updatedAt,
    String? thumbnailPath,
    Duration? duration,
    Map<String, dynamic>? colorGrade,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      tracks: tracks ?? this.tracks,
      textLayers: textLayers ?? this.textLayers,
      musicPath: musicPath ?? this.musicPath,
      musicVolume: musicVolume ?? this.musicVolume,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      colorGrade: colorGrade ?? this.colorGrade,
    );
  }

  double get aspectRatioValue {
    switch (aspectRatio) {
      case AspectRatioPreset.ratio9x16:
        return 9 / 16;
      case AspectRatioPreset.ratio1x1:
        return 1.0;
      case AspectRatioPreset.ratio16x9:
        return 16 / 9;
      case AspectRatioPreset.ratio4x5:
        return 4 / 5;
      case AspectRatioPreset.ratio3x4:
        return 3 / 4;
      case AspectRatioPreset.original:
        return 9 / 16;
    }
  }

  List<Track> get videoTracks => tracks.where((t) => t.type == TrackType.video).toList();
  List<Track> get audioTracks => tracks.where((t) => t.type == TrackType.audio).toList();

  @override
  List<Object?> get props => [id, name, type, aspectRatio, tracks, textLayers, updatedAt];
}
