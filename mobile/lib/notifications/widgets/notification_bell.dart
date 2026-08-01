import 'package:flutter/material.dart';

import '../screens/notification_center_screen.dart';
import 'notification_host.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = NotificationScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final count = scope.notifier?.state.unreadCount ?? 0;
    final badge = count > 99 ? '99+' : '$count';
    return Semantics(
      button: true,
      label: count == 0 ? 'الإشعارات' : 'الإشعارات، $count غير مقروءة',
      child: IconButton(
        key: const Key('notification_bell'),
        tooltip: 'الإشعارات',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/notifications'),
            builder: (_) => NotificationScope(
              controller: scope.notifier!,
              onNavigate: scope.onNavigate,
              child: NotificationCenterScreen(
                controller: scope.notifier!,
                onNavigate: scope.onNavigate,
              ),
            ),
          ),
        ),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            if (count > 0)
              PositionedDirectional(
                top: -7,
                end: -10,
                child: Container(
                  key: const Key('notification_badge'),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    badge,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
