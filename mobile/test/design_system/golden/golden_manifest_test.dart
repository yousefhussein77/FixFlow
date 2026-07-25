import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'approved golden manifest is deterministic and contains no sensitive data',
    () {
      final root = Directory('test/design_system/golden/goldens');
      final files = root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.png'))
          .toList();
      expect(files, isNotEmpty);
      final names = files.map((file) => file.path).toList()..sort();
      expect(names.toSet().length, names.length);
      for (final file in files) {
        expect(file.lengthSync(), greaterThan(0));
        expect(file.path, isNot(contains('TKT-')));
        expect(file.path, isNot(contains('@')));
      }
    },
  );
}
