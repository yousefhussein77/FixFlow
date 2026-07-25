import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/admin_ticket_models.dart';
import '../repositories/admin_ticket_repository.dart';
import '../state/technician_options_controller.dart';
import '../state/ticket_assignment_controller.dart';

class TicketAssignmentSheet extends StatefulWidget {
  const TicketAssignmentSheet({
    required this.repository,
    required this.ticket,
    super.key,
  });
  final AdminTicketRepository repository;
  final AdminTicketSummary ticket;

  @override
  State<TicketAssignmentSheet> createState() => _TicketAssignmentSheetState();
}

class _TicketAssignmentSheetState extends State<TicketAssignmentSheet> {
  late final TechnicianOptionsController options;
  late final TicketAssignmentController assignment;
  int? selected;

  @override
  void initState() {
    super.initState();
    options = TechnicianOptionsController(widget.repository)
      ..addListener(_changed);
    assignment = TicketAssignmentController(
      widget.repository,
      widget.ticket.reference,
    )..addListener(_changed);
    options.load();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    options.removeListener(_changed);
    assignment.removeListener(_changed);
    options.dispose();
    assignment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (assignment.status == TicketAssignmentStatus.success &&
        assignment.assigned != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, assignment.assigned);
      });
    }
    final loading = assignment.status == TicketAssignmentStatus.submitting;
    final optionsBody = switch (options.status) {
      TechnicianOptionsStatus.loading => const FixFlowStateView(
        kind: FixFlowStateKind.loading,
        title: 'Loading technicians',
      ),
      TechnicianOptionsStatus.empty => const FixFlowStateView(
        kind: FixFlowStateKind.empty,
        title: 'No active technicians are available.',
      ),
      TechnicianOptionsStatus.unauthorized ||
      TechnicianOptionsStatus.offline ||
      TechnicianOptionsStatus.serverError => FixFlowStateView(
        kind: options.status == TechnicianOptionsStatus.unauthorized
            ? FixFlowStateKind.unauthorized
            : options.status == TechnicianOptionsStatus.offline
            ? FixFlowStateKind.offline
            : FixFlowStateKind.serverError,
        title: 'Unable to load technicians.',
        message: options.message,
        actionLabel: 'Retry',
        onAction: options.load,
      ),
      _ => FixFlowDropdownField<int>(
        key: const Key('technician_select'),
        label: 'Active technician',
        value: selected,
        items: options.options.map((option) => option.id).toList(),
        itemLabel: (id) => options.options.firstWhere((o) => o.id == id).name,
        onChanged: loading ? null : (value) => setState(() => selected = value),
      ),
    };
    return AlertDialog(
      title: Text('Assign ${widget.ticket.reference}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            optionsBody,
            if (assignment.message != null)
              Padding(
                padding: const EdgeInsets.only(top: FixFlowSpacing.sm),
                child: Text(
                  assignment.fieldErrors['technician_id']?.first ??
                      assignment.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (assignment.requiresRefresh)
              const Padding(
                padding: EdgeInsets.only(top: FixFlowSpacing.sm),
                child: Text('Refresh the ticket list before trying again.'),
              ),
          ],
        ),
      ),
      actions: [
        FixFlowButton(
          label: 'Cancel',
          variant: FixFlowButtonVariant.text,
          onPressed: loading ? null : () => Navigator.pop(context),
        ),
        FixFlowButton(
          buttonKey: const Key('assignment_submit'),
          label: 'Assign',
          loading: loading,
          onPressed:
              selected == null ||
                  options.status != TechnicianOptionsStatus.ready ||
                  loading ||
                  assignment.requiresRefresh
              ? null
              : () => assignment.submit(selected!),
        ),
      ],
    );
  }
}
