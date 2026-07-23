import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final c = widget.controller, s = c.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Create ticket')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (s.status == TicketCreationStatus.loadingOptions ||
                s.status == TicketCreationStatus.submitting)
              const LinearProgressIndicator(),
            TextField(
              key: const Key('ticket_title'),
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              key: const Key('ticket_description'),
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<int>(
              key: const Key('ticket_department'),
              initialValue: c.selectedDepartmentId,
              decoration: const InputDecoration(labelText: 'Department'),
              items: c.departments
                  .map(
                    (o) => DropdownMenuItem(value: o.id, child: Text(o.name)),
                  )
                  .toList(),
              onChanged: c.isSubmitting
                  ? null
                  : (v) {
                      if (v != null) c.selectDepartment(v);
                    },
            ),
            DropdownButtonFormField<int>(
              key: const Key('ticket_category'),
              initialValue:
                  c.categories.any((o) => o.id == c.selectedCategoryId)
                  ? c.selectedCategoryId
                  : null,
              decoration: const InputDecoration(labelText: 'Category'),
              items: c.categories
                  .map(
                    (o) => DropdownMenuItem(value: o.id, child: Text(o.name)),
                  )
                  .toList(),
              onChanged: c.isSubmitting ? null : c.selectCategory,
            ),
            DropdownButtonFormField<String>(
              key: const Key('ticket_priority'),
              initialValue: priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                'low',
                'medium',
                'high',
                'urgent',
              ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => priority = v ?? priority),
            ),
            TextField(
              key: const Key('ticket_location'),
              controller: location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            if (widget.pickPhotos != null)
              OutlinedButton(
                key: const Key('ticket_photos'),
                onPressed: c.isSubmitting
                    ? null
                    : () async => c.setPhotos(await widget.pickPhotos!()),
                child: Text('Choose photos (${c.photos.length}/5)'),
              ),
            if (s.message != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  s.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            for (final e in s.errors.entries)
              Text('${e.key}: ${e.value.join(' ')}'),
            if (s.status == TicketCreationStatus.success)
              Text(
                'Created ${s.ticket!.reference}',
                key: const Key('ticket_success'),
              ),
            FilledButton(
              key: const Key('ticket_submit'),
              onPressed: c.isSubmitting
                  ? null
                  : () => c.submit(
                      title: title.text,
                      description: description.text,
                      priority: priority,
                      location: location.text,
                    ),
              child: const Text('Submit ticket'),
            ),
          ],
        ),
      ),
    );
  }
}
