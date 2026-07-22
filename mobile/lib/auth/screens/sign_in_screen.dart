import 'package:flutter/material.dart';

import '../state/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    required this.controller,
    this.onShowRegister,
    super.key,
  });
  final AuthController controller;
  final VoidCallback? onShowRegister;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final loading = state.status == AuthViewStatus.loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to FixFlow')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('login_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: state.fieldErrors['email']?.firstOrNull,
              ),
            ),
            TextField(
              key: const Key('login_password'),
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: state.fieldErrors['password']?.firstOrNull,
              ),
            ),
            if (state.message != null) ...[
              const SizedBox(height: 12),
              Text(
                state.message!,
                key: const Key('login_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('login_submit'),
              onPressed: loading
                  ? null
                  : () => widget.controller.login(
                      email: _email.text,
                      password: _password.text,
                    ),
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            TextButton(
              onPressed: loading ? null : widget.onShowRegister,
              child: const Text('Create a reporter account'),
            ),
          ],
        ),
      ),
    );
  }
}
