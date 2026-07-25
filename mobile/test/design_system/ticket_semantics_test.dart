import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:fixflow/design_system/theme/fixflow_theme_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in ['light', 'dark']) {
    test('$brightness maps every status and priority with non-color cues', () {
      final theme = brightness == 'light'
          ? FixFlowTheme.light()
          : FixFlowTheme.dark();
      final semantic = theme.extension<FixFlowSemanticColors>()!;
      expect(semantic.statuses.keys, {
        'new',
        'assigned',
        'in_progress',
        'completed',
        'rejected',
      });
      expect(semantic.priorities.keys, {'low', 'medium', 'high'});
      for (final style in [
        ...semantic.statuses.values,
        ...semantic.priorities.values,
      ]) {
        expect(style.label, isNotEmpty);
        expect(style.icon.codePoint, isPositive);
        expect(style.foreground, isNot(style.container));
      }
    });
  }
}
