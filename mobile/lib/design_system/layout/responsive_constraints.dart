import 'package:flutter/material.dart';

abstract final class FixFlowBreakpoints {
  static const double minimumPhone = 320;
  static const double compact = 360;
  static const double regularPhone = 390;
  static const double largePhone = 600;
  static const double contentMaxWidth = 720;
}

class FixFlowConstrainedContent extends StatelessWidget {
  const FixFlowConstrainedContent({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: FixFlowBreakpoints.minimumPhone,
        maxWidth: FixFlowBreakpoints.contentMaxWidth,
      ),
      child: child,
    ),
  );
}
