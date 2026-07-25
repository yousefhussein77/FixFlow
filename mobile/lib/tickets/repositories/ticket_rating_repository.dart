import '../../auth/services/token_store.dart';
import '../models/ticket_models.dart';
import '../models/ticket_rating_models.dart';
import '../services/ticket_rating_api_service.dart';

abstract interface class TicketRatingRepository {
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  });
}

class TicketRatingRepositoryImpl implements TicketRatingRepository {
  TicketRatingRepositoryImpl(this.api, this.store);
  final TicketRatingApiService api;
  final TokenStore store;

  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const TicketFailure(
        TicketFailureKind.validation,
        'Choose a rating from 1 to 5.',
      );
    }
    final token = await store.read();
    if (token == null) {
      throw const TicketFailure(
        TicketFailureKind.unauthorized,
        'Authentication required.',
      );
    }
    final envelope = await api.create(
      reference,
      token,
      rating: rating,
      submissionToken: submissionToken,
    );
    try {
      final data = envelope['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return TicketRating.fromJson(data);
    } catch (_) {
      throw const TicketFailure(
        TicketFailureKind.contract,
        'The server returned an invalid rating response.',
      );
    }
  }
}
