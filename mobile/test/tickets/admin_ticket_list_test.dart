import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/screens/admin_ticket_list_screen.dart';
import 'package:fixflow/tickets/state/admin_ticket_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';

void main() {
  test(
    'admin list deduplicates pages and clears restricted data on denial',
    () async {
      final repo = FakeAdminRepo();
      final c = AdminTicketListController(repo);
      await c.load();
      await c.load(refresh: false);
      expect(c.tickets.length, 2);
      repo.failure = const TicketFailure(
        TicketFailureKind.unauthorized,
        'Denied',
      );
      await c.load();
      expect(c.tickets, isEmpty);
      expect(c.state.status, AdminTicketListStatus.unauthorized);
    },
  );
  testWidgets('queue renders explicit unassigned and assignment action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AdminTicketListScreen(repository: FakeAdminRepo())),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('غير مسندة'), findsOneWidget);
    expect(find.text('إسناد'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('administrator queue reflows at 320 pixels and 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AdminTicketListScreen(repository: FakeAdminRepo()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('غير مسندة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

AdminTicketSummary adminTicket(String ref) => AdminTicketSummary(
  reference: ref,
  title: 'Leak',
  reporter: const UserSummary(1, 'Reporter'),
  priority: 'high',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(2, 'Plumbing'),
  status: 'new',
  assignedTechnician: null,
  createdAt: DateTime.utc(2026),
);

class FakeAdminRepo implements AdminTicketRepository {
  TicketFailure? failure;
  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) async {
    if (failure case final f?) throw f;
    return AdminTicketPage(
      page == 1 ? [adminTicket('A')] : [adminTicket('A'), adminTicket('B')],
      currentPage: page,
      lastPage: 2,
      total: 2,
    );
  }

  @override
  Future<List<TechnicianOption>> technicians() async => const [
    TechnicianOption(2, 'Tech'),
  ];
  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) async =>
      adminTicket(reference);
}
