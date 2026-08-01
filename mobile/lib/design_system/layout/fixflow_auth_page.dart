import 'package:flutter/material.dart';

import '../brand/fixflow_logo.dart';
import '../components/content/fixflow_surfaces.dart';
import '../tokens/fixflow_spacing.dart';
import 'fixflow_page.dart';

class FixFlowAuthPage extends StatelessWidget {
  const FixFlowAuthPage({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final landscape =
          MediaQuery.orientationOf(context) == Orientation.landscape;
      return FixFlowPage(
        contentMaxWidth: 560,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(child: FixFlowBitmapLogo.mark(size: 180)),
            SizedBox(height: landscape ? FixFlowSpacing.xs : FixFlowSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: FixFlowSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: landscape ? FixFlowSpacing.sm : FixFlowSpacing.lg),
            FixFlowSurface(child: child),
          ],
        ),
      );
    },
  );
}
