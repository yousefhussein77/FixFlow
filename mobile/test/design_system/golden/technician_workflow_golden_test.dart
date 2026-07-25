import 'package:fixflow/design_system/components/content/fixflow_surfaces.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_badges.dart';
import 'package:fixflow/design_system/components/tickets/fixflow_ticket_content.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/state/ticket_status_transition_controller.dart';
import 'package:fixflow/tickets/widgets/ticket_processing_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('technician workflow ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          designSystemHost(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Assigned ticket'),
                const Wrap(
                  spacing: 8,
                  children: [
                    FixFlowStatusChip(status: 'assigned'),
                    FixFlowPriorityBadge(priority: 'high'),
                  ],
                ),
                const SizedBox(height: 12),
                const FixFlowSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FixFlowMetadataRow(label: 'Location', value: 'Floor 2'),
                      FixFlowMetadataRow(label: 'Photos', value: '2'),
                      Text('Water leak requires inspection.'),
                    ],
                  ),
                ),
                const FixFlowHistoryItem(
                  title: 'new → assigned',
                  details: 'Actor: Administrator',
                  timestamp: '2026-07-25 10:00',
                ),
                TicketProcessingActions(
                  ticket: _ticket(),
                  controller: TicketStatusTransitionController(
                    _GoldenRepository(),
                    refresh: _noop,
                  ),
                  onUpdated: _ignore,
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
            'goldens/technician/technician_${brightness.name}_${direction.name}.png',
          ),
        );
      });
    }
  }
}

Future<void> _noop() async {}
void _ignore(TechnicianTicket _) {}

TechnicianTicket _ticket({String status = 'assigned'}) => TechnicianTicket(
  reference: 'TKT-TECH',
  title: 'Water leak',
  priority: 'high',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(2, 'Plumbing'),
  status: status,
  createdAt: DateTime.utc(2026),
  description: 'Water leak requires inspection.',
  location: 'Floor 2',
  photos: const [],
  assignedTechnician: const UserSummary(3, 'Technician'),
  history: const [],
  updatedAt: DateTime.utc(2026),
);

class _GoldenRepository implements TechnicianTicketRepository {
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) async => _ticket(status: status);
}
