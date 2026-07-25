import 'package:flutter/material.dart';

import '../tokens/fixflow_borders.dart';
import '../tokens/fixflow_elevation.dart';
import '../tokens/fixflow_radius.dart';
import '../tokens/fixflow_spacing.dart';
import 'fixflow_colors.dart';
import 'fixflow_theme_extensions.dart';
import 'fixflow_typography.dart';

abstract final class FixFlowTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = dark
        ? const ColorScheme.dark(
            primary: Color(0xFF8AA7FF),
            onPrimary: Color(0xFF071A45),
            primaryContainer: Color(0xFF163B91),
            onPrimaryContainer: Color(0xFFDCE5FF),
            secondary: Color(0xFFFFB55C),
            onSecondary: Color(0xFF422100),
            secondaryContainer: Color(0xFF653600),
            onSecondaryContainer: Color(0xFFFFDDB8),
            error: FixFlowColors.darkError,
            onError: Color(0xFF690005),
            errorContainer: Color(0xFF7F1D1D),
            onErrorContainer: Color(0xFFFEE2E2),
            surface: FixFlowColors.darkSurface,
            onSurface: FixFlowColors.darkText,
            surfaceContainerHighest: FixFlowColors.darkRaisedSurface,
            onSurfaceVariant: FixFlowColors.darkSupporting,
            outline: FixFlowColors.darkBorder,
          )
        : const ColorScheme.light(
            primary: FixFlowColors.brandPrimary,
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFDCE5FF),
            onPrimaryContainer: Color(0xFF102E72),
            secondary: FixFlowColors.brandAccent,
            onSecondary: Color(0xFF351900),
            secondaryContainer: Color(0xFFFFDDB8),
            onSecondaryContainer: Color(0xFF542900),
            error: FixFlowColors.lightError,
            onError: Colors.white,
            errorContainer: Color(0xFFFEE2E2),
            onErrorContainer: Color(0xFF7F1D1D),
            surface: FixFlowColors.lightSurface,
            onSurface: FixFlowColors.lightText,
            surfaceContainerHighest: Color(0xFFE5E7EB),
            onSurfaceVariant: FixFlowColors.lightSupporting,
            outline: FixFlowColors.lightBorder,
          );
    final semantic = dark ? _darkSemantic() : _lightSemantic();
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FixFlowRadius.medium),
    );
    final textTheme = FixFlowTypography.textTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? FixFlowColors.darkBackground
          : FixFlowColors.lightBackground,
      textTheme: textTheme,
      extensions: [semantic],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: FixFlowElevation.flat,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: FixFlowElevation.low,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.large),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(FixFlowSpacing.touch, FixFlowSpacing.touch),
          padding: const EdgeInsets.symmetric(horizontal: FixFlowSpacing.md),
          shape: rounded,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(FixFlowSpacing.touch, FixFlowSpacing.touch),
          padding: const EdgeInsets.symmetric(horizontal: FixFlowSpacing.md),
          shape: rounded,
          side: BorderSide(color: scheme.outline, width: FixFlowBorders.subtle),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(FixFlowSpacing.touch, FixFlowSpacing.touch),
          shape: rounded,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FixFlowSpacing.sm,
          vertical: FixFlowSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.medium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.medium),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.medium),
          borderSide: BorderSide(
            color: scheme.primary,
            width: FixFlowBorders.focus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.medium),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FixFlowRadius.extraLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FixFlowRadius.extraLarge),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: FixFlowSpacing.xs),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(FixFlowSpacing.touch, FixFlowSpacing.touch),
          ),
          shape: WidgetStatePropertyAll(rounded),
        ),
      ),
    );
  }

  static FixFlowSemanticStyle _style(
    Color foreground,
    Color container,
    IconData icon,
    String label,
  ) => FixFlowSemanticStyle(
    foreground: foreground,
    container: container,
    border: foreground,
    icon: icon,
    label: label,
  );

  static FixFlowSemanticColors _lightSemantic() {
    final info = _style(
      const Color(0xFF1E3A8A),
      const Color(0xFFDBEAFE),
      Icons.info_outline,
      'Information',
    );
    final success = _style(
      const Color(0xFF166534),
      const Color(0xFFDCFCE7),
      Icons.check_circle_outline,
      'Success',
    );
    final warning = _style(
      const Color(0xFF92400E),
      const Color(0xFFFEF3C7),
      Icons.warning_amber_outlined,
      'Warning',
    );
    final error = _style(
      const Color(0xFF991B1B),
      const Color(0xFFFEE2E2),
      Icons.error_outline,
      'Error',
    );
    return FixFlowSemanticColors(
      information: info,
      success: success,
      warning: warning,
      error: error,
      statuses: {
        'new': info,
        'assigned': _style(
          const Color(0xFF5B21B6),
          const Color(0xFFEDE9FE),
          Icons.assignment_ind_outlined,
          'Assigned',
        ),
        'in_progress': _style(
          warning.foreground,
          warning.container,
          Icons.handyman_outlined,
          'In progress',
        ),
        'completed': _style(
          success.foreground,
          success.container,
          Icons.task_alt_outlined,
          'Completed',
        ),
        'rejected': _style(
          error.foreground,
          error.container,
          Icons.cancel_outlined,
          'Rejected',
        ),
      },
      priorities: {
        'low': _style(
          const Color(0xFF334155),
          const Color(0xFFE2E8F0),
          Icons.keyboard_arrow_down,
          'Low priority',
        ),
        'medium': _style(
          warning.foreground,
          warning.container,
          Icons.remove,
          'Medium priority',
        ),
        'high': _style(
          error.foreground,
          error.container,
          Icons.priority_high,
          'High priority',
        ),
      },
    );
  }

  static FixFlowSemanticColors _darkSemantic() {
    final info = _style(
      const Color(0xFFDBEAFE),
      const Color(0xFF1E3A8A),
      Icons.info_outline,
      'Information',
    );
    final success = _style(
      const Color(0xFFDCFCE7),
      const Color(0xFF14532D),
      Icons.check_circle_outline,
      'Success',
    );
    final warning = _style(
      const Color(0xFFFEF3C7),
      const Color(0xFF78350F),
      Icons.warning_amber_outlined,
      'Warning',
    );
    final error = _style(
      const Color(0xFFFEE2E2),
      const Color(0xFF7F1D1D),
      Icons.error_outline,
      'Error',
    );
    return FixFlowSemanticColors(
      information: info,
      success: success,
      warning: warning,
      error: error,
      statuses: {
        'new': info,
        'assigned': _style(
          const Color(0xFFEDE9FE),
          const Color(0xFF4C1D95),
          Icons.assignment_ind_outlined,
          'Assigned',
        ),
        'in_progress': _style(
          warning.foreground,
          warning.container,
          Icons.handyman_outlined,
          'In progress',
        ),
        'completed': _style(
          success.foreground,
          success.container,
          Icons.task_alt_outlined,
          'Completed',
        ),
        'rejected': _style(
          error.foreground,
          error.container,
          Icons.cancel_outlined,
          'Rejected',
        ),
      },
      priorities: {
        'low': _style(
          const Color(0xFFF1F5F9),
          const Color(0xFF334155),
          Icons.keyboard_arrow_down,
          'Low priority',
        ),
        'medium': _style(
          warning.foreground,
          warning.container,
          Icons.remove,
          'Medium priority',
        ),
        'high': _style(
          error.foreground,
          error.container,
          Icons.priority_high,
          'High priority',
        ),
      },
    );
  }
}
