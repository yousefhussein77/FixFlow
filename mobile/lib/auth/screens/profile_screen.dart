import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../../reference_data/screens/department_screen.dart';
import '../../reference_data/screens/category_screen.dart';
import '../../reference_data/state/reference_controller.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/repositories/admin_ticket_repository.dart';
import '../../tickets/repositories/technician_ticket_repository.dart';
import '../../tickets/repositories/ticket_comment_repository.dart';
import '../../tickets/repositories/ticket_rating_repository.dart';
import '../../tickets/screens/assigned_tickets_screen.dart';
import '../../tickets/screens/admin_ticket_list_screen.dart';
import '../../tickets/screens/create_ticket_screen.dart';
import '../../tickets/screens/my_tickets_screen.dart';
import '../../tickets/state/ticket_creation_controller.dart';
import '../../tickets/services/ticket_photo_picker.dart';
import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';

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
    final profile = state.profile;
    return FixFlowPage(
      title: const Text('ملفي الشخصي'),
      actions: [
        FixFlowIconButton(
          key: const Key('profile_refresh'),
          onPressed: state.isLoading ? null : widget.controller.refreshProfile,
          label: 'تحديث الملف الشخصي',
          icon: Icons.refresh,
        ),
      ],
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
                  Text(profile.email, textAlign: TextAlign.center),
                  const SizedBox(height: FixFlowSpacing.xs),
                  Chip(
                    avatar: const Icon(Icons.verified_user_outlined),
                    label: Text(profile.role),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FixFlowSpacing.md),
            if (profile.role == 'reporter' &&
                widget.ticketRepository != null) ...[
              FixFlowButton(
                buttonKey: const Key('create_ticket'),
                label: 'إنشاء تذكرة',
                icon: Icons.add,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateTicketScreen(
                      controller: TicketCreationController(
                        widget.ticketRepository!,
                      ),
                      pickPhotos: widget.ticketPhotoPicker?.pick,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FixFlowSpacing.xs),
              FixFlowButton(
                buttonKey: const Key('my_tickets'),
                label: 'تذاكري',
                variant: FixFlowButtonVariant.outline,
                icon: Icons.list_alt_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyTicketsScreen(
                      repository: widget.ticketRepository!,
                      commentRepository: widget.ticketCommentRepository,
                      ratingRepository: widget.ticketRatingRepository,
                    ),
                  ),
                ),
              ),
            ],
            if (profile.role == 'administrator') ...[
              if (widget.adminTicketRepository != null)
                FixFlowButton(
                  buttonKey: const Key('admin_tickets'),
                  label: 'كل التذاكر',
                  icon: Icons.inbox_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminTicketListScreen(
                        repository: widget.adminTicketRepository!,
                        commentRepository: widget.ticketCommentRepository,
                      ),
                    ),
                  ),
                ),
              if (widget.referenceController != null) ...[
                FixFlowButton(
                  buttonKey: const Key('manage_departments'),
                  label: 'إدارة الأقسام',
                  icon: Icons.apartment_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DepartmentScreen(
                        controller: widget.referenceController!,
                      ),
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
                      builder: (_) => CategoryScreen(
                        controller: widget.referenceController!,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            if (profile.role == 'technician' &&
                widget.technicianTicketRepository != null)
              FixFlowButton(
                buttonKey: const Key('assigned_tickets'),
                label: 'التذاكر المسندة',
                icon: Icons.assignment_ind_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignedTicketsScreen(
                      repository: widget.technicianTicketRepository!,
                      commentRepository: widget.ticketCommentRepository,
                    ),
                  ),
                ),
              ),
          ],
          if (state.message != null) ...[
            Text(
              state.message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: widget.controller.refreshProfile,
              child: const Text('إعادة المحاولة'),
            ),
          ],
          const SizedBox(height: FixFlowSpacing.xl),
          FixFlowButton(
            buttonKey: const Key('logout_submit'),
            label: 'تسجيل الخروج',
            variant: FixFlowButtonVariant.outline,
            icon: Icons.logout,
            onPressed: state.isLoading ? null : widget.controller.logout,
          ),
        ],
      ),
    );
  }
}
