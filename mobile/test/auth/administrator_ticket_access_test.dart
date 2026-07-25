import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/profile_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/state/admin_ticket_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../tickets/admin_ticket_list_test.dart' show FakeAdminRepo;

void main() {
  testWidgets('only administrator profile exposes the all tickets entry', (
    tester,
  ) async {
    final admin = AuthController(RoleRepository('administrator'));
    await admin.restore();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          controller: admin,
          adminTicketRepository: FakeAdminRepo(),
        ),
      ),
    );
    expect(find.byKey(const Key('admin_tickets')), findsOneWidget);
    expect(find.byKey(const Key('rating_submit')), findsNothing);

    final reporter = AuthController(RoleRepository('reporter'));
    await reporter.restore();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          controller: reporter,
          adminTicketRepository: FakeAdminRepo(),
        ),
      ),
    );
    expect(find.byKey(const Key('admin_tickets')), findsNothing);
  });

  test('administrator list clears cached rows when access is denied', () async {
    final repo = FakeAdminRepo();
    final controller = AdminTicketListController(repo);
    await controller.load();
    expect(controller.tickets, isNotEmpty);
    repo.failure = const TicketFailure(
      TicketFailureKind.unauthorized,
      'Denied',
    );
    await controller.load();
    expect(controller.tickets, isEmpty);
    expect(controller.state.status, AdminTicketListStatus.unauthorized);
  });
}

class RoleRepository implements AuthRepository {
  RoleRepository(this.role);
  final String role;
  UserProfile get value => UserProfile(
    id: 1,
    name: role,
    email: '$role@example.com',
    role: role,
    isActive: true,
    createdAt: DateTime.utc(2026),
  );
  @override
  Future<UserProfile?> restore() async => value;
  @override
  Future<UserProfile> profile() async => value;
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async => value;
  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async => value;
}
