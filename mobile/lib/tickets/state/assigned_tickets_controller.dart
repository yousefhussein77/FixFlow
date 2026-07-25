import 'package:flutter/foundation.dart';
import '../models/technician_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/technician_ticket_repository.dart';

enum AssignedTicketsStatus {
  loading,
  populated,
  empty,
  loadingMore,
  unauthorized,
  offline,
  serverError,
}

class AssignedTicketsController extends ChangeNotifier {
  AssignedTicketsController(this.repository);
  final TechnicianTicketRepository repository;
  AssignedTicketsStatus status = AssignedTicketsStatus.loading;
  List<TechnicianTicketSummary> tickets = [];
  String? message;
  int _page = 0, _lastPage = 1, _generation = 0;
  Future<void> load({bool refresh = true}) async {
    if (!refresh &&
        (_page >= _lastPage || status == AssignedTicketsStatus.loadingMore))
      return;
    final generation = refresh ? ++_generation : _generation;
    status = refresh
        ? AssignedTicketsStatus.loading
        : AssignedTicketsStatus.loadingMore;
    notifyListeners();
    try {
      final page = await repository.list(page: refresh ? 1 : _page + 1);
      if (generation != _generation) return;
      tickets = {
        for (final t in refresh ? <TechnicianTicketSummary>[] : tickets)
          t.reference: t,
        for (final t in page.items) t.reference: t,
      }.values.toList();
      _page = page.currentPage;
      _lastPage = page.lastPage;
      status = tickets.isEmpty
          ? AssignedTicketsStatus.empty
          : AssignedTicketsStatus.populated;
      message = null;
    } on TicketFailure catch (e) {
      if (generation != _generation) return;
      if (e.kind == TicketFailureKind.unauthorized) tickets = [];
      status = switch (e.kind) {
        TicketFailureKind.unauthorized => AssignedTicketsStatus.unauthorized,
        TicketFailureKind.offline => AssignedTicketsStatus.offline,
        _ => AssignedTicketsStatus.serverError,
      };
      message = e.message;
    }
    notifyListeners();
  }
}
