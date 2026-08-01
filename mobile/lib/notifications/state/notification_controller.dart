import 'package:flutter/foundation.dart';

import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';

enum NotificationViewStatus {
  initial,
  loading,
  loaded,
  empty,
  offline,
  unauthorized,
  error,
}

class NotificationState {
  const NotificationState({
    this.status = NotificationViewStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.message,
    this.isMutating = false,
  });

  final NotificationViewStatus status;
  final List<AppNotification> items;
  final int unreadCount;
  final String? message;
  final bool isMutating;

  NotificationState copyWith({
    NotificationViewStatus? status,
    List<AppNotification>? items,
    int? unreadCount,
    String? message,
    bool clearMessage = false,
    bool? isMutating,
  }) => NotificationState(
    status: status ?? this.status,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    message: clearMessage ? null : message ?? this.message,
    isMutating: isMutating ?? this.isMutating,
  );
}

class NotificationController extends ChangeNotifier {
  NotificationController(this._repository);

  final NotificationRepository _repository;
  NotificationState _state = const NotificationState();
  bool _loading = false;
  bool _disposed = false;

  NotificationState get state => _state;

  Future<void> load({bool silent = false}) async {
    if (_loading) return;
    _loading = true;
    if (!silent && _state.items.isEmpty) {
      _state = _state.copyWith(
        status: NotificationViewStatus.loading,
        clearMessage: true,
      );
      _notify();
    }
    try {
      final results = await Future.wait<dynamic>([
        _repository.list(),
        _repository.unreadCount(),
      ]);
      final items = results[0] as List<AppNotification>;
      _state = NotificationState(
        status: items.isEmpty
            ? NotificationViewStatus.empty
            : NotificationViewStatus.loaded,
        items: items,
        unreadCount: results[1] as int,
      );
    } on NotificationFailure catch (failure) {
      _state = _state.copyWith(
        status: _statusFor(failure.kind),
        message: failure.message,
      );
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<bool> markRead(AppNotification notification) async {
    if (notification.isRead || _state.isMutating) return notification.isRead;
    _state = _state.copyWith(isMutating: true, clearMessage: true);
    _notify();
    try {
      final updated = await _repository.markRead(notification.id);
      _state = _state.copyWith(
        items: [
          for (final item in _state.items)
            if (item.id == updated.id) updated else item,
        ],
        unreadCount: (_state.unreadCount - 1).clamp(0, 1 << 31),
        isMutating: false,
      );
      _notify();
      return true;
    } on NotificationFailure catch (failure) {
      _state = _state.copyWith(message: failure.message, isMutating: false);
      _notify();
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (_state.unreadCount == 0 || _state.isMutating) return false;
    _state = _state.copyWith(isMutating: true, clearMessage: true);
    _notify();
    try {
      await _repository.markAllRead();
      final now = DateTime.now();
      _state = _state.copyWith(
        items: [
          for (final item in _state.items)
            if (item.isRead) item else item.copyWith(readAt: now),
        ],
        unreadCount: 0,
        isMutating: false,
      );
      _notify();
      return true;
    } on NotificationFailure catch (failure) {
      _state = _state.copyWith(message: failure.message, isMutating: false);
      _notify();
      return false;
    }
  }

  NotificationViewStatus _statusFor(NotificationFailureKind kind) =>
      switch (kind) {
        NotificationFailureKind.offline => NotificationViewStatus.offline,
        NotificationFailureKind.unauthenticated ||
        NotificationFailureKind.unauthorized =>
          NotificationViewStatus.unauthorized,
        _ => NotificationViewStatus.error,
      };

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
