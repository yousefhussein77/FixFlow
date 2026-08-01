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
    this.padding,
    this.scrollController,
    this.contentMaxWidth = FixFlowBreakpoints.contentMaxWidth,
    super.key,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final double contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < FixFlowBreakpoints.compact
        ? FixFlowSpacing.xs + FixFlowSpacing.half
        : width < FixFlowBreakpoints.tablet
        ? FixFlowSpacing.sm
        : FixFlowSpacing.lg;
    final effectivePadding =
        padding ??
        EdgeInsetsDirectional.fromSTEB(
          horizontal,
          FixFlowSpacing.sm,
          horizontal,
          FixFlowSpacing.lg,
        );
    final resolvedPadding = effectivePadding.resolve(
      Directionality.of(context),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: title == null ? null : AppBar(title: title, actions: actions),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: title == null,
        bottom: bottomNavigationBar == null,
        child: FixFlowConstrainedContent(
          maxWidth: contentMaxWidth,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              controller: scrollController,
              padding: effectivePadding,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - resolvedPadding.vertical)
                      .clamp(0, double.infinity),
                ),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
