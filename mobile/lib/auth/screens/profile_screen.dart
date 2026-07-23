import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../../reference_data/screens/department_screen.dart';
import '../../reference_data/screens/category_screen.dart';
import '../../reference_data/state/reference_controller.dart';
import '../../tickets/repositories/ticket_repository.dart';
import '../../tickets/screens/create_ticket_screen.dart';
import '../../tickets/screens/my_tickets_screen.dart';
import '../../tickets/state/ticket_creation_controller.dart';
import '../../tickets/services/ticket_photo_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.controller,
    this.referenceController,
    this.ticketRepository,
    this.ticketPhotoPicker,
    super.key,
  });
  final AuthController controller;
  final ReferenceController? referenceController;
  final TicketRepository? ticketRepository;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            key: const Key('profile_refresh'),
            onPressed: state.isLoading
                ? null
                : widget.controller.refreshProfile,
            tooltip: 'Refresh profile',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (profile != null) ...[
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(profile.email),
                const SizedBox(height: 8),
                Text(profile.role),
                if (profile.role == 'reporter' &&
                    widget.ticketRepository != null) ...[
                  FilledButton(
                    key: const Key('create_ticket'),
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
                    child: const Text('Create ticket'),
                  ),
                  OutlinedButton(
                    key: const Key('my_tickets'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyTicketsScreen(
                          repository: widget.ticketRepository!,
                        ),
                      ),
                    ),
                    child: const Text('My tickets'),
                  ),
                ],
                if (profile.role == 'administrator' &&
                    widget.referenceController != null) ...[
                  FilledButton(
                    key: const Key('manage_departments'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DepartmentScreen(
                          controller: widget.referenceController!,
                        ),
                      ),
                    ),
                    child: const Text('Manage departments'),
                  ),
                  OutlinedButton(
                    key: const Key('manage_categories'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(
                          controller: widget.referenceController!,
                        ),
                      ),
                    ),
                    child: const Text('Manage categories'),
                  ),
                ],
              ],
              if (state.message != null) ...[
                Text(
                  state.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: widget.controller.refreshProfile,
                  child: const Text('Retry'),
                ),
              ],
              const Spacer(),
              OutlinedButton(
                key: const Key('logout_submit'),
                onPressed: state.isLoading ? null : widget.controller.logout,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
