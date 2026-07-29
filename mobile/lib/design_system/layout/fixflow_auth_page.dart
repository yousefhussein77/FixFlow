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
  Widget build(BuildContext context) => FixFlowPage(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(child: FixFlowBitmapLogo.mark(size: 180)),
        const SizedBox(height: FixFlowSpacing.sm),
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
        const SizedBox(height: FixFlowSpacing.lg),
        FixFlowSurface(child: child),
      ],
    ),
  );
}
