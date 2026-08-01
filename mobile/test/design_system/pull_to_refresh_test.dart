import 'dart:async';

import 'package:fixflow/design_system/layout/fixflow_page.dart';
import 'package:fixflow/design_system/theme/fixflow_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'empty pages use the branded indicator and coalesce refresh requests',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pending = Completer<void>();
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FixFlowPage(
            title: const Text('قائمة فارغة'),
            onRefresh: () {
              refreshes++;
              return pending.future;
            },
            body: const Center(child: Text('لا توجد عناصر')),
          ),
        ),
      );

      final finder = find.byKey(const Key('fixflow_pull_to_refresh'));
      expect(finder, findsOneWidget);
      final indicator = tester.widget<RefreshIndicator>(finder);
      expect(indicator.color, FixFlowColors.brandPrimary);
      final scrollable = tester.widget<SingleChildScrollView>(
        find.descendant(
          of: finder,
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(scrollable.physics, isA<AlwaysScrollableScrollPhysics>());

      final state = tester.state<RefreshIndicatorState>(finder);
      final first = state.show();
      await tester.pump(const Duration(seconds: 1));
      final second = state.show();
      await tester.pump(const Duration(seconds: 1));
      expect(refreshes, 1);

      pending.complete();
      await Future.wait([first, second]);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
