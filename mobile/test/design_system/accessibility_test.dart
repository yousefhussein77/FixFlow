import 'package:fixflow/design_system/components/buttons/fixflow_buttons.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:fixflow/design_system/tokens/fixflow_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('shared actions expose semantics and minimum touch targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      designSystemHost(
        Column(
          children: [
            FixFlowButton(label: 'Save ticket', onPressed: () {}),
            FixFlowIconButton(
              icon: Icons.refresh,
              label: 'Refresh tickets',
              onPressed: () {},
            ),
            const FixFlowStatusChip(status: 'completed'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Save ticket'), findsWidgets);
    expect(find.text('مكتملة'), findsOneWidget);
    expect(
      tester.getSize(find.byType(IconButton)).shortestSide,
      greaterThanOrEqualTo(FixFlowIcons.minimumTarget),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('directional icons follow the platform policy', (tester) async {
    await tester.pumpWidget(
      designSystemHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Icon(Icons.arrow_back),
        ),
      ),
    );
    expect(FixFlowIcons.mirrorsInRtl(Icons.arrow_back), isTrue);
  });
}
