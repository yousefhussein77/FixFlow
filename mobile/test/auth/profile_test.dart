import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/profile_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unauthorized profile refresh clears profile state', () async {
    final controller = AuthController(ProfileRepository());
    await controller.restore();
    await controller.refreshProfile();
    expect(controller.state.status, AuthViewStatus.unauthenticated);
    expect(controller.state.profile, isNull);
  });

  testWidgets('profile renders only safe identity fields', (tester) async {
    final controller = AuthController(ProfileRepository(allowProfile: true));
    await controller.restore();
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(controller: controller)),
    );
    expect(find.text('Reporter'), findsOneWidget);
    expect(find.text('reporter@example.com'), findsOneWidget);
    expect(find.text('مُبلّغ'), findsOneWidget);
    expect(find.textContaining('token'), findsNothing);
    expect(find.textContaining('password'), findsNothing);
  });

  testWidgets(
    'reporter profile exposes only reporter destinations and logout',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AuthController(ProfileRepository(allowProfile: true));
      await controller.restore();
      await tester.pumpWidget(
        MaterialApp(
          theme: FixFlowTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: ProfileScreen(
              controller: controller,
              ticketRepository: _TicketRepository(),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('create_ticket')), findsOneWidget);
      expect(find.byKey(const Key('my_tickets')), findsOneWidget);
      expect(find.byKey(const Key('admin_tickets')), findsNothing);
      expect(find.byKey(const Key('assigned_tickets')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('logout_submit')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.getSemantics(find.byKey(const Key('logout_submit'))).label,
        contains('تسجيل الخروج'),
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class _TicketRepository implements TicketRepository {
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
  @override
  Future<TicketDetail> detail(String reference) => throw UnimplementedError();
}

class ProfileRepository implements AuthRepository {
  ProfileRepository({this.allowProfile = false});
  final bool allowProfile;
  final value = UserProfile(
    id: 1,
    name: 'Reporter',
    email: 'reporter@example.com',
    role: 'reporter',
    isActive: true,
    createdAt: DateTime.utc(2026),
  );
  @override
  Future<UserProfile> profile() async {
    if (!allowProfile)
      throw const AuthFailure(
        AuthFailureKind.unauthenticated,
        'Authentication required.',
      );
    return value;
  }

  @override
  Future<UserProfile?> restore() async => value;
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
    String role = 'reporter',
  }) async => value;
}
