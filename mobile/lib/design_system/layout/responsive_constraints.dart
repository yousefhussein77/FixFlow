import 'package:flutter/material.dart';

abstract final class FixFlowBreakpoints {
  static const double minimumPhone = 320;
  static const double compact = 360;
  static const double regularPhone = 390;
  static const double largePhone = 600;
  static const double tablet = 720;
  static const double desktop = 1024;
  static const double wideDesktop = 1280;
  static const double contentMaxWidth = 840;
}

class FixFlowConstrainedContent extends StatelessWidget {
  const FixFlowConstrainedContent({
    required this.child,
    this.maxWidth = FixFlowBreakpoints.contentMaxWidth,
    super.key,
  });
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

extension FixFlowResponsiveContext on BuildContext {
  double get viewportWidth => MediaQuery.sizeOf(this).width;

  bool get isCompactWidth => viewportWidth < FixFlowBreakpoints.largePhone;

  bool get isTabletWidth =>
      viewportWidth >= FixFlowBreakpoints.tablet &&
      viewportWidth < FixFlowBreakpoints.desktop;

  bool get isDesktopWidth => viewportWidth >= FixFlowBreakpoints.desktop;
}
