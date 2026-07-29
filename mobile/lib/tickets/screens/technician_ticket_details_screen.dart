import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/components/tickets/fixflow_ticket_content.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/technician_ticket_models.dart';
import '../models/ticket_comment_models.dart';
import '../repositories/technician_ticket_repository.dart';
import '../repositories/ticket_comment_repository.dart';
import '../state/technician_ticket_details_controller.dart';
import '../state/ticket_status_transition_controller.dart';
import '../widgets/ticket_processing_actions.dart';
import 'ticket_comments_screen.dart';

class TechnicianTicketDetailsScreen extends StatefulWidget {
  const TechnicianTicketDetailsScreen({
    required this.repository,
    required this.reference,
    this.commentRepository,
    super.key,
  });
  final TechnicianTicketRepository repository;
  final String reference;
  final TicketCommentRepository? commentRepository;

  @override
  State<TechnicianTicketDetailsScreen> createState() =>
      _TechnicianTicketDetailsScreenState();
}

class _TechnicianTicketDetailsScreenState
    extends State<TechnicianTicketDetailsScreen> {
  late final TechnicianTicketDetailsController controller;
  late final TicketStatusTransitionController transition;

  @override
  void initState() {
    super.initState();
    controller = TechnicianTicketDetailsController(
      widget.repository,
      widget.reference,
    )..addListener(_changed);
    transition = TicketStatusTransitionController(
      widget.repository,
      refresh: controller.load,
    );
    controller.load();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    transition.dispose();
    super.dispose();
  }

  FixFlowStateKind _stateKind(TechnicianDetailStatus status) =>
      switch (status) {
        TechnicianDetailStatus.notFound => FixFlowStateKind.unauthorized,
        TechnicianDetailStatus.unauthorized => FixFlowStateKind.unauthorized,
        TechnicianDetailStatus.offline => FixFlowStateKind.offline,
        _ => FixFlowStateKind.serverError,
      };

  @override
  Widget build(BuildContext context) => FixFlowPage(
    title: Text(widget.reference),
    actions: [
      FixFlowIconButton(
        icon: Icons.refresh,
        label: 'تحديث التذكرة',
        onPressed: controller.load,
      ),
    ],
    body: switch (controller.status) {
      TechnicianDetailStatus.loading => const FixFlowStateView(
        kind: FixFlowStateKind.loading,
        title: 'جارٍ تحميل التذكرة',
      ),
      TechnicianDetailStatus.notFound ||
      TechnicianDetailStatus.unauthorized ||
      TechnicianDetailStatus.offline ||
      TechnicianDetailStatus.serverError => FixFlowStateView(
        kind: _stateKind(controller.status),
        title: controller.status == TechnicianDetailStatus.notFound
            ? 'التذكرة غير متاحة.'
            : 'تعذر تحميل التذكرة.',
        message: controller.message,
        actionLabel: 'إعادة المحاولة',
        actionKey: const Key('technician_ticket_retry'),
        onAction: controller.load,
      ),
      _ => _TicketDetailsBody(
        ticket: controller.ticket!,
        transition: transition,
        commentRepository: widget.commentRepository,
        onUpdated: (_) => controller.load(),
      ),
    },
  );
}

class _TicketDetailsBody extends StatelessWidget {
  const _TicketDetailsBody({
    required this.ticket,
    required this.transition,
    required this.commentRepository,
    required this.onUpdated,
  });
  final TechnicianTicket ticket;
  final TicketStatusTransitionController transition;
  final TicketCommentRepository? commentRepository;
  final ValueChanged<TechnicianTicket> onUpdated;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(ticket.title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: FixFlowSpacing.xs),
      Wrap(
        spacing: FixFlowSpacing.xs,
        runSpacing: FixFlowSpacing.xs,
        children: [
          FixFlowStatusChip(status: ticket.status),
          FixFlowPriorityBadge(priority: ticket.priority),
        ],
      ),
      FixFlowMetadataRow(
        label: 'الفئة',
        value: '${ticket.department.name} / ${ticket.category.name}',
      ),
      FixFlowMetadataRow(
        label: 'الفني المسند',
        value: ticket.assignedTechnician.name,
      ),
      FixFlowMetadataRow(label: 'الموقع', value: ticket.location),
      const SizedBox(height: FixFlowSpacing.xs),
      FixFlowSurface(child: Text(ticket.description)),
      if (ticket.photos.isNotEmpty) ...[
        const SizedBox(height: FixFlowSpacing.sm),
        Text('الصور', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FixFlowSpacing.xs),
        for (final photo in ticket.photos)
          Padding(
            padding: const EdgeInsets.only(bottom: FixFlowSpacing.xs),
            child: FixFlowPhotoTile(label: photo.name),
          ),
      ],
      const SizedBox(height: FixFlowSpacing.sm),
      Text('السجل', style: Theme.of(context).textTheme.titleMedium),
      for (final item in ticket.history)
        FixFlowHistoryItem(
          title: '${item.fromStatus} → ${item.toStatus}',
          details: [
            if (item.reason != null) item.reason!,
            'المنفذ: ${item.actor.name}',
            'الفني: ${item.assignedTechnician.name}',
          ].join('\n'),
          timestamp: item.occurredAt.toLocal().toString(),
        ),
      const SizedBox(height: FixFlowSpacing.sm),
      TicketProcessingActions(
        ticket: ticket,
        controller: transition,
        onUpdated: onUpdated,
      ),
      if (commentRepository != null) ...[
        const SizedBox(height: FixFlowSpacing.sm),
        FixFlowButton(
          buttonKey: const Key('technician_comments'),
          label: 'التعليقات',
          icon: Icons.forum_outlined,
          variant: FixFlowButtonVariant.outline,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketCommentsScreen(
                repository: commentRepository!,
                context: TicketCommentContext.technician,
                reference: ticket.reference,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
