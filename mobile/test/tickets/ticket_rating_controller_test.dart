import 'package:fixflow/tickets/models/ticket_rating_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_rating_repository.dart';
import 'package:fixflow/tickets/state/ticket_rating_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid selection submits authoritative rating once', () async {
    final repository = _Repository();
    final controller = TicketRatingController(repository, 'TKT-9');
    controller.select(4);
    expect(await controller.submit(), isTrue);
    expect(controller.status, TicketRatingStatus.success);
    expect(controller.storedRating!.value, 4);
    expect(repository.calls, 1);
  });

  test('missing selection is validation', () async {
    final controller = TicketRatingController(_Repository(), 'TKT-9');
    expect(await controller.submit(), isFalse);
    expect(controller.status, TicketRatingStatus.validation);
  });

  test('distinguishes already-rated and not-completed conflicts', () async {
    for (final entry in {
      'RATING_ALREADY_EXISTS': TicketRatingStatus.alreadyRated,
      'TICKET_NOT_COMPLETED': TicketRatingStatus.notCompleted,
    }.entries) {
      final controller = TicketRatingController(
        _FailingRepository(entry.key),
        'TKT-9',
      )..select(4);
      expect(await controller.submit(), isFalse);
      expect(controller.status, entry.value);
    }
  });
}

class _Repository implements TicketRatingRepository {
  int calls = 0;
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async {
    calls++;
    return TicketRating(value: rating, ratedAt: DateTime.utc(2026, 7, 25));
  }
}

class _FailingRepository implements TicketRatingRepository {
  _FailingRepository(this.code);
  final String code;
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) => throw TicketFailure(TicketFailureKind.conflict, 'Conflict', code: code);
}
