import 'dart:convert';
import 'dart:io';
import 'package:fixflow/auth/services/token_store.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_rating_repository.dart';
import 'package:fixflow/tickets/services/ticket_rating_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('posts reporter rating and parses authoritative response', () async {
    http.Request? seen;
    final repository = TicketRatingRepositoryImpl(
      TicketRatingApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient((request) async {
          seen = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'value': 5, 'rated_at': '2026-07-25T10:00:00Z'},
            }),
            201,
          );
        }),
      ),
      _Store(),
    );
    final rating = await repository.create(
      'TKT-9',
      rating: 5,
      submissionToken: '11111111-1111-4111-8111-111111111111',
    );
    expect(seen!.url.path, '/api/reporter/tickets/TKT-9/rating');
    expect(jsonDecode(seen!.body)['rating'], 5);
    expect(rating.value, 5);
  });

  test('malformed success maps to contract failure', () async {
    final repository = TicketRatingRepositoryImpl(
      TicketRatingApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'data': {'value': 8, 'rated_at': 'bad'},
            }),
            200,
          ),
        ),
      ),
      _Store(),
    );
    await expectLater(
      repository.create('T', rating: 5, submissionToken: 'token'),
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
    409: TicketFailureKind.conflict,
    422: TicketFailureKind.validation,
    500: TicketFailureKind.server,
  }.entries) {
    test('maps HTTP ${entry.key} to ${entry.value}', () async {
      final repository = TicketRatingRepositoryImpl(
        TicketRatingApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': false,
                'message': 'failed',
                'data': null,
                'errors': entry.key == 422
                    ? {
                        'rating': ['bad'],
                      }
                    : null,
                'code': entry.key == 409 ? 'RATING_ALREADY_EXISTS' : 'ERROR',
              }),
              entry.key,
            ),
          ),
        ),
        _Store(),
      );
      await expectLater(
        repository.create('T', rating: 5, submissionToken: 'token'),
        throwsA(
          isA<TicketFailure>().having((e) => e.kind, 'kind', entry.value),
        ),
      );
    });
  }

  test('maps socket failure to offline', () async {
    final repository = TicketRatingRepositoryImpl(
      TicketRatingApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient((_) async => throw const SocketException('offline')),
      ),
      _Store(),
    );
    await expectLater(
      repository.create('T', rating: 5, submissionToken: 'token'),
      throwsA(
        isA<TicketFailure>().having(
          (e) => e.kind,
          'kind',
          TicketFailureKind.offline,
        ),
      ),
    );
  });

  test('preserves backend rating conflict codes', () async {
    for (final code in ['RATING_ALREADY_EXISTS', 'TICKET_NOT_COMPLETED']) {
      final repository = TicketRatingRepositoryImpl(
        TicketRatingApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': false,
                'message': 'conflict',
                'data': null,
                'errors': null,
                'code': code,
              }),
              409,
            ),
          ),
        ),
        _Store(),
      );
      await expectLater(
        repository.create('T', rating: 5, submissionToken: 'token'),
        throwsA(
          isA<TicketFailure>().having((failure) => failure.code, 'code', code),
        ),
      );
    }
  });

  test('malformed error payload maps to contract failure', () async {
    final repository = TicketRatingRepositoryImpl(
      TicketRatingApiService(
        Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'message': <String>['not a string'],
            }),
            403,
          ),
        ),
      ),
      _Store(),
    );
    await expectLater(
      repository.create('T', rating: 5, submissionToken: 'token'),
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

class _Store implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}
