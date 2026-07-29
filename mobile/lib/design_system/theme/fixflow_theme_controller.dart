import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ThemePreferenceStore {
  Future<String?> read();
  Future<void> write(String value);
}

class SecureThemePreferenceStore implements ThemePreferenceStore {
  SecureThemePreferenceStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const key = 'fixflow.theme_mode';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: key);

  @override
  Future<void> write(String value) => _storage.write(key: key, value: value);
}

class ThemeController extends ChangeNotifier {
  ThemeController(this.store);

  final ThemePreferenceStore store;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> restore() async {
    try {
      final value = await store.read();
      if (value == 'dark') {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.light;
      }
    } catch (_) {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      await store.write(_mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // The visual preference remains active for this session if storage fails.
    }
  }

  Future<void> toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}
