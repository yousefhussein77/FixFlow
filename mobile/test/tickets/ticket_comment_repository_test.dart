import 'dart:convert';
import 'dart:io';
import 'package:fixflow/auth/services/token_store.dart';
import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_comment_repository.dart';
import 'package:fixflow/tickets/services/ticket_comment_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('uses explicit role paths and maps stable comment contract', () async {
    for (final entry in {
      TicketCommentContext.reporter: '/api/reporter/tickets/TKT-7/comments',
      TicketCommentContext.technician: '/api/technician/tickets/TKT-7/comments',
      TicketCommentContext.administrator: '/api/admin/tickets/TKT-7/comments',
    }.entries) {
      String? path;
      final repository = TicketCommentRepositoryImpl(
        TicketCommentApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient((request) async {
            path = request.url.path;
            return http.Response(
              jsonEncode({
                'success': true,
                'message': 'ok',
                'data': [
                  _comment(2, '2026-07-23T10:00:00Z'),
                  _comment(1, '2026-07-23T10:00:00Z'),
                ],
                'errors': null,
                'code': null,
              }),
              200,
            );
          }),
        ),
        _Store(),
      );
      final comments = await repository.list(entry.key, 'TKT-7');
      expect(path, entry.value);
      expect(comments.map((item) => item.id), [1, 2]);
    }
  });

  test('maps malformed success to contract failure', () async {
    final repository = TicketCommentRepositoryImpl(
      TicketCommentApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(jsonEncode({'data': 'bad'}), 200),
        ),
      ),
      _Store(),
    );
    await expectLater(
      repository.list(TicketCommentContext.reporter, 'TKT-7'),
      throwsA(
        isA<TicketFailure>().having(
          (e) => e.kind,
          'kind',
          TicketFailureKind.contract,
        ),
      ),
    );
  });

  for (final entry in {
    401: TicketFailureKind.unauthorized,
    403: TicketFailureKind.unauthorized,
    404: TicketFailureKind.notFound,
    422: TicketFailureKind.validation,
    500: TicketFailureKind.server,
  }.entries) {
    test('maps comment HTTP ${entry.key} to ${entry.value}', () async {
      final repository = TicketCommentRepositoryImpl(
        TicketCommentApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': false,
                'message': 'failed',
                'data': null,
                'errors': entry.key == 422
                    ? {
                        'content': ['invalid'],
                      }
                    : null,
                'code': 'ERROR',
              }),
              entry.key,
            ),
          ),
        ),
        _Store(),
      );
      await expectLater(
        repository.list(TicketCommentContext.administrator, 'TKT-7'),
        throwsA(
          isA<TicketFailure>().having(
            (failure) => failure.kind,
            'kind',
            entry.value,
          ),
        ),
      );
    });
  }

  test('maps comment socket failures to offline', () async {
    final repository = TicketCommentRepositoryImpl(
      TicketCommentApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient((_) async => throw const SocketException('offline')),
      ),
      _Store(),
    );
    await expectLater(
      repository.list(TicketCommentContext.reporter, 'TKT-7'),
      throwsA(
        isA<TicketFailure>().having(
          (failure) => failure.kind,
          'kind',
          TicketFailureKind.offline,
        ),
      ),
    );
  });
}

Map<String, dynamic> _comment(int id, String time) => {
  'id': id,
  'content': '<b>plain</b>',
  'author': {'id': 1, 'name': 'User', 'role': 'reporter'},
  'created_at': time,
};

class _Store implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}
