import 'package:flutter/material.dart';

import '../../tokens/fixflow_motion.dart';
import 'fixflow_navigation.dart';

class FixFlowRoleDestination {
  const FixFlowRoleDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}

class FixFlowRoleShellController {
  _FixFlowRoleShellState? _state;

  int get selectedIndex => _state?._selectedIndex ?? 0;

  Future<void> selectDestination(int index) async {
    await _state?._select(index);
  }
}

class FixFlowRoleShell extends StatefulWidget {
  const FixFlowRoleShell({
    required this.destinations,
    this.controller,
    super.key,
  });

  final List<FixFlowRoleDestination> destinations;
  final FixFlowRoleShellController? controller;

  @override
  State<FixFlowRoleShell> createState() => _FixFlowRoleShellState();
}

class _FixFlowRoleShellState extends State<FixFlowRoleShell> {
  late final PageController _pageController;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navigatorKeys = List.generate(
      widget.destinations.length,
      (_) => GlobalKey<NavigatorState>(),
    );
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant FixFlowRoleShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this)
        oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    if (oldWidget.destinations.length != widget.destinations.length) {
      _navigatorKeys = List.generate(
        widget.destinations.length,
        (_) => GlobalKey<NavigatorState>(),
      );
      _selectedIndex = _selectedIndex.clamp(0, widget.destinations.length - 1);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _select(int index) async {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
    await _pageController.animateToPage(
      index,
      duration: FixFlowMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _destinationNavigator(BuildContext context, int index) =>
      MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Navigator(
          key: _navigatorKeys[index],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: widget.destinations[index].builder,
            settings: RouteSettings(
              name: '/role/${widget.destinations[index].label}',
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.destinations.length == 1) {
      return Scaffold(body: _destinationNavigator(context, 0));
    }
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.destinations.length,
        itemBuilder: _destinationNavigator,
      ),
      bottomNavigationBar: FixFlowBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        labelBehavior: MediaQuery.sizeOf(context).width < 360
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          for (final destination in widget.destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: destination.label,
            ),
        ],
      ),
    );
  }
}
