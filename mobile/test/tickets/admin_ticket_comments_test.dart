import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('administrator endpoint context is explicit', () {
    expect(TicketCommentContext.administrator.pathSegment, 'admin');
  });
}
