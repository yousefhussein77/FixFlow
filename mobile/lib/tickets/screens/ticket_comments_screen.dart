import 'package:flutter/material.dart';

import '../../design_system/layout/fixflow_page.dart';
import '../models/ticket_comment_models.dart';
import '../repositories/ticket_comment_repository.dart';
import '../state/ticket_comments_controller.dart';
import '../widgets/ticket_comments_section.dart';

class TicketCommentsScreen extends StatefulWidget {
  const TicketCommentsScreen({
    required this.repository,
    required this.context,
    required this.reference,
    super.key,
  });
  final TicketCommentRepository repository;
  final TicketCommentContext context;
  final String reference;

  @override
  State<TicketCommentsScreen> createState() => _TicketCommentsScreenState();
}

class _TicketCommentsScreenState extends State<TicketCommentsScreen> {
  late final TicketCommentsController controller;

  @override
  void initState() {
    super.initState();
    controller = TicketCommentsController(
      widget.repository,
      widget.context,
      widget.reference,
    )..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FixFlowPage(
    title: Text('${widget.reference} comments'),
    body: TicketCommentsSection(controller: controller),
  );
}
