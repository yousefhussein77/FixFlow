import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:fixflow/design_system/theme/fixflow_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final high = a.computeLuminance() > b.computeLuminance() ? a : b;
  final low = identical(high, a) ? b : a;
  return (high.computeLuminance() + .05) / (low.computeLuminance() + .05);
}

void main() {
  for (final theme in [FixFlowTheme.light(), FixFlowTheme.dark()]) {
    test('${theme.brightness} semantic pairs meet normal text contrast', () {
      final semantic = theme.extension<FixFlowSemanticColors>()!;
      for (final style in {
        semantic.information,
        semantic.success,
        semantic.warning,
        semantic.error,
        ...semantic.statuses.values,
        ...semantic.priorities.values,
      }) {
        expect(
          contrast(style.foreground, style.container),
          greaterThanOrEqualTo(4.5),
          reason: style.label,
        );
      }
      expect(
        contrast(theme.colorScheme.onSurface, theme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
