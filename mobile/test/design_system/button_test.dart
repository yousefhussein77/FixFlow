import 'package:fixflow/design_system/components/buttons/fixflow_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('button variants retain accessible targets and loading state', (
    tester,
  ) async {
    await tester.pumpWidget(
      designSystemHost(
        Column(
          children: [
            for (final variant in FixFlowButtonVariant.values)
              FixFlowButton(
                label: variant.name,
                variant: variant,
                onPressed: () {},
              ),
            const FixFlowButton(
              label: 'Saving',
              loading: true,
              onPressed: null,
            ),
            FixFlowIconButton(
              icon: Icons.refresh,
              label: 'Refresh',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    expect(find.byType(FixFlowButton), findsNWidgets(6));
    expect(tester.getSize(find.byTooltip('Refresh')).width, 48);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
