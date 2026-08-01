import 'dart:async';

import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/register_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registration transitions from loading to pending approval', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);
    final states = <AuthViewStatus>[];
    controller.addListener(() => states.add(controller.state.status));

    await controller.register(
      name: 'Reporter',
      email: 'reporter@example.com',
      password: 'Password1234',
      passwordConfirmation: 'Password1234',
    );

    expect(states, [
      AuthViewStatus.loading,
      AuthViewStatus.registrationPending,
    ]);
    expect(controller.state.profile?.role, 'reporter');
    expect(
      controller.state.message,
      'تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.',
    );
  });

  test('registration exposes field validation errors', () async {
    final controller = AuthController(
      FakeAuthRepository(
        failure: const AuthFailure(
          AuthFailureKind.validation,
          'Invalid data.',
          fieldErrors: {
            'email': ['The email has already been taken.'],
          },
        ),
      ),
    );

    await controller.register(
      name: 'Reporter',
      email: 'used@example.com',
      password: 'Password1234',
      passwordConfirmation: 'Password1234',
    );

    expect(controller.state.status, AuthViewStatus.validationError);
    expect(controller.state.fieldErrors['email'], isNotEmpty);
  });

  test('successful retry clears prior validation and form errors', () async {
    final repository = FakeAuthRepository(
      failure: const AuthFailure(
        AuthFailureKind.validation,
        'تحقق من البيانات المدخلة ثم حاول مجددًا.',
        fieldErrors: {
          'email': ['يوجد حساب مسجل بهذا البريد الإلكتروني.'],
        },
      ),
    );
    final controller = AuthController(repository);

    await controller.register(
      name: 'Reporter',
      email: 'used@example.com',
      password: 'Password1234',
      passwordConfirmation: 'Password1234',
    );
    expect(controller.state.fieldErrors, isNotEmpty);
    expect(controller.state.message, isNotNull);

    repository.failure = null;
    await controller.register(
      name: 'Reporter',
      email: 'new@example.com',
      password: 'Password1234',
      passwordConfirmation: 'Password1234',
    );

    expect(controller.state.status, AuthViewStatus.registrationPending);
    expect(controller.state.fieldErrors, isEmpty);
    expect(
      controller.state.message,
      'تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.',
    );
  });

  test(
    'registration validates name email password confirmation and role locally',
    () async {
      final repository = FakeAuthRepository();
      final controller = AuthController(repository);

      await controller.register(
        name: '12345',
        email: 'invalid',
        password: 'weak',
        passwordConfirmation: 'different',
        role: 'administrator',
      );

      expect(controller.state.status, AuthViewStatus.validationError);
      expect(controller.state.fieldErrors.keys, {
        'name',
        'email',
        'password',
        'password_confirmation',
        'role',
      });
      expect(repository.registerCalls, 0);
    },
  );

  testWidgets(
    'registration screen disables duplicate submission while loading',
    (tester) async {
      final repository = FakeAuthRepository(wait: true);
      final controller = AuthController(repository);
      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(controller: controller)),
      );

      await tester.enterText(
        find.byKey(const Key('register_name')),
        'Reporter',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'reporter@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'Password1234',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirmation')),
        'Password1234',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('register_submit')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pump();

      expect(controller.state.status, AuthViewStatus.loading);
      expect(controller.state.isLoading, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('register_submit')),
      );
      expect(button.onPressed, isNull);
      expect(repository.registerCalls, 1);
    },
  );

  testWidgets('successful registration resets every field and shows success', (
    tester,
  ) async {
    final controller = AuthController(FakeAuthRepository());
    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(controller: controller)),
    );

    await tester.enterText(find.byKey(const Key('register_name')), 'Reporter');
    await tester.enterText(
      find.byKey(const Key('register_email')),
      'reporter@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'Password1234',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirmation')),
      'Password1234',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('register_role')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('register_role')),
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('فني').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('register_submit')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('register_success')), findsOneWidget);
    expect(find.byKey(const Key('register_error')), findsNothing);
    expect(controller.state.fieldErrors, isEmpty);
    for (final key in const [
      Key('register_name'),
      Key('register_email'),
      Key('register_password'),
      Key('register_confirmation'),
    ]) {
      expect(
        tester.widget<TextField>(find.byKey(key)).controller?.text,
        isEmpty,
      );
    }
    expect(find.text('مُبلّغ'), findsOneWidget);
  });

  testWidgets('server failure preserves entered registration values', (
    tester,
  ) async {
    final controller = AuthController(
      FakeAuthRepository(
        failure: const AuthFailure(
          AuthFailureKind.server,
          'تعذر إرسال الطلب. حاول مرة أخرى.',
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(controller: controller)),
    );

    final values = <Key, String>{
      const Key('register_name'): 'Reporter',
      const Key('register_email'): 'reporter@example.com',
      const Key('register_password'): 'Password1234',
      const Key('register_confirmation'): 'Password1234',
    };
    for (final entry in values.entries) {
      await tester.enterText(find.byKey(entry.key), entry.value);
    }
    await tester.scrollUntilVisible(
      find.byKey(const Key('register_submit')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register_error')), findsOneWidget);
    for (final entry in values.entries) {
      final field = tester.widget<TextField>(find.byKey(entry.key));
      expect(field.controller?.text, entry.value);
      expect(field.enabled, isTrue);
      expect(field.readOnly, isFalse);
    }
  });

  testWidgets(
    'invalid registration fields remain editable and clear while editing',
    (tester) async {
      final controller = AuthController(
        FakeAuthRepository(
          failure: const AuthFailure(
            AuthFailureKind.validation,
            'تحقق من البيانات المدخلة ثم حاول مجدداً.',
            fieldErrors: {
              'email': ['تحقق من عنوان البريد الإلكتروني.'],
              'password': ['تحقق من كلمة المرور.'],
              'password_confirmation': ['تأكد من تطابق كلمتي المرور.'],
            },
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(controller: controller)),
      );
      await tester.enterText(
        find.byKey(const Key('register_name')),
        'Reporter',
      );
      await tester.enterText(
        find.byKey(const Key('register_email')),
        'invalid-email',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'short',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirmation')),
        'different',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('register_submit')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('register_submit')));
      await tester.pumpAndSettle();

      for (final key in const [
        Key('register_email'),
        Key('register_password'),
        Key('register_confirmation'),
      ]) {
        final field = tester.widget<TextField>(find.byKey(key));
        expect(field.enabled, isTrue);
        expect(field.readOnly, isFalse);
        expect(field.decoration?.errorText, isNotNull);
      }

      await tester.enterText(
        find.byKey(const Key('register_email')),
        'reporter@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password')),
        'Password1234',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirmation')),
        'Password1234',
      );
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('register_name')))
            .controller
            ?.text,
        'Reporter',
      );
      for (final key in const [
        Key('register_email'),
        Key('register_password'),
        Key('register_confirmation'),
      ]) {
        expect(
          tester.widget<TextField>(find.byKey(key)).decoration?.errorText,
          isNull,
        );
      }
      expect(find.byKey(const Key('register_error')), findsNothing);
    },
  );

  testWidgets('registration remains scrollable with RTL and large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = AuthController(FakeAuthRepository());
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: RegisterScreen(controller: controller),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('register_name')), findsOneWidget);
    expect(find.byTooltip('إظهار كلمة المرور'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.byKey(const Key('register_submit')).first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure, this.wait = false});

  AuthFailure? failure;
  final bool wait;
  int registerCalls = 0;

  static final profileValue = UserProfile(
    id: 1,
    name: 'Reporter',
    email: 'reporter@example.com',
    role: 'reporter',
    isActive: true,
    createdAt: DateTime.utc(2026),
  );

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) async {
    registerCalls++;
    if (wait) return Completer<UserProfile>().future;
    if (failure != null) throw failure!;
    return profileValue;
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async => profileValue;
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfile> profile() async => profileValue;
  @override
  Future<UserProfile?> restore() async => null;
}
