import 'package:flutter/material.dart';
import '../models/reference_models.dart';
import '../state/reference_controller.dart';

class ReferenceOptionLoader extends StatefulWidget {
  const ReferenceOptionLoader({
    required this.controller,
    this.departmentId,
    required this.builder,
    super.key,
  });
  final ReferenceController controller;
  final int? departmentId;
  final Widget Function(List<ReferenceOption>) builder;
  @override
  State<ReferenceOptionLoader> createState() => _LoaderState();
}

class _LoaderState extends State<ReferenceOptionLoader> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_c);
    _load();
  }

  void _load() {
    widget.departmentId == null
        ? widget.controller.loadDepartmentOptions()
        : widget.controller.loadCategoryOptions(widget.departmentId!);
  }

  void _c() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_c);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.controller.state;
    if (s.status == ReferenceStatus.loading)
      return const CircularProgressIndicator();
    if (s.status == ReferenceStatus.empty)
      return const Text('No active options available.');
    if (s.message != null)
      return Column(
        children: [
          Text(s.message!),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    return widget.builder(widget.controller.options);
  }
}
