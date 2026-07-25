import 'dart:async';

import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/session_gate.dart';
import 'package:fixflow/auth/screens/sign_in_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'sign in maps generic credential rejection to unauthenticated',
    () async {
      final controller = AuthController(
        RestoreRepository(
          failure: const AuthFailure(
            AuthFailureKind.unauthenticated,
            'The provided credentials are invalid.',
          ),
        ),
      );
      await controller.login(email: 'x@example.com', password: 'wrong');
      expect(controller.state.status, AuthViewStatus.unauthenticated);
    },
  );

  test('valid stored session restores profile', () async {
    final controller = AuthController(RestoreRepository());
    await controller.restore();
    expect(controller.state.status, AuthViewStatus.authenticated);
    expect(controller.state.profile?.email, 'reporter@example.com');
  });

  test('late restoration cannot replace a signed-out generation', () async {
    final completer = Completer<UserProfile?>();
    final controller = AuthController(
      RestoreRepository(restore: completer.future),
    );
    final restore = controller.restore();
    await controller.logout();
    completer.complete(RestoreRepository.profileValue);
    await restore;
    expect(controller.state.status, AuthViewStatus.signedOut);
  });

  testWidgets('session gate displays recoverable offline restoration state', (
    tester,
  ) async {
    final controller = AuthController(
      RestoreRepository(
        failure: const AuthFailure(AuthFailureKind.offline, 'Offline.'),
      ),
    );
    await controller.restore();
    await tester.pumpWidget(
      MaterialApp(home: SessionGate(controller: controller)),
    );
    expect(find.text('Offline.'), findsOneWidget);
    expect(find.byKey(const Key('session_retry')), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'sign in is accessible at 200% text in ${brightness.name} ${direction.name}',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 640));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final controller = AuthController(RestoreRepository());
          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: MaterialApp(
                theme: FixFlowTheme.light(),
                darkTheme: FixFlowTheme.dark(),
                themeMode: brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: Directionality(
                  textDirection: direction,
                  child: SignInScreen(controller: controller),
                ),
              ),
            ),
          );
          await tester.enterText(
            find.byKey(const Key('login_password')),
            'Password1234',
          );
          await tester.scrollUntilVisible(
            find.byTooltip('Show password'),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.byTooltip('Show password'));
          await tester.pump();
          expect(find.text('Password1234'), findsOneWidget);
          expect(find.text('FixFlow'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class RestoreRepository implements AuthRepository {
  RestoreRepository({this.failure, Future<UserProfile?>? restore})
    : _restore = restore;
  final AuthFailure? failure;
  final Future<UserProfile?>? _restore;

  static final profileValue = UserProfile(
    id: 1,
    name: 'Reporter',
    email: 'reporter@example.com',
    role: 'reporter',
    isActive: true,
    createdAt: DateTime.utc(2026),
  );

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    if (failure != null) throw failure!;
    return profileValue;
  }

  @override
  Future<UserProfile?> restore() async {
    if (_restore != null) return _restore;
    if (failure != null) throw failure!;
    return profileValue;
  }

  @override
  Future<void> logout() async {}
  @override
  Future<UserProfile> profile() async => profileValue;
  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async => profileValue;
}
