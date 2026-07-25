import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/technician_ticket_models.dart';
import '../repositories/technician_ticket_repository.dart';
import '../repositories/ticket_comment_repository.dart';
import '../state/assigned_tickets_controller.dart';
import 'technician_ticket_details_screen.dart';

class AssignedTicketsScreen extends StatefulWidget {
  const AssignedTicketsScreen({
    required this.repository,
    this.commentRepository,
    super.key,
  });
  final TechnicianTicketRepository repository;
  final TicketCommentRepository? commentRepository;

  @override
  State<AssignedTicketsScreen> createState() => _AssignedTicketsScreenState();
}

class _AssignedTicketsScreenState extends State<AssignedTicketsScreen> {
  late final AssignedTicketsController controller;

  @override
  void initState() {
    super.initState();
    controller = AssignedTicketsController(widget.repository)
      ..addListener(_changed);
    controller.load();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  FixFlowStateKind _stateKind(AssignedTicketsStatus status) => switch (status) {
    AssignedTicketsStatus.unauthorized => FixFlowStateKind.unauthorized,
    AssignedTicketsStatus.offline => FixFlowStateKind.offline,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) => FixFlowPage(
    title: const Text('Assigned tickets'),
    actions: [
      FixFlowIconButton(
        icon: Icons.refresh,
        label: 'Refresh assigned tickets',
        onPressed: controller.load,
      ),
    ],
    body: switch (controller.status) {
      AssignedTicketsStatus.loading => const FixFlowStateView(
        kind: FixFlowStateKind.loading,
        title: 'Loading assigned tickets',
      ),
      AssignedTicketsStatus.empty => const FixFlowStateView(
        kind: FixFlowStateKind.empty,
        title: 'No tickets are assigned to you.',
      ),
      AssignedTicketsStatus.unauthorized ||
      AssignedTicketsStatus.offline ||
      AssignedTicketsStatus.serverError => FixFlowStateView(
        kind: _stateKind(controller.status),
        title: controller.status == AssignedTicketsStatus.unauthorized
            ? 'Assigned tickets are unavailable'
            : 'Unable to load assigned tickets.',
        message: controller.message,
        actionLabel: 'Retry',
        actionKey: const Key('assigned_tickets_retry'),
        onAction: controller.load,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final ticket in controller.tickets) ...[
            _AssignedTicketCard(
              key: Key('assigned_ticket_${ticket.reference}'),
              ticket: ticket,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianTicketDetailsScreen(
                      repository: widget.repository,
                      reference: ticket.reference,
                      commentRepository: widget.commentRepository,
                    ),
                  ),
                );
                if (mounted) controller.load();
              },
            ),
            const SizedBox(height: FixFlowSpacing.sm),
          ],
          if (controller.status == AssignedTicketsStatus.loadingMore)
            const FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'Loading more tickets',
            )
          else
            FixFlowButton(
              buttonKey: const Key('assigned_tickets_more'),
              label: 'Load more',
              variant: FixFlowButtonVariant.text,
              onPressed: () => controller.load(refresh: false),
            ),
        ],
      ),
    },
  );
}

class _AssignedTicketCard extends StatelessWidget {
  const _AssignedTicketCard({
    required this.ticket,
    required this.onTap,
    super.key,
  });
  final TechnicianTicketSummary ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(FixFlowSpacing.sm),
        child: Semantics(
          button: true,
          label: '${ticket.reference}, ${ticket.title}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ticket.reference, textDirection: TextDirection.ltr),
              const SizedBox(height: FixFlowSpacing.xs),
              Text(
                ticket.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: FixFlowSpacing.xs),
              Wrap(
                spacing: FixFlowSpacing.xs,
                runSpacing: FixFlowSpacing.xs,
                children: [
                  FixFlowStatusChip(status: ticket.status),
                  FixFlowPriorityBadge(priority: ticket.priority),
                ],
              ),
              const SizedBox(height: FixFlowSpacing.xs),
              Text('${ticket.department.name} / ${ticket.category.name}'),
            ],
          ),
        ),
      ),
    ),
  );
}
