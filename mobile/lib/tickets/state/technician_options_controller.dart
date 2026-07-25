import 'package:flutter/foundation.dart';
import '../models/admin_ticket_models.dart';
import '../models/ticket_models.dart';
import '../repositories/admin_ticket_repository.dart';

enum TechnicianOptionsStatus {
  loading,
  ready,
  empty,
  unauthorized,
  offline,
  serverError,
}

class TechnicianOptionsController extends ChangeNotifier {
  TechnicianOptionsController(this.repository);
  final AdminTicketRepository repository;
  TechnicianOptionsStatus status = TechnicianOptionsStatus.loading;
  List<TechnicianOption> options = [];
  String? message;
  int _generation = 0;
  Future<void> load() async {
    final generation = ++_generation;
    status = TechnicianOptionsStatus.loading;
    notifyListeners();
    try {
      final result = await repository.technicians();
      if (generation != _generation) return;
      options = result;
      status = result.isEmpty
          ? TechnicianOptionsStatus.empty
          : TechnicianOptionsStatus.ready;
      message = null;
      notifyListeners();
    } on TicketFailure catch (e) {
      if (generation != _generation) return;
      if (e.kind == TicketFailureKind.unauthorized) options = [];
      status = switch (e.kind) {
        TicketFailureKind.unauthorized => TechnicianOptionsStatus.unauthorized,
        TicketFailureKind.offline => TechnicianOptionsStatus.offline,
        _ => TechnicianOptionsStatus.serverError,
      };
      message = e.message;
      notifyListeners();
    }
  }
}
