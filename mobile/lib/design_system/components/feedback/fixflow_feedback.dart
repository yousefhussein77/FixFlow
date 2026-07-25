import 'package:flutter/material.dart';

enum FixFlowFeedbackKind { information, success, warning, error }

void showFixFlowSnackBar(
  BuildContext context, {
  required String message,
  FixFlowFeedbackKind kind = FixFlowFeedbackKind.information,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final scheme = Theme.of(context).colorScheme;
  final (background, foreground) = switch (kind) {
    FixFlowFeedbackKind.information => (scheme.primary, scheme.onPrimary),
    FixFlowFeedbackKind.success => (const Color(0xFF166534), Colors.white),
    FixFlowFeedbackKind.warning => (const Color(0xFF92400E), Colors.white),
    FixFlowFeedbackKind.error => (scheme.error, scheme.onError),
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: background,
      content: Text(message, style: TextStyle(color: foreground)),
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction),
    ),
  );
}

class FixFlowBanner extends StatelessWidget {
  const FixFlowBanner({
    required this.message,
    this.kind = FixFlowFeedbackKind.information,
    this.action,
    super.key,
  });
  final String message;
  final FixFlowFeedbackKind kind;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (kind) {
      FixFlowFeedbackKind.information => Icons.info_outline,
      FixFlowFeedbackKind.success => Icons.check_circle_outline,
      FixFlowFeedbackKind.warning => Icons.warning_amber_outlined,
      FixFlowFeedbackKind.error => Icons.error_outline,
    };
    return MaterialBanner(
      content: Text(message),
      leading: Icon(icon),
      backgroundColor: scheme.surfaceContainerHighest,
      actions: [action ?? const SizedBox.shrink()],
    );
  }
}
