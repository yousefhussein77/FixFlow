import 'package:flutter/material.dart';

abstract final class FixFlowIcons {
  static const double compact = 16;
  static const double standard = 20;
  static const double action = 24;
  static const double prominent = 32;
  static const double state = 48;
  static const double minimumTarget = 48;

  static bool mirrorsInRtl(IconData icon) => [
    Icons.arrow_back,
    Icons.arrow_forward,
    Icons.chevron_left,
    Icons.chevron_right,
  ].contains(icon);
}
