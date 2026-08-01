import 'package:fixflow/notifications/models/notification_models.dart';
import 'package:fixflow/notifications/repositories/notification_repository.dart';
import 'package:fixflow/notifications/state/notification_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads newest notifications and updates read state immediately',
    () async {
      final repository = _FakeNotificationRepository([
        _item(2, DateTime.utc(2026, 8, 2)),
        _item(1, DateTime.utc(2026, 8, 1)),
      ]);
      final controller = NotificationController(repository);

      await controller.load();

      expect(controller.state.status, NotificationViewStatus.loaded);
      expect(controller.state.unreadCount, 2);
      expect(controller.state.items.map((item) => item.id), [2, 1]);

      expect(await controller.markRead(controller.state.items.first), isTrue);
      expect(controller.state.unreadCount, 1);
      expect(controller.state.items.first.isRead, isTrue);

      expect(await controller.markAllRead(), isTrue);
      expect(controller.state.unreadCount, 0);
      expect(controller.state.items.every((item) => item.isRead), isTrue);
    },
  );

  test('maps empty offline and unauthorized states safely', () async {
    final empty = NotificationController(_FakeNotificationRepository([]));
    await empty.load();
    expect(empty.state.status, NotificationViewStatus.empty);

    for (final entry in {
      NotificationFailureKind.offline: NotificationViewStatus.offline,
      NotificationFailureKind.unauthorized: NotificationViewStatus.unauthorized,
      NotificationFailureKind.server: NotificationViewStatus.error,
    }.entries) {
      final controller = NotificationController(
        _FakeNotificationRepository(
          const [],
          failure: NotificationFailure(entry.key, 'رسالة آمنة'),
        ),
      );
      await controller.load();
      expect(controller.state.status, entry.value);
      expect(controller.state.message, 'رسالة آمنة');
    }
  });

  test('failed read preserves unread state and exposes safe message', () async {
    final repository = _FakeNotificationRepository([
      _item(1, DateTime.utc(2026)),
    ]);
    final controller = NotificationController(repository);
    await controller.load();
    repository.failure = const NotificationFailure(
      NotificationFailureKind.offline,
      'تعذر الاتصال بالخادم.',
    );

    expect(await controller.markRead(controller.state.items.single), isFalse);
    expect(controller.state.unreadCount, 1);
    expect(controller.state.items.single.isRead, isFalse);
    expect(controller.state.message, 'تعذر الاتصال بالخادم.');
  });
}

AppNotification _item(int id, DateTime date) => AppNotification(
  id: id,
  type: 'ticket.assigned',
  title: 'تذكرة جديدة',
  message: 'تم إسناد تذكرة إليك.',
  navigationTarget: 'technician.ticket',
  payload: const {'ticket_reference': 'TKT-1'},
  createdAt: date,
);

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository(this.items, {this.failure});

  List<AppNotification> items;
  NotificationFailure? failure;

  void _fail() {
    if (failure != null) throw failure!;
  }

  @override
  Future<List<AppNotification>> list() async {
    _fail();
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
    final index = items.indexWhere((item) => item.id == id);
    items[index] = items[index].copyWith(readAt: DateTime.utc(2026, 8, 2));
    return items[index];
  }

  @override
  Future<int> markAllRead() async {
    _fail();
    final count = items.where((item) => !item.isRead).length;
    items = [
      for (final item in items)
        if (item.isRead) item else item.copyWith(readAt: DateTime.utc(2026)),
    ];
    return count;
  }
}
