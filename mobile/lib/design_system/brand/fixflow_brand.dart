enum FixFlowLogoVariant { primary, horizontal, iconOnly, monochrome }

abstract final class FixFlowBrand {
  static const String name = 'FixFlow';
  static const double minimumIconSize = 24;
  static const double minimumHorizontalWidth = 120;
  static const double clearSpace = 8;

  static const runtimeAssets = <String>{
    'assets/brand/runtime/fixflow_mark_icon_light.svg',
    'assets/brand/runtime/fixflow_mark_icon_dark.svg',
    'assets/brand/runtime/fixflow_logo_horizontal_light.svg',
    'assets/brand/runtime/fixflow_logo_horizontal_dark.svg',
    'assets/brand/runtime/fixflow_logo_horizontal_mono_light.svg',
    'assets/brand/runtime/fixflow_logo_horizontal_mono_dark.svg',
    'assets/brand/runtime/fixflow_splash_mark.svg',
  };
}
