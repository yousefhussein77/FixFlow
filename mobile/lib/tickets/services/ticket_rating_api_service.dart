import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';

class TicketRatingApiService {
  TicketRatingApiService(this.baseUri, {http.Client? client})
    : _client = client ?? http.Client();
  final Uri baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> create(
    String reference,
    String token, {
    required int rating,
    required String submissionToken,
  }) async {
    try {
      final response = await _client.post(
        baseUri.resolve('/api/reporter/tickets/$reference/rating'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'submission_token': submissionToken,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode == 200 || response.statusCode == 201)
        return decoded;
      final message = decoded['message'] as String? ?? 'Request failed.';
      final code = decoded['code'] as String?;
      final errors = <String, List<String>>{};
      if (decoded['errors'] is Map<String, dynamic>) {
        for (final entry
            in (decoded['errors'] as Map<String, dynamic>).entries) {
          errors[entry.key] = (entry.value as List).cast<String>();
        }
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw TicketFailure(
          TicketFailureKind.unauthorized,
          message,
          code: code,
        );
      }
      if (response.statusCode == 404) {
        throw TicketFailure(TicketFailureKind.notFound, message, code: code);
      }
      if (response.statusCode == 409) {
        throw TicketFailure(TicketFailureKind.conflict, message, code: code);
      }
      if (response.statusCode == 422) {
        throw TicketFailure(
          TicketFailureKind.validation,
          message,
          fieldErrors: errors,
          code: code,
        );
      }
      throw TicketFailure(TicketFailureKind.server, message, code: code);
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
        'The server returned an invalid rating response.',
      );
    }
  }
}
