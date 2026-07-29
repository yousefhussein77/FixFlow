import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/state/ticket_status_transition_controller.dart';
import 'package:fixflow/tickets/widgets/ticket_processing_actions.dart';

void main() {
  testWidgets('assigned ticket offers only start and reject', (tester) async {
    final repository = _Transitions();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketProcessingActions(
            ticket: _ticket(),
            controller: TicketStatusTransitionController(
              repository,
              refresh: () async {},
            ),
            onUpdated: (_) {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('start_work')), findsOneWidget);
    expect(find.byKey(const Key('complete_ticket')), findsNothing);
    expect(find.byKey(const Key('reject_ticket')), findsOneWidget);
    await tester.tap(find.byKey(const Key('start_work')));
    await tester.pumpAndSettle();
    expect(repository.status, isNull);
    expect(find.text('بدء العمل؟'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_start_work')));
    await tester.pumpAndSettle();
    expect(repository.status, 'in_progress');
  });

  testWidgets('processing actions remain accessible in dark RTL at 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TicketProcessingActions(
              ticket: _ticket(),
              controller: TicketStatusTransitionController(
                _Transitions(),
                refresh: () async {},
              ),
              onUpdated: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('start_work')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejection presents a required reason field', (tester) async {
    final repository = _Transitions();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketProcessingActions(
            ticket: _ticket(),
            controller: TicketStatusTransitionController(
              repository,
              refresh: () async {},
            ),
            onUpdated: (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('reject_ticket')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rejection_reason')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('rejection_reason')),
      'Not safe',
    );
    await tester.tap(find.text('رفض').last);
    await tester.pumpAndSettle();
    expect(repository.status, 'rejected');
  });

  for (final failure in {
    TicketFailureKind.conflict: TicketTransitionStatus.conflict,
    TicketFailureKind.offline: TicketTransitionStatus.offline,
    TicketFailureKind.server: TicketTransitionStatus.serverError,
  }.entries) {
    test(
      '${failure.key.name} refreshes and keeps the transition error',
      () async {
        var refreshes = 0;
        final repository = _AmbiguousFailureRepository(failure.key);
        final controller = TicketStatusTransitionController(
          repository,
          refresh: () async {
            refreshes++;
          },
        );

        expect(await controller.submit('TKT-7', 'in_progress'), isNull);
        expect(refreshes, 1);
        expect(controller.status, failure.value);
        expect(controller.message, 'Refresh required.');
        expect(controller.isRefreshingAuthoritativeState, isFalse);
      },
    );
  }
}

class _Transitions implements TechnicianTicketRepository {
  String? status;
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String value, {
    String? reason,
  }) async {
    status = value;
    return _ticket(status: value);
  }

  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw UnimplementedError();
}

class _AmbiguousFailureRepository implements TechnicianTicketRepository {
  _AmbiguousFailureRepository(this.kind);
  final TicketFailureKind kind;
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String value, {
    String? reason,
  }) => throw TicketFailure(kind, 'Refresh required.');
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw UnimplementedError();
}

TechnicianTicket _ticket({String status = 'assigned'}) => TechnicianTicket(
  reference: 'TKT-7',
  title: 'Leak',
  priority: 'high',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(2, 'Plumbing'),
  status: status,
  createdAt: DateTime.utc(2026),
  description: 'Leak',
  location: 'Floor 2',
  photos: const [],
  assignedTechnician: const UserSummary(3, 'Tech'),
  history: const [],
  updatedAt: DateTime.utc(2026),
);
