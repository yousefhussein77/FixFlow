import '../../auth/services/token_store.dart';
import '../models/ticket_comment_models.dart';
import '../models/ticket_models.dart';
import '../services/ticket_comment_api_service.dart';

abstract interface class TicketCommentRepository {
  Future<List<TicketComment>> list(
    TicketCommentContext context,
    String reference,
  );
  Future<TicketComment> create(
    TicketCommentContext context,
    String reference, {
    required String content,
    required String submissionToken,
  });
}

class TicketCommentRepositoryImpl implements TicketCommentRepository {
  TicketCommentRepositoryImpl(this.api, this.store);
  final TicketCommentApiService api;
  final TokenStore store;
  Future<String> _token() async =>
      await store.read() ??
      (throw const TicketFailure(
        TicketFailureKind.unauthorized,
        'يرجى تسجيل الدخول للمتابعة.',
      ));
  String _path(TicketCommentContext context, String reference) =>
      '/api/${context.pathSegment}/tickets/$reference/comments';
  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on TicketFailure {
      rethrow;
    } catch (_) {
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة بيانات التعليقات.',
      );
    }
  }

  @override
  Future<List<TicketComment>> list(
    TicketCommentContext context,
    String reference,
  ) async {
    final envelope = await api.get(_path(context, reference), await _token());
    return _parse(() {
      final data = envelope['data'];
      if (data is! List) throw const FormatException();
      final comments =
          data.cast<Map<String, dynamic>>().map(TicketComment.fromJson).toList()
            ..sort((a, b) {
              final time = a.createdAt.compareTo(b.createdAt);
              return time != 0 ? time : a.id.compareTo(b.id);
            });
      return comments;
    });
  }

  @override
  Future<TicketComment> create(
    TicketCommentContext context,
    String reference, {
    required String content,
    required String submissionToken,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || trimmed.length > 2000)
      throw const TicketFailure(
        TicketFailureKind.validation,
        'أدخل تعليقاً من حرف واحد إلى 2000 حرف.',
      );
    final envelope = await api.post(_path(context, reference), await _token(), {
      'content': trimmed,
      'submission_token': submissionToken,
    });
    return _parse(() {
      final data = envelope['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return TicketComment.fromJson(data);
    });
  }
}
