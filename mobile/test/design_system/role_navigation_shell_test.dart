import 'package:fixflow/design_system/components/navigation/fixflow_role_shell.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({Size size = const Size(390, 844), double textScale = 1}) =>
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 24, bottom: 20),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: FixFlowRoleShell(
              destinations: [
                FixFlowRoleDestination(
                  label: 'الرئيسية',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('الرئيسية')),
                    body: ListView(
                      key: const PageStorageKey('home_scroll'),
                      children: [
                        FilledButton(
                          key: const Key('open_detail'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const Scaffold(
                                body: Center(child: Text('تفاصيل داخلية')),
                              ),
                            ),
                          ),
                          child: const Text('فتح التفاصيل'),
                        ),
                        for (var index = 0; index < 30; index++)
                          SizedBox(height: 48, child: Text('عنصر $index')),
                      ],
                    ),
                  ),
                ),
                FixFlowRoleDestination(
                  label: 'الحساب',
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  builder: (_) =>
                      const Scaffold(body: Center(child: Text('محتوى الحساب'))),
                ),
              ],
            ),
          ),
        ),
      );

  testWidgets('bottom navigation stays fixed while content scrolls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host());

    final navigation = find.byType(NavigationBar);
    final initialTop = tester.getTopLeft(navigation).dy;
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(navigation).dy, initialTop);
    expect(tester.getBottomRight(navigation).dy, lessThanOrEqualTo(824));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab and nested route state remain available during navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host());

    await tester.tap(find.byKey(const Key('open_detail')));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل داخلية'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('الحساب'));
    await tester.pumpAndSettle();
    expect(find.text('محتوى الحساب'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل داخلية'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  for (final configuration in <(String, Size, double)>[
    ('portrait narrow', const Size(320, 700), 2),
    ('landscape mobile', const Size(844, 390), 1),
    ('narrow landscape', const Size(568, 320), 2),
  ]) {
    testWidgets('${configuration.$1} avoids navigation overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(configuration.$2);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        host(size: configuration.$2, textScale: configuration.$3),
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
