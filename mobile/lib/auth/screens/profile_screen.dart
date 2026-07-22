import 'package:flutter/material.dart';

import '../state/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.controller, super.key});
  final AuthController controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final profile = state.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            key: const Key('profile_refresh'),
            onPressed: state.isLoading
                ? null
                : widget.controller.refreshProfile,
            tooltip: 'Refresh profile',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isLoading) const LinearProgressIndicator(),
              if (profile != null) ...[
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(profile.email),
                const SizedBox(height: 8),
                Text(profile.role),
              ],
              if (state.message != null) ...[
                Text(
                  state.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: widget.controller.refreshProfile,
                  child: const Text('Retry'),
                ),
              ],
              const Spacer(),
              OutlinedButton(
                key: const Key('logout_submit'),
                onPressed: state.isLoading ? null : widget.controller.logout,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
