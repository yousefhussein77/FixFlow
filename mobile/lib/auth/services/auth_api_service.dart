import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/auth_models.dart';

class AuthApiService {
  AuthApiService({required this.baseUri, http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final envelope = await _send(
      'POST',
      '/api/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return _session(envelope);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final envelope = await _send(
      'POST',
      '/api/login',
      body: {'email': email, 'password': password},
    );
    return _session(envelope);
  }

  Future<UserProfile> profile(String token) async {
    final envelope = await _send('GET', '/api/profile', token: token);
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<void> logout(String token) async {
    await _send('POST', '/api/logout', token: token);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final uri = baseUri.resolve(path);
      final response = switch (method) {
        'GET' => await _client.get(uri, headers: headers),
        'POST' => await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, dynamic>{}),
        ),
        _ => throw StateError('Unsupported method'),
      };
      return _decode(response);
    } on AuthFailure {
      rethrow;
    } on SocketException catch (error, stackTrace) {
      _debugFailure(error, stackTrace);
      throw const AuthFailure(
        AuthFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    } on TimeoutException catch (error, stackTrace) {
      _debugFailure(error, stackTrace);
      throw const AuthFailure(
        AuthFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    } on http.ClientException catch (error, stackTrace) {
      _debugFailure(error, stackTrace);
      throw const AuthFailure(
        AuthFailureKind.offline,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    } catch (error, stackTrace) {
      _debugFailure(error, stackTrace);
      throw const AuthFailure(
        AuthFailureKind.contract,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> envelope;
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is! Map<String, dynamic>) throw const FormatException();
      envelope = value;
    } catch (error, stackTrace) {
      _debugFailure(error, stackTrace);
      throw const AuthFailure(
        AuthFailureKind.contract,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (envelope['success'] != true) {
        throw const AuthFailure(
          AuthFailureKind.contract,
          'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
        );
      }
      return envelope;
    }

    final message = _messageForStatus(response.statusCode);
    final errors = <String, List<String>>{};
    final rawErrors = envelope['errors'];
    if (rawErrors is Map<String, dynamic>) {
      for (final entry in rawErrors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          errors[entry.key] = [_validationMessageForField(entry.key)];
        }
      }
    }

    if (response.statusCode == 422) {
      throw AuthFailure(
        AuthFailureKind.validation,
        message,
        fieldErrors: errors,
      );
    }
    if (response.statusCode == 401) {
      throw AuthFailure(AuthFailureKind.unauthenticated, message);
    }
    throw AuthFailure(AuthFailureKind.server, message);
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    401 => 'بيانات الدخول غير صحيحة أو انتهت الجلسة.',
    403 => 'ليست لديك صلاحية لتنفيذ هذا الإجراء.',
    422 => 'تحقق من البيانات المدخلة ثم حاول مجدداً.',
    _ => 'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
  };

  String _validationMessageForField(String field) => switch (field) {
    'name' => 'تحقق من الاسم المدخل.',
    'email' => 'تحقق من عنوان البريد الإلكتروني.',
    'password' => 'تحقق من كلمة المرور.',
    'password_confirmation' => 'تأكد من تطابق كلمتي المرور.',
    _ => 'تحقق من القيمة المدخلة.',
  };

  void _debugFailure(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('Auth API failure: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  AuthSession _session(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic> ||
        data['token'] is! String ||
        (data['token'] as String).isEmpty) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
      );
    }
    return AuthSession(
      profile: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}
