import '../../auth/models/auth_models.dart';
import '../../auth/services/token_store.dart';
import '../models/reference_models.dart';
import '../services/reference_api_service.dart';

abstract interface class ReferenceRepository {
  Future<List<Department>> departments();
  Future<List<Category>> categories();
  Future<List<ReferenceOption>> departmentOptions();
  Future<List<ReferenceOption>> categoryOptions(int departmentId);
  Future<Department> saveDepartment({
    int? id,
    required String name,
    int? version,
  });
  Future<Department> setDepartmentActive(Department value, bool active);
  Future<Category> saveCategory({
    int? id,
    required int departmentId,
    required String name,
    int? version,
  });
  Future<Category> setCategoryActive(Category value, bool active);
}

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this.api, this.store);
  final ReferenceApiService api;
  final TokenStore store;
  Future<String> _token() async {
    final t = await store.read();
    if (t == null)
      throw const AuthFailure(
        AuthFailureKind.unauthenticated,
        'يجب تسجيل الدخول للمتابعة.',
      );
    return t;
  }

  @override
  Future<List<Department>> departments() async => (await api.list(
    '/api/admin/departments',
    await _token(),
  )).map(Department.fromJson).toList();
  @override
  Future<List<Category>> categories() async => (await api.list(
    '/api/admin/categories',
    await _token(),
  )).map(Category.fromJson).toList();
  @override
  Future<List<ReferenceOption>> departmentOptions() async => (await api.list(
    '/api/options/departments',
    await _token(),
  )).map(ReferenceOption.fromJson).toList();
  @override
  Future<List<ReferenceOption>> categoryOptions(int id) async =>
      (await api.list(
        '/api/options/departments/$id/categories',
        await _token(),
      )).map(ReferenceOption.fromJson).toList();
  @override
  Future<Department> saveDepartment({
    int? id,
    required String name,
    int? version,
  }) async => Department.fromJson(
    await api.mutate(
      id == null ? 'POST' : 'PUT',
      id == null ? '/api/admin/departments' : '/api/admin/departments/$id',
      await _token(),
      {'name': name, if (version != null) 'version': version},
    ),
  );
  @override
  Future<Department> setDepartmentActive(
    Department d,
    bool active,
  ) async => Department.fromJson(
    await api.mutate(
      'PATCH',
      '/api/admin/departments/${d.id}/${active ? 'activate' : 'deactivate'}',
      await _token(),
      {'version': d.version},
    ),
  );
  @override
  Future<Category> saveCategory({
    int? id,
    required int departmentId,
    required String name,
    int? version,
  }) async => Category.fromJson(
    await api.mutate(
      id == null ? 'POST' : 'PUT',
      id == null ? '/api/admin/categories' : '/api/admin/categories/$id',
      await _token(),
      {
        'department_id': departmentId,
        'name': name,
        if (version != null) 'version': version,
      },
    ),
  );
  @override
  Future<Category> setCategoryActive(Category c, bool active) async =>
      Category.fromJson(
        await api.mutate(
          'PATCH',
          '/api/admin/categories/${c.id}/${active ? 'activate' : 'deactivate'}',
          await _token(),
          {'version': c.version},
        ),
      );
}
