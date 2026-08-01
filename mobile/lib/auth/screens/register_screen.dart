import 'package:flutter/material.dart';

import '../../design_system/components/buttons/fixflow_buttons.dart';
import '../../design_system/components/forms/fixflow_fields.dart';
import '../../design_system/components/feedback/fixflow_feedback.dart';
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
  String _role = 'reporter';
  late AuthViewStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _lastStatus = widget.controller.state.status;
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
      _lastStatus = widget.controller.state.status;
    }
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
    if (!mounted) return;
    final status = widget.controller.state.status;
    if (status == AuthViewStatus.registrationPending &&
        _lastStatus != AuthViewStatus.registrationPending) {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirmation.clear();
      _role = 'reporter';
    }
    _lastStatus = status;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final loading = state.status == AuthViewStatus.loading;
    return FixFlowAuthPage(
      title: 'طلب إنشاء حساب',
      subtitle: 'أرسل بياناتك إلى الإدارة للمراجعة قبل تفعيل الحساب.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FixFlowTextField(
            fieldKey: const Key('register_name'),
            label: 'الاسم',
            controller: _name,
            error: state.fieldErrors['name']?.firstOrNull,
            onChanged: (_) => widget.controller.clearFieldError('name'),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowDropdownField<String>(
            key: const Key('register_role'),
            label: 'نوع الحساب المطلوب',
            items: const ['reporter', 'technician'],
            itemLabel: (value) => value == 'technician' ? 'فني' : 'مُبلّغ',
            value: _role,
            error: state.fieldErrors['role']?.firstOrNull,
            onChanged: loading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _role = value);
                    widget.controller.clearFieldError('role');
                  },
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_email'),
            label: 'البريد الإلكتروني',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            error: state.fieldErrors['email']?.firstOrNull,
            onChanged: (_) => widget.controller.clearFieldError('email'),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_password'),
            label: 'كلمة المرور',
            controller: _password,
            obscureText: true,
            helper: 'من 12 إلى 128 حرفًا، مع حرف كبير وحرف صغير ورقم',
            error: state.fieldErrors['password']?.firstOrNull,
            onChanged: (_) => widget.controller.clearFieldError('password'),
          ),
          const SizedBox(height: FixFlowSpacing.sm),
          FixFlowTextField(
            fieldKey: const Key('register_confirmation'),
            label: 'تأكيد كلمة المرور',
            controller: _confirmation,
            obscureText: true,
            error: state.fieldErrors['password_confirmation']?.firstOrNull,
            onChanged: (_) =>
                widget.controller.clearFieldError('password_confirmation'),
          ),
          if (state.message != null) ...[
            const SizedBox(height: FixFlowSpacing.sm),
            Semantics(
              liveRegion: true,
              child: FixFlowBanner(
                key: state.status == AuthViewStatus.registrationPending
                    ? const Key('register_success')
                    : const Key('register_error'),
                message: state.message!,
                kind: state.status == AuthViewStatus.registrationPending
                    ? FixFlowFeedbackKind.success
                    : FixFlowFeedbackKind.error,
              ),
            ),
          ],
          const SizedBox(height: FixFlowSpacing.md),
          FixFlowButton(
            buttonKey: const Key('register_submit'),
            label: 'إرسال طلب الحساب',
            loading: loading,
            onPressed: loading
                ? null
                : () => widget.controller.register(
                    name: _name.text,
                    email: _email.text,
                    password: _password.text,
                    passwordConfirmation: _confirmation.text,
                    role: _role,
                  ),
          ),
          FixFlowButton(
            label: 'لديك حساب بالفعل؟ تسجيل الدخول',
            variant: FixFlowButtonVariant.text,
            onPressed: loading ? null : widget.onShowSignIn,
          ),
        ],
      ),
    );
  }
}
