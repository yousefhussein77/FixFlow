import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/components/tickets/fixflow_ticket_content.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../models/ticket_models.dart';
import '../state/ticket_creation_controller.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({
    required this.controller,
    this.pickPhotos,
    super.key,
  });
  final TicketCreationController controller;
  final Future<List<SelectedPhoto>> Function()? pickPhotos;

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final title = TextEditingController(),
      description = TextEditingController(),
      location = TextEditingController();
  String priority = 'medium';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    widget.controller.loadDepartments();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    title.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  FixFlowStateKind _stateKind(TicketCreationStatus status) => switch (status) {
    TicketCreationStatus.validation ||
    TicketCreationStatus.photoValidation => FixFlowStateKind.validation,
    TicketCreationStatus.unauthorized => FixFlowStateKind.unauthorized,
    TicketCreationStatus.offline => FixFlowStateKind.offline,
    TicketCreationStatus.conflict => FixFlowStateKind.conflict,
    TicketCreationStatus.serverError => FixFlowStateKind.serverError,
    TicketCreationStatus.success => FixFlowStateKind.success,
    _ => FixFlowStateKind.validation,
  };

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final s = c.state;
    final showState =
        s.message != null ||
        s.status == TicketCreationStatus.success ||
        s.status == TicketCreationStatus.photoValidation ||
        s.status == TicketCreationStatus.validation;
    return FixFlowPage(
      title: const Text('إنشاء تذكرة'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FixFlowButton(
            buttonKey: const Key('ticket_submit'),
            label: 'إرسال التذكرة',
            loading: c.isSubmitting,
            onPressed: c.isSubmitting
                ? null
                : () => c.submit(
                    title: title.text,
                    description: description.text,
                    priority: priority,
                    location: location.text,
                  ),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          if (s.status == TicketCreationStatus.loadingOptions ||
              s.status == TicketCreationStatus.submitting)
            const LinearProgressIndicator(),
          FixFlowTextField(
            fieldKey: const Key('ticket_title'),
            label: 'العنوان',
            controller: title,
            error: s.errors['title']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('ticket_description'),
            label: 'الوصف',
            controller: description,
            maxLines: 4,
            maxLength: 2000,
            error: s.errors['description']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowDropdownField<int>(
            key: const Key('ticket_department'),
            label: 'القسم',
            value: c.selectedDepartmentId,
            items: c.departments.map((o) => o.id).toList(),
            itemLabel: (id) => c.departments.firstWhere((o) => o.id == id).name,
            error: s.errors['department_id']?.firstOrNull,
            onChanged: c.isSubmitting
                ? null
                : (v) {
                    if (v != null) c.selectDepartment(v);
                  },
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowDropdownField<int>(
            key: const Key('ticket_category'),
            label: 'الفئة',
            value: c.categories.any((o) => o.id == c.selectedCategoryId)
                ? c.selectedCategoryId
                : null,
            items: c.categories.map((o) => o.id).toList(),
            itemLabel: (id) => c.categories.firstWhere((o) => o.id == id).name,
            error: s.errors['category_id']?.firstOrNull,
            onChanged: c.isSubmitting ? null : c.selectCategory,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowDropdownField<String>(
            key: const Key('ticket_priority'),
            label: 'الأولوية',
            value: priority,
            items: const ['low', 'medium', 'high', 'urgent'],
            itemLabel: (value) => value,
            onChanged: (v) => setState(() => priority = v ?? priority),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('ticket_location'),
            label: 'الموقع',
            controller: location,
            error: s.errors['location']?.firstOrNull,
          ),
          if (widget.pickPhotos != null) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            FixFlowButton(
              buttonKey: const Key('ticket_photos'),
              label: 'اختيار الصور (${c.photos.length}/5)',
              variant: FixFlowButtonVariant.outline,
              icon: Icons.photo_library_outlined,
              onPressed: c.isSubmitting
                  ? null
                  : () async => c.setPhotos(await widget.pickPhotos!()),
            ),
          ],
          if (c.photos.isNotEmpty) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            Wrap(
              spacing: FixFlowSpacing.xs,
              children: [
                for (final photo in c.photos)
                  SizedBox(
                    width: 88,
                    child: FixFlowPhotoTile(label: photo.name),
                  ),
              ],
            ),
          ],
          if (showState)
            Padding(
              padding: const EdgeInsets.only(top: FixFlowSpacing.sm),
              child: FixFlowStateView(
                kind: _stateKind(s.status),
                title: s.status == TicketCreationStatus.success
                    ? 'Ticket created'
                    : s.status == TicketCreationStatus.validation
                    ? 'Check the ticket details'
                    : s.status == TicketCreationStatus.photoValidation
                    ? 'Photo selection needs attention'
                    : 'Ticket submission needs attention',
                message:
                    s.message ??
                    (s.status == TicketCreationStatus.success
                        ? 'Created ${s.ticket!.reference}'
                        : null),
              ),
            ),
        ],
      ),
    );
  }
}
