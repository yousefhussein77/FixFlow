import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/state/technician_options_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('technician options distinguish ready and empty', () async {
    final repo = OptionsRepo();
    final c = TechnicianOptionsController(repo);
    await c.load();
    expect(c.status, TechnicianOptionsStatus.ready);
    repo.empty = true;
    await c.load();
    expect(c.status, TechnicianOptionsStatus.empty);
  });
}

class OptionsRepo implements AdminTicketRepository {
  bool empty = false;
  @override
  Future<List<TechnicianOption>> technicians() async =>
      empty ? [] : const [TechnicianOption(1, 'Tech')];
  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) =>
      throw UnimplementedError();
}
