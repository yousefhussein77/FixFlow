import 'package:flutter/material.dart';

import '../../theme/fixflow_theme_extensions.dart';
import '../../tokens/fixflow_radius.dart';
import '../../tokens/fixflow_spacing.dart';
import '../buttons/fixflow_buttons.dart';

enum FixFlowStateKind {
  loading,
  skeleton,
  empty,
  success,
  validation,
  unauthorized,
  offline,
  conflict,
  serverError,
}

class FixFlowStateView extends StatelessWidget {
  const FixFlowStateView({
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    super.key,
  });
  final FixFlowStateKind kind;
  final String title;
  final String? message, actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    if (kind == FixFlowStateKind.loading) {
      return Semantics(
        liveRegion: true,
        label: title,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: FixFlowSpacing.sm),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (kind == FixFlowStateKind.skeleton) {
      return ExcludeSemantics(
        child: _Skeleton(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
    final theme = Theme.of(context);
    final semantic = theme.extension<FixFlowSemanticColors>();
    final fallback = FixFlowSemanticStyle(
      foreground: theme.colorScheme.onSurface,
      container: theme.colorScheme.surfaceContainerHighest,
      border: theme.colorScheme.outline,
      icon: Icons.info_outline,
      label: title,
    );
    final style = switch (kind) {
      FixFlowStateKind.success => semantic?.success ?? fallback,
      FixFlowStateKind.validation ||
      FixFlowStateKind.conflict => semantic?.warning ?? fallback,
      FixFlowStateKind.unauthorized ||
      FixFlowStateKind.serverError => semantic?.error ?? fallback,
      _ => semantic?.information ?? fallback,
    };
    final icon = switch (kind) {
      FixFlowStateKind.empty => Icons.inbox_outlined,
      FixFlowStateKind.unauthorized => Icons.lock_outline,
      FixFlowStateKind.offline => Icons.cloud_off_outlined,
      FixFlowStateKind.conflict => Icons.sync_problem_outlined,
      FixFlowStateKind.serverError => Icons.error_outline,
      _ => style.icon,
    };
    return Semantics(
      liveRegion: kind != FixFlowStateKind.empty,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FixFlowSpacing.md),
        decoration: BoxDecoration(
          color: style.container,
          borderRadius: BorderRadius.circular(FixFlowRadius.large),
          border: Border.all(color: style.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: style.foreground),
            const SizedBox(height: FixFlowSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: style.foreground),
            ),
            if (message != null) ...[
              const SizedBox(height: FixFlowSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: style.foreground),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: FixFlowSpacing.sm),
              FixFlowButton(
                buttonKey: actionKey,
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final factor in const [1.0, .72, .52])
          FractionallySizedBox(
            widthFactor: factor,
            child: Container(
              height: 18,
              margin: const EdgeInsets.only(bottom: FixFlowSpacing.xs),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(FixFlowRadius.small),
              ),
            ),
          ),
      ],
    ),
  );
}
