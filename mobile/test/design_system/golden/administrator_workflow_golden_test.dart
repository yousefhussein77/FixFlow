import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/feedback/fixflow_state_view.dart';
import 'package:fixflow/design_system/components/forms/fixflow_fields.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('administrator workflow ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          designSystemHost(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('All tickets'),
                const SizedBox(height: 12),
                const FixFlowSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('TKT-ADMIN-01'),
                      Text('Leaking pipe'),
                      Wrap(
                        spacing: 8,
                        children: [
                          FixFlowStatusChip(status: 'new'),
                          FixFlowPriorityBadge(priority: 'high'),
                        ],
                      ),
                      FixFlowMetadataRow(
                        label: 'Reporter',
                        value: 'Riley Reporter',
                      ),
                      FixFlowMetadataRow(
                        label: 'Assignment',
                        value: 'Unassigned',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FixFlowDropdownField<int>(
                  label: 'Active technician',
                  items: [1, 2],
                  itemLabel: _technicianLabel,
                  onChanged: _ignoreSelection,
                ),
                const SizedBox(height: 12),
                const FixFlowSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Departments'),
                      FixFlowMetadataRow(label: 'Facilities', value: 'Active'),
                      FixFlowMetadataRow(
                        label: 'Operations',
                        value: 'Inactive',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FixFlowCommentItem(
                  author: 'Administrator',
                  role: 'administrator',
                  content: 'Oversight note.',
                  timestamp: '2026-07-25 10:00',
                ),
                const SizedBox(height: 12),
                const FixFlowStateView(
                  kind: FixFlowStateKind.conflict,
                  title: 'Refresh before trying again.',
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
            'goldens/administrator/administrator_${brightness.name}_${direction.name}.png',
          ),
        );
      });
    }
  }
}

String _technicianLabel(int id) =>
    id == 1 ? 'Taylor Technician' : 'Jordan Technician';
void _ignoreSelection(int? value) {}
