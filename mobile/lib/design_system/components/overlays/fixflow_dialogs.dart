import 'package:flutter/material.dart';

import '../buttons/fixflow_buttons.dart';

Future<bool> showFixFlowConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'إلغاء',
  bool destructive = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FixFlowButton(
            label: cancelLabel,
            variant: FixFlowButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
          FixFlowButton(
            label: confirmLabel,
            variant: destructive
                ? FixFlowButtonVariant.destructive
                : FixFlowButtonVariant.primary,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ??
    false;

class FixFlowFormDialog extends StatelessWidget {
  const FixFlowFormDialog({
    required this.title,
    required this.content,
    required this.primaryAction,
    this.secondaryAction,
    super.key,
  });
  final String title;
  final Widget content, primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(child: content),
    actions: [if (secondaryAction != null) secondaryAction!, primaryAction],
  );
}
