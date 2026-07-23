import 'package:flutter/widgets.dart';

import 'app.dart';
import 'auth/repositories/auth_repository.dart';
import 'auth/services/auth_api_service.dart';
import 'auth/services/token_store.dart';
import 'auth/state/auth_controller.dart';
import 'reference_data/repositories/reference_repository.dart';
import 'reference_data/services/reference_api_service.dart';
import 'reference_data/state/reference_controller.dart';
import 'tickets/repositories/ticket_repository.dart';
import 'tickets/services/ticket_api_service.dart';
import 'tickets/services/ticket_photo_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const apiUrl = String.fromEnvironment(
    'FIXFLOW_API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  final tokenStore = SecureTokenStore();
  final repository = AuthRepositoryImpl(
    api: AuthApiService(baseUri: Uri.parse(apiUrl)),
    tokenStore: tokenStore,
  );
  runApp(
    FixFlowApp(
      controller: AuthController(repository, restoreOnCreate: true),
      referenceController: ReferenceController(
        ReferenceRepositoryImpl(
          ReferenceApiService(Uri.parse(apiUrl)),
          tokenStore,
        ),
      ),
      ticketRepository: TicketRepositoryImpl(
        TicketApiService(Uri.parse(apiUrl)),
        tokenStore,
      ),
      ticketPhotoPicker: const TicketPhotoPicker(),
    ),
  );
}
