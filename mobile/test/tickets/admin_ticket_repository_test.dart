import 'dart:convert';

import 'package:fixflow/auth/services/token_store.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/services/admin_ticket_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('admin ticket contract maps explicit null and assigned technician', () {
    final json = <String, dynamic>{
      'reference': 'TKT-ABCDEFGHIJKL',
      'title': 'Leak',
      'reporter': {'id': 1, 'name': 'Reporter'},
      'priority': 'high',
      'department': {'id': 2, 'name': 'Facilities'},
      'category': {'id': 3, 'name': 'Plumbing'},
      'status': 'new',
      'assigned_technician': null,
      'created_at': '2026-07-23T00:00:00Z',
    };
    final ticket = AdminTicketSummary.fromJson(json);
    expect(ticket.assignedTechnician, isNull);
    expect(ticket.canAssign, isTrue);
    final assigned = AdminTicketSummary.fromJson({
      ...json,
      'status': 'assigned',
      'assigned_technician': {'id': 4, 'name': 'Tech'},
    });
    expect(assigned.assignedTechnician?.name, 'Tech');
    expect(assigned.canAssign, isFalse);
  });

  test('maps malformed successful list payload to contract failure', () async {
    final repository = AdminTicketRepositoryImpl(
      AdminTicketApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'message': 'ok',
              'data': [
                {'reference': 7},
              ],
              'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
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
      repository.list(),
      throwsA(
        isA<TicketFailure>().having(
          (failure) => failure.kind,
          'kind',
          TicketFailureKind.contract,
        ),
      ),
    );
  });
}

class _TokenStore implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}
