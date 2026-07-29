import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';

class TechnicianTicketApiService {
  TechnicianTicketApiService(this.baseUri, {http.Client? client})
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
      final request = http.Request(method, baseUri.resolve(path))
        ..headers.addAll({
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await _client.send(request),
      );
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode >= 200 && response.statusCode < 300)
        return decoded;
      final message = _messageForStatus(response.statusCode);
      final errors = <String, List<String>>{};
      if (decoded['errors'] is Map<String, dynamic>)
        for (final entry
            in (decoded['errors'] as Map<String, dynamic>).entries) {
          errors[entry.key] = (entry.value as List).cast<String>();
        }
      if (response.statusCode == 401 || response.statusCode == 403)
        throw TicketFailure(TicketFailureKind.unauthorized, message);
      if (response.statusCode == 404)
        throw TicketFailure(TicketFailureKind.notFound, message);
      if (response.statusCode == 409)
        throw TicketFailure(TicketFailureKind.conflict, message);
      if (response.statusCode == 422)
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
        'تعذر معالجة استجابة تذاكر الفني.',
      );
    }
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    401 || 403 => 'ليست لديك صلاحية لتنفيذ هذا الإجراء.',
    404 => 'التذكرة غير متاحة.',
    409 => 'تغيرت حالة التذكرة. حدّث التفاصيل ثم حاول مجدداً.',
    422 => 'تحقق من البيانات المدخلة ثم حاول مجدداً.',
    _ => 'تعذر تنفيذ الطلب. حاول مجدداً.',
  };
}
