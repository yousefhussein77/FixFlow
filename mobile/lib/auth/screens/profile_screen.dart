import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/navigation/fixflow_role_shell.dart';
import '../../design_system/components/overlays/fixflow_dialogs.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../../reference_data/screens/category_screen.dart';
import '../../reference_data/screens/department_screen.dart';
import '../../reference_data/state/reference_controller.dart';
import '../../tickets/repositories/admin_ticket_repository.dart';
import '../../tickets/repositories/technician_ticket_repository.dart';
import '../../tickets/repositories/ticket_comment_repository.dart';
import '../../tickets/repositories/ticket_rating_repository.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/screens/admin_ticket_list_screen.dart';
import '../../tickets/screens/assigned_tickets_screen.dart';
import '../../tickets/screens/create_ticket_screen.dart';
import '../../tickets/screens/my_tickets_screen.dart';
import '../../tickets/services/ticket_photo_picker.dart';
import '../../tickets/state/ticket_creation_controller.dart';
import '../state/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _shellController = FixFlowRoleShellController();

  @override
  Widget build(BuildContext context) {
    final role = widget.controller.state.profile?.role;
    final destinations = <FixFlowRoleDestination>[];
    destinations.add(
      FixFlowRoleDestination(
        label: 'الحساب',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        builder: (_) => _ProfileOverview(
          controller: widget.controller,
          referenceController: widget.referenceController,
          adminTicketRepository: widget.adminTicketRepository,
          onReporterTickets:
              role == 'reporter' && widget.ticketRepository != null
              ? () => _shellController.selectDestination(1)
              : null,
          onCreateTicket: role == 'reporter' && widget.ticketRepository != null
              ? () => _shellController.selectDestination(2)
              : null,
          onAssignedTickets:
              role == 'technician' && widget.technicianTicketRepository != null
              ? () => _shellController.selectDestination(1)
              : null,
        ),
      ),
    );
    if (role == 'reporter' && widget.ticketRepository != null) {
      destinations.addAll([
        FixFlowRoleDestination(
          label: 'تذاكري',
          icon: Icons.list_alt_outlined,
          selectedIcon: Icons.list_alt,
          builder: (_) => MyTicketsScreen(
            repository: widget.ticketRepository!,
            commentRepository: widget.ticketCommentRepository,
            ratingRepository: widget.ticketRatingRepository,
          ),
        ),
        FixFlowRoleDestination(
          label: 'إنشاء',
          icon: Icons.add_circle_outline,
          selectedIcon: Icons.add_circle,
          builder: (_) => CreateTicketScreen(
            controller: TicketCreationController(widget.ticketRepository!),
            pickPhotos: widget.ticketPhotoPicker?.pick,
          ),
        ),
      ]);
    }
    if (role == 'technician' && widget.technicianTicketRepository != null) {
      destinations.add(
        FixFlowRoleDestination(
          label: 'المسندة',
          icon: Icons.assignment_ind_outlined,
          selectedIcon: Icons.assignment_ind,
          builder: (_) => AssignedTicketsScreen(
            repository: widget.technicianTicketRepository!,
            commentRepository: widget.ticketCommentRepository,
          ),
        ),
      );
    }
    return FixFlowRoleShell(
      controller: _shellController,
      destinations: destinations,
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({
    required this.controller,
    this.referenceController,
    this.adminTicketRepository,
    this.onReporterTickets,
    this.onCreateTicket,
    this.onAssignedTickets,
  });

  final AuthController controller;
  final ReferenceController? referenceController;
  final AdminTicketRepository? adminTicketRepository;
  final VoidCallback? onReporterTickets;
  final VoidCallback? onCreateTicket;
  final VoidCallback? onAssignedTickets;

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showFixFlowConfirmationDialog(
      context: context,
      title: 'تسجيل الخروج؟',
      message: 'ستحتاج إلى تسجيل الدخول مجدداً للمتابعة.',
      confirmLabel: 'تسجيل الخروج',
      destructive: true,
    );
    if (confirmed) await controller.logout();
  }

  String _roleLabel(String role) => switch (role) {
    'reporter' => 'مُبلّغ',
    'technician' => 'فني',
    'administrator' => 'مسؤول',
    _ => role,
  };

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final state = controller.state;
      final profile = state.profile;
      return FixFlowPage(
        title: const Text('ملفي الشخصي'),
        onRefresh: state.isLoading ? () async {} : controller.refreshProfile,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (profile != null) ...[
              FixFlowSurface(
                child: Column(
                  children: [
                    FixFlowAvatar(name: profile.name),
                    const SizedBox(height: FixFlowSpacing.sm),
                    Text(
                      profile.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: FixFlowSpacing.xs),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(profile.email, textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: FixFlowSpacing.xs),
                    Chip(
                      avatar: const Icon(Icons.verified_user_outlined),
                      label: Text(_roleLabel(profile.role)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FixFlowSpacing.md),
              if (onCreateTicket != null) ...[
                FixFlowButton(
                  buttonKey: const Key('create_ticket'),
                  label: 'إنشاء تذكرة',
                  icon: Icons.add,
                  onPressed: onCreateTicket,
                ),
                const SizedBox(height: FixFlowSpacing.xs),
              ],
              if (onReporterTickets != null)
                FixFlowButton(
                  buttonKey: const Key('my_tickets'),
                  label: 'تذاكري',
                  variant: FixFlowButtonVariant.outline,
                  icon: Icons.list_alt_outlined,
                  onPressed: onReporterTickets,
                ),
              if (profile.role == 'administrator') ...[
                if (adminTicketRepository != null)
                  FixFlowButton(
                    buttonKey: const Key('admin_tickets'),
                    label: 'كل التذاكر',
                    icon: Icons.inbox_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminTicketListScreen(
                          repository: adminTicketRepository!,
                        ),
                      ),
                    ),
                  ),
                if (referenceController != null) ...[
                  const SizedBox(height: FixFlowSpacing.xs),
                  FixFlowButton(
                    buttonKey: const Key('manage_departments'),
                    label: 'إدارة الأقسام',
                    icon: Icons.apartment_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DepartmentScreen(controller: referenceController!),
                      ),
                    ),
                  ),
                  const SizedBox(height: FixFlowSpacing.xs),
                  FixFlowButton(
                    buttonKey: const Key('manage_categories'),
                    label: 'إدارة الفئات',
                    variant: FixFlowButtonVariant.outline,
                    icon: Icons.category_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryScreen(controller: referenceController!),
                      ),
                    ),
                  ),
                ],
              ],
              if (onAssignedTickets != null)
                FixFlowButton(
                  buttonKey: const Key('assigned_tickets'),
                  label: 'التذاكر المسندة',
                  icon: Icons.assignment_ind_outlined,
                  onPressed: onAssignedTickets,
                ),
            ],
            if (state.message != null) ...[
              const SizedBox(height: FixFlowSpacing.sm),
              Text(
                state.message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: controller.refreshProfile,
                child: const Text('إعادة المحاولة'),
              ),
            ],
            const SizedBox(height: FixFlowSpacing.xl),
            FixFlowButton(
              buttonKey: const Key('logout_submit'),
              label: 'تسجيل الخروج',
              variant: FixFlowButtonVariant.outline,
              icon: Icons.logout,
              onPressed: state.isLoading ? null : () => _signOut(context),
            ),
          ],
        ),
      );
    },
  );
}
