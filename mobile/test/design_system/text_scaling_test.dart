import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/forms/fixflow_fields.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('long role content remains usable at ${scale}x text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        designSystemHost(
          ListView(
            children: const [
              FixFlowStatusChip(status: 'in_progress'),
              FixFlowPriorityBadge(priority: 'high'),
              FixFlowMetadataRow(
                label: 'Rejection reason',
                value: 'The work area requires additional safety review.',
              ),
              FixFlowTextField(
                label: 'Comment or work note',
                maxLines: 4,
                maxLength: 2000,
              ),
            ],
          ),
          textScale: scale,
          direction: TextDirection.rtl,
          size: const Size(320, 700),
        ),
      );
      expect(find.byType(FixFlowTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
