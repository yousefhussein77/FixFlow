import 'package:fixflow/auth/screens/profile_screen.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'administrator_ticket_access_test.dart' show RoleRepository;

void main() {
  testWidgets('only technician profile exposes assigned tickets', (
    tester,
  ) async {
    final repository = _Repository();
    for (final role in ['technician', 'reporter', 'administrator']) {
      final controller = AuthController(RoleRepository(role));
      await controller.restore();
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            controller: controller,
            technicianTicketRepository: repository,
          ),
        ),
      );
      expect(
        find.byKey(const Key('assigned_tickets')),
        role == 'technician' ? findsOneWidget : findsNothing,
      );
      expect(find.byKey(const Key('rating_submit')), findsNothing);
    }
  });
}

class _Repository implements TechnicianTicketRepository {
  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> details(String reference) =>
      throw UnimplementedError();
  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) => throw UnimplementedError();
}
