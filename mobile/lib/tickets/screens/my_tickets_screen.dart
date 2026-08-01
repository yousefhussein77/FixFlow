import 'package:flutter/material.dart';

import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/tickets/fixflow_ticket_list_item.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../repositories/ticket_comment_repository.dart';
import '../repositories/ticket_rating_repository.dart';
import '../repositories/ticket_repository.dart';
import '../state/my_tickets_controller.dart';
import 'ticket_details_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({
    required this.repository,
    this.commentRepository,
    this.ratingRepository,
    super.key,
  });
  final TicketRepository repository;
  final TicketCommentRepository? commentRepository;
  final TicketRatingRepository? ratingRepository;

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late final MyTicketsController controller;

  @override
  void initState() {
    super.initState();
    controller = MyTicketsController(widget.repository)..addListener(_changed);
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

  FixFlowStateKind _stateKind(MyTicketsStatus status) => switch (status) {
    MyTicketsStatus.offline => FixFlowStateKind.offline,
    MyTicketsStatus.unauthorized => FixFlowStateKind.unauthorized,
    MyTicketsStatus.serverError => FixFlowStateKind.serverError,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    return FixFlowPage(
      title: const Text('تذاكري'),
      onRefresh:
          s.status == MyTicketsStatus.loading ||
              s.status == MyTicketsStatus.loadingMore
          ? () async {}
          : controller.load,
      body: switch (s.status) {
        MyTicketsStatus.loading => const FixFlowStateView(
          kind: FixFlowStateKind.loading,
          title: 'جارٍ تحميل التذاكر',
        ),
        MyTicketsStatus.empty => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FixFlowStateView(
              kind: FixFlowStateKind.empty,
              title: 'لا توجد لديك تذاكر بعد.',
            ),
            const SizedBox(height: FixFlowSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إنشاء تذكرة'),
            ),
          ],
        ),
        MyTicketsStatus.offline ||
        MyTicketsStatus.serverError ||
        MyTicketsStatus.unauthorized => FixFlowStateView(
          kind: _stateKind(s.status),
          title: s.status == MyTicketsStatus.unauthorized
              ? 'التذاكر غير متاحة.'
              : 'تعذر تحميل التذاكر.',
          message: s.message,
          actionLabel: 'إعادة المحاولة',
          actionKey: const Key('tickets_retry'),
          onAction: controller.load,
        ),
        _ => Column(
          children: [
            for (final ticket in controller.tickets)
              Padding(
                padding: const EdgeInsets.only(bottom: FixFlowSpacing.sm),
                child: FixFlowTicketListItem(
                  key: Key('ticket_${ticket.reference}'),
                  reference: ticket.reference,
                  title: ticket.title,
                  status: ticket.status,
                  priority: ticket.priority,
                  metadata:
                      '${ticket.department.name} · ${ticket.category.name}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailsScreen(
                        repository: widget.repository,
                        reference: ticket.reference,
                        commentRepository: widget.commentRepository,
                        ratingRepository: widget.ratingRepository,
                      ),
                    ),
                  ),
                ),
              ),
            if (s.status == MyTicketsStatus.loadingMore)
              const FixFlowStateView(
                kind: FixFlowStateKind.loading,
                title: 'جارٍ تحميل المزيد من التذاكر',
              ),
            if (controller.state.status != MyTicketsStatus.loadingMore)
              TextButton(
                key: const Key('tickets_more'),
                onPressed: () => controller.load(refresh: false),
                child: const Text('تحميل المزيد'),
              ),
          ],
        ),
      },
    );
  }
}
