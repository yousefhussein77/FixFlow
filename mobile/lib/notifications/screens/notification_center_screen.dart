import 'package:flutter/material.dart';

import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../../design_system/theme/fixflow_colors.dart';
import '../models/notification_models.dart';
import '../state/notification_controller.dart';
import '../widgets/notification_host.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({
    required this.controller,
    required this.onNavigate,
    super.key,
  });

  final NotificationController controller;
  final NotificationNavigationHandler onNavigate;

  Future<void> _open(BuildContext context, AppNotification item) async {
    if (!item.isRead && !await controller.markRead(item)) {
      if (context.mounted) _showMessage(context, controller.state.message);
      return;
    }
    if (!context.mounted) return;
    final message = await onNavigate(context, item);
    if (context.mounted && message != null) _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'تعذر فتح وجهة الإشعار.')),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final state = controller.state;
      return Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            TextButton.icon(
              key: const Key('mark_all_notifications_read'),
              onPressed: state.unreadCount == 0 || state.isMutating
                  ? null
                  : () async {
                      final success = await controller.markAllRead();
                      if (!success && context.mounted) {
                        _showMessage(context, controller.state.message);
                      }
                    },
              icon: const Icon(Icons.done_all),
              label: const Text('قراءة الكل'),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            key: const Key('notifications_pull_to_refresh'),
            color: FixFlowColors.brandPrimary,
            onRefresh: controller.load,
            child: _body(context, state),
          ),
        ),
      );
    },
  );

  Widget _body(BuildContext context, NotificationState state) {
    if (state.status == NotificationViewStatus.loading ||
        state.status == NotificationViewStatus.initial) {
      return _stateBody(
        const FixFlowStateView(
          kind: FixFlowStateKind.loading,
          title: 'جاري تحميل الإشعارات',
        ),
      );
    }
    if (state.status == NotificationViewStatus.empty) {
      return _stateBody(
        const FixFlowStateView(
          kind: FixFlowStateKind.empty,
          title: 'لا توجد إشعارات',
          message: 'ستظهر هنا التحديثات المهمة عند وصولها.',
        ),
      );
    }
    if (state.status == NotificationViewStatus.offline ||
        state.status == NotificationViewStatus.unauthorized ||
        state.status == NotificationViewStatus.error) {
      return _stateBody(
        FixFlowStateView(
          kind: state.status == NotificationViewStatus.offline
              ? FixFlowStateKind.offline
              : state.status == NotificationViewStatus.unauthorized
              ? FixFlowStateKind.unauthorized
              : FixFlowStateKind.serverError,
          title: state.status == NotificationViewStatus.offline
              ? 'لا يوجد اتصال بالشبكة'
              : state.status == NotificationViewStatus.unauthorized
              ? 'تعذر الوصول إلى الإشعارات'
              : 'تعذر تحميل الإشعارات',
          message: state.message,
          actionLabel: 'إعادة المحاولة',
          onAction: controller.load,
        ),
      );
    }
    return ListView.separated(
      key: const Key('notification_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(FixFlowSpacing.sm),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: FixFlowSpacing.xs),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Card(
          color: item.isRead
              ? null
              : Theme.of(context).colorScheme.primaryContainer.withAlpha(90),
          child: ListTile(
            key: Key('notification_${item.id}'),
            onTap: state.isMutating ? null : () => _open(context, item),
            leading: Icon(
              item.isRead ? Icons.notifications_none : Icons.notifications,
              color: item.isRead
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    _date(item.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            trailing: item.isRead
                ? null
                : IconButton(
                    key: Key('mark_notification_${item.id}_read'),
                    tooltip: 'تحديد كمقروء',
                    onPressed: state.isMutating
                        ? null
                        : () async {
                            final success = await controller.markRead(item);
                            if (!success && context.mounted) {
                              _showMessage(context, controller.state.message);
                            }
                          },
                    icon: const Icon(Icons.done),
                  ),
          ),
        );
      },
    );
  }

  Widget _stateBody(Widget child) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: child),
      ),
    ),
  );

  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${local.year}/${two(local.month)}/${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
