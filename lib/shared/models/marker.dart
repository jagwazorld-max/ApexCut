import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TimelineMarker extends Equatable {
  final String id;
  final Duration time;
  final String label;
  final int colorValue;

  const TimelineMarker({
    required this.id,
    required this.time,
    this.label = '',
    this.colorValue = 0xFFFF3B5C,
  });

  factory TimelineMarker.create({
    required Duration time,
    String label = '',
  }) {
    return TimelineMarker(
      id: const Uuid().v4(),
      time: time,
      label: label,
    );
  }

  @override
  List<Object?> get props => [id, time, label];
}
