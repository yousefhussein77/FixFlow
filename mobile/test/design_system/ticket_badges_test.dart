import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('$brightness badges expose text and icons', (tester) async {
      await tester.pumpWidget(
        designSystemHost(
          const Wrap(
            children: [
              FixFlowStatusChip(status: 'new'),
              FixFlowStatusChip(status: 'assigned'),
              FixFlowStatusChip(status: 'in_progress'),
              FixFlowStatusChip(status: 'completed'),
              FixFlowStatusChip(status: 'rejected'),
              FixFlowPriorityBadge(priority: 'low'),
              FixFlowPriorityBadge(priority: 'medium'),
              FixFlowPriorityBadge(priority: 'high'),
            ],
          ),
          brightness: brightness,
        ),
      );
      expect(find.byType(Icon), findsNWidgets(8));
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('High priority'), findsOneWidget);
    });
  }
}
