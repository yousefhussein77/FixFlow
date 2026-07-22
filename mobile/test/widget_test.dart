import 'package:fixflow/app.dart';
import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the signed-out FixFlow authentication entry point', (
    tester,
  ) async {
    await tester.pumpWidget(
      FixFlowApp(controller: AuthController(EmptyRepository())),
    );
    expect(find.text('Sign in to FixFlow'), findsOneWidget);
    expect(find.text('Create a reporter account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class EmptyRepository implements AuthRepository {
  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfile> profile() => throw UnimplementedError();
  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => throw UnimplementedError();
  @override
  Future<UserProfile?> restore() async => null;
}
