import 'dart:io';

import 'package:fixflow/design_system/brand/fixflow_brand.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approved brand inventory exists with stable naming', () {
    expect(
      File('assets/brand/source/fixflow_logo_master.svg').existsSync(),
      isTrue,
    );
    expect(FixFlowBrand.runtimeAssets, hasLength(7));
    for (final path in FixFlowBrand.runtimeAssets) {
      expect(path, startsWith('assets/brand/runtime/fixflow_'));
      expect(File(path).existsSync(), isTrue, reason: path);
      expect(File(path).readAsStringSync(), contains('viewBox'), reason: path);
    }
    expect(FixFlowBrand.minimumIconSize, 24);
    expect(FixFlowBrand.minimumHorizontalWidth, 120);
    final guidance = File('assets/brand/README.md').readAsStringSync();
    expect(guidance.toLowerCase(), contains('clear space'));
    expect(guidance.toLowerCase(), contains('prohibited'));
  });

  test('dashboard uses the exact approved bitmap logo assets', () {
    final mark = File('assets/brand/fixflow_logo_mark.png');
    final wordmark = File('assets/brand/fixflow_logo_wordmark.png');
    expect(mark.existsSync(), isTrue);
    expect(wordmark.existsSync(), isTrue);
    expect(mark.lengthSync(), greaterThan(0));
    expect(wordmark.lengthSync(), greaterThan(0));
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('    - assets/brand/'));
  });
}
