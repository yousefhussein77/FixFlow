import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/components/tickets/fixflow_ticket_content.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../state/ticket_comments_controller.dart';

class TicketCommentsSection extends StatefulWidget {
  const TicketCommentsSection({required this.controller, super.key});
  final TicketCommentsController controller;

  @override
  State<TicketCommentsSection> createState() => _TicketCommentsSectionState();
}

class _TicketCommentsSectionState extends State<TicketCommentsSection> {
  late final TextEditingController text;

  @override
  void initState() {
    super.initState();
    text = TextEditingController(text: widget.controller.draft);
    widget.controller.addListener(_changed);
  }

  void _changed() {
    if (text.text != widget.controller.draft) {
      text.value = TextEditingValue(
        text: widget.controller.draft,
        selection: TextSelection.collapsed(
          offset: widget.controller.draft.length,
        ),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    text.dispose();
    super.dispose();
  }

  FixFlowStateKind _stateKind(TicketCommentsStatus status) => switch (status) {
    TicketCommentsStatus.validation => FixFlowStateKind.validation,
    TicketCommentsStatus.notFound ||
    TicketCommentsStatus.unauthorized => FixFlowStateKind.unauthorized,
    TicketCommentsStatus.offline => FixFlowStateKind.offline,
    TicketCommentsStatus.serverError => FixFlowStateKind.serverError,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('التعليقات', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: FixFlowSpacing.sm),
          if (c.status == TicketCommentsStatus.loading)
            const FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'جارٍ تحميل التعليقات',
            ),
          if (c.status == TicketCommentsStatus.empty)
            const FixFlowStateView(
              kind: FixFlowStateKind.empty,
              title: 'لا توجد تعليقات بعد.',
            ),
          for (final comment in c.comments) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: FixFlowSpacing.sm),
              child: FixFlowCommentItem(
                key: Key('comment_${comment.id}'),
                author: comment.author.name,
                role: comment.author.role,
                content: comment.content,
                timestamp: comment.createdAt.toLocal().toString(),
              ),
            ),
          ],
          if (c.message != null)
            FixFlowStateView(
              kind: _stateKind(c.status),
              title: c.status == TicketCommentsStatus.validation
                  ? 'يحتاج التعليق إلى مراجعة'
                  : 'تعذر تحميل التعليقات',
              message: c.message,
              actionLabel:
                  c.status == TicketCommentsStatus.offline ||
                      c.status == TicketCommentsStatus.serverError
                  ? 'إعادة التحميل'
                  : null,
              onAction:
                  c.status == TicketCommentsStatus.offline ||
                      c.status == TicketCommentsStatus.serverError
                  ? c.load
                  : null,
            ),
          const SizedBox(height: FixFlowSpacing.md),
          FixFlowSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FixFlowTextField(
                  fieldKey: const Key('comment_content'),
                  label: 'أضف تعليقاً نصياً',
                  controller: text,
                  maxLength: 2000,
                  maxLines: 5,
                  onChanged: c.updateDraft,
                ),
                const SizedBox(height: FixFlowSpacing.sm),
                FixFlowButton(
                  buttonKey: const Key('comment_submit'),
                  label: c.isSubmitting ? 'جارٍ الإرسال…' : 'إضافة تعليق',
                  loading: c.isSubmitting,
                  onPressed: c.isSubmitting ? null : c.submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
