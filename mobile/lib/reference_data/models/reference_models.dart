import '../../auth/models/auth_models.dart';

class Department {
  const Department({
    required this.id,
    required this.name,
    required this.isActive,
    required this.version,
  });
  final int id;
  final String name;
  final bool isActive;
  final int version;
  factory Department.fromJson(Map<String, dynamic> j) => Department(
    id: j['id'] as int,
    name: j['name'] as String,
    isActive: j['is_active'] as bool,
    version: j['version'] as int,
  );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
    required this.isActive,
    required this.version,
  });
  final int id;
  final String name;
  final int departmentId;
  final String departmentName;
  final bool isActive;
  final int version;
  factory Category.fromJson(Map<String, dynamic> j) {
    final d = j['department'] as Map<String, dynamic>;
    return Category(
      id: j['id'] as int,
      name: j['name'] as String,
      departmentId: d['id'] as int,
      departmentName: d['name'] as String,
      isActive: j['is_active'] as bool,
      version: j['version'] as int,
    );
  }
}

class ReferenceOption {
  const ReferenceOption(this.id, this.name);
  final int id;
  final String name;
  factory ReferenceOption.fromJson(Map<String, dynamic> j) =>
      ReferenceOption(j['id'] as int, j['name'] as String);
}

enum ReferenceStatus {
  idle,
  loading,
  success,
  empty,
  validation,
  unauthorized,
  offline,
  conflict,
  serverError,
}

class ReferenceFailure extends AuthFailure {
  const ReferenceFailure(super.kind, super.message, {super.fieldErrors});
}
