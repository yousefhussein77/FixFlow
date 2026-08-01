import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/profile_screen.dart';
import 'package:fixflow/auth/screens/sign_in_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/design_system_test_host.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('authentication ${brightness.name} ${direction.name}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final controller = AuthController(_GoldenAuthRepository('reporter'));
        await tester.pumpWidget(
          designSystemHost(
            SignInScreen(controller: controller),
            brightness: brightness,
            direction: direction,
          ),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/auth_profile/sign_in_${brightness.name}_${direction.name}.png',
          ),
        );
      });
    }
  }

  for (final role in ['reporter', 'administrator', 'technician']) {
    testWidgets('$role profile identity', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AuthController(_GoldenAuthRepository(role));
      await controller.restore();
      await tester.pumpWidget(
        designSystemHost(ProfileScreen(controller: controller)),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/auth_profile/profile_$role.png'),
      );
    });
  }
}

class _GoldenAuthRepository implements AuthRepository {
  _GoldenAuthRepository(this.role);

  final String role;

  UserProfile get profileValue => UserProfile(
    id: 1,
    name: role == 'administrator'
        ? 'Alex Administrator'
        : role == 'technician'
        ? 'Taylor Technician'
        : 'Riley Reporter',
    email: '$role@example.com',
    role: role,
    isActive: true,
    createdAt: DateTime.utc(2026),
  );

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
