import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../validation/auth_input_validator.dart';

enum AuthViewStatus {
  restoring,
  signedOut,
  loading,
  authenticated,
  registrationPending,
  accountPending,
  accountRejected,
  accountInactive,
  validationError,
  unauthenticated,
  offline,
  serverError,
  storageError,
}

class AuthViewState {
  const AuthViewState({
    required this.status,
    this.profile,
    this.message,
    this.fieldErrors = const {},
    this.isRestoreFailure = false,
  });

  const AuthViewState.signedOut() : this(status: AuthViewStatus.signedOut);

  final AuthViewStatus status;
  final UserProfile? profile;
  final String? message;
  final Map<String, List<String>> fieldErrors;
  final bool isRestoreFailure;

  bool get isLoading =>
      status == AuthViewStatus.loading || status == AuthViewStatus.restoring;
}

class AuthController extends ChangeNotifier {
  AuthController(this._repository, {bool restoreOnCreate = false})
    : _state = restoreOnCreate
          ? const AuthViewState(status: AuthViewStatus.restoring)
          : const AuthViewState.signedOut() {
    if (restoreOnCreate) restore();
  }

  final AuthRepository _repository;
  AuthViewState _state;
  int _generation = 0;
  bool _registrationInFlight = false;

  AuthViewState get state => _state;

  void _set(AuthViewState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) async {
    if (_registrationInFlight) return;

    final errors = <String, List<String>>{
      if (AuthInputValidator.name(name) case final error?) 'name': [error],
      if (AuthInputValidator.email(email) case final error?) 'email': [error],
      if (AuthInputValidator.password(password) case final error?)
        'password': [error],
      if (AuthInputValidator.confirmation(password, passwordConfirmation)
          case final error?)
        'password_confirmation': [error],
      if (role != 'reporter' && role != 'technician')
        'role': ['اختر نوع حساب مدعومًا.'],
    };
    if (errors.isNotEmpty) {
      _set(
        AuthViewState(
          status: AuthViewStatus.validationError,
          fieldErrors: errors,
          message: 'تحقق من البيانات المدخلة ثم حاول مجددًا.',
        ),
      );
      return;
    }
    _registrationInFlight = true;
    final generation = ++_generation;
    _set(const AuthViewState(status: AuthViewStatus.loading));
    try {
      final profile = await _repository.register(
        name: AuthInputValidator.normalizeName(name),
        email: AuthInputValidator.normalizeEmail(email),
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      if (generation != _generation) return;
      _set(
        AuthViewState(
          status: AuthViewStatus.registrationPending,
          profile: profile,
          message: 'تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.',
        ),
      );
    } on AuthFailure catch (failure) {
      if (generation == _generation) _setFailure(failure);
    } finally {
      _registrationInFlight = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final errors = <String, List<String>>{
      if (AuthInputValidator.email(email) case final error?) 'email': [error],
      if (password.isEmpty) 'password': ['كلمة المرور مطلوبة.'],
    };
    if (errors.isNotEmpty) {
      _set(
        AuthViewState(
          status: AuthViewStatus.validationError,
          fieldErrors: errors,
          message: 'تحقق من البيانات المدخلة ثم حاول مجددًا.',
        ),
      );
      return;
    }
    final generation = ++_generation;
    _set(const AuthViewState(status: AuthViewStatus.loading));
    try {
      final profile = await _repository.login(
        email: AuthInputValidator.normalizeEmail(email),
        password: password,
      );
      if (generation != _generation) return;
      _set(
        AuthViewState(status: AuthViewStatus.authenticated, profile: profile),
      );
    } on AuthFailure catch (failure) {
      if (generation == _generation) _setFailure(failure);
    }
  }

  Future<void> restore() async {
    final generation = ++_generation;
    _set(const AuthViewState(status: AuthViewStatus.restoring));
    try {
      final profile = await _repository.restore();
      if (generation != _generation) return;
      _set(
        profile == null
            ? const AuthViewState.signedOut()
            : AuthViewState(
                status: AuthViewStatus.authenticated,
                profile: profile,
              ),
      );
    } on AuthFailure catch (failure) {
      if (generation == _generation) {
        if (kDebugMode) {
          debugPrint('Session restore failed: $failure');
        }
        _setFailure(
          failure,
          message:
              'تعذر الاتصال بالخادم. تأكد من تشغيل الخدمة ثم حاول مرة أخرى.',
          isRestoreFailure: true,
        );
      }
    }
  }

  Future<void> refreshProfile() async {
    final generation = ++_generation;
    final previous = state.profile;
    _set(AuthViewState(status: AuthViewStatus.loading, profile: previous));
    try {
      final profile = await _repository.profile();
      if (generation != _generation) return;
      _set(
        AuthViewState(status: AuthViewStatus.authenticated, profile: profile),
      );
    } on AuthFailure catch (failure) {
      if (generation == _generation) _setFailure(failure);
    }
  }

  Future<void> logout() async {
    ++_generation;
    _set(const AuthViewState(status: AuthViewStatus.loading));
    try {
      await _repository.logout();
    } on AuthFailure {
      // Local sign-out remains authoritative for every remote failure.
    } finally {
      _set(const AuthViewState.signedOut());
    }
  }

  void clearFieldError(String field) {
    if (_state.isLoading ||
        (_state.message == null && !_state.fieldErrors.containsKey(field))) {
      return;
    }
    final fieldErrors = Map<String, List<String>>.from(_state.fieldErrors)
      ..remove(field);
    _set(
      AuthViewState(
        status: fieldErrors.isEmpty
            ? AuthViewStatus.signedOut
            : AuthViewStatus.validationError,
        fieldErrors: fieldErrors,
      ),
    );
  }

  void _setFailure(
    AuthFailure failure, {
    String? message,
    bool isRestoreFailure = false,
  }) {
    final status = switch (failure.kind) {
      AuthFailureKind.validation => AuthViewStatus.validationError,
      AuthFailureKind.unauthenticated => AuthViewStatus.unauthenticated,
      AuthFailureKind.pending => AuthViewStatus.accountPending,
      AuthFailureKind.rejected => AuthViewStatus.accountRejected,
      AuthFailureKind.inactive => AuthViewStatus.accountInactive,
      AuthFailureKind.offline => AuthViewStatus.offline,
      AuthFailureKind.storage => AuthViewStatus.storageError,
      AuthFailureKind.server ||
      AuthFailureKind.contract => AuthViewStatus.serverError,
    };
    _set(
      AuthViewState(
        status: status,
        message: message ?? failure.message,
        fieldErrors: failure.fieldErrors,
        isRestoreFailure: isRestoreFailure,
      ),
    );
  }
}
