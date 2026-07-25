import 'package:flutter/foundation.dart';
import '../models/admin_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/admin_ticket_repository.dart';

enum AdminTicketListStatus {
  loading,
  populated,
  empty,
  loadingMore,
  unauthorized,
  offline,
  serverError,
}

class AdminTicketListState {
  const AdminTicketListState(this.status, {this.message});
  final AdminTicketListStatus status;
  final String? message;
}

class AdminTicketListController extends ChangeNotifier {
  AdminTicketListController(this.repository);
  final AdminTicketRepository repository;
  AdminTicketListState state = const AdminTicketListState(
    AdminTicketListStatus.loading,
  );
  List<AdminTicketSummary> tickets = [];
  int _page = 0, _lastPage = 1, _generation = 0;
  void _set(AdminTicketListState value) {
    state = value;
    notifyListeners();
  }

  Future<void> load({bool refresh = true}) async {
    if (!refresh &&
        (_page >= _lastPage ||
            state.status == AdminTicketListStatus.loadingMore))
      return;
    final generation = refresh ? ++_generation : _generation;
    _set(
      AdminTicketListState(
        refresh
            ? AdminTicketListStatus.loading
            : AdminTicketListStatus.loadingMore,
      ),
    );
    try {
      final result = await repository.list(page: refresh ? 1 : _page + 1);
      if (generation != _generation) return;
      tickets = {
        for (final t in refresh ? <AdminTicketSummary>[] : tickets)
          t.reference: t,
        for (final t in result.items) t.reference: t,
      }.values.toList();
      _page = result.currentPage;
      _lastPage = result.lastPage;
      _set(
        AdminTicketListState(
          tickets.isEmpty
              ? AdminTicketListStatus.empty
              : AdminTicketListStatus.populated,
        ),
      );
    } on TicketFailure catch (e) {
      if (generation != _generation) return;
      if (e.kind == TicketFailureKind.unauthorized) tickets = [];
      _set(
        AdminTicketListState(switch (e.kind) {
          TicketFailureKind.unauthorized => AdminTicketListStatus.unauthorized,
          TicketFailureKind.offline => AdminTicketListStatus.offline,
          _ => AdminTicketListStatus.serverError,
        }, message: e.message),
      );
    }
  }

  void replace(AdminTicketSummary ticket) {
    tickets = [
      for (final current in tickets)
        if (current.reference == ticket.reference) ticket else current,
    ];
    _set(const AdminTicketListState(AdminTicketListStatus.populated));
  }
}
