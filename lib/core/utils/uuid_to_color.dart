import 'dart:math';
import 'package:flutter/material.dart';

Color generateColorFromUUID(String uuid) {
  final hash = uuid.hashCode;
  final rng = Random(hash);

  final hue = rng.nextInt(360);
  final color = HSLColor.fromAHSL(
    1.0,
    hue.toDouble(),
    0.5,
    0.6,
  ).toColor().withAlpha(77);

  return color;
}
