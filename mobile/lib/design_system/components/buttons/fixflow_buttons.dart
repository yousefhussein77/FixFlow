import 'package:flutter/material.dart';

import '../../tokens/fixflow_icons.dart';

enum FixFlowButtonVariant { primary, secondary, outline, text, destructive }

class FixFlowButton extends StatelessWidget {
  const FixFlowButton({
    required this.label,
    required this.onPressed,
    this.variant = FixFlowButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.buttonKey,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final FixFlowButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final action = loading ? null : onPressed;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox.square(
            dimension: FixFlowIcons.standard,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: FixFlowIcons.standard),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final style = variant == FixFlowButtonVariant.destructive
        ? FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          )
        : null;
    return Semantics(
      button: true,
      enabled: action != null,
      label: label,
      value: loading ? 'جارٍ التحميل' : null,
      child: switch (variant) {
        FixFlowButtonVariant.primary ||
        FixFlowButtonVariant.destructive => FilledButton(
          key: buttonKey,
          onPressed: action,
          style: style,
          child: child,
        ),
        FixFlowButtonVariant.secondary => FilledButton.tonal(
          key: buttonKey,
          onPressed: action,
          child: child,
        ),
        FixFlowButtonVariant.outline => OutlinedButton(
          key: buttonKey,
          onPressed: action,
          child: child,
        ),
        FixFlowButtonVariant.text => TextButton(
          key: buttonKey,
          onPressed: action,
          child: child,
        ),
      },
    );
  }
}

class FixFlowIconButton extends StatelessWidget {
  const FixFlowIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    constraints: const BoxConstraints.tightFor(
      width: FixFlowIcons.minimumTarget,
      height: FixFlowIcons.minimumTarget,
    ),
    tooltip: label,
    onPressed: onPressed,
    icon: Icon(icon, size: FixFlowIcons.action),
  );
}

class FixFlowFloatingButton extends StatelessWidget {
  const FixFlowFloatingButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
  );
}
