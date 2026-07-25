import 'package:flutter/material.dart';

abstract final class FixFlowElevation {
  static const double flat = 0;
  static const double low = 1;
  static const double raised = 2;
  static const double overlay = 3;

  static List<BoxShadow> shadow(Color color, double level) => level == flat
      ? const []
      : [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: level * 6,
            offset: Offset(0, level * 2),
          ),
        ];
}
