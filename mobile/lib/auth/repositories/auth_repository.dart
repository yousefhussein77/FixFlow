import '../models/auth_models.dart';
import '../services/auth_api_service.dart';
import '../services/token_store.dart';

abstract interface class AuthRepository {
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  });
  Future<UserProfile> login({required String email, required String password});
  Future<UserProfile?> restore();
  Future<UserProfile> profile();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiService api,
    required TokenStore tokenStore,
  }) : _api = api,
       _tokenStore = tokenStore;

  final AuthApiService _api;
  final TokenStore _tokenStore;

  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) async {
    return _api.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.login(email: email, password: password);
    await _tokenStore.write(session.token);
    return session.profile;
  }

  @override
  Future<UserProfile?> restore() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) return null;
    try {
      return await _api.profile(token);
    } on AuthFailure catch (failure) {
      if (failure.kind == AuthFailureKind.unauthenticated) {
        await _tokenStore.clear();
      }
      rethrow;
    }
  }

  @override
  Future<UserProfile> profile() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      throw const AuthFailure(
        AuthFailureKind.unauthenticated,
        'يرجى تسجيل الدخول للمتابعة.',
      );
    }
    try {
      return await _api.profile(token);
    } on AuthFailure catch (failure) {
      if (failure.kind == AuthFailureKind.unauthenticated) {
        await _tokenStore.clear();
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final token = await _tokenStore.read();
    try {
      if (token != null && token.isNotEmpty) await _api.logout(token);
    } finally {
      await _tokenStore.clear();
    }
  }
}
