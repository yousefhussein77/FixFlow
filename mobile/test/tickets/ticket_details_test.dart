import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_repository.dart';
import 'package:fixflow/tickets/screens/ticket_details_screen.dart';
import 'package:fixflow/tickets/state/ticket_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'detail distinguishes concealed denial, offline, and recovery',
    () async {
      final r = DetailRepo();
      final c = TicketDetailsController(r);
      r.failure = const TicketFailure(
        TicketFailureKind.notFound,
        'Ticket not found.',
      );
      await c.load('hidden');
      expect(c.state.status, TicketDetailsStatus.notFound);
      r.failure = const TicketFailure(TicketFailureKind.offline, 'Offline');
      await c.load('x');
      expect(c.state.status, TicketDetailsStatus.offline);
      r.failure = null;
      await c.load('owned');
      expect(c.state.status, TicketDetailsStatus.populated);
      c.photoUnavailable();
      expect(c.state.status, TicketDetailsStatus.photoUnavailable);
    },
  );
  testWidgets('owned detail renders all submitted fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TicketDetailsScreen(
          repository: DetailRepo(),
          reference: 'TKT-ABCDEFGHIJKL',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leak'), findsOneWidget);
    expect(find.text('Location: Floor 2'), findsOneWidget);
    expect(find.text('Photos: 0'), findsOneWidget);
  });
}

class DetailRepo implements TicketRepository {
  TicketFailure? failure;
  @override
  Future<TicketDetail> detail(String reference) async {
    if (failure case final f?) throw f;
    return value;
  }

  @override
  Future<List<TicketOption>> departments() async => [];
  @override
  Future<List<TicketOption>> categories(int id) async => [];
  @override
  Future<TicketDetail> create(CreateTicketInput input) =>
      throw UnimplementedError();
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
}

final value = TicketDetail(
  reference: 'TKT-ABCDEFGHIJKL',
  title: 'Leak',
  status: 'new',
  priority: 'high',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(2, 'Plumbing'),
  createdAt: DateTime.utc(2026),
  description: 'Water leak',
  location: 'Floor 2',
  photos: const [],
  updatedAt: DateTime.utc(2026),
);
