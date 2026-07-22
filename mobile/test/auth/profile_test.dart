import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/profile_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
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
    expect(find.text('reporter'), findsOneWidget);
    expect(find.textContaining('token'), findsNothing);
    expect(find.textContaining('password'), findsNothing);
  });
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
  }) async => value;
}
