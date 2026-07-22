import 'package:flutter/material.dart';
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

  Future<void> _edit([Department? d]) async {
    final c = TextEditingController(text: d?.name);
    await showDialog(
      context: context,
      builder: (x) => AlertDialog(
        title: Text(d == null ? 'Create department' : 'Edit department'),
        content: TextField(
          key: const Key('department_name'),
          controller: c,
          decoration: InputDecoration(
            errorText: widget.controller.state.errors['name']?.firstOrNull,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(x);
              widget.controller.saveDepartment(
                id: d?.id,
                name: c.text,
                version: d?.version,
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
    final s = widget.controller.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      floatingActionButton: FloatingActionButton(
        key: const Key('department_add'),
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
      body: s.status == ReferenceStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : s.status == ReferenceStatus.empty
          ? const Center(child: Text('No departments yet.'))
          : s.message != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.message!),
                  FilledButton(
                    onPressed: widget.controller.loadDepartments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView(
              children: widget.controller.departments
                  .map(
                    (d) => ListTile(
                      title: Text(d.name),
                      subtitle: Text(d.isActive ? 'Active' : 'Inactive'),
                      onTap: () => _edit(d),
                      trailing: Switch(
                        value: d.isActive,
                        onChanged: (_) => widget.controller.toggleDepartment(d),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
