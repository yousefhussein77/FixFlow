import 'dart:convert';

import 'package:fixflow/auth/services/token_store.dart';
import 'package:fixflow/notifications/models/notification_models.dart';
import 'package:fixflow/notifications/repositories/notification_repository.dart';
import 'package:fixflow/notifications/services/notification_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses list, unread count, read and read-all contracts', () async {
    final requests = <String>[];
    final api = NotificationApiService(
      Uri.parse('https://fixflow.test'),
      client: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        final data = switch (request.url.path) {
          '/api/notifications' => [_json(1)],
          '/api/notifications/unread-count' => {'unread_count': 1},
          '/api/notifications/1/read' => _json(
            1,
            readAt: '2026-08-01T10:00:00Z',
          ),
          '/api/notifications/read-all' => {'updated_count': 1},
          _ => throw StateError('Unexpected path'),
        };
        return http.Response(
          jsonEncode({'success': true, 'data': data}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final repository = NotificationRepositoryImpl(api, _TokenStore());

    expect((await repository.list()).single.title, 'تذكرة جديدة');
    expect(await repository.unreadCount(), 1);
    expect((await repository.markRead(1)).isRead, isTrue);
    expect(await repository.markAllRead(), 1);
    expect(requests, [
      'GET /api/notifications',
      'GET /api/notifications/unread-count',
      'PATCH /api/notifications/1/read',
      'PATCH /api/notifications/read-all',
    ]);
  });

  test('maps malformed success and authorization failures safely', () async {
    final malformed = NotificationRepositoryImpl(
      NotificationApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'success': true, 'data': 'invalid'}),
            200,
          ),
        ),
      ),
      _TokenStore(),
    );
    await expectLater(
      malformed.list(),
      throwsA(
        isA<NotificationFailure>().having(
          (failure) => failure.kind,
          'kind',
          NotificationFailureKind.contract,
        ),
      ),
    );

    final forbidden = NotificationRepositoryImpl(
      NotificationApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(jsonEncode({'success': false}), 403),
        ),
      ),
      _TokenStore(),
    );
    await expectLater(
      forbidden.unreadCount(),
      throwsA(
        isA<NotificationFailure>().having(
          (failure) => failure.kind,
          'kind',
          NotificationFailureKind.unauthorized,
        ),
      ),
    );
  });
}

Map<String, dynamic> _json(int id, {String? readAt}) => {
  'id': id,
  'type': 'ticket.created',
  'title': 'تذكرة جديدة',
  'message': 'تم إنشاء تذكرة جديدة.',
  'related_entity_type': 'ticket',
  'related_entity_id': 7,
  'navigation_target': 'admin.tickets',
  'payload': {'ticket_reference': 'TKT-1'},
  'read_at': readAt,
  'created_at': '2026-08-01T09:00:00Z',
};

class _TokenStore implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> clear() async {}
  @override
  Future<void> write(String token) async {}
}
