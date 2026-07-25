import 'package:flutter/foundation.dart';

abstract final class FixFlowMotion {
  static const Duration immediate = Duration.zero;
  static const Duration short = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration emphasized = Duration(milliseconds: 350);

  static Duration resolve(Duration duration, {required bool reduceMotion}) =>
      reduceMotion ? immediate : duration;

  static bool platformReduceMotion() =>
      PlatformDispatcher.instance.accessibilityFeatures.disableAnimations;
}
