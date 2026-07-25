import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_comment_repository.dart';
import 'package:fixflow/tickets/state/ticket_comments_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ambiguous retry preserves draft and reuses token', () async {
    final repository = _RetryRepository();
    final controller = TicketCommentsController(
      repository,
      TicketCommentContext.technician,
      'TKT-7',
    )..updateDraft('Note');
    await controller.submit();
    expect(controller.draft, 'Note');
    final first = repository.tokens.single;
    await controller.submit();
    expect(repository.tokens.last, first);
    expect(controller.comments.single.content, 'Note');
  });
}

class _RetryRepository implements TicketCommentRepository {
  final tokens = <String>[];
  @override
  Future<List<TicketComment>> list(
    TicketCommentContext context,
    String reference,
  ) async => [];
  @override
  Future<TicketComment> create(
    TicketCommentContext context,
    String reference, {
    required String content,
    required String submissionToken,
  }) async {
    tokens.add(submissionToken);
    if (tokens.length == 1)
      throw const TicketFailure(TicketFailureKind.offline, 'Offline');
    return TicketComment(
      id: 1,
      content: content,
      author: const TicketCommentAuthor(
        id: 2,
        name: 'Tech',
        role: 'technician',
      ),
      createdAt: DateTime.utc(2026),
    );
  }
}
