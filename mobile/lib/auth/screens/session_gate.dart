import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import 'profile_screen.dart';
import 'register_screen.dart';
import 'sign_in_screen.dart';
import '../../reference_data/state/reference_controller.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/repositories/admin_ticket_repository.dart';
import '../../tickets/repositories/technician_ticket_repository.dart';
import '../../tickets/repositories/ticket_comment_repository.dart';
import '../../tickets/repositories/ticket_rating_repository.dart';
import '../../tickets/services/ticket_photo_picker.dart';
import '../../design_system/brand/fixflow_logo.dart';
import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../../tickets/screens/administrator_dashboard_screen.dart';
import '../../design_system/theme/fixflow_theme_controller.dart';
import '../../accounts/repositories/account_request_repository.dart';
import '../../accounts/screens/account_requests_screen.dart';
import '../../notifications/models/notification_models.dart';
import '../../notifications/repositories/notification_repository.dart';
import '../../notifications/screens/account_status_notification_screen.dart';
import '../../notifications/widgets/notification_host.dart';
import '../../tickets/screens/admin_ticket_list_screen.dart';
import '../../tickets/screens/technician_ticket_details_screen.dart';
import '../../tickets/screens/ticket_details_screen.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({
    required this.controller,
    this.referenceController,
    this.ticketRepository,
    this.adminTicketRepository,
    this.technicianTicketRepository,
    this.ticketCommentRepository,
    this.ticketRatingRepository,
    this.ticketPhotoPicker,
    this.themeController,
    this.accountRequestRepository,
    this.notificationRepository,
    super.key,
  });
  final AuthController controller;
  final ReferenceController? referenceController;
  final TicketRepository? ticketRepository;
  final AdminTicketRepository? adminTicketRepository;
  final TechnicianTicketRepository? technicianTicketRepository;
  final TicketCommentRepository? ticketCommentRepository;
  final TicketRatingRepository? ticketRatingRepository;
  final TicketPhotoPicker? ticketPhotoPicker;
  final ThemeController? themeController;
  final AccountRequestRepository? accountRequestRepository;
  final NotificationRepository? notificationRepository;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _registering = false;
  String? _activeNotificationDestination;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<String?> _openNotification(
    BuildContext context,
    AppNotification item,
  ) async {
    const unavailable =
        'تعذر فتح العنصر المرتبط. قد يكون غير متاح أو لا تملك صلاحية الوصول إليه.';
    final target = item.navigationTarget;
    final reference = item.payload['ticket_reference'];
    final destinationKey = '$target:${reference ?? item.relatedEntityId ?? ''}';
    if (_activeNotificationDestination == destinationKey) {
      Navigator.of(context).pop();
      return null;
    }
    try {
      Widget? destination;
      if (target == 'admin.account_requests' &&
          widget.accountRequestRepository != null) {
        destination = AccountRequestsScreen(
          repository: widget.accountRequestRepository!,
        );
      } else if (target == 'admin.tickets' &&
          widget.adminTicketRepository != null) {
        destination = AdminTicketListScreen(
          repository: widget.adminTicketRepository!,
          commentRepository: widget.ticketCommentRepository,
        );
      } else if (target == 'account.status') {
        final status = item.payload['account_status'];
        if (status is! String ||
            !const {'approved', 'rejected'}.contains(status)) {
          return unavailable;
        }
        destination = AccountStatusNotificationScreen(status: status);
      } else if (target.startsWith('reporter.ticket') &&
          reference is String &&
          reference.isNotEmpty &&
          widget.ticketRepository != null) {
        await widget.ticketRepository!.detail(reference);
        destination = TicketDetailsScreen(
          repository: widget.ticketRepository!,
          reference: reference,
          commentRepository: widget.ticketCommentRepository,
          ratingRepository: widget.ticketRatingRepository,
        );
      } else if (target.startsWith('technician.ticket') &&
          reference is String &&
          reference.isNotEmpty &&
          widget.technicianTicketRepository != null) {
        await widget.technicianTicketRepository!.details(reference);
        destination = TechnicianTicketDetailsScreen(
          repository: widget.technicianTicketRepository!,
          reference: reference,
          commentRepository: widget.ticketCommentRepository,
        );
      }
      if (destination == null) return unavailable;
      if (!context.mounted) return null;
      final scope = NotificationScope.maybeOf(context);
      _activeNotificationDestination = destinationKey;
      try {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            settings: RouteSettings(name: '/notification/$destinationKey'),
            builder: (_) => scope == null
                ? destination!
                : NotificationScope(
                    controller: scope.notifier!,
                    onNavigate: scope.onNavigate,
                    child: destination!,
                  ),
          ),
        );
      } finally {
        if (_activeNotificationDestination == destinationKey) {
          _activeNotificationDestination = null;
        }
      }
      return null;
    } catch (_) {
      return unavailable;
    }
  }

  Widget _withNotifications(Widget child) {
    final repository = widget.notificationRepository;
    if (repository == null) return child;
    return NotificationHost(
      repository: repository,
      onNavigate: _openNotification,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    if (state.status == AuthViewStatus.restoring) {
      return const FixFlowPage(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixFlowBitmapLogo.mark(size: 130),
            SizedBox(height: FixFlowSpacing.lg),
            FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'جارٍ استعادة جلستك',
            ),
          ],
        ),
      );
    }
    if (state.status == AuthViewStatus.authenticated ||
        (state.isLoading && state.profile != null)) {
      if (state.profile?.role == 'administrator' &&
          widget.adminTicketRepository != null) {
        return _withNotifications(
          AdministratorDashboardScreen(
            authController: widget.controller,
            repository: widget.adminTicketRepository!,
            referenceController: widget.referenceController,
            commentRepository: widget.ticketCommentRepository,
            themeController: widget.themeController,
            accountRequestRepository: widget.accountRequestRepository,
          ),
        );
      }
      return _withNotifications(
        ProfileScreen(
          controller: widget.controller,
          referenceController: widget.referenceController,
          ticketRepository: widget.ticketRepository,
          adminTicketRepository: widget.adminTicketRepository,
          technicianTicketRepository: widget.technicianTicketRepository,
          ticketCommentRepository: widget.ticketCommentRepository,
          ticketRatingRepository: widget.ticketRatingRepository,
          ticketPhotoPicker: widget.ticketPhotoPicker,
        ),
      );
    }
    if (state.isRestoreFailure &&
        (state.status == AuthViewStatus.offline ||
            state.status == AuthViewStatus.serverError ||
            state.status == AuthViewStatus.storageError)) {
      final kind = state.status == AuthViewStatus.offline
          ? FixFlowStateKind.offline
          : FixFlowStateKind.serverError;
      return FixFlowPage(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FixFlowBitmapLogo.mark(size: 130),
            const SizedBox(height: FixFlowSpacing.lg),
            FixFlowStateView(
              kind: kind,
              title: 'تعذر استعادة جلستك',
              message: state.message,
              actionLabel: 'إعادة المحاولة',
              actionKey: const Key('session_retry'),
              onAction: widget.controller.restore,
            ),
            const SizedBox(height: FixFlowSpacing.sm),
            FixFlowButton(
              label: 'تسجيل الخروج محلياً',
              variant: FixFlowButtonVariant.text,
              onPressed: widget.controller.logout,
            ),
          ],
        ),
      );
    }
    if (_registering) {
      return RegisterScreen(
        controller: widget.controller,
        onShowSignIn: () => setState(() => _registering = false),
      );
    }
    return SignInScreen(
      controller: widget.controller,
      onShowRegister: () => setState(() => _registering = true),
    );
  }
}
