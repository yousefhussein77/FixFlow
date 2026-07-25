import 'package:fixflow/design_system/theme/fixflow_colors.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:fixflow/design_system/theme/fixflow_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand anchors and both explicit themes are complete', () {
    expect(FixFlowColors.brandPrimary, const Color(0xFF1E4DB7));
    expect(FixFlowColors.brandSecondary, const Color(0xFF386CFF));
    expect(FixFlowColors.brandAccent, const Color(0xFFF28A1B));
    expect(FixFlowColors.brandSuccess, const Color(0xFF22C55E));
    expect(FixFlowColors.lightBackground, const Color(0xFFF3F4F6));
    expect(FixFlowColors.lightSurface, Colors.white);
    expect(FixFlowColors.lightText, const Color(0xFF111827));

    final light = FixFlowTheme.light();
    final dark = FixFlowTheme.dark();
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.colorScheme.primary, FixFlowColors.brandPrimary);
    expect(light.extension<FixFlowSemanticColors>(), isNotNull);
    expect(dark.extension<FixFlowSemanticColors>(), isNotNull);
    expect(light.filledButtonTheme.style, isNotNull);
    expect(dark.inputDecorationTheme.filled, isTrue);
  });
}
