import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth/screens/session_gate.dart';
import 'auth/state/auth_controller.dart';
import 'reference_data/state/reference_controller.dart';
import 'tickets/repositories/ticket_repository.dart';
import 'tickets/repositories/admin_ticket_repository.dart';
import 'tickets/repositories/technician_ticket_repository.dart';
import 'tickets/repositories/ticket_comment_repository.dart';
import 'tickets/repositories/ticket_rating_repository.dart';
import 'tickets/services/ticket_photo_picker.dart';
import 'design_system/theme/fixflow_theme.dart';

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({
    required this.controller,
    this.referenceController,
    this.ticketRepository,
    this.adminTicketRepository,
    this.technicianTicketRepository,
    this.ticketCommentRepository,
    this.ticketRatingRepository,
    this.ticketPhotoPicker,
    super.key,
  });
  final AuthController controller;
  final ReferenceController? referenceController;
  final TicketRepository? ticketRepository;
  final AdminTicketRepository? adminTicketRepository;
  final TechnicianTicketRepository? technicianTicketRepository;
  final TicketCommentRepository? ticketCommentRepository;
  final TicketRatingRepository? ticketRatingRepository;
  final TicketPhotoPicker? ticketPhotoPicker;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow',
      debugShowCheckedModeBanner: false,
      theme: FixFlowTheme.light(),
      darkTheme: FixFlowTheme.dark(),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SessionGate(
        controller: controller,
        referenceController: referenceController,
        ticketRepository: ticketRepository,
        adminTicketRepository: adminTicketRepository,
        technicianTicketRepository: technicianTicketRepository,
        ticketCommentRepository: ticketCommentRepository,
        ticketRatingRepository: ticketRatingRepository,
        ticketPhotoPicker: ticketPhotoPicker,
      ),
    );
  }
}
