import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/state/assigned_tickets_controller.dart';
import 'package:fixflow/tickets/screens/assigned_tickets_screen.dart';
import 'package:flutter/material.dart';

void main() {
  test('assigned controller exposes owned page', () async {
    final controller = AssignedTicketsController(_Repository());
    await controller.load();
    expect(controller.status, AssignedTicketsStatus.populated);
    expect(controller.tickets.single.reference, 'TKT-7');
  });

  testWidgets('assigned list remains readable at narrow width and large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AssignedTicketsScreen(repository: _Repository()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Repository implements TechnicianTicketRepository {
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) async =>
      TechnicianTicketPage(
        [TechnicianTicketSummary.fromJson(_summary())],
        currentPage: 1,
        lastPage: 1,
        total: 1,
      );
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) => throw UnimplementedError();
}

Map<String, dynamic> _summary() => {
  'reference': 'TKT-7',
  'title': 'Leak',
  'priority': 'high',
  'department': {'id': 1, 'name': 'Facilities'},
  'category': {'id': 2, 'name': 'Plumbing'},
  'status': 'assigned',
  'created_at': '2026-07-23T10:00:00Z',
};
