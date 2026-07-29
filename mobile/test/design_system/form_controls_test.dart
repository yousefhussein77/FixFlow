import 'package:fixflow/design_system/components/forms/fixflow_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('fields preserve value while password visibility changes', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'secret');
    await tester.pumpWidget(
      designSystemHost(
        ListView(
          children: [
            FixFlowTextField(
              label: 'Password',
              controller: controller,
              obscureText: true,
              error: 'Required field',
            ),
            FixFlowDropdownField<int>(
              label: 'Priority',
              items: const [1, 2],
              itemLabel: (value) => '$value',
              onChanged: (_) {},
            ),
          ],
        ),
        direction: TextDirection.rtl,
        textScale: 2,
        size: const Size(320, 700),
      ),
    );
    await tester.tap(find.byTooltip('إظهار كلمة المرور'));
    await tester.pump();
    expect(controller.text, 'secret');
    expect(find.text('Required field'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search and multiline controls retain caller-owned input', (
    tester,
  ) async {
    final search = TextEditingController();
    final notes = TextEditingController();
    await tester.pumpWidget(
      designSystemHost(
        ListView(
          children: [
            FixFlowSearchField(label: 'Search', controller: search),
            FixFlowTextField(
              label: 'Notes',
              controller: notes,
              maxLines: 4,
              maxLength: 2000,
              helper: 'Plain text',
            ),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'TKT-010');
    await tester.enterText(find.byType(TextField).last, 'Work note');
    expect(search.text, 'TKT-010');
    expect(notes.text, 'Work note');
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
