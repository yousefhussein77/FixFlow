import 'package:fixflow/accounts/models/account_request_models.dart';
import 'package:fixflow/accounts/repositories/account_request_repository.dart';
import 'package:fixflow/accounts/screens/account_requests_screen.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('account requests refresh by pull without a refresh button', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      _host(AccountRequestsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(repository.listCalls, 1);
    expect(find.byIcon(Icons.refresh), findsNothing);

    final indicator = find.byKey(const Key('fixflow_pull_to_refresh'));
    expect(indicator, findsOneWidget);
    await tester.drag(indicator, const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.text('مستخدم جديد'), findsOneWidget);
  });

  testWidgets(
    'administrator can confirm approval and refreshed list is empty',
    (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(
        _host(AccountRequestsScreen(repository: repository)),
      );
      await tester.pumpAndSettle();

      expect(find.text('مستخدم جديد'), findsOneWidget);
      await tester.tap(find.byKey(const Key('approve_account_9')));
      await tester.pumpAndSettle();
      expect(find.text('اعتماد طلب الحساب؟'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_account_approval')));
      await tester.pumpAndSettle();

      expect(repository.approveCalls, 1);
      expect(repository.listCalls, 2);
      expect(find.textContaining('لا توجد طلبات'), findsOneWidget);
    },
  );

  testWidgets('administrator can provide an optional rejection reason', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      _host(AccountRequestsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reject_account_9')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('account_rejection_reason')),
      'بيانات ناقصة',
    );
    await tester.tap(find.byKey(const Key('confirm_account_rejection')));
    await tester.pumpAndSettle();

    expect(repository.rejectCalls, 1);
    expect(repository.reason, 'بيانات ناقصة');
  });

  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('account request list supports RTL at ${width.toInt()}px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: _host(AccountRequestsScreen(repository: _Repository())),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.text('طلبات الحسابات').first)),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('offline failure shows Arabic retry state', (tester) async {
    await tester.pumpWidget(
      _host(
        AccountRequestsScreen(
          repository: _Repository(
            failure: const AccountRequestFailure(
              AccountRequestFailureKind.offline,
              'تعذر الاتصال بالخادم. تأكد من اتصالك ثم حاول مرة أخرى.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('تعذر الاتصال بالخادم'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('stale approval conflict refreshes the authoritative list', (
    tester,
  ) async {
    final repository = _Repository(
      actionFailure: const AccountRequestFailure(
        AccountRequestFailureKind.conflict,
        'تغيرت حالة الطلب. تم تحديث القائمة.',
      ),
    );
    await tester.pumpWidget(
      _host(AccountRequestsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('approve_account_9')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_account_approval')));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.textContaining('تغيرت حالة الطلب'), findsOneWidget);
    expect(find.text('مستخدم جديد'), findsNothing);
  });
}

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  theme: FixFlowTheme.light(),
  home: Directionality(textDirection: TextDirection.rtl, child: child),
);

class _Repository implements AccountRequestRepository {
  _Repository({this.failure, this.actionFailure});

  final AccountRequestFailure? failure;
  final AccountRequestFailure? actionFailure;
  bool removed = false;
  int listCalls = 0;
  int approveCalls = 0;
  int rejectCalls = 0;
  String? reason;

  static final item = AccountRequest(
    id: 9,
    name: 'مستخدم جديد',
    email: 'new@example.com',
    requestedRole: 'technician',
    status: AccountRequestStatus.pending,
    registeredAt: DateTime.utc(2026, 8, 1),
  );

  @override
  Future<List<AccountRequest>> list(AccountRequestStatus status) async {
    listCalls++;
    if (failure != null) throw failure!;
    return removed ? [] : [item];
  }

  @override
  Future<AccountRequest> approve(int id) async {
    approveCalls++;
    removed = true;
    if (actionFailure != null) throw actionFailure!;
    return item;
  }

  @override
  Future<AccountRequest> reject(int id, {String? reason}) async {
    rejectCalls++;
    this.reason = reason;
    removed = true;
    if (actionFailure != null) throw actionFailure!;
    return item;
  }
}
