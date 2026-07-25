import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_rating_models.dart';
import 'package:fixflow/tickets/repositories/ticket_rating_repository.dart';
import 'package:fixflow/tickets/state/ticket_rating_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ambiguous retry retains submission token', () async {
    final repository = _RetryRepository();
    final controller = TicketRatingController(repository, 'TKT-9')..select(3);
    expect(await controller.submit(), isFalse);
    expect(controller.status, TicketRatingStatus.offline);
    expect(await controller.submit(), isTrue);
    expect(repository.tokens[0], repository.tokens[1]);
  });
}

class _RetryRepository implements TicketRatingRepository {
  final tokens = <String>[];
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async {
    tokens.add(submissionToken);
    if (tokens.length == 1)
      throw const TicketFailure(TicketFailureKind.offline, 'Offline');
    return TicketRating(value: rating, ratedAt: DateTime.utc(2026, 7, 25));
  }
}
