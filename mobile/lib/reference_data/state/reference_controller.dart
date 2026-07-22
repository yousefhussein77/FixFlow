import 'package:flutter/foundation.dart' hide Category;
import '../../auth/models/auth_models.dart';
import '../models/reference_models.dart';
import '../repositories/reference_repository.dart';

class ReferenceState {
  const ReferenceState(this.status, {this.message, this.errors = const {}});
  final ReferenceStatus status;
  final String? message;
  final Map<String, List<String>> errors;
}

class ReferenceController extends ChangeNotifier {
  ReferenceController(this.repository);
  final ReferenceRepository repository;
  ReferenceState state = const ReferenceState(ReferenceStatus.idle);
  List<Department> departments = [];
  List<Category> categories = [];
  List<ReferenceOption> options = [];
  int _generation = 0;
  void _set(ReferenceState s) {
    state = s;
    notifyListeners();
  }

  Future<void> loadDepartments() async =>
      _load(() => repository.departments(), (v) => departments = v);
  Future<void> loadCategories() async =>
      _load(() => repository.categories(), (v) => categories = v);
  Future<void> loadDepartmentOptions() async =>
      _load(() => repository.departmentOptions(), (v) => options = v);
  Future<void> loadCategoryOptions(int id) async =>
      _load(() => repository.categoryOptions(id), (v) => options = v);
  Future<void> saveDepartment({
    int? id,
    required String name,
    int? version,
  }) async => _mutation(
    () => repository.saveDepartment(id: id, name: name, version: version),
    loadDepartments,
  );
  Future<void> toggleDepartment(Department d) async => _mutation(
    () => repository.setDepartmentActive(d, !d.isActive),
    loadDepartments,
  );
  Future<void> saveCategory({
    int? id,
    required int departmentId,
    required String name,
    int? version,
  }) async => _mutation(
    () => repository.saveCategory(
      id: id,
      departmentId: departmentId,
      name: name,
      version: version,
    ),
    loadCategories,
  );
  Future<void> toggleCategory(Category c) async => _mutation(
    () => repository.setCategoryActive(c, !c.isActive),
    loadCategories,
  );
  Future<void> _load<T>(
    Future<List<T>> Function() op,
    void Function(List<T>) assign,
  ) async {
    final g = ++_generation;
    _set(const ReferenceState(ReferenceStatus.loading));
    try {
      final v = await op();
      if (g != _generation) return;
      assign(v);
      _set(
        ReferenceState(
          v.isEmpty ? ReferenceStatus.empty : ReferenceStatus.success,
        ),
      );
    } on AuthFailure catch (e) {
      if (g == _generation) _failure(e);
    }
  }

  Future<void> _mutation(
    Future<Object> Function() op,
    Future<void> Function() refresh,
  ) async {
    final g = ++_generation;
    _set(const ReferenceState(ReferenceStatus.loading));
    try {
      await op();
      if (g != _generation) return;
      _set(const ReferenceState(ReferenceStatus.success));
      await refresh();
    } on AuthFailure catch (e) {
      if (g == _generation) _failure(e);
    }
  }

  void _failure(AuthFailure e) {
    final conflict = e.fieldErrors.containsKey('conflict');
    final s = conflict
        ? ReferenceStatus.conflict
        : switch (e.kind) {
            AuthFailureKind.validation => ReferenceStatus.validation,
            AuthFailureKind.unauthenticated => ReferenceStatus.unauthorized,
            AuthFailureKind.offline => ReferenceStatus.offline,
            _ => ReferenceStatus.serverError,
          };
    _set(ReferenceState(s, message: e.message, errors: e.fieldErrors));
  }
}
