import 'package:flutter/material.dart';

import '../theme/fixflow_colors.dart';
import 'fixflow_brand.dart';

enum FixFlowBitmapLogoVariant { mark, wordmark }

class FixFlowBitmapLogo extends StatelessWidget {
  const FixFlowBitmapLogo.mark({this.size = 40, super.key})
    : variant = FixFlowBitmapLogoVariant.mark;
  const FixFlowBitmapLogo.wordmark({this.size = 48, super.key})
    : variant = FixFlowBitmapLogoVariant.wordmark;

  final double size;
  final FixFlowBitmapLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final mark = variant == FixFlowBitmapLogoVariant.mark;
    return Semantics(
      image: true,
      label: FixFlowBrand.name,
      child: Image.asset(
        mark
            ? 'assets/brand/fixflow_logo_mark.png'
            : 'assets/brand/fixflow_logo_wordmark.png',
        width: mark ? size : size * 3.2,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        excludeFromSemantics: true,
      ),
    );
  }
}

class FixFlowLogo extends StatelessWidget {
  const FixFlowLogo({
    this.variant = FixFlowLogoVariant.horizontal,
    this.size = 48,
    this.useApprovedBrandColors = false,
    this.useGeometricMark = false,
    super.key,
  });

  final FixFlowLogoVariant variant;
  final double size;
  final bool useApprovedBrandColors;
  final bool useGeometricMark;

  @override
  Widget build(BuildContext context) {
    final horizontal = variant == FixFlowLogoVariant.horizontal;
    final effectiveSize = size.clamp(FixFlowBrand.minimumIconSize, 256.0);
    final width = horizontal
        ? (effectiveSize * 3).clamp(FixFlowBrand.minimumHorizontalWidth, 768.0)
        : effectiveSize;
    final monochrome = variant == FixFlowLogoVariant.monochrome;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = monochrome
        ? Theme.of(context).colorScheme.onSurface
        : (useApprovedBrandColors || !dark
              ? FixFlowColors.brandPrimary
              : const Color(0xFF8AA7FF));
    final accent = monochrome
        ? primary
        : (useApprovedBrandColors || !dark
              ? FixFlowColors.brandAccent
              : const Color(0xFFFFB55C));

    return Semantics(
      image: true,
      label: FixFlowBrand.name,
      child: SizedBox(
        width: width,
        height: effectiveSize,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            SizedBox.square(
              dimension: effectiveSize,
              child: CustomPaint(
                painter: useGeometricMark
                    ? _FixFlowGeometricPainter(primary, accent)
                    : _FixFlowMarkPainter(primary, accent),
              ),
            ),
            if (horizontal) ...[
              SizedBox(width: effectiveSize * .22),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    FixFlowBrand.name,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: effectiveSize * .62,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FixFlowGeometricPainter extends CustomPainter {
  const _FixFlowGeometricPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    final blue = Paint()..color = primary;
    final blueShade = Paint()..color = const Color(0xFF386CFF);
    final orange = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final top = Path()
      ..moveTo(50 * scale, 8 * scale)
      ..lineTo(91 * scale, 30 * scale)
      ..lineTo(50 * scale, 52 * scale)
      ..lineTo(9 * scale, 30 * scale)
      ..close();
    final left = Path()
      ..moveTo(9 * scale, 30 * scale)
      ..lineTo(50 * scale, 52 * scale)
      ..lineTo(50 * scale, 92 * scale)
      ..lineTo(9 * scale, 69 * scale)
      ..close();
    final right = Path()
      ..moveTo(50 * scale, 52 * scale)
      ..lineTo(91 * scale, 30 * scale)
      ..lineTo(91 * scale, 69 * scale)
      ..lineTo(50 * scale, 92 * scale)
      ..close();
    canvas.drawPath(top, blueShade);
    canvas.drawPath(left, blue);
    canvas.drawPath(right, blue);
    canvas.drawPath(
      Path()
        ..moveTo(31 * scale, 52 * scale)
        ..lineTo(45 * scale, 66 * scale)
        ..lineTo(73 * scale, 38 * scale),
      orange,
    );
  }

  @override
  bool shouldRepaint(covariant _FixFlowGeometricPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.accent != accent;
}

class _FixFlowMarkPainter extends CustomPainter {
  const _FixFlowMarkPainter(this.primary, this.accent);
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    final blue = Paint()..color = primary;
    final orange = Paint()..color = accent;
    final f = Path()
      ..moveTo(18 * scale, 12 * scale)
      ..lineTo(80 * scale, 12 * scale)
      ..lineTo(80 * scale, 29 * scale)
      ..lineTo(38 * scale, 29 * scale)
      ..lineTo(38 * scale, 45 * scale)
      ..lineTo(70 * scale, 45 * scale)
      ..lineTo(70 * scale, 62 * scale)
      ..lineTo(38 * scale, 62 * scale)
      ..lineTo(38 * scale, 90 * scale)
      ..lineTo(18 * scale, 90 * scale)
      ..close();
    canvas.drawPath(f, blue);
    final flow = Path()
      ..moveTo(44 * scale, 39 * scale)
      ..lineTo(72 * scale, 39 * scale)
      ..lineTo(91 * scale, 53 * scale)
      ..lineTo(72 * scale, 67 * scale)
      ..lineTo(44 * scale, 67 * scale)
      ..lineTo(60 * scale, 53 * scale)
      ..close();
    canvas.drawPath(flow, orange);
    canvas.drawCircle(Offset(88 * scale, 53 * scale), 5 * scale, orange);
  }

  @override
  bool shouldRepaint(covariant _FixFlowMarkPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.accent != accent;
}
