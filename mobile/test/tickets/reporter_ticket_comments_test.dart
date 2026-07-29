import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:fixflow/tickets/repositories/ticket_comment_repository.dart';
import 'package:fixflow/tickets/state/ticket_comments_controller.dart';
import 'package:fixflow/tickets/widgets/ticket_comments_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';

void main() {
  testWidgets('renders comments as plain text and validates blank composer', (
    tester,
  ) async {
    final controller = TicketCommentsController(
      _Repository(),
      TicketCommentContext.reporter,
      'TKT-7',
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TicketCommentsSection(controller: controller)),
      ),
    );
    expect(find.text('<b>not markup</b>'), findsOneWidget);
    await tester.tap(find.byKey(const Key('comment_submit')));
    await tester.pump();
    expect(find.text('أدخل تعليقاً من 1 إلى 2000 حرف.'), findsOneWidget);
  });

  testWidgets('comment composer reflows at 320 pixels and 200% text', (
    tester,
  ) async {
    final controller = TicketCommentsController(
      _Repository(),
      TicketCommentContext.reporter,
      'TKT-7',
    );
    await controller.load();
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: TicketCommentsSection(controller: controller),
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('comment_content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Repository implements TicketCommentRepository {
  @override
  Future<List<TicketComment>> list(
    TicketCommentContext context,
    String reference,
  ) async => [
    TicketComment(
      id: 1,
      content: '<b>not markup</b>',
      author: const TicketCommentAuthor(
        id: 1,
        name: 'Reporter',
        role: 'reporter',
      ),
      createdAt: DateTime.utc(2026),
    ),
  ];
  @override
  Future<TicketComment> create(
    TicketCommentContext context,
    String reference, {
    required String content,
    required String submissionToken,
  }) => throw UnimplementedError();
}
