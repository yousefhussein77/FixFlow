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
import 'design_system/theme/fixflow_theme_controller.dart';
import 'accounts/repositories/account_request_repository.dart';
import 'notifications/repositories/notification_repository.dart';

class FixFlowApp extends StatefulWidget {
  const FixFlowApp({
    required this.controller,
    this.referenceController,
    this.ticketRepository,
    this.adminTicketRepository,
    this.technicianTicketRepository,
    this.ticketCommentRepository,
    this.ticketRatingRepository,
    this.ticketPhotoPicker,
    this.themeController,
    this.accountRequestRepository,
    this.notificationRepository,
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
  final ThemeController? themeController;
  final AccountRequestRepository? accountRequestRepository;
  final NotificationRepository? notificationRepository;

  @override
  State<FixFlowApp> createState() => _FixFlowAppState();
}

class _FixFlowAppState extends State<FixFlowApp> {
  late final ThemeController _themeController;
  late final bool _ownsThemeController;

  @override
  void initState() {
    super.initState();
    _ownsThemeController = widget.themeController == null;
    _themeController =
        widget.themeController ?? ThemeController(SecureThemePreferenceStore())
          ..restore();
  }

  @override
  void dispose() {
    if (_ownsThemeController) _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) => MaterialApp(
        title: 'FixFlow',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        theme: FixFlowTheme.light(),
        darkTheme: FixFlowTheme.dark(),
        themeMode: _themeController.mode,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SessionGate(
          controller: widget.controller,
          referenceController: widget.referenceController,
          ticketRepository: widget.ticketRepository,
          adminTicketRepository: widget.adminTicketRepository,
          technicianTicketRepository: widget.technicianTicketRepository,
          ticketCommentRepository: widget.ticketCommentRepository,
          ticketRatingRepository: widget.ticketRatingRepository,
          ticketPhotoPicker: widget.ticketPhotoPicker,
          themeController: _themeController,
          accountRequestRepository: widget.accountRequestRepository,
          notificationRepository: widget.notificationRepository,
        ),
      ),
    );
  }
}
