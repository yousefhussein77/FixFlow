import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
        'The server returned an invalid profile.',
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
    } on SocketException catch (_) {
      throw const AuthFailure(
        AuthFailureKind.offline,
        'You appear to be offline. Check your connection and retry.',
      );
    } on TimeoutException catch (_) {
      throw const AuthFailure(
        AuthFailureKind.offline,
        'The connection timed out. Check your connection and retry.',
      );
    } on http.ClientException catch (_) {
      throw const AuthFailure(
        AuthFailureKind.offline,
        'Unable to reach FixFlow. Check your connection and retry.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> envelope;
    try {
      final value = jsonDecode(response.body);
      if (value is! Map<String, dynamic>) throw const FormatException();
      envelope = value;
    } catch (_) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'The server returned an invalid response.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (envelope['success'] != true) {
        throw const AuthFailure(
          AuthFailureKind.contract,
          'The server returned an invalid response.',
        );
      }
      return envelope;
    }

    final message = envelope['message'] is String
        ? envelope['message'] as String
        : 'The request could not be completed.';
    final errors = <String, List<String>>{};
    final rawErrors = envelope['errors'];
    if (rawErrors is Map<String, dynamic>) {
      for (final entry in rawErrors.entries) {
        final value = entry.value;
        if (value is List) {
          errors[entry.key] = value.whereType<String>().toList();
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

  AuthSession _session(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic> ||
        data['token'] is! String ||
        (data['token'] as String).isEmpty) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'The server returned an invalid session.',
      );
    }
    return AuthSession(
      profile: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}
