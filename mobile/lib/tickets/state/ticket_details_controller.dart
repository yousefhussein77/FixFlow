import 'package:flutter/foundation.dart';
import '../models/ticket_models.dart';
import '../repositories/ticket_repository.dart';

enum TicketDetailsStatus {
  loading,
  populated,
  notFound,
  unauthorized,
  offline,
  photoUnavailable,
  serverError,
}

class TicketDetailsState {
  const TicketDetailsState(this.status, {this.ticket, this.message});
  final TicketDetailsStatus status;
  final TicketDetail? ticket;
  final String? message;
}

class TicketDetailsController extends ChangeNotifier {
  TicketDetailsController(this.repository);
  final TicketRepository repository;
  TicketDetailsState state = const TicketDetailsState(
    TicketDetailsStatus.loading,
  );
  int _generation = 0;
  void _set(TicketDetailsState s) {
    state = s;
    notifyListeners();
  }

  Future<void> load(String reference) async {
    final g = ++_generation;
    _set(const TicketDetailsState(TicketDetailsStatus.loading));
    try {
      final ticket = await repository.detail(reference);
      if (g == _generation)
        _set(TicketDetailsState(TicketDetailsStatus.populated, ticket: ticket));
    } on TicketFailure catch (e) {
      if (g != _generation) return;
      _set(
        TicketDetailsState(switch (e.kind) {
          TicketFailureKind.notFound => TicketDetailsStatus.notFound,
          TicketFailureKind.unauthorized => TicketDetailsStatus.unauthorized,
          TicketFailureKind.offline => TicketDetailsStatus.offline,
          _ => TicketDetailsStatus.serverError,
        }, message: e.message),
      );
    }
  }

  void photoUnavailable() {
    final ticket = state.ticket;
    _set(
      TicketDetailsState(
        TicketDetailsStatus.photoUnavailable,
        ticket: ticket,
        message: 'الصورة غير متاحة مؤقتاً.',
      ),
    );
  }
}
