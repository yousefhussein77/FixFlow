import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_comment_repository.dart';
import 'package:fixflow/tickets/state/ticket_comments_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads empty and submits one authoritative comment', () async {
    final repository = _Repository();
    final controller = TicketCommentsController(
      repository,
      TicketCommentContext.reporter,
      'TKT-7',
    );
    await controller.load();
    expect(controller.status, TicketCommentsStatus.empty);
    controller.updateDraft('  Work note  ');
    await controller.submit();
    expect(controller.comments.single.content, 'Work note');
    expect(controller.draft, isEmpty);
    expect(repository.lastToken, isNotEmpty);
  });

  test(
    'maps authorization, not-found, offline, validation, and server states',
    () async {
      for (final entry in {
        TicketFailureKind.unauthorized: TicketCommentsStatus.unauthorized,
        TicketFailureKind.notFound: TicketCommentsStatus.notFound,
        TicketFailureKind.offline: TicketCommentsStatus.offline,
        TicketFailureKind.validation: TicketCommentsStatus.validation,
        TicketFailureKind.server: TicketCommentsStatus.serverError,
      }.entries) {
        final repository = _Repository()
          ..failure = TicketFailure(entry.key, 'failed');
        final controller = TicketCommentsController(
          repository,
          TicketCommentContext.reporter,
          'TKT-7',
        );
        controller.comments = [_comment()];
        controller.updateDraft('draft');
        await controller.load();
        expect(controller.status, entry.value);
        if (entry.key == TicketFailureKind.unauthorized ||
            entry.key == TicketFailureKind.notFound) {
          expect(controller.comments, isEmpty);
          expect(controller.draft, isEmpty);
        }
      }
    },
  );
}

class _Repository implements TicketCommentRepository {
  String? lastToken;
  TicketFailure? failure;
  @override
  Future<List<TicketComment>> list(
    TicketCommentContext context,
    String reference,
  ) async {
    if (failure != null) throw failure!;
    return [];
  }

  @override
  Future<TicketComment> create(
    TicketCommentContext context,
    String reference, {
    required String content,
    required String submissionToken,
  }) async {
    lastToken = submissionToken;
    return TicketComment(
      id: 1,
      content: content,
      author: const TicketCommentAuthor(
        id: 1,
        name: 'Reporter',
        role: 'reporter',
      ),
      createdAt: DateTime.utc(2026),
    );
  }
}

TicketComment _comment() => TicketComment(
  id: 1,
  content: 'existing',
  author: const TicketCommentAuthor(id: 1, name: 'User', role: 'reporter'),
  createdAt: DateTime.utc(2026),
);
