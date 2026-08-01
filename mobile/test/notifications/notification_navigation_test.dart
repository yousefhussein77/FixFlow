import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/session_gate.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/accounts/models/account_request_models.dart';
import 'package:fixflow/accounts/repositories/account_request_repository.dart';
import 'package:fixflow/accounts/screens/account_requests_screen.dart';
import 'package:fixflow/notifications/models/notification_models.dart';
import 'package:fixflow/notifications/repositories/notification_repository.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/repositories/ticket_repository.dart';
import 'package:fixflow/tickets/screens/technician_ticket_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'reporter notification validates ownership and avoids duplicate routes',
    (tester) async {
      final auth = AuthController(_AuthRepository());
      await auth.restore();
      final tickets = _TicketRepository();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SessionGate(
            controller: auth,
            ticketRepository: tickets,
            notificationRepository: _NotificationRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('notification_bell')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('notification_1')));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل التذكرة'), findsOneWidget);
      expect(find.byKey(const Key('notification_bell')), findsOneWidget);
      expect(tickets.detailCalls, 2);

      await tester.tap(find.byKey(const Key('notification_bell')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('notification_1')));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل التذكرة'), findsOneWidget);
      expect(tickets.detailCalls, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('missing reporter destination is handled without route change', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository());
    await auth.restore();
    final tickets = _TicketRepository(fail: true);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SessionGate(
          controller: auth,
          ticketRepository: tickets,
          notificationRepository: _NotificationRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('تعذر فتح العنصر المرتبط'), findsOneWidget);
    expect(find.byKey(const Key('notification_list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('administrator account request notification opens requests', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository(role: 'administrator'));
    await auth.restore();
    final accounts = _AccountRequestRepository();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: SessionGate(
          controller: auth,
          adminTicketRepository: _AdminTicketRepository(),
          accountRequestRepository: accounts,
          notificationRepository: _NotificationRepository(
            target: 'admin.account_requests',
            payload: const {'account_id': 2},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_1')));
    await tester.pumpAndSettle();

    expect(find.byType(AccountRequestsScreen), findsOneWidget);
    expect(accounts.listCalls, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('technician assignment notification opens owned ticket', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository(role: 'technician'));
    await auth.restore();
    final tickets = _TechnicianTicketRepository();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: SessionGate(
          controller: auth,
          technicianTicketRepository: tickets,
          notificationRepository: _NotificationRepository(
            target: 'technician.ticket',
            payload: const {'ticket_reference': 'TKT-1'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_1')));
    await tester.pumpAndSettle();

    expect(find.byType(TechnicianTicketDetailsScreen), findsOneWidget);
    expect(tickets.detailCalls, 2);
    expect(tester.takeException(), isNull);
  });
}

class _AuthRepository implements AuthRepository {
  _AuthRepository({String role = 'reporter'})
    : profileValue = UserProfile(
        id: 1,
        name: 'User',
        email: 'user@example.com',
        role: role,
        isActive: true,
        createdAt: DateTime.utc(2026),
      );

  final UserProfile profileValue;

  @override
  Future<UserProfile?> restore() async => profileValue;
  @override
  Future<UserProfile> profile() async => profileValue;
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async => profileValue;
  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) async => profileValue;
}

class _TicketRepository implements TicketRepository {
  _TicketRepository({this.fail = false});
  final bool fail;
  int detailCalls = 0;

  @override
  Future<TicketDetail> detail(String reference) async {
    detailCalls++;
    if (fail) {
      throw const TicketFailure(
        TicketFailureKind.notFound,
        'التذكرة غير متاحة.',
      );
    }
    return TicketDetail(
      reference: reference,
      title: 'تذكرة اختبار',
      status: 'assigned',
      priority: 'medium',
      department: const TicketOption(1, 'الصيانة'),
      category: const TicketOption(1, 'عام'),
      createdAt: DateTime.utc(2026),
      description: 'الوصف',
      location: 'الموقع',
      photos: const [],
      updatedAt: DateTime.utc(2026),
    );
  }

  @override
  Future<List<TicketOption>> departments() => throw UnimplementedError();
  @override
  Future<List<TicketOption>> categories(int departmentId) =>
      throw UnimplementedError();
  @override
  Future<TicketDetail> create(CreateTicketInput input) =>
      throw UnimplementedError();
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
}

class _NotificationRepository implements NotificationRepository {
  _NotificationRepository({
    String target = 'reporter.ticket',
    Map<String, dynamic> payload = const {'ticket_reference': 'TKT-1'},
  }) : item = AppNotification(
         id: 1,
         type: 'ticket.event',
         title: 'تحديث جديد',
         message: 'يوجد تحديث جديد.',
         relatedEntityType: 'ticket',
         relatedEntityId: 1,
         navigationTarget: target,
         payload: payload,
         createdAt: DateTime.utc(2026, 8, 1),
       );

  AppNotification item;

  @override
  Future<List<AppNotification>> list() async => [item];
  @override
  Future<int> unreadCount() async => item.isRead ? 0 : 1;
  @override
  Future<AppNotification> markRead(int id) async {
    item = item.copyWith(readAt: DateTime.utc(2026, 8, 1));
    return item;
  }

  @override
  Future<int> markAllRead() async {
    item = item.copyWith(readAt: DateTime.utc(2026, 8, 1));
    return 1;
  }
}

class _AdminTicketRepository implements AdminTicketRepository {
  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) async =>
      const AdminTicketPage([], currentPage: 1, lastPage: 1, total: 0);
  @override
  Future<List<TechnicianOption>> technicians() async => const [];
  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) =>
      throw UnimplementedError();
}

class _AccountRequestRepository implements AccountRequestRepository {
  int listCalls = 0;
  @override
  Future<List<AccountRequest>> list(AccountRequestStatus status) async {
    listCalls++;
    return [];
  }

  @override
  Future<AccountRequest> approve(int id) => throw UnimplementedError();
  @override
  Future<AccountRequest> reject(int id, {String? reason}) =>
      throw UnimplementedError();
}

class _TechnicianTicketRepository implements TechnicianTicketRepository {
  int detailCalls = 0;

  @override
  Future<TechnicianTicket> details(String reference) async {
    detailCalls++;
    return TechnicianTicket(
      reference: reference,
      title: 'تذكرة فني',
      priority: 'high',
      department: const TicketOption(1, 'الصيانة'),
      category: const TicketOption(1, 'عام'),
      status: 'assigned',
      createdAt: DateTime.utc(2026),
      description: 'الوصف',
      location: 'الموقع',
      photos: const [],
      assignedTechnician: const UserSummary(1, 'فني'),
      history: const [],
      updatedAt: DateTime.utc(2026),
    );
  }

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
