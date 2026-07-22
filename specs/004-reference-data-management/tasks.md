# Tasks: Department and Category Reference Data

## Phase 1: Setup

- [X] T001 Verify existing ignore and dependency configuration in `.gitignore`, `backend/composer.json`, and `mobile/pubspec.yaml`
- [X] T002 Resolve existing Laravel and Flutter dependencies using `backend/composer.lock` and `mobile/pubspec.lock`

## Phase 2: Foundational

- [X] T003 Create department and category migrations in `backend/database/migrations/2026_07_22_130000_create_departments_table.php` and `backend/database/migrations/2026_07_22_130100_create_categories_table.php`
- [X] T004 Create Department and Category models/factories in `backend/app/Models/Department.php`, `backend/app/Models/Category.php`, `backend/database/factories/DepartmentFactory.php`, and `backend/database/factories/CategoryFactory.php`
- [X] T005 Create administrator middleware and alias in `backend/app/Http/Middleware/EnsureUserIsAdministrator.php` and `backend/bootstrap/app.php`
- [X] T006 [P] Create reference resources and conflict response support in `backend/app/Http/Resources/DepartmentResource.php`, `backend/app/Http/Resources/CategoryResource.php`, and `backend/app/Support/ApiResponse.php`
- [X] T007 [P] Create shared reference-data Flutter models/failures in `mobile/lib/reference_data/models/reference_models.dart`
- [X] T008 [P] Create reference-data API service in `mobile/lib/reference_data/services/reference_api_service.dart`
- [X] T009 Create reference-data repository in `mobile/lib/reference_data/repositories/reference_repository.dart`

## Phase 3: User Story 1 - Manage Departments (P1)

**Independent Test**: Administrator completes all department operations; non-admin IDs are concealed; duplicate/stale/atomic behavior is verified.

- [X] T010 [US1] Add failing department API and authorization tests in `backend/tests/Feature/ReferenceData/DepartmentTest.php`
- [X] T011 [P] [US1] Create department Form Requests in `backend/app/Http/Requests/ReferenceData/DepartmentRequest.php` and `backend/app/Http/Requests/ReferenceData/VersionRequest.php`
- [X] T012 [US1] Implement department Actions in `backend/app/Actions/ReferenceData/ManageDepartment.php`
- [X] T013 [US1] Implement department controller and admin routes in `backend/app/Http/Controllers/Api/DepartmentController.php` and `backend/routes/api.php`
- [X] T014 [US1] Add failing Flutter department state/widget tests in `mobile/test/reference_data/department_management_test.dart`
- [X] T015 [US1] Implement reference controller department transitions in `mobile/lib/reference_data/state/reference_controller.dart`
- [X] T016 [US1] Implement department list/form/detail/lifecycle UI in `mobile/lib/reference_data/screens/department_screen.dart`
- [X] T017 [US1] Run and pass independent department backend and Flutter tests in `backend/tests/Feature/ReferenceData/DepartmentTest.php` and `mobile/test/reference_data/department_management_test.dart`

## Phase 4: User Story 2 - Manage Categories (P1)

**Independent Test**: Administrator manages scoped-unique categories and relationships; all denied/conflict paths preserve data.

- [X] T018 [US2] Add failing category API/relationship/authorization tests in `backend/tests/Feature/ReferenceData/CategoryTest.php`
- [X] T019 [P] [US2] Create category Form Request in `backend/app/Http/Requests/ReferenceData/CategoryRequest.php`
- [X] T020 [US2] Implement category Actions in `backend/app/Actions/ReferenceData/ManageCategory.php`
- [X] T021 [US2] Implement category controller and admin routes in `backend/app/Http/Controllers/Api/CategoryController.php` and `backend/routes/api.php`
- [X] T022 [US2] Add Flutter category state/widget tests in `mobile/test/reference_data/category_management_test.dart`
- [X] T023 [US2] Implement category transitions and UI in `mobile/lib/reference_data/state/reference_controller.dart` and `mobile/lib/reference_data/screens/category_screen.dart`
- [X] T024 [US2] Run and pass independent category backend and Flutter tests in `backend/tests/Feature/ReferenceData/CategoryTest.php` and `mobile/test/reference_data/category_management_test.dart`

## Phase 5: User Story 3 - Load Active Options (P2)

**Independent Test**: Every active role receives only effectively active options; inactive and unauthenticated combinations are verified.

- [X] T025 [US3] Add failing active-option API tests in `backend/tests/Feature/ReferenceData/ReferenceOptionTest.php`
- [X] T026 [US3] Implement option controller/routes in `backend/app/Http/Controllers/Api/ReferenceOptionController.php` and `backend/routes/api.php`
- [X] T027 [US3] Add Flutter option loading tests in `mobile/test/reference_data/reference_options_test.dart`
- [X] T028 [US3] Implement reusable option loading state/widget in `mobile/lib/reference_data/state/reference_controller.dart` and `mobile/lib/reference_data/widgets/reference_option_loader.dart`

## Phase 6: Polish and Verification

- [X] T029 Update reproducible seed/reference documentation in `backend/database/seeders/DatabaseSeeder.php`, `backend/README.md`, and `mobile/README.md`
- [X] T030 Run all Laravel tests, Pint, route/migration, dependency, authorization, and security checks across `backend/`
- [X] T031 Run Dart formatting, Flutter analysis/tests, and dependency checks across `mobile/`
- [X] T032 Audit forbidden scope, DELETE absence, secrets, completed quickstart, and record evidence in `specs/004-reference-data-management/tasks.md`

## Dependencies and Strategy

T001–T009 block stories. US1 is the MVP. US2 depends on departments. US3 depends on both entities. Tests precede implementation. No delete, ticket, assignment, comment, rating, user/role administration, or analytics tasks exist.

## Completion Evidence

- Laravel: 19 tests passed with 141 assertions; reference-data subset 6 tests/49 assertions; Pint passed.
- Flutter: 18 tests passed; formatter changed zero files on final check; analyzer reported no issues.
- Migrations: department and category migrations ran successfully in the testing database.
- Dependencies: Composer validation passed, Composer reported no advisories, and Flutter direct dependencies are current.
- Authorization: reporter/nonexistent ID probes return identical `403`; visitors return `401`; active reporter, technician, and administrator option reads passed.
- Security/scope: no DELETE routes; inactive rows retained; names and scoped uniqueness enforced at validation/database layers; no ticket, assignment, comment, rating, user/role administration, or analytics implementation.
