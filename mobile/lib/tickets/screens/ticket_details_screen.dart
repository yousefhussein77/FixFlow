import 'package:flutter/material.dart';
import '../repositories/ticket_repository.dart';
import '../state/ticket_details_controller.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({
    required this.repository,
    required this.reference,
    super.key,
  });
  final TicketRepository repository;
  final String reference;
  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late final TicketDetailsController controller;
  @override
  void initState() {
    super.initState();
    controller = TicketDetailsController(widget.repository)
      ..addListener(_changed);
    controller.load(widget.reference);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = controller.state, t = s.ticket;
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket details')),
      body: SafeArea(
        child: s.status == TicketDetailsStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : t == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.message ??
                          (s.status == TicketDetailsStatus.notFound
                              ? 'Ticket not found.'
                              : 'Unable to load ticket.'),
                    ),
                    FilledButton(
                      key: const Key('detail_retry'),
                      onPressed: () => controller.load(widget.reference),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    t.reference,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(t.title),
                  Text(t.description),
                  Text('Status: ${t.status}'),
                  Text('Priority: ${t.priority}'),
                  Text('Department: ${t.department.name}'),
                  Text('Category: ${t.category.name}'),
                  Text('Location: ${t.location}'),
                  Text('Created: ${t.createdAt.toLocal()}'),
                  Text('Updated: ${t.updatedAt.toLocal()}'),
                  Text('Photos: ${t.photos.length}'),
                  if (s.status == TicketDetailsStatus.photoUnavailable)
                    Text(s.message!, key: const Key('photo_unavailable')),
                ],
              ),
      ),
    );
  }
}
