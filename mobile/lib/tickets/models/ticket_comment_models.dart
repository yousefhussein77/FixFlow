import 'ticket_models.dart';

enum TicketCommentContext {
  reporter('reporter'),
  technician('technician'),
  administrator('admin');

  const TicketCommentContext(this.pathSegment);
  final String pathSegment;
}

class TicketCommentAuthor {
  const TicketCommentAuthor({
    required this.id,
    required this.name,
    required this.role,
  });
  final int id;
  final String name, role;
  factory TicketCommentAuthor.fromJson(Map<String, dynamic> json) =>
      TicketCommentAuthor(
        id: json['id'] as int,
        name: json['name'] as String,
        role: json['role'] as String,
      );
}

class TicketComment {
  const TicketComment({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
  });
  final int id;
  final String content;
  final TicketCommentAuthor author;
  final DateTime createdAt;
  factory TicketComment.fromJson(Map<String, dynamic> json) => TicketComment(
    id: json['id'] as int,
    content: json['content'] as String,
    author: TicketCommentAuthor.fromJson(
      json['author'] as Map<String, dynamic>,
    ),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class TicketCommentFailure extends TicketFailure {
  const TicketCommentFailure(super.kind, super.message, {super.fieldErrors});
}
