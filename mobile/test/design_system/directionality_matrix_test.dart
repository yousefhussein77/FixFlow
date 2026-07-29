import 'package:fixflow/design_system/components/buttons/fixflow_buttons.dart';
import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('all role surfaces preserve ${direction.name} reading order', (
      tester,
    ) async {
      await tester.pumpWidget(
        designSystemHost(
          ListView(
            children: const [
              Text('Authentication'),
              Text('Reporter tickets'),
              Text('Administrator queue'),
              Text('Technician work'),
              Text('TKT-RTL-001', textDirection: TextDirection.ltr),
              FixFlowStatusChip(status: 'in_progress'),
              FixFlowPriorityBadge(priority: 'high'),
              FixFlowMetadataRow(label: 'Reference', value: 'TKT-RTL-001'),
              FixFlowButton(label: 'Continue', onPressed: null),
            ],
          ),
          direction: direction,
        ),
      );
      expect(find.text('TKT-RTL-001'), findsOneWidget);
      expect(find.text('قيد التنفيذ'), findsOneWidget);
      expect(find.text('أولوية عالية'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
