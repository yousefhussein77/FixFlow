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

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _registering = false;

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

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    if (state.status == AuthViewStatus.restoring) {
      return const FixFlowPage(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixFlowLogo(size: 48),
            SizedBox(height: FixFlowSpacing.lg),
            FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'Restoring your session',
            ),
          ],
        ),
      );
    }
    if (state.status == AuthViewStatus.authenticated ||
        (state.isLoading && state.profile != null)) {
      return ProfileScreen(
        controller: widget.controller,
        referenceController: widget.referenceController,
        ticketRepository: widget.ticketRepository,
        adminTicketRepository: widget.adminTicketRepository,
        technicianTicketRepository: widget.technicianTicketRepository,
        ticketCommentRepository: widget.ticketCommentRepository,
        ticketRatingRepository: widget.ticketRatingRepository,
        ticketPhotoPicker: widget.ticketPhotoPicker,
      );
    }
    if (state.status == AuthViewStatus.offline ||
        state.status == AuthViewStatus.serverError ||
        state.status == AuthViewStatus.storageError) {
      final kind = state.status == AuthViewStatus.offline
          ? FixFlowStateKind.offline
          : FixFlowStateKind.serverError;
      return FixFlowPage(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FixFlowLogo(size: 48),
            const SizedBox(height: FixFlowSpacing.lg),
            FixFlowStateView(
              kind: kind,
              title: 'Unable to restore your session',
              message: state.message,
              actionLabel: 'Retry',
              actionKey: const Key('session_retry'),
              onAction: widget.controller.restore,
            ),
            const SizedBox(height: FixFlowSpacing.sm),
            FixFlowButton(
              label: 'Sign out locally',
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
