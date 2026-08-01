import 'package:fixflow/design_system/layout/fixflow_page.dart';
import 'package:fixflow/notifications/models/notification_models.dart';
import 'package:fixflow/notifications/repositories/notification_repository.dart';
import 'package:fixflow/notifications/widgets/notification_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('refreshes periodically and when returning to foreground', (
    tester,
  ) async {
    final repository = _Repository([]);
    await _pump(
      tester,
      repository: repository,
      refreshInterval: const Duration(minutes: 1),
    );
    await tester.pump();
    expect(repository.listCalls, 1);

    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(repository.listCalls, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(repository.listCalls, 3);
  });

  testWidgets('bell badge opens Arabic list and marks one or all read', (
    tester,
  ) async {
    final repository = _Repository([_item(2), _item(1)]);
    await _pump(tester, repository: repository);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notification_bell')), findsOneWidget);
    expect(find.byKey(const Key('notification_badge')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    expect(find.text('الإشعارات'), findsWidgets);
    expect(find.byKey(const Key('notification_list')), findsOneWidget);

    await tester.tap(find.byKey(const Key('mark_notification_2_read')));
    await tester.pumpAndSettle();
    expect(repository.readIds, [2]);

    await tester.tap(find.byKey(const Key('mark_all_notifications_read')));
    await tester.pumpAndSettle();
    expect(repository.markedAll, isTrue);
  });

  testWidgets('notification tap marks read and navigates once', (tester) async {
    final repository = _Repository([_item(4)]);
    var navigations = 0;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _pump(
      tester,
      repository: repository,
      onNavigate: (context, item) async {
        navigations++;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const Text('وجهة التذكرة')),
        );
        return null;
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_4')));
    await tester.pumpAndSettle();

    expect(navigations, 1);
    expect(repository.readIds, [4]);
    expect(find.text('وجهة التذكرة'), findsOneWidget);
  });

  testWidgets('invalid destination shows safe Arabic error without crashing', (
    tester,
  ) async {
    await _pump(
      tester,
      repository: _Repository([_item(5)]),
      onNavigate: (_, _) async => 'تعذر فتح العنصر المرتبط. قد يكون غير متاح.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_5')));
    await tester.pumpAndSettle();

    expect(find.textContaining('تعذر فتح العنصر المرتبط'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty offline and responsive RTL states are accessible', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pump(
      tester,
      repository: _Repository([]),
      mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد إشعارات'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('لا توجد إشعارات'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _pump(
      tester,
      repository: _Repository(
        const [],
        failure: const NotificationFailure(
          NotificationFailureKind.offline,
          'تعذر الاتصال بالخادم.',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification_bell')));
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد اتصال بالشبكة'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required _Repository repository,
  Future<String?> Function(BuildContext, AppNotification)? onNavigate,
  MediaQueryData? mediaQuery,
  Duration refreshInterval = const Duration(days: 1),
}) => tester.pumpWidget(
  MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: MediaQuery(
      data: mediaQuery ?? const MediaQueryData(),
      child: NotificationHost(
        repository: repository,
        refreshInterval: refreshInterval,
        onNavigate: onNavigate ?? (_, _) async => null,
        child: const FixFlowPage(
          title: Text('الرئيسية'),
          body: Text('المحتوى'),
        ),
      ),
    ),
  ),
);

AppNotification _item(int id) => AppNotification(
  id: id,
  type: 'ticket.created',
  title: 'إشعار $id',
  message: 'رسالة الإشعار',
  navigationTarget: 'admin.tickets',
  payload: const {'ticket_reference': 'TKT-1'},
  createdAt: DateTime.utc(2026, 8, id),
);

class _Repository implements NotificationRepository {
  _Repository(this.items, {this.failure});
  List<AppNotification> items;
  final NotificationFailure? failure;
  final List<int> readIds = [];
  bool markedAll = false;
  int listCalls = 0;

  void _fail() {
    if (failure != null) throw failure!;
  }

  @override
  Future<List<AppNotification>> list() async {
    _fail();
    listCalls++;
    return List.of(items);
  }

  @override
  Future<int> unreadCount() async {
    _fail();
    return items.where((item) => !item.isRead).length;
  }

  @override
  Future<AppNotification> markRead(int id) async {
    _fail();
    readIds.add(id);
    final index = items.indexWhere((item) => item.id == id);
    items[index] = items[index].copyWith(readAt: DateTime.utc(2026));
    return items[index];
  }

  @override
  Future<int> markAllRead() async {
    _fail();
    markedAll = true;
    final count = items.where((item) => !item.isRead).length;
    items = [
      for (final item in items)
        if (item.isRead) item else item.copyWith(readAt: DateTime.utc(2026)),
    ];
    return count;
  }
}
