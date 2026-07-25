import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/layout/fixflow_auth_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
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
    return FixFlowAuthPage(
      title: 'Sign in to FixFlow',
      subtitle: 'Manage maintenance requests with confidence.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FixFlowTextField(
            fieldKey: const Key('login_email'),
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            error: state.fieldErrors['email']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('login_password'),
            label: 'Password',
            controller: _password,
            obscureText: true,
            error: state.fieldErrors['password']?.firstOrNull,
          ),
          if (state.message != null) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            Text(
              state.message!,
              key: const Key('login_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: FixFlowSpacing.md),
          FixFlowButton(
            buttonKey: const Key('login_submit'),
            label: 'Sign in',
            loading: loading,
            onPressed: loading
                ? null
                : () => widget.controller.login(
                    email: _email.text,
                    password: _password.text,
                  ),
          ),
          FixFlowButton(
            label: 'Create a reporter account',
            variant: FixFlowButtonVariant.text,
            onPressed: loading ? null : widget.onShowRegister,
          ),
        ],
      ),
    );
  }
}
