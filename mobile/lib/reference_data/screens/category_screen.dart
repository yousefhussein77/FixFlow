import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/layout/fixflow_page.dart';
import '../models/reference_models.dart' as model;
import '../state/reference_controller.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.controller, super.key});
  final ReferenceController controller;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    widget.controller.loadCategories();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  Future<void> _edit([model.Category? value]) async {
    final name = TextEditingController(text: value?.name);
    final department = TextEditingController(
      text: value?.departmentId.toString(),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(value == null ? 'إنشاء فئة' : 'تعديل الفئة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FixFlowTextField(
              label: 'معرّف القسم',
              controller: department,
              keyboardType: TextInputType.number,
            ),
            FixFlowTextField(label: 'الاسم', controller: name),
          ],
        ),
        actions: [
          FixFlowButton(
            label: 'إلغاء',
            variant: FixFlowButtonVariant.text,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FixFlowButton(
            label: 'حفظ',
            onPressed: () {
              final departmentId = int.tryParse(department.text);
              if (departmentId == null) return;
              Navigator.pop(dialogContext);
              widget.controller.saveCategory(
                id: value?.id,
                departmentId: departmentId,
                name: name.text,
                version: value?.version,
              );
            },
          ),
        ],
      ),
    );
    department.dispose();
    name.dispose();
  }

  FixFlowStateKind _stateKind(model.ReferenceStatus status) => switch (status) {
    model.ReferenceStatus.unauthorized => FixFlowStateKind.unauthorized,
    model.ReferenceStatus.offline => FixFlowStateKind.offline,
    model.ReferenceStatus.conflict => FixFlowStateKind.conflict,
    model.ReferenceStatus.validation => FixFlowStateKind.validation,
    _ => FixFlowStateKind.serverError,
  };

  @override
  Widget build(BuildContext context) {
    final s = widget.controller.state;
    return FixFlowPage(
      title: const Text('الفئات'),
      onRefresh: s.status == model.ReferenceStatus.loading
          ? () async {}
          : widget.controller.loadCategories,
      floatingActionButton: FixFlowFloatingButton(
        key: const Key('category_add'),
        icon: Icons.add,
        label: 'إضافة فئة',
        onPressed: () => _edit(),
      ),
      body: switch (s.status) {
        model.ReferenceStatus.loading => const FixFlowStateView(
          kind: FixFlowStateKind.loading,
          title: 'جارٍ تحميل الفئات',
        ),
        model.ReferenceStatus.empty => const FixFlowStateView(
          kind: FixFlowStateKind.empty,
          title: 'لا توجد فئات بعد.',
        ),
        model.ReferenceStatus.unauthorized ||
        model.ReferenceStatus.offline ||
        model.ReferenceStatus.conflict ||
        model.ReferenceStatus.validation ||
        model.ReferenceStatus.serverError => FixFlowStateView(
          kind: _stateKind(s.status),
          title: 'تعذر تحميل الفئات',
          message: s.message,
          actionLabel: 'إعادة المحاولة',
          onAction: widget.controller.loadCategories,
        ),
        _ => Column(
          children: [
            for (final category in widget.controller.categories)
              Card(
                child: ListTile(
                  onTap: () => _edit(category),
                  title: Text(category.name),
                  subtitle: Text(
                    '${category.departmentName} • ${category.isActive ? 'نشطة' : 'غير نشطة'}',
                  ),
                  trailing: Switch(
                    value: category.isActive,
                    onChanged: (_) =>
                        widget.controller.toggleCategory(category),
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }
}
