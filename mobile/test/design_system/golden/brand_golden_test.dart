import 'package:fixflow/design_system/brand/fixflow_brand.dart';
import 'package:fixflow/design_system/brand/fixflow_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('brand catalog ${brightness.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 300));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        designSystemHost(
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixFlowLogo(size: 56),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FixFlowLogo(variant: FixFlowLogoVariant.iconOnly, size: 64),
                    FixFlowLogo(
                      variant: FixFlowLogoVariant.monochrome,
                      size: 64,
                    ),
                  ],
                ),
              ],
            ),
          ),
          brightness: brightness,
          size: const Size(420, 300),
        ),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/brand/brand_${brightness.name}.png'),
      );
    });
  }
}
