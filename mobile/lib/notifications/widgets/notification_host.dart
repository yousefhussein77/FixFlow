import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';
import '../state/notification_controller.dart';

typedef NotificationNavigationHandler =
    Future<String?> Function(BuildContext context, AppNotification item);

class NotificationScope extends InheritedNotifier<NotificationController> {
  const NotificationScope({
    required NotificationController controller,
    required this.onNavigate,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  final NotificationNavigationHandler onNavigate;

  static NotificationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NotificationScope>();
}

class NotificationHost extends StatefulWidget {
  const NotificationHost({
    required this.repository,
    required this.onNavigate,
    required this.child,
    this.refreshInterval = const Duration(minutes: 1),
    super.key,
  });

  final NotificationRepository repository;
  final NotificationNavigationHandler onNavigate;
  final Widget child;
  final Duration refreshInterval;

  @override
  State<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends State<NotificationHost>
    with WidgetsBindingObserver {
  late final NotificationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = NotificationController(widget.repository)..load();
    _timer = Timer.periodic(
      widget.refreshInterval,
      (_) => _controller.load(silent: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.load(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NotificationScope(
    controller: _controller,
    onNavigate: widget.onNavigate,
    child: widget.child,
  );
}
