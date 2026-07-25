import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/components/tickets/fixflow_ticket_content.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/ticket_comment_models.dart';
import '../repositories/ticket_comment_repository.dart';
import '../repositories/ticket_rating_repository.dart';
import '../repositories/ticket_repository.dart';
import '../state/ticket_details_controller.dart';
import '../widgets/ticket_rating_section.dart';
import 'ticket_comments_screen.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({
    required this.repository,
    required this.reference,
    this.commentRepository,
    this.ratingRepository,
    super.key,
  });
  final TicketRepository repository;
  final String reference;
  final TicketCommentRepository? commentRepository;
  final TicketRatingRepository? ratingRepository;

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late final TicketDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = TicketDetailsController(widget.repository)
      ..addListener(_changed);
    controller.load(widget.reference);
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

  FixFlowStateKind _stateKind(TicketDetailsStatus status) => switch (status) {
    TicketDetailsStatus.notFound => FixFlowStateKind.empty,
    TicketDetailsStatus.unauthorized => FixFlowStateKind.unauthorized,
    TicketDetailsStatus.offline => FixFlowStateKind.offline,
    TicketDetailsStatus.serverError => FixFlowStateKind.serverError,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    final t = s.ticket;
    if (t == null) {
      return FixFlowPage(
        title: const Text('Ticket details'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (s.status == TicketDetailsStatus.loading)
              const FixFlowStateView(
                kind: FixFlowStateKind.loading,
                title: 'Loading ticket details',
              )
            else
              FixFlowStateView(
                kind: _stateKind(s.status),
                title: s.status == TicketDetailsStatus.notFound
                    ? 'Ticket not found.'
                    : 'Unable to load ticket.',
                message: s.message,
                actionLabel: 'Retry',
                actionKey: const Key('detail_retry'),
                onAction: () => controller.load(widget.reference),
              ),
          ],
        ),
      );
    }

    return FixFlowPage(
      title: const Text('Ticket details'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FixFlowSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.reference,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: FixFlowSpacing.xs),
                Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: FixFlowSpacing.sm),
                Wrap(
                  spacing: FixFlowSpacing.xs,
                  runSpacing: FixFlowSpacing.xs,
                  children: [
                    FixFlowStatusChip(status: t.status),
                    FixFlowPriorityBadge(priority: t.priority),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FixFlowSpacing.md),
          FixFlowSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: FixFlowSpacing.xs),
                Text(t.description),
                const SizedBox(height: FixFlowSpacing.sm),
                FixFlowMetadataRow(
                  label: 'Department',
                  value: t.department.name,
                ),
                FixFlowMetadataRow(label: 'Category', value: t.category.name),
                FixFlowMetadataRow(label: 'Location', value: t.location),
                FixFlowMetadataRow(
                  label: 'Photos',
                  value: '${t.photos.length}',
                ),
                FixFlowMetadataRow(
                  label: 'Created',
                  value: t.createdAt.toLocal().toString(),
                ),
                FixFlowMetadataRow(
                  label: 'Updated',
                  value: t.updatedAt.toLocal().toString(),
                ),
              ],
            ),
          ),
          if (t.photos.isNotEmpty) ...[
            const SizedBox(height: FixFlowSpacing.md),
            Text('Photos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: FixFlowSpacing.xs),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: FixFlowSpacing.xs,
              mainAxisSpacing: FixFlowSpacing.xs,
              children: [
                for (final photo in t.photos)
                  FixFlowPhotoTile(label: photo.name),
              ],
            ),
          ],
          if (s.status == TicketDetailsStatus.photoUnavailable)
            Padding(
              padding: const EdgeInsets.only(top: FixFlowSpacing.sm),
              child: FixFlowStateView(
                kind: FixFlowStateKind.serverError,
                title: 'Photo unavailable',
                message: s.message,
              ),
            ),
          if (widget.ratingRepository != null) ...[
            const SizedBox(height: FixFlowSpacing.md),
            TicketRatingSection(
              repository: widget.ratingRepository!,
              reference: widget.reference,
              completed: t.status == 'completed',
              rating: t.rating,
              onAccepted: () => controller.load(widget.reference),
            ),
          ],
          if (widget.commentRepository != null) ...[
            const SizedBox(height: FixFlowSpacing.md),
            FixFlowButton(
              buttonKey: const Key('reporter_comments'),
              label: 'Comments',
              variant: FixFlowButtonVariant.outline,
              icon: Icons.forum_outlined,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketCommentsScreen(
                    repository: widget.commentRepository!,
                    context: TicketCommentContext.reporter,
                    reference: widget.reference,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
