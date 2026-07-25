import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/ticket_rating_models.dart';
import '../repositories/ticket_rating_repository.dart';
import '../state/ticket_rating_controller.dart';

class TicketRatingSection extends StatefulWidget {
  const TicketRatingSection({
    required this.repository,
    required this.reference,
    required this.completed,
    this.rating,
    this.onAccepted,
    super.key,
  });
  final TicketRatingRepository repository;
  final String reference;
  final bool completed;
  final TicketRating? rating;
  final Future<void> Function()? onAccepted;

  @override
  State<TicketRatingSection> createState() => _TicketRatingSectionState();
}

class _TicketRatingSectionState extends State<TicketRatingSection> {
  late TicketRatingController controller;

  @override
  void initState() {
    super.initState();
    controller = TicketRatingController(
      widget.repository,
      widget.reference,
      rating: widget.rating,
    )..addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TicketRatingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference ||
        oldWidget.rating?.value != widget.rating?.value ||
        oldWidget.rating?.ratedAt != widget.rating?.ratedAt) {
      controller.removeListener(_changed);
      controller.dispose();
      controller = TicketRatingController(
        widget.repository,
        widget.reference,
        rating: widget.rating,
      )..addListener(_changed);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rating = controller.storedRating;
    if (rating != null) {
      return FixFlowSurface(
        child: Semantics(
          label: 'Ticket rating ${rating.value} out of 5',
          child: Row(
            children: [
              const Icon(Icons.star_rate_outlined),
              const SizedBox(width: FixFlowSpacing.xs),
              Expanded(
                child: Text(
                  'Rating: ${rating.value}/5',
                  key: const Key('rating_value'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!widget.completed) {
      return const FixFlowStateView(
        kind: FixFlowStateKind.empty,
        title: 'Rating available after completion.',
        key: Key('rating_ineligible'),
      );
    }
    return FixFlowSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rate completed service',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          Semantics(
            label: 'Rating from 1 to 5',
            child: SegmentedButton<int>(
              key: const Key('rating_input'),
              emptySelectionAllowed: true,
              segments: [
                for (var value = 1; value <= 5; value++)
                  ButtonSegment(value: value, label: Text('$value')),
              ],
              selected: controller.selectedValue == null
                  ? const {}
                  : {controller.selectedValue!},
              onSelectionChanged: controller.isSubmitting
                  ? null
                  : (values) => controller.select(values.first),
            ),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowButton(
            buttonKey: const Key('rating_submit'),
            label: 'Submit rating',
            loading: controller.isSubmitting,
            onPressed: controller.isSubmitting
                ? null
                : () async {
                    final accepted = await controller.submit();
                    if (accepted ||
                        controller.status == TicketRatingStatus.alreadyRated ||
                        controller.status == TicketRatingStatus.notCompleted ||
                        controller.status == TicketRatingStatus.conflict) {
                      await widget.onAccepted?.call();
                    }
                  },
          ),
          if (controller.message != null)
            Padding(
              padding: const EdgeInsets.only(top: FixFlowSpacing.sm),
              child: Text(
                controller.message!,
                key: const Key('rating_message'),
              ),
            ),
        ],
      ),
    );
  }
}
