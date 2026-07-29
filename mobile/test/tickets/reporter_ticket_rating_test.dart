import 'package:fixflow/tickets/models/ticket_rating_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/ticket_rating_repository.dart';
import 'package:fixflow/tickets/widgets/ticket_rating_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';

void main() {
  testWidgets('completed unrated ticket requires selection then shows rating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketRatingSection(
            key: const ValueKey('rated'),
            repository: _Repository(),
            reference: 'TKT-9',
            completed: true,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('rating_input')), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.tap(find.byKey(const Key('rating_submit')));
    await tester.pumpAndSettle();
    expect(find.text('التقييم: 5/5'), findsOneWidget);
    expect(find.textContaining('review'), findsNothing);
  });

  testWidgets('non-completed and already-rated are read only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketRatingSection(
            repository: _Repository(),
            reference: 'T',
            completed: false,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('rating_ineligible')), findsOneWidget);
    expect(find.byKey(const Key('rating_submit')), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketRatingSection(
            key: const ValueKey('already-rated'),
            repository: _Repository(),
            reference: 'T',
            completed: true,
            rating: TicketRating(value: 4, ratedAt: DateTime.utc(2026)),
          ),
        ),
      ),
    );
    expect(find.text('التقييم: 4/5'), findsOneWidget);
    expect(find.byKey(const Key('rating_submit')), findsNothing);
  });

  testWidgets('ticket change resets selection token and stale rating state', (
    tester,
  ) async {
    final repository = _RecordingRepository();
    Widget host(String reference, {TicketRating? rating}) => MaterialApp(
      home: Scaffold(
        body: TicketRatingSection(
          repository: repository,
          reference: reference,
          completed: true,
          rating: rating,
        ),
      ),
    );
    await tester.pumpWidget(host('TKT-ONE'));
    await tester.tap(find.text('5'));
    await tester.pumpWidget(host('TKT-TWO'));
    expect(find.byKey(const Key('rating_input')), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.tap(find.byKey(const Key('rating_submit')));
    await tester.pumpAndSettle();
    expect(repository.references, ['TKT-TWO']);
    expect(repository.values, [3]);

    await tester.pumpWidget(
      host(
        'TKT-TWO',
        rating: TicketRating(value: 4, ratedAt: DateTime.utc(2026, 7, 25)),
      ),
    );
    expect(find.text('التقييم: 4/5'), findsOneWidget);
  });

  testWidgets('rating conflicts preserve their message and request refresh', (
    tester,
  ) async {
    for (final conflict in const {
      'RATING_ALREADY_EXISTS': 'This ticket was already rated.',
      'TICKET_NOT_COMPLETED': 'This ticket is not completed.',
    }.entries) {
      var refreshes = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TicketRatingSection(
              repository: _ConflictRepository(conflict.key, conflict.value),
              reference: 'TKT-${conflict.key}',
              completed: true,
              onAccepted: () async => refreshes++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('4'));
      await tester.tap(find.byKey(const Key('rating_submit')));
      await tester.pumpAndSettle();
      expect(find.text(conflict.value), findsOneWidget);
      expect(refreshes, 1);
    }
  });

  testWidgets('rating entry reflows at 320 pixels and 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: TicketRatingSection(
                repository: _Repository(),
                reference: 'TKT-9',
                completed: true,
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('rating_input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Repository implements TicketRatingRepository {
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async => TicketRating(value: rating, ratedAt: DateTime.utc(2026, 7, 25));
}

class _RecordingRepository implements TicketRatingRepository {
  final references = <String>[];
  final values = <int>[];
  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) async {
    references.add(reference);
    values.add(rating);
    return TicketRating(value: rating, ratedAt: DateTime.utc(2026, 7, 25));
  }
}

class _ConflictRepository implements TicketRatingRepository {
  const _ConflictRepository(this.code, this.message);
  final String code;
  final String message;

  @override
  Future<TicketRating> create(
    String reference, {
    required int rating,
    required String submissionToken,
  }) => throw TicketFailure(TicketFailureKind.conflict, message, code: code);
}
