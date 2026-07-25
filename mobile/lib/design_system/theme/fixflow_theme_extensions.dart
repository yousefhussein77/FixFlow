import 'package:flutter/material.dart';

@immutable
class FixFlowSemanticStyle {
  const FixFlowSemanticStyle({
    required this.foreground,
    required this.container,
    required this.border,
    required this.icon,
    required this.label,
  });

  final Color foreground;
  final Color container;
  final Color border;
  final IconData icon;
  final String label;

  FixFlowSemanticStyle lerp(FixFlowSemanticStyle other, double t) =>
      FixFlowSemanticStyle(
        foreground: Color.lerp(foreground, other.foreground, t)!,
        container: Color.lerp(container, other.container, t)!,
        border: Color.lerp(border, other.border, t)!,
        icon: t < .5 ? icon : other.icon,
        label: t < .5 ? label : other.label,
      );
}

@immutable
class FixFlowSemanticColors extends ThemeExtension<FixFlowSemanticColors> {
  const FixFlowSemanticColors({
    required this.information,
    required this.success,
    required this.warning,
    required this.error,
    required this.statuses,
    required this.priorities,
  });

  final FixFlowSemanticStyle information;
  final FixFlowSemanticStyle success;
  final FixFlowSemanticStyle warning;
  final FixFlowSemanticStyle error;
  final Map<String, FixFlowSemanticStyle> statuses;
  final Map<String, FixFlowSemanticStyle> priorities;

  FixFlowSemanticStyle status(String value) => statuses[value] ?? information;
  FixFlowSemanticStyle priority(String value) =>
      priorities[value] ?? information;

  @override
  FixFlowSemanticColors copyWith({
    FixFlowSemanticStyle? information,
    FixFlowSemanticStyle? success,
    FixFlowSemanticStyle? warning,
    FixFlowSemanticStyle? error,
    Map<String, FixFlowSemanticStyle>? statuses,
    Map<String, FixFlowSemanticStyle>? priorities,
  }) => FixFlowSemanticColors(
    information: information ?? this.information,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    statuses: statuses ?? this.statuses,
    priorities: priorities ?? this.priorities,
  );

  @override
  FixFlowSemanticColors lerp(covariant FixFlowSemanticColors other, double t) =>
      FixFlowSemanticColors(
        information: information.lerp(other.information, t),
        success: success.lerp(other.success, t),
        warning: warning.lerp(other.warning, t),
        error: error.lerp(other.error, t),
        statuses: {
          for (final key in statuses.keys)
            key: statuses[key]!.lerp(other.statuses[key] ?? statuses[key]!, t),
        },
        priorities: {
          for (final key in priorities.keys)
            key: priorities[key]!.lerp(
              other.priorities[key] ?? priorities[key]!,
              t,
            ),
        },
      );
}
