import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_feedback.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/account_request_models.dart';
import '../repositories/account_request_repository.dart';
import '../state/account_requests_controller.dart';

class AccountRequestsScreen extends StatefulWidget {
  const AccountRequestsScreen({required this.repository, super.key});

  final AccountRequestRepository repository;

  @override
  State<AccountRequestsScreen> createState() => _AccountRequestsScreenState();
}

class _AccountRequestsScreenState extends State<AccountRequestsScreen> {
  late final AccountRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = AccountRequestsController(widget.repository)
      ..addListener(_changed)
      ..load();
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return FixFlowPage(
      title: const Text('طلبات الحسابات'),
      onRefresh:
          state.status == AccountRequestsViewStatus.loading ||
              state.status == AccountRequestsViewStatus.acting
          ? () async {}
          : controller.load,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مراجعة طلبات إنشاء الحسابات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: FixFlowSpacing.xs),
          Text(
            'اعتمد الطلبات الصحيحة أو ارفضها مع توضيح السبب عند الحاجة.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: FixFlowSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AccountRequestStatus>(
              segments: [
                for (final status in AccountRequestStatus.values)
                  ButtonSegment(value: status, label: Text(status.label)),
              ],
              selected: {state.filter},
              onSelectionChanged:
                  state.status == AccountRequestsViewStatus.acting
                  ? null
                  : (selection) => controller.load(filter: selection.single),
            ),
          ),
          const SizedBox(height: FixFlowSpacing.md),
          if (state.status == AccountRequestsViewStatus.loading &&
              state.items.isEmpty)
            const FixFlowStateView(
              kind: FixFlowStateKind.loading,
              title: 'جارٍ تحميل طلبات الحسابات',
            )
          else if (state.status == AccountRequestsViewStatus.empty)
            FixFlowStateView(
              kind: FixFlowStateKind.empty,
              title: 'لا توجد طلبات بحالة ${state.filter.label}.',
            )
          else ...[
            if (_isFailure(state.status)) ...[
              _FailureBanner(state: state, onRetry: controller.load),
              const SizedBox(height: FixFlowSpacing.sm),
            ],
            for (final request in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: FixFlowSpacing.sm),
                child: _AccountRequestCard(
                  request: request,
                  busy: state.status == AccountRequestsViewStatus.acting,
                  acting: state.actingId == request.id,
                  onApprove: () => _approve(request),
                  onReject: () => _reject(request),
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _isFailure(AccountRequestsViewStatus status) => switch (status) {
    AccountRequestsViewStatus.unauthorized ||
    AccountRequestsViewStatus.offline ||
    AccountRequestsViewStatus.conflict ||
    AccountRequestsViewStatus.validationError ||
    AccountRequestsViewStatus.serverError => true,
    _ => false,
  };

  Future<void> _approve(AccountRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اعتماد طلب الحساب؟'),
        content: Text(
          'سيتم تفعيل حساب ${request.name} والسماح له بتسجيل الدخول.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: const Key('confirm_account_approval'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('اعتماد'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await controller.approve(request.id);
    if (success && mounted) {
      showFixFlowSnackBar(
        context,
        message: 'تم اعتماد طلب الحساب بنجاح.',
        kind: FixFlowFeedbackKind.success,
      );
    }
  }

  Future<void> _reject(AccountRequest request) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectionDialog(name: request.name),
    );
    if (reason == null) return;
    final success = await controller.reject(request.id, reason: reason);
    if (success && mounted) {
      showFixFlowSnackBar(
        context,
        message: 'تم رفض طلب الحساب.',
        kind: FixFlowFeedbackKind.success,
      );
    }
  }
}

class _AccountRequestCard extends StatelessWidget {
  const _AccountRequestCard({
    required this.request,
    required this.busy,
    required this.acting,
    required this.onApprove,
    required this.onReject,
  });

  final AccountRequest request;
  final bool busy;
  final bool acting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => FixFlowSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(child: Text(request.name.characters.first)),
            const SizedBox(width: FixFlowSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      request.email,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
        Wrap(
          spacing: FixFlowSpacing.md,
          runSpacing: FixFlowSpacing.xs,
          children: [
            Chip(label: Text(request.status.label)),
            Text('نوع الحساب: ${request.roleLabel}'),
            Text('تاريخ التسجيل: ${_date(request.registeredAt)}'),
          ],
        ),
        if (request.rejectionReason case final reason?) ...[
          const SizedBox(height: FixFlowSpacing.xs),
          Text('سبب الرفض: $reason'),
        ],
        if (request.status == AccountRequestStatus.pending) ...[
          const SizedBox(height: FixFlowSpacing.sm),
          Wrap(
            spacing: FixFlowSpacing.sm,
            runSpacing: FixFlowSpacing.xs,
            children: [
              FixFlowButton(
                buttonKey: Key('approve_account_${request.id}'),
                label: 'اعتماد',
                icon: Icons.check_circle_outline,
                loading: acting,
                onPressed: busy ? null : onApprove,
              ),
              FixFlowButton(
                buttonKey: Key('reject_account_${request.id}'),
                label: 'رفض',
                icon: Icons.cancel_outlined,
                variant: FixFlowButtonVariant.destructive,
                onPressed: busy ? null : onReject,
              ),
            ],
          ),
        ],
      ],
    ),
  );

  static String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }
}

class _RejectionDialog extends StatefulWidget {
  const _RejectionDialog({required this.name});

  final String name;

  @override
  State<_RejectionDialog> createState() => _RejectionDialogState();
}

class _RejectionDialogState extends State<_RejectionDialog> {
  final reason = TextEditingController();

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('رفض طلب الحساب؟'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('سيتم منع ${widget.name} من تسجيل الدخول.'),
        const SizedBox(height: FixFlowSpacing.sm),
        FixFlowTextField(
          fieldKey: const Key('account_rejection_reason'),
          label: 'سبب الرفض (اختياري)',
          controller: reason,
          maxLength: 1000,
          maxLines: 4,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        key: const Key('confirm_account_rejection'),
        onPressed: () => Navigator.pop(context, reason.text),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('رفض الطلب'),
      ),
    ],
  );
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.state, required this.onRetry});

  final AccountRequestsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FixFlowStateView(
    kind: switch (state.status) {
      AccountRequestsViewStatus.unauthorized => FixFlowStateKind.unauthorized,
      AccountRequestsViewStatus.offline => FixFlowStateKind.offline,
      AccountRequestsViewStatus.conflict => FixFlowStateKind.conflict,
      AccountRequestsViewStatus.validationError => FixFlowStateKind.validation,
      _ => FixFlowStateKind.serverError,
    },
    title: state.message ?? 'تعذر تحميل طلبات الحسابات.',
    actionLabel: 'إعادة المحاولة',
    onAction: onRetry,
  );
}
