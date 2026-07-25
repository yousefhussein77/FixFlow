import 'package:fixflow/tickets/models/ticket_comment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('technician endpoint context is explicit', () {
    expect(TicketCommentContext.technician.pathSegment, 'technician');
    expect(TicketCommentContext.reporter.pathSegment, isNot('technician'));
  });
}
