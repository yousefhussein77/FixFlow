import 'package:flutter/material.dart';

import '../../theme/fixflow_theme_extensions.dart';

class FixFlowStatusChip extends StatelessWidget {
  const FixFlowStatusChip({required this.status, super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<FixFlowSemanticColors>();
    final style =
        semantic?.status(status) ??
        FixFlowSemanticStyle(
          foreground: Theme.of(context).colorScheme.primary,
          container: Theme.of(context).colorScheme.primaryContainer,
          border: Theme.of(context).colorScheme.primary,
          icon: Icons.label_outline,
          label: status,
        );
    return _SemanticBadge(style: style, kind: 'Status');
  }
}

class FixFlowPriorityBadge extends StatelessWidget {
  const FixFlowPriorityBadge({required this.priority, super.key});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<FixFlowSemanticColors>();
    final style =
        semantic?.priority(priority) ??
        FixFlowSemanticStyle(
          foreground: Theme.of(context).colorScheme.primary,
          container: Theme.of(context).colorScheme.primaryContainer,
          border: Theme.of(context).colorScheme.primary,
          icon: Icons.flag_outlined,
          label: priority,
        );
    return _SemanticBadge(style: style, kind: 'Priority');
  }
}

class _SemanticBadge extends StatelessWidget {
  const _SemanticBadge({required this.style, required this.kind});
  final FixFlowSemanticStyle style;
  final String kind;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$kind: ${style.label}',
    child: Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: ShapeDecoration(
        color: style.container,
        shape: StadiumBorder(side: BorderSide(color: style.border)),
      ),
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(style.icon, size: 16, color: style.foreground),
          Text(
            style.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
