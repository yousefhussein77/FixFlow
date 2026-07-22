enum AuthFailureKind {
  validation,
  unauthenticated,
  offline,
  server,
  contract,
  storage,
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    } catch (_) {
      throw const AuthFailure(
        AuthFailureKind.contract,
        'The server returned an invalid profile.',
      );
    }
  }
}

class AuthSession {
  const AuthSession({required this.profile, required this.token});

  final UserProfile profile;
  final String token;
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, this.message, {this.fieldErrors = const {}});

  final AuthFailureKind kind;
  final String message;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => 'AuthFailure($kind, $message)';
}
