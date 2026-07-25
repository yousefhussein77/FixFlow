import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/state/technician_ticket_details_controller.dart';
import 'package:fixflow/tickets/screens/technician_ticket_details_screen.dart';

void main() {
  test('concealed not found clears detail', () async {
    final controller = TechnicianTicketDetailsController(_Missing(), 'hidden');
    await controller.load();
    expect(controller.status, TechnicianDetailStatus.notFound);
    expect(controller.ticket, isNull);
  });

  testWidgets('technician detail reflows at 320 pixels and 200% text', (
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
            child: TechnicianTicketDetailsScreen(
              repository: _DetailsRepo(),
              reference: 'TKT-7',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leak'), findsNWidgets(2));
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _DetailsRepo implements TechnicianTicketRepository {
  @override
  Future<TechnicianTicket> details(String reference) async => TechnicianTicket(
    reference: reference,
    title: 'Leak',
    priority: 'high',
    department: const TicketOption(1, 'Facilities'),
    category: const TicketOption(2, 'Plumbing'),
    status: 'assigned',
    createdAt: DateTime.utc(2026),
    description: 'Leak',
    location: 'Floor 2',
    photos: const [],
    assignedTechnician: UserSummary(3, 'Tech'),
    history: const [],
    updatedAt: DateTime.utc(2026),
  );
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) => throw UnimplementedError();
}

class _Missing implements TechnicianTicketRepository {
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw const TicketFailure(
        TicketFailureKind.notFound,
        'Ticket not found.',
      );
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) => throw UnimplementedError();
}
