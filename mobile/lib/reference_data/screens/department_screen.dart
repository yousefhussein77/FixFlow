import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../models/reference_models.dart';
import '../state/reference_controller.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({required this.controller, super.key});
  final ReferenceController controller;

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    widget.controller.loadDepartments();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  Future<void> _edit([Department? department]) async {
    final name = TextEditingController(text: department?.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          department == null ? 'Create department' : 'Edit department',
        ),
        content: FixFlowTextField(
          fieldKey: const Key('department_name'),
          label: 'Name',
          controller: name,
          error: widget.controller.state.errors['name']?.firstOrNull,
        ),
        actions: [
          FixFlowButton(
            label: 'Cancel',
            variant: FixFlowButtonVariant.text,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FixFlowButton(
            label: 'Save',
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.controller.saveDepartment(
                id: department?.id,
                name: name.text,
                version: department?.version,
              );
            },
          ),
        ],
      ),
    );
    name.dispose();
  }

  FixFlowStateKind _stateKind(ReferenceStatus status) => switch (status) {
    ReferenceStatus.unauthorized => FixFlowStateKind.unauthorized,
    ReferenceStatus.offline => FixFlowStateKind.offline,
    ReferenceStatus.conflict => FixFlowStateKind.conflict,
    ReferenceStatus.validation => FixFlowStateKind.validation,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) {
    final s = widget.controller.state;
    return FixFlowPage(
      title: const Text('Departments'),
      floatingActionButton: FixFlowFloatingButton(
        key: const Key('department_add'),
        icon: Icons.add,
        label: 'Add department',
        onPressed: () => _edit(),
      ),
      body: switch (s.status) {
        ReferenceStatus.loading => const FixFlowStateView(
          kind: FixFlowStateKind.loading,
          title: 'Loading departments',
        ),
        ReferenceStatus.empty => const FixFlowStateView(
          kind: FixFlowStateKind.empty,
          title: 'No departments yet.',
        ),
        ReferenceStatus.unauthorized ||
        ReferenceStatus.offline ||
        ReferenceStatus.conflict ||
        ReferenceStatus.validation ||
        ReferenceStatus.serverError => FixFlowStateView(
          kind: _stateKind(s.status),
          title: 'Unable to load departments',
          message: s.message,
          actionLabel: 'Retry',
          onAction: widget.controller.loadDepartments,
        ),
        _ => Column(
          children: [
            for (final department in widget.controller.departments)
              Card(
                child: ListTile(
                  title: Text(department.name),
                  subtitle: Text(department.isActive ? 'Active' : 'Inactive'),
                  onTap: () => _edit(department),
                  trailing: Switch(
                    value: department.isActive,
                    onChanged: (_) =>
                        widget.controller.toggleDepartment(department),
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }
}
