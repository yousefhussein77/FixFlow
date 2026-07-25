import 'package:flutter/material.dart';

import '../../tokens/fixflow_icons.dart';
import '../../tokens/fixflow_spacing.dart';

class FixFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FixFlowAppBar({required this.title, this.actions, super.key});
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(title: Text(title), actions: actions);
}

class FixFlowDestinationTile extends StatelessWidget {
  const FixFlowDestinationTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.supportingText,
    super.key,
  });
  final IconData icon;
  final String label;
  final String? supportingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: FixFlowSpacing.touch,
    leading: Icon(icon),
    title: Text(label),
    subtitle: supportingText == null ? null : Text(supportingText!),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class FixFlowPagination extends StatelessWidget {
  const FixFlowPagination({
    required this.currentPage,
    required this.lastPage,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });
  final int currentPage, lastPage;
  final VoidCallback? onPrevious, onNext;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Page $currentPage of $lastPage',
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          constraints: const BoxConstraints.tightFor(
            width: FixFlowIcons.minimumTarget,
            height: FixFlowIcons.minimumTarget,
          ),
          tooltip: 'Previous page',
          onPressed: currentPage > 1 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FixFlowSpacing.xs),
          child: Text('$currentPage / $lastPage'),
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(
            width: FixFlowIcons.minimumTarget,
            height: FixFlowIcons.minimumTarget,
          ),
          tooltip: 'Next page',
          onPressed: currentPage < lastPage ? onNext : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}

class FixFlowBottomNavigation extends StatelessWidget {
  const FixFlowBottomNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    super.key,
  });
  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    destinations: destinations,
    onDestinationSelected: onDestinationSelected,
  );
}

class FixFlowTabs extends StatelessWidget {
  const FixFlowTabs({required this.tabs, this.controller, super.key});

  final List<Tab> tabs;
  final TabController? controller;

  @override
  Widget build(BuildContext context) => TabBar(
    controller: controller,
    tabs: tabs,
    isScrollable: tabs.length > 3,
    tabAlignment: tabs.length > 3 ? TabAlignment.start : TabAlignment.fill,
  );
}

class FixFlowSegmentedControl<T> extends StatelessWidget {
  const FixFlowSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    super.key,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<T>(
    segments: segments,
    selected: selected,
    onSelectionChanged: onSelectionChanged,
    showSelectedIcon: true,
  );
}
