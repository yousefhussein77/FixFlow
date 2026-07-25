import 'package:flutter/material.dart';

abstract final class FixFlowTypography {
  static TextStyle _style(double size, FontWeight weight, double height) =>
      TextStyle(fontSize: size, fontWeight: weight, height: height);

  static TextTheme textTheme(Color color) => TextTheme(
    displaySmall: _style(32, FontWeight.w700, 1.25).copyWith(color: color),
    headlineMedium: _style(28, FontWeight.w700, 1.30).copyWith(color: color),
    titleLarge: _style(20, FontWeight.w600, 1.35).copyWith(color: color),
    titleMedium: _style(17, FontWeight.w600, 1.40).copyWith(color: color),
    bodyLarge: _style(16, FontWeight.w400, 1.50).copyWith(color: color),
    bodyMedium: _style(14, FontWeight.w400, 1.45).copyWith(color: color),
    labelLarge: _style(14, FontWeight.w600, 1.40).copyWith(color: color),
    bodySmall: _style(12, FontWeight.w400, 1.45).copyWith(color: color),
    labelMedium: _style(14, FontWeight.w600, 1.35).copyWith(color: color),
  );
}
