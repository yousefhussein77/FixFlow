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

  for (final scenario in [
    (
      AuthFailureKind.pending,
      AuthViewStatus.accountPending,
      'طلب إنشاء الحساب قيد مراجعة الإدارة.',
    ),
    (
      AuthFailureKind.rejected,
      AuthViewStatus.accountRejected,
      'تم رفض طلب إنشاء الحساب. يمكنك التواصل مع الإدارة للمزيد من المعلومات.',
    ),
    (
      AuthFailureKind.inactive,
      AuthViewStatus.accountInactive,
      'هذا الحساب غير نشط. يرجى التواصل مع الإدارة.',
    ),
  ]) {
    testWidgets('${scenario.$2.name} remains on editable sign-in form', (
      tester,
    ) async {
      final controller = AuthController(
        RestoreRepository(failure: AuthFailure(scenario.$1, scenario.$3)),
      );
      await tester.pumpWidget(
        MaterialApp(home: SignInScreen(controller: controller)),
      );
      await tester.enterText(
        find.byKey(const Key('login_email')),
        'user@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password')),
        'StrongPassword123',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('login_submit')),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pumpAndSettle();

      expect(controller.state.status, scenario.$2);
      expect(find.text(scenario.$3), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byKey(const Key('login_email'))).enabled,
        isTrue,
      );
    });
  }

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
    expect(
      find.text('تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.text('Offline.'), findsNothing);
    expect(find.byKey(const Key('session_retry')), findsOneWidget);
  });

  testWidgets('failed sign in keeps fields editable and clears its error', (
    tester,
  ) async {
    final controller = AuthController(
      RestoreRepository(
        failure: const AuthFailure(
          AuthFailureKind.unauthenticated,
          'بيانات الدخول غير صحيحة أو انتهت الجلسة.',
          fieldErrors: {
            'email': ['تحقق من عنوان البريد الإلكتروني.'],
            'password': ['تحقق من كلمة المرور.'],
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'invalid-email',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'bad');
    await tester.scrollUntilVisible(
      find.byKey(const Key('login_submit')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    final emailBeforeEdit = tester.widget<TextField>(
      find.byKey(const Key('login_email')),
    );
    final passwordBeforeEdit = tester.widget<TextField>(
      find.byKey(const Key('login_password')),
    );
    expect(emailBeforeEdit.enabled, isTrue);
    expect(emailBeforeEdit.readOnly, isFalse);
    expect(passwordBeforeEdit.enabled, isTrue);
    expect(passwordBeforeEdit.readOnly, isFalse);
    expect(emailBeforeEdit.decoration?.errorText, isNotNull);
    expect(passwordBeforeEdit.decoration?.errorText, isNull);

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'reporter@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'Password1234',
    );
    await tester.pump();

    final emailAfterEdit = tester.widget<TextField>(
      find.byKey(const Key('login_email')),
    );
    final passwordAfterEdit = tester.widget<TextField>(
      find.byKey(const Key('login_password')),
    );
    expect(emailAfterEdit.controller?.text, 'reporter@example.com');
    expect(passwordAfterEdit.controller?.text, 'Password1234');
    expect(emailAfterEdit.decoration?.errorText, isNull);
    expect(passwordAfterEdit.decoration?.errorText, isNull);
    expect(find.byKey(const Key('login_error')), findsNothing);
  });

  testWidgets('server failure during sign in does not replace the form', (
    tester,
  ) async {
    final controller = AuthController(
      RestoreRepository(
        failure: const AuthFailure(
          AuthFailureKind.server,
          'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: SessionGate(controller: controller)),
    );
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'reporter@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      'Password1234',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('login_submit')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byKey(const Key('session_retry')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'updated@example.com',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('login_email')))
          .controller
          ?.text,
      'updated@example.com',
    );
    expect(find.byKey(const Key('login_error')), findsNothing);
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
            find.byTooltip('إظهار كلمة المرور'),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.byTooltip('إظهار كلمة المرور'));
          await tester.pump();
          expect(find.text('Password1234'), findsOneWidget);
          expect(find.bySemanticsLabel('FixFlow'), findsOneWidget);
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
    String role = 'reporter',
  }) async => profileValue;
}
