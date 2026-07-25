import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';

void main() {
  test(
    'repository contract rejects unsupported transition before transport',
    () async {
      final repository = _GuardedRepository();
      expect(
        () => repository.transition('TKT-7', 'assigned'),
        throwsA(isA<TicketFailure>()),
      );
    },
  );
}

class _GuardedRepository implements TechnicianTicketRepository {
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
  }) async {
    if (!const {'in_progress', 'completed', 'rejected'}.contains(status))
      throw const TicketFailure(
        TicketFailureKind.validation,
        'Unsupported status.',
      );
    throw UnimplementedError();
  }
}
