import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:fixflow/design_system/components/forms/fixflow_fields.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_content.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_list_item.dart';
import 'package:fixflow/tickets/models/ticket_rating_models.dart';
import 'package:fixflow/tickets/repositories/ticket_rating_repository.dart';
import 'package:fixflow/tickets/widgets/ticket_rating_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('reporter workflow ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          designSystemHost(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const FixFlowTicketListItem(
                  reference: 'TKT-REPORTER',
                  title: 'Water leak',
                  status: 'new',
                  priority: 'high',
                  metadata: 'Facilities / Plumbing',
                ),
                const SizedBox(height: 12),
                const FixFlowSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Ticket details'),
                      FixFlowMetadataRow(label: 'Location', value: 'Floor 2'),
                      FixFlowMetadataRow(label: 'Photos', value: '2'),
                      FixFlowStatusChip(status: 'completed'),
                      SizedBox(height: 8),
                      FixFlowPriorityBadge(priority: 'medium'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FixFlowCommentItem(
                  author: 'Reporter',
                  role: 'reporter',
                  content: 'Plain-text work context.',
                  timestamp: '2026-07-25 10:00',
                ),
                const SizedBox(height: 12),
                const FixFlowTextField(
                  label: 'Add a plain-text comment',
                  maxLines: 2,
                  maxLength: 2000,
                ),
                const SizedBox(height: 12),
                TicketRatingSection(
                  repository: _GoldenRatingRepository(),
                  reference: 'TKT-REPORTER',
                  completed: true,
                ),
                const SizedBox(height: 12),
                const FixFlowStateView(
                  kind: FixFlowStateKind.offline,
                  title: 'Unable to load tickets.',
                  message: 'Check your connection and try again.',
                ),
              ],
            ),
            brightness: brightness,
            direction: direction,
            size: const Size(390, 844),
          ),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/reporter/reporter_${brightness.name}_${direction.name}.png',
          ),
        );
      });
    }
  }
}

class _GoldenRatingRepository implements TicketRatingRepository {
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async => TicketRating(value: rating, ratedAt: DateTime.utc(2026));
}
