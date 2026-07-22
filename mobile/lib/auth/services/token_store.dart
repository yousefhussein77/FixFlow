import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'fixflow.auth_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _protect(() => _storage.read(key: _key));

  @override
  Future<void> write(String token) =>
      _protect(() => _storage.write(key: _key, value: token));

  @override
  Future<void> clear() => _protect(() => _storage.delete(key: _key));

  Future<T> _protect<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (_) {
      throw const AuthFailure(
        AuthFailureKind.storage,
        'Secure session storage is unavailable on this device.',
      );
    }
  }
}
