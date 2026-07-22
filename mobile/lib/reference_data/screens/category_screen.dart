import 'package:flutter/material.dart';

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
        title: Text(value == null ? 'Create category' : 'Edit category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: department,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Department ID'),
            ),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    Widget body;
    if (state.status == model.ReferenceStatus.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.status == model.ReferenceStatus.empty) {
      body = const Center(child: Text('No categories yet.'));
    } else if (state.message != null) {
      body = Center(child: Text(state.message!));
    } else {
      body = ListView(
        children: widget.controller.categories
            .map(
              (category) => ListTile(
                onTap: () => _edit(category),
                title: Text(category.name),
                subtitle: Text(
                  '${category.departmentName} • ${category.isActive ? 'Active' : 'Inactive'}',
                ),
                trailing: Switch(
                  value: category.isActive,
                  onChanged: (_) => widget.controller.toggleCategory(category),
                ),
              ),
            )
            .toList(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        key: const Key('category_add'),
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
      body: body,
    );
  }
}
