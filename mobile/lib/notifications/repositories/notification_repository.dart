import '../../auth/services/token_store.dart';
import '../models/notification_models.dart';
import '../services/notification_api_service.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> list();
  Future<int> unreadCount();
  Future<AppNotification> markRead(int id);
  Future<int> markAllRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api, this._tokenStore);

  final NotificationApiService _api;
  final TokenStore _tokenStore;

  Future<String> _token() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      throw const NotificationFailure(
        NotificationFailureKind.unauthenticated,
        'انتهت الجلسة. سجل الدخول مرة أخرى.',
      );
    }
    return token;
  }

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on NotificationFailure {
      rethrow;
    } catch (_) {
      throw const NotificationFailure(
        NotificationFailureKind.contract,
        'تعذر معالجة بيانات الإشعارات.',
      );
    }
  }

  @override
  Future<List<AppNotification>> list() async {
    final envelope = await _api.list(await _token());
    return _parse(() {
      final data = envelope['data'];
      if (data is! List) throw const FormatException();
      final items = data
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
      items.sort((a, b) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });
      return items;
    });
  }

  @override
  Future<int> unreadCount() async {
    final envelope = await _api.unreadCount(await _token());
    return _parse(() {
      final data = envelope['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return data['unread_count'] as int;
    });
  }

  @override
  Future<AppNotification> markRead(int id) async {
    final envelope = await _api.markRead(await _token(), id);
    return _parse(
      () => AppNotification.fromJson(envelope['data'] as Map<String, dynamic>),
    );
  }

  @override
  Future<int> markAllRead() async {
    final envelope = await _api.markAllRead(await _token());
    return _parse(() {
      final data = envelope['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return data['updated_count'] as int;
    });
  }
}
