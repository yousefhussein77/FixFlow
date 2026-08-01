import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/screens/register_screen.dart';
import 'package:fixflow/auth/screens/sign_in_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/design_system/brand/fixflow_logo.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign in and registration use the approved mark bitmap', (
    tester,
  ) async {
    final controller = AuthController(_Repository());
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: SignInScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(_assetNames(tester), contains('assets/brand/fixflow_logo_mark.png'));
    final signInLogo = tester.widget<Image>(find.byType(Image).first);
    expect(signInLogo.width, 180);
    expect(signInLogo.height, 180);
    expect(find.byType(FixFlowLogo), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.dark(),
        home: RegisterScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(_assetNames(tester), contains('assets/brand/fixflow_logo_mark.png'));
    final registrationLogo = tester.widget<Image>(find.byType(Image).first);
    expect(registrationLogo.width, 180);
    expect(registrationLogo.height, 180);
    expect(find.byType(FixFlowLogo), findsNothing);
  });

  testWidgets('mark remains unmirrored and fits narrow RTL at 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SignInScreen(controller: AuthController(_Repository())),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image).first);
    expect(image.fit, BoxFit.contain);
    expect(image.filterQuality, FilterQuality.high);
    expect(image.isAntiAlias, isTrue);
    expect(
      (image.image as AssetImage).assetName,
      'assets/brand/fixflow_logo_mark.png',
    );
    expect(tester.takeException(), isNull);
  });
}

Set<String> _assetNames(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map((image) => image.image)
    .whereType<AssetImage>()
    .map((image) => image.assetName)
    .toSet();

class _Repository implements AuthRepository {
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
  }) => Future.value(profileValue);

  @override
  Future<UserProfile?> restore() => Future.value(profileValue);

  @override
  Future<void> logout() async {}

  @override
  Future<UserProfile> profile() => Future.value(profileValue);

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) => Future.value(profileValue);
}
