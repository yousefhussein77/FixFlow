import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';

class TicketApiService {
  TicketApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();
  final Uri baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, String token) => _send(
    http.Request('GET', baseUri.resolve(path))..headers.addAll(_headers(token)),
  );

  Future<Map<String, dynamic>> create(CreateTicketInput input, String token) {
    final request = http.MultipartRequest(
      'POST',
      baseUri.resolve('/api/reporter/tickets'),
    )..headers.addAll(_headers(token));
    request.fields.addAll({
      'submission_token': input.submissionToken,
      'title': input.title,
      'description': input.description,
      'department_id': '${input.departmentId}',
      'category_id': '${input.categoryId}',
      'priority': input.priority,
      'location': input.location,
    });
    for (final photo in input.photos) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photos[]',
          photo.bytes,
          filename: photo.name,
        ),
      );
    }
    return _send(request);
  }

  Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Future<Map<String, dynamic>> _send(http.BaseRequest request) async {
    try {
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode >= 200 && response.statusCode < 300)
        return decoded;
      final message = decoded['message'] as String? ?? 'Request failed.';
      final raw = decoded['errors'];
      final errors = <String, List<String>>{};
      if (raw is Map<String, dynamic>)
        for (final entry in raw.entries)
          errors[entry.key] = (entry.value as List).cast<String>();
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
        'You appear to be offline.',
      );
    } on http.ClientException {
      throw const TicketFailure(
        TicketFailureKind.offline,
        'Unable to reach FixFlow.',
      );
    } catch (_) {
      throw const TicketFailure(
        TicketFailureKind.contract,
        'The server returned an invalid ticket response.',
      );
    }
  }
}
