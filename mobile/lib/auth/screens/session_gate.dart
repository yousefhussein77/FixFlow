import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import 'profile_screen.dart';
import 'register_screen.dart';
import 'sign_in_screen.dart';
import '../../reference_data/state/reference_controller.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({
    required this.controller,
    this.referenceController,
    super.key,
  });
  final AuthController controller;
  final ReferenceController? referenceController;

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    if (state.status == AuthViewStatus.restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.status == AuthViewStatus.authenticated ||
        (state.isLoading && state.profile != null)) {
      return ProfileScreen(
        controller: widget.controller,
        referenceController: widget.referenceController,
      );
    }
    if (state.status == AuthViewStatus.offline ||
        state.status == AuthViewStatus.serverError ||
        state.status == AuthViewStatus.storageError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message ?? 'Unable to restore your session.'),
                FilledButton(
                  key: const Key('session_retry'),
                  onPressed: widget.controller.restore,
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: widget.controller.logout,
                  child: const Text('Sign out locally'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_registering) {
      return RegisterScreen(
        controller: widget.controller,
        onShowSignIn: () => setState(() => _registering = false),
      );
    }
    return SignInScreen(
      controller: widget.controller,
      onShowRegister: () => setState(() => _registering = true),
    );
  }
}
