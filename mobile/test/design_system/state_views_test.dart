import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets(
    'all shared states render safely without fabricated skeleton text',
    (tester) async {
      for (final kind in FixFlowStateKind.values) {
        await tester.pumpWidget(
          designSystemHost(
            FixFlowStateView(
              kind: kind,
              title: kind.name,
              message: kind == FixFlowStateKind.skeleton
                  ? null
                  : 'Supportive message',
              actionLabel: kind == FixFlowStateKind.offline ? 'Retry' : null,
              onAction: kind == FixFlowStateKind.offline ? () {} : null,
            ),
          ),
        );
        if (kind == FixFlowStateKind.offline) {
          expect(find.text('Retry'), findsOneWidget);
        }
        expect(tester.takeException(), isNull, reason: kind.name);
      }
    },
  );
}
