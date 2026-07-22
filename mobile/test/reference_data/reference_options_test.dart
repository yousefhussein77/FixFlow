import 'package:fixflow/reference_data/models/reference_models.dart';
import 'package:fixflow/reference_data/repositories/reference_repository.dart';
import 'package:fixflow/reference_data/state/reference_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active options expose success and empty states', () async {
    final r = Options();
    final c = ReferenceController(r);
    await c.loadDepartmentOptions();
    expect(c.options.single.name, 'Facilities');
    r.empty = true;
    await c.loadCategoryOptions(1);
    expect(c.state.status, ReferenceStatus.empty);
  });
}

class Options implements ReferenceRepository {
  bool empty = false;
  @override
  Future<List<ReferenceOption>> departmentOptions() async => const [
    ReferenceOption(1, 'Facilities'),
  ];
  @override
  Future<List<ReferenceOption>> categoryOptions(int id) async =>
      empty ? [] : const [ReferenceOption(2, 'Electrical')];
  @override
  Future<List<Department>> departments() async => [];
  @override
  Future<List<Category>> categories() async => [];
  @override
  Future<Department> saveDepartment({
    int? id,
    required String name,
    int? version,
  }) => throw UnimplementedError();
  @override
  Future<Department> setDepartmentActive(Department value, bool active) =>
      throw UnimplementedError();
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
