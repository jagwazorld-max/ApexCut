import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum EffectCategory {
  transition,
  videoEffect,
  color,
  audio,
  stylize,
  blur,
  distort,
}

class Effect extends Equatable {
  final String id;
  final String name;
  final EffectCategory category;
  final Map<String, dynamic> parameters;
  final bool isEnabled;

  const Effect({
    required this.id,
    required this.name,
    required this.category,
    this.parameters = const {},
    this.isEnabled = true,
  });

  factory Effect.create({
    required String name,
    required EffectCategory category,
    Map<String, dynamic> parameters = const {},
  }) {
    return Effect(
      id: const Uuid().v4(),
      name: name,
      category: category,
      parameters: parameters,
    );
  }

  Effect copyWith({
    Map<String, dynamic>? parameters,
    bool? isEnabled,
  }) {
    return Effect(
      id: id,
      name: name,
      category: category,
      parameters: parameters ?? this.parameters,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // Common built-in effects (Premiere + CapCut style)
  static Effect crossDissolve() => Effect.create(
        name: 'Cross Dissolve',
        category: EffectCategory.transition,
        parameters: {'duration': 0.5},
      );

  static Effect fadeToBlack() => Effect.create(
        name: 'Fade to Black',
        category: EffectCategory.transition,
      );

  static Effect gaussianBlur() => Effect.create(
        name: 'Gaussian Blur',
        category: EffectCategory.blur,
        parameters: {'radius': 10.0},
      );

  static Effect brightnessContrast() => Effect.create(
        name: 'Brightness & Contrast',
        category: EffectCategory.color,
        parameters: {'brightness': 0.0, 'contrast': 0.0},
      );

  @override
  List<Object?> get props => [id, name, category, parameters, isEnabled];
}
