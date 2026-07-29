import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'shared semantic styles remain complete in ${brightness.name}',
      (tester) async {
        await tester.pumpWidget(
          designSystemHost(
            const Column(
              children: [
                FixFlowStatusChip(status: 'new'),
                FixFlowStatusChip(status: 'assigned'),
                FixFlowStatusChip(status: 'in_progress'),
                FixFlowStatusChip(status: 'completed'),
                FixFlowStatusChip(status: 'rejected'),
                FixFlowPriorityBadge(priority: 'low'),
                FixFlowPriorityBadge(priority: 'medium'),
                FixFlowPriorityBadge(priority: 'high'),
                FixFlowStateView(
                  kind: FixFlowStateKind.offline,
                  title: 'Offline',
                ),
                FixFlowStateView(
                  kind: FixFlowStateKind.conflict,
                  title: 'Conflict',
                ),
              ],
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('مكتملة'), findsOneWidget);
        expect(find.text('أولوية عالية'), findsOneWidget);
        expect(find.text('Offline'), findsOneWidget);
        expect(find.text('Conflict'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
