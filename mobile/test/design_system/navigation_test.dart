import 'package:fixflow/design_system/components/navigation/fixflow_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/design_system_test_host.dart';

void main() {
  testWidgets('navigation exposes selection and bounded pagination', (
    tester,
  ) async {
    await tester.pumpWidget(
      designSystemHost(
        Column(
          children: [
            FixFlowDestinationTile(
              icon: Icons.list_alt,
              label: 'Tickets',
              onTap: () {},
            ),
            FixFlowPagination(
              currentPage: 1,
              lastPage: 3,
              onPrevious: () {},
              onNext: () {},
            ),
          ],
        ),
        direction: TextDirection.rtl,
      ),
    );
    final previous = find.widgetWithIcon(IconButton, Icons.chevron_left);
    final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
    expect(previous, findsOneWidget);
    expect(next, findsWidgets);
    expect(tester.widget<IconButton>(previous).onPressed, isNull);
    expect(tester.getSize(next.last).width, 48);
  });

  testWidgets(
    'app bar, bottom navigation, tabs, and segments expose selection',
    (tester) async {
      var destination = 0;
      var segment = <String>{'open'};
      await tester.pumpWidget(
        designSystemHost(
          DefaultTabController(
            length: 2,
            child: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                appBar: const FixFlowAppBar(title: 'FixFlow'),
                body: Column(
                  children: [
                    const FixFlowTabs(
                      tabs: [
                        Tab(text: 'Open'),
                        Tab(text: 'Done'),
                      ],
                    ),
                    FixFlowSegmentedControl<String>(
                      segments: const [
                        ButtonSegment(value: 'open', label: Text('Open')),
                        ButtonSegment(value: 'done', label: Text('Done')),
                      ],
                      selected: segment,
                      onSelectionChanged: (value) =>
                          setState(() => segment = value),
                    ),
                  ],
                ),
                bottomNavigationBar: FixFlowBottomNavigation(
                  selectedIndex: destination,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.list_alt),
                      label: 'Tickets',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                  onDestinationSelected: (value) =>
                      setState(() => destination = value),
                ),
              ),
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.tap(find.text('Done').last);
      await tester.pump();
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(segment, {'done'});
      expect(destination, 1);
      expect(find.text('FixFlow'), findsOneWidget);
    },
  );
}
