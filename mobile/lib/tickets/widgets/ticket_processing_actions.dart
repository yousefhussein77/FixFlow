import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/technician_ticket_models.dart';
import '../state/ticket_status_transition_controller.dart';

class TicketProcessingActions extends StatefulWidget {
  const TicketProcessingActions({
    required this.ticket,
    required this.controller,
    required this.onUpdated,
    super.key,
  });
  final TechnicianTicket ticket;
  final TicketStatusTransitionController controller;
  final ValueChanged<TechnicianTicket> onUpdated;

  @override
  State<TicketProcessingActions> createState() =>
      _TicketProcessingActionsState();
}

class _TicketProcessingActionsState extends State<TicketProcessingActions> {
  final reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    reason.dispose();
    super.dispose();
  }

  Future<void> _submit(String status) async {
    final updated = await widget.controller.submit(
      widget.ticket.reference,
      status,
      reason: status == 'rejected' ? reason.text : null,
    );
    if (updated != null) widget.onUpdated(updated);
  }

  Future<void> _reject() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض التذكرة'),
        content: FixFlowTextField(
          fieldKey: const Key('rejection_reason'),
          label: 'السبب',
          controller: reason,
          maxLength: 1000,
          maxLines: 4,
          error: widget.controller.status == TicketTransitionStatus.validation
              ? widget.controller.message
              : null,
        ),
        actions: [
          FixFlowButton(
            label: 'إلغاء',
            variant: FixFlowButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
          FixFlowButton(
            label: 'رفض',
            variant: FixFlowButtonVariant.destructive,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (accepted == true) await _submit('rejected');
  }

  Future<void> _startWork() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بدء العمل؟'),
        content: const Text('أكد أنك جاهز لبدء العمل على هذه التذكرة.'),
        actions: [
          FixFlowButton(
            label: 'إلغاء',
            variant: FixFlowButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
          FixFlowButton(
            buttonKey: const Key('confirm_start_work'),
            label: 'بدء العمل',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (accepted == true) await _submit('in_progress');
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        widget.controller.status == TicketTransitionStatus.submitting ||
        widget.controller.isRefreshingAuthoritativeState;
    if (widget.ticket.status == 'completed' ||
        widget.ticket.status == 'rejected') {
      return const FixFlowStateViewCompatClosed();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.ticket.status == 'assigned')
          FixFlowButton(
            buttonKey: const Key('start_work'),
            label: 'بدء العمل',
            icon: Icons.play_arrow,
            onPressed: busy ? null : _startWork,
          ),
        if (widget.ticket.status == 'in_progress')
          FixFlowButton(
            buttonKey: const Key('complete_ticket'),
            label: 'إكمال التذكرة',
            icon: Icons.check_circle_outline,
            onPressed: busy ? null : () => _submit('completed'),
          ),
        const SizedBox(height: FixFlowSpacing.xs),
        FixFlowButton(
          buttonKey: const Key('reject_ticket'),
          label: 'رفض التذكرة',
          variant: FixFlowButtonVariant.destructive,
          icon: Icons.cancel_outlined,
          onPressed: busy ? null : _reject,
        ),
        if (widget.controller.message != null)
          Padding(
            padding: const EdgeInsets.only(top: FixFlowSpacing.xs),
            child: Text(
              widget.controller.message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class FixFlowStateViewCompatClosed extends StatelessWidget {
  const FixFlowStateViewCompatClosed({super.key});

  @override
  Widget build(BuildContext context) => const Text('هذه التذكرة مغلقة.');
}
