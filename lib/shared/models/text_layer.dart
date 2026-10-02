import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TextLayer extends Equatable {
  final String id;
  final String text;
  final Duration startTime;
  final Duration duration;
  final Offset position;
  final double fontSize;
  final String fontFamily;
  final Color color;
  final Color? backgroundColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final double rotation;
  final double scale;
  final bool hasShadow;
  final String? animationId;

  const TextLayer({
    required this.id,
    required this.text,
    required this.startTime,
    required this.duration,
    this.position = const Offset(0.5, 0.5),
    this.fontSize = 32,
    this.fontFamily = 'Inter',
    this.color = Colors.white,
    this.backgroundColor,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.center,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.hasShadow = true,
    this.animationId,
  });

  factory TextLayer.create({
    required String text,
    required Duration startTime,
    Duration duration = const Duration(seconds: 3),
  }) {
    return TextLayer(
      id: const Uuid().v4(),
      text: text,
      startTime: startTime,
      duration: duration,
    );
  }

  TextLayer copyWith({
    String? text,
    Duration? startTime,
    Duration? duration,
    Offset? position,
    double? fontSize,
    String? fontFamily,
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    double? rotation,
    double? scale,
    bool? hasShadow,
    String? animationId,
  }) {
    return TextLayer(
      id: id,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      hasShadow: hasShadow ?? this.hasShadow,
      animationId: animationId ?? this.animationId,
    );
  }

  Duration get endTime => startTime + duration;

  @override
  List<Object?> get props => [id, text, startTime, duration, position, fontSize, color];
}
