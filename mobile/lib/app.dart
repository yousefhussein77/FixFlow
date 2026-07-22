import 'package:flutter/material.dart';

import 'auth/screens/session_gate.dart';
import 'auth/state/auth_controller.dart';
import 'reference_data/state/reference_controller.dart';

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({
    required this.controller,
    this.referenceController,
    super.key,
  });
  final AuthController controller;
  final ReferenceController? referenceController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: SessionGate(
        controller: controller,
        referenceController: referenceController,
      ),
    );
  }
}
