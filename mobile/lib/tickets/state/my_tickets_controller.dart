import 'package:flutter/foundation.dart';
import '../models/ticket_models.dart';
import '../repositories/ticket_repository.dart';

enum MyTicketsStatus {
  loading,
  populated,
  empty,
  loadingMore,
  unauthorized,
  offline,
  serverError,
}

class MyTicketsState {
  const MyTicketsState(this.status, {this.message});
  final MyTicketsStatus status;
  final String? message;
}

class MyTicketsController extends ChangeNotifier {
  MyTicketsController(this.repository);
  final TicketRepository repository;
  MyTicketsState state = const MyTicketsState(MyTicketsStatus.loading);
  List<TicketSummary> tickets = [];
  int _page = 0;
  int _lastPage = 1;
  int _generation = 0;
  void _set(MyTicketsState s) {
    state = s;
    notifyListeners();
  }

  Future<void> load({bool refresh = true}) async {
    if (!refresh &&
        (_page >= _lastPage || state.status == MyTicketsStatus.loadingMore))
      return;
    final generation = refresh ? ++_generation : _generation;
    final next = refresh ? 1 : _page + 1;
    _set(
      MyTicketsState(
        refresh ? MyTicketsStatus.loading : MyTicketsStatus.loadingMore,
      ),
    );
    try {
      final page = await repository.list(page: next);
      if (generation != _generation) return;
      final byReference = <String, TicketSummary>{
        for (final t in refresh ? <TicketSummary>[] : tickets) t.reference: t,
        for (final t in page.items) t.reference: t,
      };
      tickets = byReference.values.toList();
      _page = page.currentPage;
      _lastPage = page.lastPage;
      _set(
        MyTicketsState(
          tickets.isEmpty ? MyTicketsStatus.empty : MyTicketsStatus.populated,
        ),
      );
    } on TicketFailure catch (e) {
      if (generation == _generation) _fail(e);
    }
  }

  void _fail(TicketFailure e) => _set(
    MyTicketsState(switch (e.kind) {
      TicketFailureKind.unauthorized => MyTicketsStatus.unauthorized,
      TicketFailureKind.offline => MyTicketsStatus.offline,
      _ => MyTicketsStatus.serverError,
    }, message: e.message),
  );
}
