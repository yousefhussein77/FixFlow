import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../auth/models/auth_models.dart';

class ReferenceApiService {
  ReferenceApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();
  final Uri baseUri;
  final http.Client _client;
  Future<List<Map<String, dynamic>>> list(String path, String token) async {
    final e = await _send('GET', path, token);
    final d = e['data'];
    if (d is! List)
      throw const AuthFailure(
        AuthFailureKind.contract,
        'Invalid reference response.',
      );
    return d.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> mutate(
    String method,
    String path,
    String token,
    Map<String, dynamic> body,
  ) async {
    final e = await _send(method, path, token, body);
    final d = e['data'];
    if (d is! Map<String, dynamic>)
      throw const AuthFailure(
        AuthFailureKind.contract,
        'Invalid reference response.',
      );
    return d;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    String token, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final h = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final u = baseUri.resolve(path);
      final r = method == 'GET'
          ? await _client.get(u, headers: h)
          : method == 'POST'
          ? await _client.post(u, headers: h, body: jsonEncode(body))
          : method == 'PUT'
          ? await _client.put(u, headers: h, body: jsonEncode(body))
          : await _client.patch(u, headers: h, body: jsonEncode(body));
      final e = jsonDecode(r.body);
      if (e is! Map<String, dynamic>) throw const FormatException();
      if (r.statusCode >= 200 && r.statusCode < 300) return e;
      final msg = e['message'] as String? ?? 'Request failed.';
      final raw = e['errors'];
      final errors = <String, List<String>>{};
      if (raw is Map<String, dynamic>)
        for (final x in raw.entries)
          errors[x.key] = (x.value as List).cast<String>();
      if (r.statusCode == 401 || r.statusCode == 403)
        throw AuthFailure(AuthFailureKind.unauthenticated, msg);
      if (r.statusCode == 409)
        throw AuthFailure(
          AuthFailureKind.contract,
          msg,
          fieldErrors: const {
            'conflict': ['The record changed.'],
          },
        );
      if (r.statusCode == 422)
        throw AuthFailure(AuthFailureKind.validation, msg, fieldErrors: errors);
      throw AuthFailure(AuthFailureKind.server, msg);
    } on AuthFailure {
      rethrow;
    } on SocketException {
      throw const AuthFailure(
        AuthFailureKind.offline,
        'You appear to be offline.',
      );
    } on http.ClientException {
      throw const AuthFailure(
        AuthFailureKind.offline,
        'Unable to reach FixFlow.',
      );
    } catch (_) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'Invalid reference response.',
      );
    }
  }
}
