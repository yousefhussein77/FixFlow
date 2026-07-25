import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_content.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('content components wrap safely at compact width', (
    tester,
  ) async {
    await tester.pumpWidget(
      designSystemHost(
        ListView(
          children: [
            const FixFlowTicketListItem(
              reference: 'TKT-123456',
              title: 'A long mixed عنوان ticket title that must wrap safely',
              status: 'in_progress',
              priority: 'high',
              metadata: 'Facilities / Electrical',
            ),
            const FixFlowMetadataRow(label: 'Location', value: 'Building A'),
            const FixFlowHistoryItem(title: 'Started work', timestamp: '10:30'),
            const FixFlowCommentItem(
              author: 'Reporter',
              role: 'reporter',
              content: '<b>plain text</b>',
              timestamp: '11:00',
            ),
            const FixFlowPhotoTile(label: 'Ticket photo'),
          ],
        ),
        size: const Size(320, 900),
      ),
    );
    expect(find.text('<b>plain text</b>'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
