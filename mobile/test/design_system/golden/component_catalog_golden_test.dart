import 'package:fixflow/design_system/components/buttons/fixflow_buttons.dart';
import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:fixflow/design_system/components/feedback/fixflow_feedback.dart';
import 'package:fixflow/design_system/components/forms/fixflow_fields.dart';
import 'package:fixflow/design_system/components/navigation/fixflow_navigation.dart';
import 'package:fixflow/design_system/components/overlays/fixflow_dialogs.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('component catalog ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          designSystemHost(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const FixFlowTicketListItem(
                  reference: 'TKT-010',
                  title: 'Water leak تسرب مياه',
                  status: 'in_progress',
                  priority: 'high',
                  metadata: 'Facilities / Plumbing',
                ),
                const SizedBox(height: 16),
                const FixFlowTextField(
                  label: 'Description',
                  helper: 'Plain text',
                  maxLength: 2000,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FixFlowButton(label: 'Submit', onPressed: () {}),
                    FixFlowButton(
                      label: 'Delete',
                      variant: FixFlowButtonVariant.destructive,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FixFlowStateView(
                  kind: FixFlowStateKind.offline,
                  title: 'You are offline',
                  message: 'Check your connection and try again.',
                ),
              ],
            ),
            brightness: brightness,
            direction: direction,
            size: const Size(390, 844),
          ),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/components/catalog_${brightness.name}_${direction.name}.png',
          ),
        );
      });

      testWidgets('overlay and navigation ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          designSystemHost(
            Column(
              children: [
                const FixFlowAppBar(title: 'Tickets'),
                const FixFlowBanner(
                  message: 'Check the latest ticket state.',
                  kind: FixFlowFeedbackKind.information,
                ),
                FixFlowDestinationTile(
                  icon: Icons.list_alt_outlined,
                  label: 'Assigned tickets',
                  supportingText: 'Open your current work queue',
                  onTap: () {},
                ),
                FixFlowPagination(
                  currentPage: 2,
                  lastPage: 4,
                  onPrevious: () {},
                  onNext: () {},
                ),
                Expanded(
                  child: FixFlowFormDialog(
                    title: 'Confirm action',
                    content: const Text(
                      'Review the information before continuing.',
                    ),
                    secondaryAction: FixFlowButton(
                      label: 'Cancel',
                      variant: FixFlowButtonVariant.text,
                      onPressed: () {},
                    ),
                    primaryAction: FixFlowButton(
                      label: 'Continue',
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            brightness: brightness,
            direction: direction,
            size: const Size(390, 844),
          ),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/components/overlay_navigation_${brightness.name}_${direction.name}.png',
          ),
        );
      });
    }
  }
}
