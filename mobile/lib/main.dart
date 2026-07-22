import 'package:flutter/widgets.dart';

import 'app.dart';
import 'auth/repositories/auth_repository.dart';
import 'auth/services/auth_api_service.dart';
import 'auth/services/token_store.dart';
import 'auth/state/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const apiUrl = String.fromEnvironment(
    'FIXFLOW_API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  final repository = AuthRepositoryImpl(
    api: AuthApiService(baseUri: Uri.parse(apiUrl)),
    tokenStore: SecureTokenStore(),
  );
  runApp(
    FixFlowApp(controller: AuthController(repository, restoreOnCreate: true)),
  );
}
