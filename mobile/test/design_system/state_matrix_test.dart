import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  for (final kind in FixFlowStateKind.values) {
    testWidgets('shared ${kind.name} state has safe presentation', (
      tester,
    ) async {
      await tester.pumpWidget(
        designSystemHost(
          FixFlowStateView(
            kind: kind,
            title: kind.name,
            message: kind == FixFlowStateKind.skeleton ? null : 'State message',
            actionLabel: kind == FixFlowStateKind.empty ? null : 'Retry',
            onAction: kind == FixFlowStateKind.empty ? null : () {},
          ),
        ),
      );
      if (kind != FixFlowStateKind.skeleton &&
          kind != FixFlowStateKind.loading) {
        expect(find.text(kind.name), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
