import 'package:flutter/material.dart';

import '../tokens/fixflow_spacing.dart';
import 'responsive_constraints.dart';

class FixFlowPage extends StatelessWidget {
  const FixFlowPage({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = const EdgeInsetsDirectional.all(FixFlowSpacing.sm),
    super.key,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: title == null ? null : AppBar(title: title, actions: actions),
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    body: SafeArea(
      child: FixFlowConstrainedContent(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: padding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    padding.vertical.clamp(0, constraints.maxHeight),
              ),
              child: body,
            ),
          ),
        ),
      ),
    ),
  );
}
