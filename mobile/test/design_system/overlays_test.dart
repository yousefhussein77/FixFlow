import 'package:fixflow/design_system/components/overlays/fixflow_bottom_sheet.dart';
import 'package:fixflow/design_system/components/overlays/fixflow_dialogs.dart';
import 'package:fixflow/design_system/components/feedback/fixflow_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('confirmation and bottom sheet return caller-owned results', (
    tester,
  ) async {
    bool? confirmed;
    await tester.pumpWidget(
      designSystemHost(
        Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () async =>
                    confirmed = await showFixFlowConfirmationDialog(
                      context: context,
                      title: 'Confirm',
                      message: 'Continue?',
                      confirmLabel: 'Continue',
                    ),
                child: const Text('Dialog'),
              ),
              ElevatedButton(
                onPressed: () => showFixFlowBottomSheet<void>(
                  context: context,
                  builder: (_) => const Text('Sheet content'),
                ),
                child: const Text('Sheet'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('snackbar and banner announce feedback with non-color cues', (
    tester,
  ) async {
    await tester.pumpWidget(
      designSystemHost(
        Builder(
          builder: (context) => Column(
            children: [
              const FixFlowBanner(
                message: 'Connection unavailable',
                kind: FixFlowFeedbackKind.warning,
              ),
              ElevatedButton(
                onPressed: () => showFixFlowSnackBar(
                  context,
                  message: 'Saved successfully',
                  kind: FixFlowFeedbackKind.success,
                ),
                child: const Text('Show feedback'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    await tester.tap(find.text('Show feedback'));
    await tester.pump();
    expect(find.text('Saved successfully'), findsOneWidget);
  });
}
