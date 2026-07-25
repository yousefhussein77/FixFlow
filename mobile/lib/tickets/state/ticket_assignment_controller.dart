import 'package:flutter/foundation.dart';
import '../models/admin_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/admin_ticket_repository.dart';

enum TicketAssignmentStatus {
  ready,
  submitting,
  success,
  validation,
  unauthorized,
  notFound,
  conflict,
  offline,
  serverError,
}

class TicketAssignmentController extends ChangeNotifier {
  TicketAssignmentController(this.repository, this.reference);
  final AdminTicketRepository repository;
  final String reference;
  TicketAssignmentStatus status = TicketAssignmentStatus.ready;
  String? message;
  AdminTicketSummary? assigned;
  Map<String, List<String>> fieldErrors = const {};
  bool requiresRefresh = false;
  Future<void> submit(int technicianId) async {
    if (status == TicketAssignmentStatus.submitting) return;
    status = TicketAssignmentStatus.submitting;
    notifyListeners();
    try {
      assigned = await repository.assign(reference, technicianId);
      status = TicketAssignmentStatus.success;
      requiresRefresh = false;
      message = null;
    } on TicketFailure catch (e) {
      fieldErrors = e.fieldErrors;
      status = switch (e.kind) {
        TicketFailureKind.validation => TicketAssignmentStatus.validation,
        TicketFailureKind.unauthorized => TicketAssignmentStatus.unauthorized,
        TicketFailureKind.notFound => TicketAssignmentStatus.notFound,
        TicketFailureKind.conflict => TicketAssignmentStatus.conflict,
        TicketFailureKind.offline => TicketAssignmentStatus.offline,
        _ => TicketAssignmentStatus.serverError,
      };
      requiresRefresh = const {
        TicketAssignmentStatus.notFound,
        TicketAssignmentStatus.conflict,
        TicketAssignmentStatus.offline,
        TicketAssignmentStatus.serverError,
      }.contains(status);
      message = e.message;
    }
    notifyListeners();
  }
}
