import 'package:fixflow/design_system/components/buttons/fixflow_buttons.dart';
import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final width in [320.0, 360.0, 390.0, 600.0]) {
    testWidgets('representative role layout fits ${width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        designSystemHost(
          ListView(
            children: const [
              FixFlowSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Reporter / Administrator / Technician'),
                    Wrap(
                      spacing: 8,
                      children: [
                        FixFlowStatusChip(status: 'assigned'),
                        FixFlowPriorityBadge(priority: 'medium'),
                      ],
                    ),
                    SizedBox(height: 8),
                    FixFlowButton(label: 'Primary action', onPressed: null),
                  ],
                ),
              ),
            ],
          ),
          size: Size(width, 700),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
