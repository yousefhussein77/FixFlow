import 'dart:async';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/state/ticket_assignment_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'assignment blocks duplicates and requires refresh after conflict',
    () async {
      final repo = AssignmentRepo();
      final c = TicketAssignmentController(repo, 'TKT-ABCDEFGHIJKL');
      final a = c.submit(2);
      final b = c.submit(2);
      repo.release.complete();
      await Future.wait([a, b]);
      expect(repo.calls, 1);
      expect(c.status, TicketAssignmentStatus.success);
      repo.failure = const TicketFailure(TicketFailureKind.conflict, 'Refresh');
      repo.release = Completer<void>()..complete();
      await c.submit(2);
      expect(c.status, TicketAssignmentStatus.conflict);
      expect(c.requiresRefresh, isTrue);
    },
  );
}

class AssignmentRepo implements AdminTicketRepository {
  int calls = 0;
  TicketFailure? failure;
  Completer<void> release = Completer<void>();
  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) async {
    calls++;
    await release.future;
    if (failure case final f?) throw f;
    return AdminTicketSummary(
      reference: reference,
      title: 'Leak',
      reporter: const UserSummary(1, 'Reporter'),
      priority: 'high',
      department: const TicketOption(1, 'Facilities'),
      category: const TicketOption(2, 'Plumbing'),
      status: 'assigned',
      assignedTechnician: UserSummary(technicianId, 'Tech'),
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) =>
      throw UnimplementedError();
  @override
  Future<List<TechnicianOption>> technicians() => throw UnimplementedError();
}
