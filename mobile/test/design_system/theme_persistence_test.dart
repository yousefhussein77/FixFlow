import 'package:fixflow/design_system/theme/fixflow_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to light when no preference is saved', () async {
    final controller = ThemeController(_MemoryThemeStore());
    await controller.restore();
    expect(controller.mode, ThemeMode.light);
  });

  test('persists and restores the selected theme', () async {
    final store = _MemoryThemeStore();
    final controller = ThemeController(store);
    await controller.setMode(ThemeMode.dark);
    expect(controller.mode, ThemeMode.dark);

    final restored = ThemeController(store);
    await restored.restore();
    expect(restored.mode, ThemeMode.dark);

    await restored.toggle();
    expect(restored.mode, ThemeMode.light);
    expect(store.value, 'light');
  });

  testWidgets(
    'theme control switches immediately and exposes an accessible label',
    (tester) async {
      final store = _MemoryThemeStore();
      final controller = ThemeController(store);
      await tester.pumpWidget(
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: controller.mode,
            home: Scaffold(
              body: IconButton(
                key: const Key('theme_control'),
                tooltip: controller.isDark
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                onPressed: controller.toggle,
                icon: Icon(
                  controller.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byTooltip('Switch to dark theme'), findsOneWidget);
      await tester.tap(find.byKey(const Key('theme_control')));
      await tester.pump();
      expect(find.byTooltip('Switch to light theme'), findsOneWidget);
      expect(store.value, 'dark');
    },
  );
}

class _MemoryThemeStore implements ThemePreferenceStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String next) async => value = next;
}
