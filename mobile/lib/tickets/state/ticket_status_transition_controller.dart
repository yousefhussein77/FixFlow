import 'package:flutter/foundation.dart';
import '../models/technician_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/technician_ticket_repository.dart';

enum TicketTransitionStatus {
  ready,
  submitting,
  success,
  validation,
  notFound,
  unauthorized,
  conflict,
  offline,
  serverError,
}

class TicketStatusTransitionController extends ChangeNotifier {
  TicketStatusTransitionController(this.repository, {required this.refresh});
  final TechnicianTicketRepository repository;
  final Future<void> Function() refresh;
  TicketTransitionStatus status = TicketTransitionStatus.ready;
  String? message;
  bool isRefreshingAuthoritativeState = false;
  Future<TechnicianTicket?> submit(
    String reference,
    String nextStatus, {
    String? reason,
  }) async {
    if (status == TicketTransitionStatus.submitting ||
        isRefreshingAuthoritativeState) {
      return null;
    }
    status = TicketTransitionStatus.submitting;
    notifyListeners();
    try {
      final ticket = await repository.transition(
        reference,
        nextStatus,
        reason: reason,
      );
      status = TicketTransitionStatus.success;
      message = null;
      notifyListeners();
      return ticket;
    } on TicketFailure catch (e) {
      final failureStatus = switch (e.kind) {
        TicketFailureKind.validation => TicketTransitionStatus.validation,
        TicketFailureKind.notFound => TicketTransitionStatus.notFound,
        TicketFailureKind.unauthorized => TicketTransitionStatus.unauthorized,
        TicketFailureKind.conflict => TicketTransitionStatus.conflict,
        TicketFailureKind.offline => TicketTransitionStatus.offline,
        _ => TicketTransitionStatus.serverError,
      };
      status = failureStatus;
      message = e.message;
      notifyListeners();
      if (failureStatus == TicketTransitionStatus.conflict ||
          failureStatus == TicketTransitionStatus.offline ||
          failureStatus == TicketTransitionStatus.serverError) {
        isRefreshingAuthoritativeState = true;
        notifyListeners();
        try {
          await refresh();
        } catch (_) {
          // Preserve the original transition failure; refresh owns its UI state.
        } finally {
          isRefreshingAuthoritativeState = false;
          notifyListeners();
        }
      }
      return null;
    }
  }
}
