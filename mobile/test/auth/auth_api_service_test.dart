import 'dart:convert';

import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/auth/services/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _safeServerMessage =
    'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.';

void main() {
  test('profile response is decoded as UTF-8', () async {
    final service = AuthApiService(
      baseUri: Uri.parse('https://fixflow.test'),
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'message': 'تم تحميل الملف الشخصي.',
              'data': {
                'id': 1,
                'name': 'مستخدم عربي',
                'email': 'reporter@example.com',
                'role': 'reporter',
                'is_active': true,
                'created_at': '2026-01-01T00:00:00Z',
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    final profile = await service.profile('token');

    expect(profile.name, 'مستخدم عربي');
  });

  test('server details are replaced with the safe Arabic fallback', () async {
    final service = AuthApiService(
      baseUri: Uri.parse('https://fixflow.test'),
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': false,
              'message': 'SQLSTATE connection failed at 127.0.0.1:3306',
              'data': null,
              'errors': null,
              'code': 'SERVER_ERROR',
            }),
          ),
          500,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    await expectLater(
      service.profile('token'),
      throwsA(
        isA<AuthFailure>()
            .having((failure) => failure.kind, 'kind', AuthFailureKind.server)
            .having(
              (failure) => failure.message,
              'message',
              _safeServerMessage,
            ),
      ),
    );
  });

  test(
    'backend validation details are replaced with safe Arabic text',
    () async {
      final service = AuthApiService(
        baseUri: Uri.parse('https://fixflow.test'),
        client: MockClient(
          (_) async => http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'success': false,
                'message': 'Validation failed',
                'data': null,
                'errors': {
                  'email': ['SQLSTATE internal validation detail'],
                },
                'code': 'VALIDATION_ERROR',
              }),
            ),
            422,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );

      await expectLater(
        service.login(email: 'bad', password: 'password'),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.fieldErrors['email'],
            'email error',
            ['تحقق من عنوان البريد الإلكتروني.'],
          ),
        ),
      );
    },
  );
}
