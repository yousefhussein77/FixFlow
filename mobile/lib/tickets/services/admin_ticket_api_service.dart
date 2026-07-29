import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';

class AdminTicketApiService {
  AdminTicketApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();
  final Uri baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, String token) =>
      _send('GET', path, token);
  Future<Map<String, dynamic>> patch(
    String path,
    String token,
    Map<String, dynamic> body,
  ) => _send('PATCH', path, token, body: body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    String token, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.send(
        http.Request(method, baseUri.resolve(path))
          ..headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          })
          ..body = body == null ? '' : jsonEncode(body),
      );
      final materialized = await http.Response.fromStream(response);
      final decoded = jsonDecode(materialized.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (materialized.statusCode >= 200 && materialized.statusCode < 300)
        return decoded;
      final message = _messageForStatus(materialized.statusCode);
      final raw = decoded['errors'];
      final errors = <String, List<String>>{};
      if (raw is Map<String, dynamic>) {
        for (final entry in raw.entries)
          errors[entry.key] = (entry.value as List).cast<String>();
      }
      if (materialized.statusCode == 401 || materialized.statusCode == 403)
        throw TicketFailure(TicketFailureKind.unauthorized, message);
      if (materialized.statusCode == 404)
        throw TicketFailure(TicketFailureKind.notFound, message);
      if (materialized.statusCode == 409)
        throw TicketFailure(TicketFailureKind.conflict, message);
      if (materialized.statusCode == 422)
        throw TicketFailure(
          TicketFailureKind.validation,
          message,
          fieldErrors: errors,
        );
      throw TicketFailure(TicketFailureKind.server, message);
    } on TicketFailure {
      rethrow;
    } on SocketException {
      throw const TicketFailure(
        TicketFailureKind.offline,
        'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مجدداً.',
      );
    } on http.ClientException {
      throw const TicketFailure(
        TicketFailureKind.offline,
        'تعذر الاتصال بخدمة FixFlow. حاول مجدداً.',
      );
    } catch (_) {
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة استجابة تذاكر المسؤول.',
      );
    }
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    401 || 403 => 'ليست لديك صلاحية لتنفيذ هذا الإجراء.',
    404 => 'العنصر المطلوب غير متاح.',
    409 => 'تعارضت البيانات مع الحالة الحالية. حدّث الصفحة ثم حاول مجدداً.',
    422 => 'تحقق من البيانات المدخلة ثم حاول مجدداً.',
    _ => 'تعذر تنفيذ الطلب. حاول مجدداً.',
  };
}
