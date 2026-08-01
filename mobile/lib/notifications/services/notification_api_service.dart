import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/notification_models.dart';

class NotificationApiService {
  NotificationApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> list(String token) =>
      _send('GET', '/api/notifications', token);

  Future<Map<String, dynamic>> unreadCount(String token) =>
      _send('GET', '/api/notifications/unread-count', token);

  Future<Map<String, dynamic>> markRead(String token, int id) =>
      _send('PATCH', '/api/notifications/$id/read', token);

  Future<Map<String, dynamic>> markAllRead(String token) =>
      _send('PATCH', '/api/notifications/read-all', token);

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    String token,
  ) async {
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
              body: jsonEncode(const <String, dynamic>{}),
            );
      return _decode(response);
    } on NotificationFailure {
      rethrow;
    } on SocketException catch (_) {
      throw const NotificationFailure(
        NotificationFailureKind.offline,
        'تعذر الاتصال بالخادم. تحقق من اتصالك ثم حاول مرة أخرى.',
      );
    } on TimeoutException catch (_) {
      throw const NotificationFailure(
        NotificationFailureKind.offline,
        'تعذر الاتصال بالخادم. تحقق من اتصالك ثم حاول مرة أخرى.',
      );
    } on http.ClientException catch (_) {
      throw const NotificationFailure(
        NotificationFailureKind.offline,
        'تعذر الاتصال بالخادم. تحقق من اتصالك ثم حاول مرة أخرى.',
      );
    } catch (_) {
      throw const NotificationFailure(
        NotificationFailureKind.contract,
        'تعذر معالجة بيانات الإشعارات.',
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
      throw const NotificationFailure(
        NotificationFailureKind.contract,
        'تعذر معالجة بيانات الإشعارات.',
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (envelope['success'] != true) {
        throw const NotificationFailure(
          NotificationFailureKind.contract,
          'تعذر معالجة بيانات الإشعارات.',
        );
      }
      return envelope;
    }
    final kind = switch (response.statusCode) {
      401 => NotificationFailureKind.unauthenticated,
      403 => NotificationFailureKind.unauthorized,
      404 => NotificationFailureKind.notFound,
      _ => NotificationFailureKind.server,
    };
    final message = switch (kind) {
      NotificationFailureKind.unauthenticated =>
        'انتهت الجلسة. سجل الدخول مرة أخرى.',
      NotificationFailureKind.unauthorized ||
      NotificationFailureKind.notFound => 'تعذر الوصول إلى هذا الإشعار.',
      _ => 'تعذر تحميل الإشعارات. حاول مرة أخرى لاحقاً.',
    };
    throw NotificationFailure(kind, message);
  }
}
