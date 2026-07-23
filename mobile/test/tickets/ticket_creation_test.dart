import 'dart:async';
import 'dart:typed_data';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_repository.dart';
import 'package:fixflow/tickets/screens/create_ticket_screen.dart';
import 'package:fixflow/tickets/state/ticket_creation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'photo validation, stale options, and duplicate submit are safe',
    () async {
      final repo = FakeTickets();
      final c = TicketCreationController(repo);
      await c.loadDepartments();
      final first = c.selectDepartment(1);
      final second = c.selectDepartment(2);
      repo.releaseCategories();
      await Future.wait([first, second]);
      expect(c.selectedDepartmentId, 2);
      expect(c.categories.single.name, 'Plumbing');
      expect(
        c.setPhotos(
          List.generate(
            6,
            (i) => SelectedPhoto(
              name: '$i.png',
              mimeType: 'image/png',
              bytes: pngBytes(),
            ),
          ),
        ),
        isFalse,
      );
      c.selectCategory(20);
      c.setPhotos([
        SelectedPhoto(name: 'x.png', mimeType: 'image/png', bytes: pngBytes()),
      ]);
      final a = c.submit(
        title: 'Leak',
        description: 'Water',
        priority: 'high',
        location: 'Floor 2',
      );
      final b = c.submit(
        title: 'Leak',
        description: 'Water',
        priority: 'high',
        location: 'Floor 2',
      );
      await Future.wait([a, b]);
      expect(repo.creates, 1);
      expect(c.state.status, TicketCreationStatus.success);
    },
  );

  testWidgets('creation widget preserves input and reports server errors', (
    tester,
  ) async {
    final repo = FakeTickets()
      ..failure = const TicketFailure(TicketFailureKind.server, 'Try again.');
    final c = TicketCreationController(repo);
    await tester.pumpWidget(
      MaterialApp(home: CreateTicketScreen(controller: c)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ticket_title')),
      'Leaking pipe',
    );
    c.selectedDepartmentId = 1;
    c.selectedCategoryId = 10;
    await tester.tap(find.byKey(const Key('ticket_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Try again.'), findsOneWidget);
    expect(find.text('Leaking pipe'), findsOneWidget);
  });
}

class FakeTickets implements TicketRepository {
  int creates = 0;
  TicketFailure? failure;
  final _waiters = <void Function()>[];
  void releaseCategories() {
    for (final w in _waiters) w();
    _waiters.clear();
  }

  @override
  Future<List<TicketOption>> departments() async => const [
    TicketOption(1, 'Facilities'),
    TicketOption(2, 'Operations'),
  ];
  @override
  Future<List<TicketOption>> categories(int id) async {
    final completer = Completer<void>();
    _waiters.add(completer.complete);
    await completer.future;
    return [TicketOption(id * 10, id == 2 ? 'Plumbing' : 'Electrical')];
  }

  @override
  Future<TicketDetail> create(CreateTicketInput input) async {
    creates++;
    if (failure case final f?) throw f;
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return detailValue;
  }

  @override
  Future<TicketDetail> detail(String reference) async => detailValue;
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) async =>
      const TicketPage([], currentPage: 1, lastPage: 1, total: 0);
}

final detailValue = TicketDetail(
  reference: 'TKT-ABCDEFGHIJKL',
  title: 'Leak',
  status: 'new',
  priority: 'high',
  department: const TicketOption(1, 'Facilities'),
  category: const TicketOption(10, 'Plumbing'),
  createdAt: DateTime.utc(2026),
  description: 'Water',
  location: 'Floor 2',
  photos: const [],
  updatedAt: DateTime.utc(2026),
);

Uint8List pngBytes() =>
    Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
