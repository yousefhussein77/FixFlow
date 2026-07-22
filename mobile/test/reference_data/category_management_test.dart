import 'package:fixflow/reference_data/models/reference_models.dart';
import 'package:fixflow/reference_data/repositories/reference_repository.dart';
import 'package:fixflow/reference_data/state/reference_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category list retains inactive records', () async {
    final c = ReferenceController(Categories());
    await c.loadCategories();
    expect(c.categories.length, 2);
    expect(c.categories.last.isActive, false);
    expect(c.state.status, ReferenceStatus.success);
  });
}

class Categories implements ReferenceRepository {
  final values = const [
    Category(
      id: 1,
      name: 'Electrical',
      departmentId: 1,
      departmentName: 'Facilities',
      isActive: true,
      version: 1,
    ),
    Category(
      id: 2,
      name: 'Old',
      departmentId: 1,
      departmentName: 'Facilities',
      isActive: false,
      version: 2,
    ),
  ];
  @override
  Future<List<Category>> categories() async => values;
  @override
  Future<List<Department>> departments() async => [];
  @override
  Future<List<ReferenceOption>> departmentOptions() async => [];
  @override
  Future<List<ReferenceOption>> categoryOptions(int id) async => [];
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
  }) async => values.first;
  @override
  Future<Category> setCategoryActive(Category value, bool active) async =>
      value;
}
