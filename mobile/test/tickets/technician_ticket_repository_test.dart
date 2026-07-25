import 'dart:convert';

import 'package:fixflow/auth/services/token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/tickets/models/technician_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/technician_ticket_repository.dart';
import 'package:fixflow/tickets/services/technician_ticket_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses technician detail including nullable history reason', () {
    final ticket = TechnicianTicket.fromJson(_ticketJson());
    expect(ticket.reference, 'TKT-7');
    expect(ticket.history.single.reason, isNull);
    expect(ticket.assignedTechnician.name, 'Tech');
  });

  test(
    'maps malformed successful detail payload to contract failure',
    () async {
      final repository = TechnicianTicketRepositoryImpl(
        TechnicianTicketApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': true,
                'message': 'ok',
                'data': {'reference': 7},
                'errors': null,
                'code': null,
              }),
              200,
            ),
          ),
        ),
        _TokenStore(),
      );

      await expectLater(
        repository.details('TKT-7'),
        throwsA(
          isA<TicketFailure>().having(
            (failure) => failure.kind,
            'kind',
            TicketFailureKind.contract,
          ),
        ),
      );
    },
  );
}

class _TokenStore implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}

Map<String, dynamic> _ticketJson({String status = 'assigned'}) => {
  'reference': 'TKT-7',
  'title': 'Leak',
  'priority': 'high',
  'department': {'id': 1, 'name': 'Facilities'},
  'category': {'id': 2, 'name': 'Plumbing'},
  'status': status,
  'created_at': '2026-07-23T10:00:00Z',
  'updated_at': '2026-07-23T10:00:00Z',
  'description': 'Pipe leak',
  'location': 'Floor 2',
  'photos': <dynamic>[],
  'assigned_technician': {'id': 3, 'name': 'Tech'},
  'status_history': [
    {
      'from_status': 'new',
      'to_status': 'assigned',
      'actor': {'id': 4, 'name': 'Admin'},
      'assigned_technician': {'id': 3, 'name': 'Tech'},
      'reason': null,
      'occurred_at': '2026-07-23T10:00:00Z',
    },
  ],
};
