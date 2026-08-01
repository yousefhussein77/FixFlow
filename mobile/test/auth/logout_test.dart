import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final failure in <AuthFailure?>[
    null,
    const AuthFailure(AuthFailureKind.offline, 'Offline.'),
    const AuthFailure(AuthFailureKind.server, 'Server error.'),
    const AuthFailure(
      AuthFailureKind.unauthenticated,
      'Authentication required.',
    ),
  ]) {
    test('logout ends signed out for ${failure?.kind ?? 'success'}', () async {
      final controller = AuthController(LogoutRepository(failure));
      await controller.restore();
      await controller.logout();
      expect(controller.state.status, AuthViewStatus.signedOut);
      expect(controller.state.profile, isNull);
    });
  }
}

class LogoutRepository implements AuthRepository {
  LogoutRepository(this.failure);
  final AuthFailure? failure;
  final value = UserProfile(
    id: 1,
    name: 'Reporter',
    email: 'reporter@example.com',
    role: 'reporter',
    isActive: true,
    createdAt: DateTime.utc(2026),
  );
  @override
  Future<void> logout() async {
    if (failure != null) throw failure!;
  }

  @override
  Future<UserProfile?> restore() async => value;
  @override
  Future<UserProfile> profile() async => value;
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
