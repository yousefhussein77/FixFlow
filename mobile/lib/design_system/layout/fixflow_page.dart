import 'package:flutter/material.dart';

import '../tokens/fixflow_spacing.dart';
import '../theme/fixflow_colors.dart';
import 'responsive_constraints.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../notifications/widgets/notification_host.dart';

class FixFlowPage extends StatelessWidget {
  const FixFlowPage({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.scrollController,
    this.onRefresh,
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
  final Future<void> Function()? onRefresh;
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
    final pageActions = <Widget>[
      if (NotificationScope.maybeOf(context) != null) const NotificationBell(),
      ...?actions,
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: title == null ? null : AppBar(title: title, actions: pageActions),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: title == null,
        bottom: bottomNavigationBar == null,
        child: FixFlowConstrainedContent(
          maxWidth: contentMaxWidth,
          child: LayoutBuilder(
            builder: (context, constraints) => _FixFlowPageScroll(
              controller: scrollController,
              padding: effectivePadding,
              minHeight: (constraints.maxHeight - resolvedPadding.vertical)
                  .clamp(0, double.infinity),
              onRefresh: onRefresh,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

class _FixFlowPageScroll extends StatefulWidget {
  const _FixFlowPageScroll({
    required this.padding,
    required this.minHeight,
    required this.child,
    this.controller,
    this.onRefresh,
  });

  final EdgeInsetsGeometry padding;
  final double minHeight;
  final Widget child;
  final ScrollController? controller;
  final Future<void> Function()? onRefresh;

  @override
  State<_FixFlowPageScroll> createState() => _FixFlowPageScrollState();
}

class _FixFlowPageScrollState extends State<_FixFlowPageScroll> {
  Future<void>? _refreshInFlight;

  Future<void> _refresh() {
    final active = _refreshInFlight;
    if (active != null) return active;
    final operation = widget.onRefresh!();
    _refreshInFlight = operation;
    return operation.whenComplete(() {
      if (identical(_refreshInFlight, operation)) _refreshInFlight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.onRefresh == null
          ? null
          : const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.minHeight),
        child: widget.child,
      ),
    );
    if (widget.onRefresh == null) return scrollView;
    return RefreshIndicator(
      key: const Key('fixflow_pull_to_refresh'),
      color: FixFlowColors.brandPrimary,
      onRefresh: _refresh,
      child: scrollView,
    );
  }
}
