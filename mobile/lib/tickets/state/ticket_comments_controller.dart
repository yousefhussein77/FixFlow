import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/ticket_comment_models.dart';
import '../models/ticket_models.dart';
import '../repositories/ticket_comment_repository.dart';

enum TicketCommentsStatus {
  loading,
  populated,
  empty,
  submitting,
  validation,
  notFound,
  unauthorized,
  offline,
  serverError,
}

class TicketCommentsController extends ChangeNotifier {
  TicketCommentsController(this.repository, this.context, this.reference);
  final TicketCommentRepository repository;
  final TicketCommentContext context;
  final String reference;
  TicketCommentsStatus status = TicketCommentsStatus.loading;
  List<TicketComment> comments = [];
  String draft = '';
  String? message, _submissionToken;
  int _generation = 0;
  bool get isSubmitting => status == TicketCommentsStatus.submitting;
  void updateDraft(String value) {
    draft = value;
    notifyListeners();
  }

  Future<void> load() async {
    final generation = ++_generation;
    status = TicketCommentsStatus.loading;
    notifyListeners();
    try {
      final result = await repository.list(context, reference);
      if (generation != _generation) return;
      comments = result;
      status = result.isEmpty
          ? TicketCommentsStatus.empty
          : TicketCommentsStatus.populated;
      message = null;
    } on TicketFailure catch (e) {
      if (generation != _generation) return;
      _applyFailure(e, clearRestricted: true);
    }
    notifyListeners();
  }

  Future<void> submit() async {
    if (isSubmitting) return;
    final trimmed = draft.trim();
    if (trimmed.isEmpty || trimmed.length > 2000) {
      status = TicketCommentsStatus.validation;
      message = 'أدخل تعليقاً من 1 إلى 2000 حرف.';
      notifyListeners();
      return;
    }
    _submissionToken ??= _uuid();
    status = TicketCommentsStatus.submitting;
    notifyListeners();
    try {
      final comment = await repository.create(
        context,
        reference,
        content: trimmed,
        submissionToken: _submissionToken!,
      );
      comments =
          {
            for (final item in comments) item.id: item,
            comment.id: comment,
          }.values.toList()..sort((a, b) {
            final time = a.createdAt.compareTo(b.createdAt);
            return time != 0 ? time : a.id.compareTo(b.id);
          });
      draft = '';
      _submissionToken = null;
      status = TicketCommentsStatus.populated;
      message = null;
    } on TicketFailure catch (e) {
      _applyFailure(
        e,
        clearRestricted:
            e.kind == TicketFailureKind.unauthorized ||
            e.kind == TicketFailureKind.notFound,
      );
    }
    notifyListeners();
  }

  void _applyFailure(TicketFailure e, {required bool clearRestricted}) {
    if (clearRestricted &&
        (e.kind == TicketFailureKind.unauthorized ||
            e.kind == TicketFailureKind.notFound)) {
      comments = [];
      draft = '';
      _submissionToken = null;
    }
    status = switch (e.kind) {
      TicketFailureKind.validation => TicketCommentsStatus.validation,
      TicketFailureKind.notFound => TicketCommentsStatus.notFound,
      TicketFailureKind.unauthorized => TicketCommentsStatus.unauthorized,
      TicketFailureKind.offline => TicketCommentsStatus.offline,
      _ => TicketCommentsStatus.serverError,
    };
    message = e.message;
  }

  String _uuid() {
    final random = Random.secure();
    String hex(int count) => List.generate(
      count,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }
}
