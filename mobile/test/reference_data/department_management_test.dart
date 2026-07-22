import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/reference_data/models/reference_models.dart';
import 'package:fixflow/reference_data/repositories/reference_repository.dart';
import 'package:fixflow/reference_data/state/reference_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('department loading represents populated and empty success', () async {
    final r = FakeReferences();
    final c = ReferenceController(r);
    await c.loadDepartments();
    expect(c.state.status, ReferenceStatus.success);
    expect(c.departments.single.name, 'Facilities');
    r.empty = true;
    await c.loadDepartments();
    expect(c.state.status, ReferenceStatus.empty);
  });
  test('stale conflict maps to conflict state', () async {
    final c = ReferenceController(FakeReferences(conflict: true));
    await c.saveDepartment(name: 'X');
    expect(c.state.status, ReferenceStatus.conflict);
  });
}

class FakeReferences implements ReferenceRepository {
  FakeReferences({this.conflict = false});
  bool empty = false;
  final bool conflict;
  final d = const Department(
    id: 1,
    name: 'Facilities',
    isActive: true,
    version: 1,
  );
  @override
  Future<List<Department>> departments() async => empty ? [] : [d];
  @override
  Future<Department> saveDepartment({
    int? id,
    required String name,
    int? version,
  }) async {
    if (conflict)
      throw const ReferenceFailure(
        AuthFailureKind.contract,
        'Conflict',
        fieldErrors: {
          'conflict': ['changed'],
        },
      );
    return d;
  }

  @override
  Future<Department> setDepartmentActive(Department value, bool active) async =>
      d;
  @override
  Future<List<Category>> categories() async => [];
  @override
  Future<List<ReferenceOption>> departmentOptions() async => [];
  @override
  Future<List<ReferenceOption>> categoryOptions(int id) async => [];
  @override
  Future<Category> saveCategory({
    int? id,
    required int departmentId,
    required String name,
    int? version,
  }) => throw UnimplementedError();
  @override
  Future<Category> setCategoryActive(Category value, bool active) =>
      throw UnimplementedError();
}
