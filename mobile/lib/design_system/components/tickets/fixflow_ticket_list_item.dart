import 'package:flutter/material.dart';

import '../../tokens/fixflow_spacing.dart';
import '../content/fixflow_surfaces.dart';
import 'fixflow_ticket_badges.dart';

class FixFlowTicketListItem extends StatelessWidget {
  const FixFlowTicketListItem({
    required this.reference,
    required this.title,
    required this.status,
    required this.priority,
    required this.metadata,
    this.onTap,
    super.key,
  });
  final String reference, title, status, priority, metadata;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FixFlowSurface(
    onTap: onTap,
    semanticLabel: '$reference, $title',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reference,
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: FixFlowSpacing.half),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FixFlowSpacing.xs),
        Wrap(
          spacing: FixFlowSpacing.xs,
          runSpacing: FixFlowSpacing.xs,
          children: [
            FixFlowStatusChip(status: status),
            FixFlowPriorityBadge(priority: priority),
          ],
        ),
        const SizedBox(height: FixFlowSpacing.xs),
        Text(metadata, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
