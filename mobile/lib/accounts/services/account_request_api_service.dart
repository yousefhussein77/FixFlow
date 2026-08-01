import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/account_request_models.dart';

class AccountRequestApiService {
  AccountRequestApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> list(String token, String status) =>
      _send('GET', '/api/admin/account-requests?status=$status', token);

  Future<Map<String, dynamic>> approve(String token, int id) =>
      _send('PATCH', '/api/admin/account-requests/$id/approve', token);

  Future<Map<String, dynamic>> reject(String token, int id, String? reason) =>
      _send(
        'PATCH',
        '/api/admin/account-requests/$id/reject',
        token,
        body: {'rejection_reason': reason},
      );

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    String token, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = baseUri.resolve(path);
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = method == 'GET'
          ? await _client.get(uri, headers: headers)
          : await _client.patch(
              uri,
              headers: headers,
              body: jsonEncode(body ?? const <String, dynamic>{}),
            );
      return _decode(response);
    } on AccountRequestFailure {
      rethrow;
    } on SocketException catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من اتصالك ثم حاول مرة أخرى.',
      );
    } on TimeoutException catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من اتصالك ثم حاول مرة أخرى.',
      );
    } on http.ClientException catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من اتصالك ثم حاول مرة أخرى.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Account request response processing failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw const AccountRequestFailure(
        AccountRequestFailureKind.contract,
        'تعذر معالجة استجابة الخادم.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> envelope;
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is! Map<String, dynamic>) throw const FormatException();
      envelope = value;
    } catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.contract,
        'تعذر معالجة استجابة الخادم.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (envelope['success'] != true) {
        throw const AccountRequestFailure(
          AccountRequestFailureKind.contract,
          'تعذر معالجة استجابة الخادم.',
        );
      }
      return envelope;
    }

    final kind = switch (response.statusCode) {
      401 => AccountRequestFailureKind.unauthenticated,
      403 => AccountRequestFailureKind.unauthorized,
      404 => AccountRequestFailureKind.conflict,
      409 => AccountRequestFailureKind.conflict,
      422 => AccountRequestFailureKind.validation,
      _ => AccountRequestFailureKind.server,
    };
    final message = switch (kind) {
      AccountRequestFailureKind.unauthenticated =>
        'انتهت الجلسة. سجل الدخول مرة أخرى.',
      AccountRequestFailureKind.unauthorized =>
        'ليست لديك صلاحية لإدارة طلبات الحسابات.',
      AccountRequestFailureKind.conflict =>
        'تغيرت حالة الطلب. حدّث القائمة وحاول مرة أخرى.',
      AccountRequestFailureKind.validation =>
        'تحقق من البيانات المدخلة ثم حاول مجددًا.',
      _ => 'تعذر إكمال العملية. حاول مرة أخرى لاحقًا.',
    };
    throw AccountRequestFailure(kind, message);
  }
}
