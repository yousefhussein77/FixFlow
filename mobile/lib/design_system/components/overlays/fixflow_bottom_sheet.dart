import 'package:flutter/material.dart';

import '../../tokens/fixflow_spacing.dart';

Future<T?> showFixFlowBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  isDismissible: isDismissible,
  useSafeArea: true,
  builder: (context) => AnimatedPadding(
    duration: const Duration(milliseconds: 150),
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(FixFlowSpacing.sm),
      child: builder(context),
    ),
  ),
);
