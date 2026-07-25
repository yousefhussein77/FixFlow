import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';

Widget designSystemHost(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  Size size = const Size(390, 844),
}) => MediaQuery(
  data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: FixFlowTheme.light(),
    darkTheme: FixFlowTheme.dark(),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: SafeArea(child: child)),
    ),
  ),
);
