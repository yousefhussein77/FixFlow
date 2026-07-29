import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/admin_ticket_models.dart';
import '../models/ticket_comment_models.dart';
import '../repositories/admin_ticket_repository.dart';
import '../repositories/ticket_comment_repository.dart';
import '../state/admin_ticket_list_controller.dart';
import '../widgets/ticket_assignment_sheet.dart';
import 'ticket_comments_screen.dart';

class AdminTicketListScreen extends StatefulWidget {
  const AdminTicketListScreen({
    required this.repository,
    this.commentRepository,
    super.key,
  });
  final AdminTicketRepository repository;
  final TicketCommentRepository? commentRepository;

  @override
  State<AdminTicketListScreen> createState() => _AdminTicketListScreenState();
}

class _AdminTicketListScreenState extends State<AdminTicketListScreen> {
  late final AdminTicketListController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminTicketListController(widget.repository)
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

  FixFlowStateKind _stateKind(AdminTicketListStatus status) => switch (status) {
    AdminTicketListStatus.unauthorized => FixFlowStateKind.unauthorized,
    AdminTicketListStatus.offline => FixFlowStateKind.offline,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) => FixFlowPage(
    title: const Text('كل التذاكر'),
    actions: [
      FixFlowIconButton(
        icon: Icons.refresh,
        label: 'تحديث التذاكر',
        onPressed: controller.load,
      ),
    ],
    body: switch (controller.state.status) {
      AdminTicketListStatus.loading => const FixFlowStateView(
        kind: FixFlowStateKind.loading,
        title: 'جارٍ تحميل التذاكر',
      ),
      AdminTicketListStatus.empty => const FixFlowStateView(
        kind: FixFlowStateKind.empty,
        title: 'لا توجد تذاكر.',
      ),
      AdminTicketListStatus.unauthorized ||
      AdminTicketListStatus.offline ||
      AdminTicketListStatus.serverError => FixFlowStateView(
        kind: _stateKind(controller.state.status),
        title: controller.state.status == AdminTicketListStatus.unauthorized
            ? 'التذاكر غير متاحة.'
            : 'تعذر تحميل التذاكر.',
        message: controller.state.message,
        actionLabel: 'إعادة المحاولة',
        actionKey: const Key('admin_tickets_retry'),
        onAction: controller.load,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final ticket in controller.tickets)
            Padding(
              padding: const EdgeInsets.only(bottom: FixFlowSpacing.sm),
              child: _AdminTicketCard(
                ticket: ticket,
                commentRepository: widget.commentRepository,
                onAssign: () async {
                  final updated = await showDialog<AdminTicketSummary>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => TicketAssignmentSheet(
                      repository: widget.repository,
                      ticket: ticket,
                    ),
                  );
                  if (updated != null) controller.replace(updated);
                },
              ),
            ),
          if (controller.state.status == AdminTicketListStatus.loadingMore)
            const FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'جارٍ تحميل المزيد من التذاكر',
            ),
          if (controller.state.status != AdminTicketListStatus.loadingMore)
            TextButton(
              key: const Key('admin_tickets_more'),
              onPressed: () => controller.load(refresh: false),
              child: const Text('تحميل المزيد'),
            ),
        ],
      ),
    },
  );
}

class _AdminTicketCard extends StatelessWidget {
  const _AdminTicketCard({
    required this.ticket,
    required this.commentRepository,
    required this.onAssign,
  });
  final AdminTicketSummary ticket;
  final TicketCommentRepository? commentRepository;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(FixFlowSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: commentRepository != null,
            label: '${ticket.reference}, ${ticket.title}',
            child: InkWell(
              key: Key('admin_ticket_${ticket.reference}'),
              onTap: commentRepository == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketCommentsScreen(
                          repository: commentRepository!,
                          context: TicketCommentContext.administrator,
                          reference: ticket.reference,
                        ),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text('المُبلّغ: ${ticket.reporter.name}'),
                  Text('${ticket.department.name} / ${ticket.category.name}'),
                  Text(
                    'المسند إليه: ${ticket.assignedTechnician?.name ?? 'غير مسندة'}',
                  ),
                ],
              ),
            ),
          ),
          if (ticket.canAssign) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            FixFlowButton(
              buttonKey: Key('assign_${ticket.reference}'),
              label: 'إسناد',
              icon: Icons.person_add_outlined,
              onPressed: onAssign,
            ),
          ],
        ],
      ),
    ),
  );
}
