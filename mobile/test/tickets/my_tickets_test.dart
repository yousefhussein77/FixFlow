import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_repository.dart';
import 'package:fixflow/tickets/screens/my_tickets_screen.dart';
import 'package:fixflow/tickets/state/my_tickets_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'pagination appends without duplicate rows and recovers offline',
    () async {
      final r = ListRepo();
      final c = MyTicketsController(r);
      await c.load();
      expect(c.tickets.length, 2);
      await c.load(refresh: false);
      expect(c.tickets.length, 3);
      r.offline = true;
      await c.load();
      expect(c.state.status, MyTicketsStatus.offline);
      r.offline = false;
      await c.load();
      expect(c.state.status, MyTicketsStatus.populated);
    },
  );
  testWidgets('empty list invites ticket creation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyTicketsScreen(repository: EmptyRepo())),
    );
    await tester.pumpAndSettle();
    expect(find.text('You have no tickets yet.'), findsOneWidget);
  });
}

TicketSummary summary(String ref) => TicketSummary(
  reference: ref,
  title: ref,
  status: 'new',
  priority: 'low',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(2, 'Electrical'),
  createdAt: DateTime.utc(2026),
);

class ListRepo implements TicketRepository {
  bool offline = false;
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) async {
    if (offline)
      throw const TicketFailure(TicketFailureKind.offline, 'Offline');
    return TicketPage(
      page == 1 ? [summary('A'), summary('B')] : [summary('B'), summary('C')],
      currentPage: page,
      lastPage: 2,
      total: 3,
    );
  }

  @override
  Future<List<TicketOption>> departments() async => [];
  @override
  Future<List<TicketOption>> categories(int id) async => [];
  @override
  Future<TicketDetail> create(CreateTicketInput input) =>
      throw UnimplementedError();
  @override
  Future<TicketDetail> detail(String reference) => throw UnimplementedError();
}

class EmptyRepo extends ListRepo {
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) async =>
      const TicketPage([], currentPage: 1, lastPage: 1, total: 0);
}
