import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/layout/fixflow_auth_page.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
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
    return FixFlowAuthPage(
      title: 'Create reporter account',
      subtitle: 'Report and follow maintenance requests in one place.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FixFlowTextField(
            fieldKey: const Key('register_name'),
            label: 'Name',
            controller: _name,
            error: state.fieldErrors['name']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_email'),
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            error: state.fieldErrors['email']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_password'),
            label: 'Password',
            controller: _password,
            obscureText: true,
            helper: '12–128 characters with a letter and number',
            error: state.fieldErrors['password']?.firstOrNull,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_confirmation'),
            label: 'Confirm password',
            controller: _confirmation,
            obscureText: true,
          ),
          if (state.message != null) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            Text(
              state.message!,
              key: const Key('register_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: FixFlowSpacing.md),
          FixFlowButton(
            buttonKey: const Key('register_submit'),
            label: 'Create account',
            loading: loading,
            onPressed: loading
                ? null
                : () => widget.controller.register(
                    name: _name.text,
                    email: _email.text,
                    password: _password.text,
                    passwordConfirmation: _confirmation.text,
                  ),
          ),
          FixFlowButton(
            label: 'Already have an account? Sign in',
            variant: FixFlowButtonVariant.text,
            onPressed: loading ? null : widget.onShowSignIn,
          ),
        ],
      ),
    );
  }
}
