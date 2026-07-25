import 'package:flutter/foundation.dart';
import '../models/technician_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/technician_ticket_repository.dart';

enum TechnicianDetailStatus {
  loading,
  populated,
  notFound,
  unauthorized,
  offline,
  serverError,
}

class TechnicianTicketDetailsController extends ChangeNotifier {
  TechnicianTicketDetailsController(this.repository, this.reference);
  final TechnicianTicketRepository repository;
  final String reference;
  TechnicianDetailStatus status = TechnicianDetailStatus.loading;
  TechnicianTicket? ticket;
  String? message;
  Future<void> load() async {
    status = TechnicianDetailStatus.loading;
    notifyListeners();
    try {
      ticket = await repository.details(reference);
      status = TechnicianDetailStatus.populated;
      message = null;
    } on TicketFailure catch (e) {
      if (e.kind == TicketFailureKind.unauthorized ||
          e.kind == TicketFailureKind.notFound)
        ticket = null;
      status = switch (e.kind) {
        TicketFailureKind.unauthorized => TechnicianDetailStatus.unauthorized,
        TicketFailureKind.notFound => TechnicianDetailStatus.notFound,
        TicketFailureKind.offline => TechnicianDetailStatus.offline,
        _ => TechnicianDetailStatus.serverError,
      };
      message = e.message;
    }
    notifyListeners();
  }
}
