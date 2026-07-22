import 'package:flutter/material.dart';

import '../state/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.controller,
    this.onShowSignIn,
    super.key,
  });

  final AuthController controller;
  final VoidCallback? onShowSignIn;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
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
      appBar: AppBar(title: const Text('Create reporter account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('register_name'),
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: state.fieldErrors['name']?.firstOrNull,
              ),
            ),
            TextField(
              key: const Key('register_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: state.fieldErrors['email']?.firstOrNull,
              ),
            ),
            TextField(
              key: const Key('register_password'),
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: '12–128 characters with a letter and number',
                errorText: state.fieldErrors['password']?.firstOrNull,
              ),
            ),
            TextField(
              key: const Key('register_confirmation'),
              controller: _confirmation,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
            if (state.message != null) ...[
              const SizedBox(height: 12),
              Text(
                state.message!,
                key: const Key('register_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('register_submit'),
              onPressed: loading
                  ? null
                  : () => widget.controller.register(
                      name: _name.text,
                      email: _email.text,
                      password: _password.text,
                      passwordConfirmation: _confirmation.text,
                    ),
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
            TextButton(
              onPressed: loading ? null : widget.onShowSignIn,
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
