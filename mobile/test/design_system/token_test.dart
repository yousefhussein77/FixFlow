import 'package:fixflow/design_system/theme/fixflow_typography.dart';
import 'package:fixflow/design_system/tokens/fixflow_borders.dart';
import 'package:fixflow/design_system/tokens/fixflow_elevation.dart';
import 'package:fixflow/design_system/tokens/fixflow_icons.dart';
import 'package:fixflow/design_system/tokens/fixflow_motion.dart';
import 'package:fixflow/design_system/tokens/fixflow_radius.dart';
import 'package:fixflow/design_system/tokens/fixflow_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokens follow documented invariants', () {
    expect(FixFlowSpacing.half, 4);
    for (final value in [
      FixFlowSpacing.xs,
      FixFlowSpacing.sm,
      FixFlowSpacing.md,
      FixFlowSpacing.lg,
      FixFlowSpacing.xl,
      FixFlowSpacing.touch,
      FixFlowSpacing.xxl,
    ]) {
      expect(value % 8, 0);
    }
    expect(FixFlowRadius.medium, 12);
    expect(FixFlowBorders.focus, 2);
    expect(FixFlowElevation.overlay, greaterThan(FixFlowElevation.raised));
    expect(FixFlowIcons.minimumTarget, 48);
    expect(FixFlowMotion.short, const Duration(milliseconds: 150));
    expect(
      FixFlowMotion.resolve(FixFlowMotion.standard, reduceMotion: true),
      Duration.zero,
    );
  });

  test('typography provides readable Arabic and Latin scale metrics', () {
    final theme = FixFlowTypography.textTheme(Colors.black);
    expect(theme.displaySmall!.fontSize, 32);
    expect(theme.bodyLarge!.fontSize, 14);
    expect(theme.bodySmall!.fontSize, 12);
    expect(theme.bodyLarge!.height, 1.6);
    expect(theme.labelLarge!.fontWeight, FontWeight.w600);
  });
}
