import 'dart:convert';

import 'package:fixflow/accounts/models/account_request_models.dart';
import 'package:fixflow/accounts/repositories/account_request_repository.dart';
import 'package:fixflow/accounts/services/account_request_api_service.dart';
import 'package:fixflow/auth/services/token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'lists and maps pending account requests with bearer authorization',
    () async {
      final repository = AccountRequestRepositoryImpl(
        AccountRequestApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient((request) async {
            expect(request.headers['Authorization'], 'Bearer token');
            expect(request.url.queryParameters['status'], 'pending');
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'success': true,
                  'message': 'ok',
                  'data': [_requestJson()],
                  'errors': null,
                  'code': null,
                }),
              ),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        ),
        _TokenStore(),
      );

      final result = await repository.list(AccountRequestStatus.pending);

      expect(result.single.name, 'مستخدم جديد');
      expect(result.single.status, AccountRequestStatus.pending);
      expect(result.single.requestedRole, 'technician');
    },
  );

  test(
    'approve and reject use strict endpoints and normalize rejection reason',
    () async {
      final requests = <http.Request>[];
      final repository = AccountRequestRepositoryImpl(
        AccountRequestApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient((request) async {
            requests.add(request);
            final rejected = request.url.path.endsWith('/reject');
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'success': true,
                  'message': 'ok',
                  'data': _requestJson(
                    status: rejected ? 'rejected' : 'approved',
                    reason: rejected ? 'سبب واضح' : null,
                  ),
                  'errors': null,
                  'code': null,
                }),
              ),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        ),
        _TokenStore(),
      );

      await repository.approve(9);
      await repository.reject(9, reason: '  سبب   واضح  ');

      expect(requests[0].url.path, '/api/admin/account-requests/9/approve');
      expect(requests[1].url.path, '/api/admin/account-requests/9/reject');
      expect(jsonDecode(requests[1].body)['rejection_reason'], 'سبب واضح');
    },
  );

  for (final scenario in [
    (401, AccountRequestFailureKind.unauthenticated),
    (403, AccountRequestFailureKind.unauthorized),
    (404, AccountRequestFailureKind.conflict),
    (409, AccountRequestFailureKind.conflict),
    (422, AccountRequestFailureKind.validation),
    (500, AccountRequestFailureKind.server),
  ]) {
    test('maps ${scenario.$1} to ${scenario.$2.name}', () async {
      final repository = AccountRequestRepositoryImpl(
        AccountRequestApiService(
          Uri.parse('https://fixflow.test'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'success': false,
                'message': 'SQLSTATE secret',
                'data': null,
                'errors': null,
                'code': 'ERROR',
              }),
              scenario.$1,
            ),
          ),
        ),
        _TokenStore(),
      );

      await expectLater(
        repository.list(AccountRequestStatus.pending),
        throwsA(
          isA<AccountRequestFailure>()
              .having((value) => value.kind, 'kind', scenario.$2)
              .having(
                (value) => value.message,
                'safe message',
                isNot(contains('SQLSTATE')),
              ),
        ),
      );
    });
  }

  test('malformed successful payload maps to contract failure', () async {
    final repository = AccountRequestRepositoryImpl(
      AccountRequestApiService(
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
      repository.list(AccountRequestStatus.pending),
      throwsA(
        isA<AccountRequestFailure>().having(
          (value) => value.kind,
          'kind',
          AccountRequestFailureKind.contract,
        ),
      ),
    );
  });
}

Map<String, dynamic> _requestJson({
  String status = 'pending',
  String? reason,
}) => {
  'id': 9,
  'name': 'مستخدم جديد',
  'email': 'new@example.com',
  'requested_role': 'technician',
  'status': status,
  'registered_at': '2026-08-01T10:00:00Z',
  'approved_by': status == 'approved' ? {'id': 1, 'name': 'المسؤول'} : null,
  'approved_at': status == 'approved' ? '2026-08-01T11:00:00Z' : null,
  'rejected_by': status == 'rejected' ? {'id': 1, 'name': 'المسؤول'} : null,
  'rejected_at': status == 'rejected' ? '2026-08-01T11:00:00Z' : null,
  'rejection_reason': reason,
};

class _TokenStore implements TokenStore {
  @override
  Future<String?> read() async => 'token';
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}
