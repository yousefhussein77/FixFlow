import 'package:flutter/material.dart';

import 'auth/screens/session_gate.dart';
import 'auth/state/auth_controller.dart';

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({required this.controller, super.key});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: SessionGate(controller: controller),
    );
  }
}
