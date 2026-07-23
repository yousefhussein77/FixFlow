import 'package:flutter/material.dart';
import '../repositories/ticket_repository.dart';
import '../state/my_tickets_controller.dart';
import 'ticket_details_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({required this.repository, super.key});
  final TicketRepository repository;
  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late final MyTicketsController controller;
  @override
  void initState() {
    super.initState();
    controller = MyTicketsController(widget.repository)..addListener(_changed);
    controller.load();
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
    final s = controller.state;
    return Scaffold(
      appBar: AppBar(title: const Text('My tickets')),
      body: SafeArea(
        child: switch (s.status) {
          MyTicketsStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MyTicketsStatus.empty => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You have no tickets yet.'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Create a ticket'),
                ),
              ],
            ),
          ),
          MyTicketsStatus.offline ||
          MyTicketsStatus.serverError ||
          MyTicketsStatus.unauthorized => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.message ?? 'Unable to load tickets.'),
                FilledButton(
                  key: const Key('tickets_retry'),
                  onPressed: controller.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          _ => ListView(
            children: [
              for (final ticket in controller.tickets)
                ListTile(
                  key: Key('ticket_${ticket.reference}'),
                  title: Text(ticket.title),
                  subtitle: Text(
                    '${ticket.reference} · ${ticket.status} · ${ticket.priority}',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailsScreen(
                        repository: widget.repository,
                        reference: ticket.reference,
                      ),
                    ),
                  ),
                ),
              if (s.status == MyTicketsStatus.loadingMore)
                const Center(child: CircularProgressIndicator()),
              TextButton(
                key: const Key('tickets_more'),
                onPressed: () => controller.load(refresh: false),
                child: const Text('Load more'),
              ),
            ],
          ),
        },
      ),
    );
  }
}
