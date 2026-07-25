import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/reference_data/models/reference_models.dart';
import 'package:fixflow/reference_data/repositories/reference_repository.dart';
import 'package:fixflow/reference_data/state/reference_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fixflow/reference_data/screens/department_screen.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';

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

  testWidgets('department management reflows at 320 pixels and 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.light(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DepartmentScreen(
              controller: ReferenceController(FakeReferences()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Facilities'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
