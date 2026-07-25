# Tasks: Design System and UI Polish

**Input**: Design documents from `specs/010-design-system-ui-polish/`

**Verification**: Flutter tests are mandatory and precede the corresponding presentation implementation. Every migration phase must preserve the existing state controllers, repositories, API services, routes, validation, authorization, retry semantics, and business workflows. Backend changes are not required or authorized.

**Execution boundary**: Run Flutter and Dart commands from `mobile/`. Do not add product behavior, change backend/API files, commit, or push.

## Phase 1: Brand, Themes, and Tokens

**Goal**: Establish the approved FixFlow identity and centralized theme/token foundation without migrating business screens beyond app-level theme wiring.

**Independent Test**: Construct both themes, verify every token and semantic ticket mapping, render approved brand variants deterministically, switch theme and direction without losing app state, and confirm the existing Flutter suite remains green.

### Tests for Phase 1

> Write these tests first and observe the focused design-system suite fail before implementation.

- [x] T001 [P] [US1] Add failing exact-anchor, light/dark completeness, and `ThemeExtension` presence tests for the planned `ColorScheme` and semantic colors in mobile/test/design_system/theme_test.dart
- [x] T002 [P] [US1] Add failing typography, 8-point spacing, radius, border, elevation, icon-size, and motion invariant tests in mobile/test/design_system/token_test.dart
- [x] T003 [P] [US1] Add failing ticket status (`new`, `assigned`, `in_progress`, `completed`, `rejected`) and priority (`low`, `medium`, `high`) style tests proving label/icon/non-color cues and complete light/dark pairs in mobile/test/design_system/ticket_semantics_test.dart
- [x] T004 [P] [US5] Add failing contrast-ratio tests for text, graphics, focus, disabled, feedback, status, and priority foreground/container pairs in mobile/test/design_system/contrast_test.dart
- [x] T005 [P] [US1] Add failing brand asset inventory, naming, variant-dimension, clear-space metadata, and missing-asset fallback tests in mobile/test/design_system/brand_assets_test.dart
- [x] T006 [P] [US1] Add deterministic light/dark brand-lockup and icon-only golden cases with fixed surface sizes in mobile/test/design_system/golden/brand_golden_test.dart and mobile/test/design_system/golden/goldens/brand/

### Implementation for Phase 1

- [x] T007 [US1] Create the canonical approved geometric blue-and-orange vector source, usage metadata, and runtime asset folders with unambiguous variant names in mobile/assets/brand/source/fixflow_logo_master.svg, mobile/assets/brand/README.md, and mobile/assets/brand/runtime/
- [x] T008 [P] [US1] Produce approved horizontal light/dark, icon-only light/dark, monochrome light/dark, app-icon/launcher master, and splash-mark runtime derivatives without changing the logo concept in mobile/assets/brand/runtime/
- [x] T009 [US1] Register only in-app brand assets in mobile/pubspec.yaml, derive Android launcher outputs in mobile/android/app/src/main/res/mipmap-*/, integrate approved light/dark splash treatment in mobile/android/app/src/main/res/drawable/launch_background.xml, mobile/android/app/src/main/res/drawable-v21/launch_background.xml, mobile/android/app/src/main/res/values/styles.xml, and mobile/android/app/src/main/res/values-night/styles.xml, and verify no font, icon, splash, or third-party design-system dependency is introduced
- [x] T010 [P] [US1] Implement immutable brand anchors, planned light/dark neutral roles, and feedback color roles in mobile/lib/design_system/theme/fixflow_colors.dart
- [x] T011 [P] [US1] Implement the Arabic/Latin-compatible display, page-title, section-title, card-title, body, supporting, label, caption, and ticket-reference scale in mobile/lib/design_system/theme/fixflow_typography.dart
- [x] T012 [P] [US1] Implement 8-point spacing with the controlled 4-point half-step plus radius and border tokens in mobile/lib/design_system/tokens/fixflow_spacing.dart, mobile/lib/design_system/tokens/fixflow_radius.dart, and mobile/lib/design_system/tokens/fixflow_borders.dart
- [x] T013 [P] [US1] Implement flat/low/raised/overlay elevation, consistent line-icon sizes, direction policy, and reduced-motion-aware durations in mobile/lib/design_system/tokens/fixflow_elevation.dart, mobile/lib/design_system/tokens/fixflow_icons.dart, and mobile/lib/design_system/tokens/fixflow_motion.dart
- [x] T014 [US1] Implement typed feedback, ticket-status, and ticket-priority theme extensions with complete `copyWith` and interpolation behavior in mobile/lib/design_system/theme/fixflow_theme_extensions.dart
- [x] T015 [US1] Implement centralized light and dark `ThemeData` through `FixFlowTheme.light()` and `FixFlowTheme.dark()` with Material component themes and explicit `ColorScheme` values in mobile/lib/design_system/theme/fixflow_theme.dart
- [x] T016 [US1] Implement accessible primary/horizontal/icon/monochrome rendering, fallback text, minimum-size, and background-variant selection in mobile/lib/design_system/brand/fixflow_brand.dart and mobile/lib/design_system/brand/fixflow_logo.dart
- [x] T017 [US1] Replace the inline indigo seed theme with centralized light/dark themes and theme-mode wiring without changing dependency composition or session behavior in mobile/lib/app.dart
- [x] T018 [US1] Run mobile/test/design_system/theme_test.dart, mobile/test/design_system/token_test.dart, mobile/test/design_system/ticket_semantics_test.dart, mobile/test/design_system/contrast_test.dart, mobile/test/design_system/brand_assets_test.dart, and mobile/test/design_system/golden/brand_golden_test.dart from mobile/ and verify Phase 1 independently

**Checkpoint**: Approved brand assets, complete themes, and typed tokens are independently usable; no business screen or backend behavior has changed.

---

## Phase 2: Shared Components and States

**Goal**: Provide accessible reusable primitives for controls, content, navigation, overlays, and every approved application state without embedding business logic.

**Independent Test**: Render the shared component catalog in both themes and directions at 320-pixel width and 200% text scale; verify semantics, touch targets, focus, loading stability, state recovery callbacks, and zero repository/API ownership.

### Tests for Phase 2

- [x] T019 [P] [US1] Add failing button variant/state tests for primary, secondary, outline, text, destructive, icon, and floating actions including 48×48 targets, semantics, focus, disabled, and size-stable loading in mobile/test/design_system/button_test.dart
- [x] T020 [P] [US1] Add failing text/password/search/dropdown/multiline/help/error/counter tests including value/focus preservation and long Arabic/English wrapping in mobile/test/design_system/form_controls_test.dart
- [x] T021 [P] [US1] Add failing card, ticket-list-item, metadata-row, avatar, divider, history-item, comment-item, and photo-tile tests in mobile/test/design_system/content_components_test.dart
- [x] T022 [P] [US1] Add failing status-chip and priority-badge tests for all values, themes, directions, semantic labels, and non-color cues in mobile/test/design_system/ticket_badges_test.dart
- [x] T023 [P] [US5] Add failing dialog, form-dialog, bottom-sheet, snackbar, banner, focus-containment, focus-restoration, keyboard-inset, and announcement tests in mobile/test/design_system/overlays_test.dart
- [x] T024 [P] [US5] Add failing app-bar, role-destination, bottom-navigation, tab, segmented-control, and pagination tests for selection semantics, directionality, and minimum targets in mobile/test/design_system/navigation_test.dart
- [x] T025 [P] [US5] Add failing loading, skeleton, empty, success, validation, unauthorized, offline, conflict, and server-error tests proving supportive copy, safe callbacks, no fabricated data, and no color-only meaning in mobile/test/design_system/state_views_test.dart

### Implementation for Phase 2

- [x] T026 [US1] Implement responsive page scaffolding, safe areas, constrained content width, directional padding, scroll/keyboard behavior, and section hierarchy in mobile/lib/design_system/layout/fixflow_page.dart and mobile/lib/design_system/layout/responsive_constraints.dart
- [x] T027 [P] [US1] Implement primary, secondary, outline, text, destructive, icon, and floating button wrappers that accept callbacks/state only in mobile/lib/design_system/components/buttons/fixflow_buttons.dart
- [x] T028 [P] [US1] Implement labeled text, password, search, dropdown, multiline, help/error, and counter components without owning validation rules in mobile/lib/design_system/components/forms/fixflow_fields.dart
- [x] T029 [P] [US1] Implement reusable surface/card, metadata row, avatar, divider, and ticket list-item presentation in mobile/lib/design_system/components/content/fixflow_surfaces.dart and mobile/lib/design_system/components/tickets/fixflow_ticket_list_item.dart
- [x] T030 [P] [US1] Implement semantic status chips and priority badges using only the typed theme mappings in mobile/lib/design_system/components/tickets/fixflow_ticket_badges.dart
- [x] T031 [P] [US1] Implement reusable history item, plain-text comment item, and photo tile/loading/error presentation in mobile/lib/design_system/components/tickets/fixflow_ticket_content.dart
- [x] T032 [P] [US5] Implement accessible confirmation/form dialogs and adaptive keyboard-safe bottom sheets with caller-owned actions in mobile/lib/design_system/components/overlays/fixflow_dialogs.dart and mobile/lib/design_system/components/overlays/fixflow_bottom_sheet.dart
- [x] T033 [P] [US5] Implement snackbar and banner helpers for information, success, warning, validation, offline, conflict, and server feedback without logging content in mobile/lib/design_system/components/feedback/fixflow_feedback.dart
- [x] T034 [P] [US5] Implement branded app bar, role destination tile, bottom navigation, tabs, segmented controls, and accessible pagination primitives in mobile/lib/design_system/components/navigation/fixflow_navigation.dart
- [x] T035 [US5] Implement progress, non-readable skeleton, empty, success, validation, unauthorized, offline, conflict, and server-error panels in mobile/lib/design_system/components/feedback/fixflow_state_view.dart
- [x] T036 [US5] Add a deterministic component-catalog test host covering theme, direction, text scale, viewport, reduced motion, and long-content fixtures in mobile/test/design_system/support/design_system_test_host.dart
- [x] T037 [P] [US1] Add stable light/dark and RTL/LTR component-catalog goldens for buttons, forms, cards/badges, overlays, navigation, and state panels in mobile/test/design_system/golden/component_catalog_golden_test.dart and mobile/test/design_system/golden/goldens/components/
- [x] T038 [US1] Run all mobile/test/design_system shared-component tests and goldens from mobile/, review every intended golden difference, and verify Phase 2 without modifying feature controllers, repositories, services, or models

**Checkpoint**: Shared visual components are independently verified and contain no authorization, API, repository, or workflow logic.

---

## Phase 3: Authentication and Profile Migration

**Goal**: Apply the design system to session restore, authentication, registration, profile, logout, and role-gated navigation while preserving all existing behavior.

**Independent Test**: Exercise signed-out restore, sign-in, registration, validation, offline/server retry, profile for every role, and logout in both themes and directions with keyboard and 200% text; compare existing behavioral tests.

### Tests for Phase 3

- [x] T039 [P] [US1] Extend authentication widget tests for branded loading, sign-in/register field semantics, password visibility, validation, duplicate protection, keyboard insets, light/dark, RTL/LTR, and 200% text in mobile/test/auth/sign_in_restore_test.dart and mobile/test/auth/registration_test.dart
- [x] T040 [P] [US1] Extend profile/logout tests for safe identity hierarchy, role badge, exact reporter/administrator/technician destination presence and absence, accessible logout, themes, directions, and narrow widths in mobile/test/auth/profile_test.dart, mobile/test/auth/logout_test.dart, mobile/test/auth/administrator_ticket_access_test.dart, and mobile/test/auth/technician_ticket_access_test.dart
- [x] T041 [P] [US1] Add stable authentication and role-profile representative goldens using fake repositories and fixed profiles in mobile/test/design_system/golden/auth_profile_golden_test.dart and mobile/test/design_system/golden/goldens/auth_profile/

### Implementation for Phase 3

- [x] T042 [US1] Migrate restore loading, signed-out recovery, and authenticated shell presentation to brand/state components without changing controller routing or retry in mobile/lib/auth/screens/session_gate.dart
- [x] T043 [P] [US1] Migrate sign-in to the branded auth page, shared fields/buttons, password semantics, and responsive keyboard-safe layout without changing submission behavior in mobile/lib/auth/screens/sign_in_screen.dart
- [x] T044 [P] [US1] Migrate registration to the branded auth page and shared validation controls without changing reporter-only account creation or duplicate protection in mobile/lib/auth/screens/register_screen.dart
- [x] T045 [US1] Migrate profile identity, role badge, grouped role-gated destinations, and logout presentation without adding or broadening navigation in mobile/lib/auth/screens/profile_screen.dart
- [x] T046 [US1] Run all mobile/test/auth tests plus mobile/test/design_system/golden/auth_profile_golden_test.dart and verify authentication, profile, role gating, and logout behavior remain unchanged
- [x] T047 [US1] Audit the Phase 3 diff to confirm no changes under mobile/lib/auth/models/, mobile/lib/auth/repositories/, mobile/lib/auth/services/, mobile/lib/auth/state/, backend/, or any API/role behavior

**Checkpoint**: Authentication and profile are visually cohesive and accessible with exact prior role behavior.

---

## Phase 4: Reporter Workflow Migration

**Goal**: Migrate the complete reporter-owned ticket journey—list, creation, details, comments, and rating—without changing ownership, validation, retries, photos, or rating rules.

**Independent Test**: Run reporter list/create/detail/comment/rating journeys across all existing states, both themes/directions, 320 width, and 200% text; verify existing test outcomes and excluded-action absence.

### Tests for Phase 4

- [x] T048 [P] [US2] Extend reporter list tests for themed loading, empty, populated, pagination, offline/server retry, ticket badges, RTL/LTR, 320-width, 200% text, and no overflow in mobile/test/tickets/my_tickets_test.dart
- [x] T049 [P] [US2] Extend ticket-creation tests for shared form states, long content, counters, photo tiles, reference-option loading, validation, submitting, preserved input, duplicate protection, themes, directions, keyboard, and narrow widths in mobile/test/tickets/ticket_creation_test.dart and mobile/test/reference_data/reference_options_test.dart
- [x] T050 [P] [US2] Extend reporter detail tests for metadata hierarchy, photos, concealed/offline/server states, authorized comments/rating entry, themes, directions, scaling, and excluded controls in mobile/test/tickets/ticket_details_test.dart
- [x] T051 [P] [US2] Extend reporter comment tests for comment semantics, chronological plain text, empty/loading/validation/offline/server/retry states, composer counter, themes, directions, scaling, and overflow prevention in mobile/test/tickets/reporter_ticket_comments_test.dart and mobile/test/tickets/ticket_comments_controller_test.dart
- [x] T052 [P] [US2] Extend rating tests for accessible segmented values, eligible/read-only/success/validation/already-rated/not-completed/offline/server states, refresh, ticket replacement reset, themes, directions, and role-safe labels in mobile/test/tickets/reporter_ticket_rating_test.dart and mobile/test/tickets/ticket_rating_controller_test.dart
- [x] T053 [P] [US2] Add stable reporter list, creation, detail, comments, and rating representative goldens with deterministic fixtures in mobile/test/design_system/golden/reporter_workflow_golden_test.dart and mobile/test/design_system/golden/goldens/reporter/

### Implementation for Phase 4

- [x] T054 [US2] Migrate owned-ticket list scaffolding, ticket cards/badges, pagination, loading, empty, offline, and server states without changing ownership or controller behavior in mobile/lib/tickets/screens/my_tickets_screen.dart
- [x] T055 [US2] Migrate ticket creation to responsive sections and shared fields/buttons/photo presentation while preserving active department/category validation, priorities, photo constraints, input state, idempotency, and retry in mobile/lib/tickets/screens/create_ticket_screen.dart and mobile/lib/reference_data/widgets/reference_option_loader.dart
- [x] T056 [US2] Migrate reporter ticket detail hierarchy, metadata, photos, state panels, comments entry, and rating placement without changing concealed access or authoritative data in mobile/lib/tickets/screens/ticket_details_screen.dart
- [x] T057 [P] [US2] Migrate the shared role-context comments page and chronological comment/composer presentation without changing endpoints, immutability, token reuse, or retry behavior in mobile/lib/tickets/screens/ticket_comments_screen.dart and mobile/lib/tickets/widgets/ticket_comments_section.dart
- [x] T058 [P] [US2] Migrate rating entry/read-only/conflict presentation to shared components without changing reporter-only, completed-only, exactly-once, token, refresh, or stale-reset behavior in mobile/lib/tickets/widgets/ticket_rating_section.dart
- [x] T059 [US2] Run focused reporter, reference-option, comment, rating, and reporter golden tests from mobile/ and fix presentation regressions without weakening behavioral assertions
- [x] T060 [US2] Audit reporter screens for zero ticket edit/delete, assignment, processing, comment mutation, rating mutation, chat, map, notification, export, analytics, or offline-sync controls in mobile/lib/tickets/screens/ and mobile/lib/tickets/widgets/
- [x] T061 [US2] Audit the Phase 4 diff to confirm reporter models, repositories, services, controllers, backend routes/contracts, validation, authorization, and retry semantics remain unchanged

**Checkpoint**: The complete reporter journey is polished, responsive, accessible, and behaviorally identical.

---

## Phase 5: Administrator Workflow Migration

**Goal**: Migrate the queue, one-time technician assignment, reference-data management, oversight, and administrator comments without adding reassignment, processing, or other authority.

**Independent Test**: Exercise queue states, pagination, technician options, assignment confirmation/conflict/refresh, department/category actions, oversight comments, role absence, themes, directions, text scale, and narrow widths.

### Tests for Phase 5

- [x] T062 [P] [US3] Extend administrator queue tests for dense readable hierarchy, ticket badges, unassigned state, pagination, loading/empty/unauthorized/offline/server states, themes, directions, scaling, and overflow in mobile/test/tickets/admin_ticket_list_test.dart
- [x] T063 [P] [US3] Extend technician-option and assignment tests for accessible option identity/selection, confirmation, loading, validation, conflict, authoritative refresh, duplicate blocking, and no reassignment/unassignment in mobile/test/tickets/technician_options_test.dart and mobile/test/tickets/ticket_assignment_test.dart
- [x] T064 [P] [US3] Extend department/category tests for shared list/form/dialog/activation states, validation, focus, themes, directions, keyboard, scaling, and narrow widths in mobile/test/reference_data/department_management_test.dart and mobile/test/reference_data/category_management_test.dart
- [x] T065 [P] [US3] Extend administrator comment and role-access tests for shared oversight states, explicit administrator context, semantics, and zero technician/rating controls in mobile/test/tickets/admin_ticket_comments_test.dart and mobile/test/auth/administrator_ticket_access_test.dart
- [x] T066 [P] [US3] Add stable administrator queue, assignment dialog, reference-data, and oversight comment goldens in mobile/test/design_system/golden/administrator_workflow_golden_test.dart and mobile/test/design_system/golden/goldens/administrator/

### Implementation for Phase 5

- [x] T067 [US3] Migrate the administrator queue to responsive ticket cards, badges, assignment state, pagination, and shared feedback without changing queue data or role access in mobile/lib/tickets/screens/admin_ticket_list_screen.dart
- [x] T068 [US3] Migrate technician assignment selection/confirmation/validation/conflict presentation without changing one-time assignment or authoritative refresh behavior in mobile/lib/tickets/widgets/ticket_assignment_sheet.dart
- [x] T069 [P] [US3] Migrate department management to shared page/list/dialog/state components without changing administrator authorization or reference-data behavior in mobile/lib/reference_data/screens/department_screen.dart
- [x] T070 [P] [US3] Migrate category management to shared page/list/dialog/state components without changing department scope, validation, or activation behavior in mobile/lib/reference_data/screens/category_screen.dart
- [x] T071 [US3] Verify administrator oversight comments use the migrated shared comments presentation without adding ticket mutation in mobile/lib/tickets/screens/ticket_comments_screen.dart and mobile/lib/tickets/widgets/ticket_comments_section.dart
- [x] T072 [US3] Run focused administrator, reference-data, role-gating, and administrator golden tests from mobile/ and audit zero reassignment, unassignment, processing, rating, or new oversight operations

**Checkpoint**: Administrator workflows are visually consistent and efficient with exactly the previous authority and operations.

---

## Phase 6: Technician Workflow Migration

**Goal**: Migrate assigned-ticket list, details, history, exact processing actions, rejection, and comments while preserving current-assignee concealment and authoritative recovery.

**Independent Test**: Exercise assigned and in-progress tickets through the exact four transitions, rejection validation, terminal states, assignment/access loss, conflict/offline/server refresh, history, and comments across theme/direction/scale/width combinations.

### Tests for Phase 6

- [x] T073 [P] [US4] Extend assigned-list tests for assigned-only cards, badges, pagination, loading/empty/unauthorized/offline/server states, themes, directions, scaling, and narrow widths in mobile/test/tickets/assigned_tickets_test.dart
- [x] T074 [P] [US4] Extend technician-detail tests for work hierarchy, photos, immutable history, comments, concealment, assignment loss, photo failure, offline/server retry, themes, directions, scaling, and overflow in mobile/test/tickets/technician_ticket_details_test.dart
- [x] T075 [P] [US4] Extend Start Work tests for accessible confirmation, disabled duplicate action, assigned-only controls, preserved transition error during refresh, themes, directions, focus, and text scaling in mobile/test/tickets/technician_start_ticket_test.dart
- [x] T076 [P] [US4] Extend completion/rejection tests for exact controls, terminal/destructive distinction, reason field/counter/errors, preserved safe input, conflict/access/offline/server recovery, and no unsupported transition in mobile/test/tickets/technician_resolve_ticket_test.dart
- [x] T077 [P] [US4] Extend technician comment and role-access tests for current-assignment states, semantics, access-loss clearing, retry, themes/directions, and zero assignment/rating controls in mobile/test/tickets/technician_ticket_comments_test.dart and mobile/test/auth/technician_ticket_access_test.dart
- [x] T078 [P] [US4] Add stable assigned-list, technician-detail/history, Start Work confirmation, rejection dialog, terminal state, and comment goldens in mobile/test/design_system/golden/technician_workflow_golden_test.dart and mobile/test/design_system/golden/goldens/technician/

### Implementation for Phase 6

- [x] T079 [US4] Migrate assigned-ticket list scaffolding, cards/badges, pagination, and shared state panels without changing technician-only filtering in mobile/lib/tickets/screens/assigned_tickets_screen.dart
- [x] T080 [US4] Migrate technician detail hierarchy, work metadata, photos, immutable history, comment entry, and state recovery without changing concealed access in mobile/lib/tickets/screens/technician_ticket_details_screen.dart
- [x] T081 [US4] Migrate Start Work, Complete, and Reject controls to shared buttons/dialogs/fields while preserving confirmation, exact transition matrix, rejection validation, duplicate blocking, and authoritative refresh in mobile/lib/tickets/widgets/ticket_processing_actions.dart
- [x] T082 [US4] Verify technician comments use the shared migrated comments UI while preserving current-assignment authorization, immutable plain text, token retry, and restricted clearing in mobile/lib/tickets/screens/ticket_comments_screen.dart and mobile/lib/tickets/widgets/ticket_comments_section.dart
- [x] T083 [US4] Run focused technician list/detail/processing/comment/access and technician golden tests from mobile/ and fix visual regressions without changing state-machine assertions
- [x] T084 [US4] Audit technician presentation for exactly `assigned → in_progress`, `assigned → rejected`, `in_progress → completed`, and `in_progress → rejected` controls and zero reassignment, deletion, rating, or unsupported operations

**Checkpoint**: Technician work is polished and accessible while exact assignment, authorization, transition, history, and retry behavior remains intact.

---

## Phase 7: Cross-Role Consistency and Visual Acceptance

**Goal**: Prove the complete visual system is consistent, accessible, responsive, scope-safe, and regression-free across all roles and environments.

**Independent Test**: Execute the automated and manual matrices in quickstart.md across representative authentication, reporter, administrator, and technician surfaces, shared components and states, themes, directions, 320/360/390/larger phone widths, and 100%/200% text; separate Android evidence from automated checks.

### Cross-Role Tests and Hardening

- [x] T085 [P] [US5] Add a cross-role Arabic RTL and English LTR widget matrix covering representative authentication, reporter, administrator, and technician surfaces plus shared components, mixed Arabic/Latin content, ticket-reference isolation, directional icon policy, and reading order in mobile/test/design_system/directionality_matrix_test.dart
- [x] T086 [P] [US5] Add a cross-role light/dark theme matrix covering representative role surfaces, shared components, and all shared feedback/status/priority states in mobile/test/design_system/theme_matrix_test.dart
- [x] T087 [P] [US5] Add 100%/200% text-scale tests with long Arabic/English labels, metadata, validation, comments, and rejection reason across representative screens in mobile/test/design_system/text_scaling_test.dart
- [x] T088 [P] [US5] Add 320/360/390/larger-width representative-width and zero-overflow tests for role surfaces and shared components, with safe-area/scroll coverage where supported, in mobile/test/design_system/responsive_layout_test.dart
- [x] T089 [P] [US5] Add semantic-tree, 48x48 target, accessible-action, directional-icon, and non-color-meaning checks in mobile/test/design_system/accessibility_test.dart; platform focus and reduced-motion behavior remain covered by component implementations and existing widget tests
- [x] T090 [P] [US5] Add shared loading, skeleton, empty, success, validation, unauthorized, offline, conflict, and server-error state coverage in mobile/test/design_system/state_matrix_test.dart; role-specific concealment, retry, restricted-clearing, and stale-refresh behavior remains covered by workflow tests
- [x] T091 [P] [US5] Add a golden manifest test that verifies every approved deterministic baseline is declared, uniquely named by theme/direction/viewport, and free of dynamic personal or ticket content in mobile/test/design_system/golden/golden_manifest_test.dart
- [x] T092 [US5] Run all mobile/test/design_system tests and goldens from mobile/, inspect intended diffs, and reject baseline updates that hide clipping, contrast, directionality, state, or workflow defects

### Final Automated Validation and Audits

- [x] T093 [US5] Run `dart format --output=none --set-exit-if-changed .` from mobile/, fix formatting failures, and record the exact result in specs/010-design-system-ui-polish/quickstart.md
- [x] T094 [US5] Run `flutter analyze` from mobile/, resolve all diagnostics without suppressing relevant accessibility or correctness warnings, and record the exact result in specs/010-design-system-ui-polish/quickstart.md
- [x] T095 [US5] Run focused theme/token/component, authentication, reporter, administrator, and technician test groups from mobile/ and record exact results in specs/010-design-system-ui-polish/quickstart.md
- [x] T096 [US5] Run the complete `flutter test` suite from mobile/ and record the exact total while preserving every pre-feature behavioral assertion in specs/010-design-system-ui-polish/quickstart.md
- [x] T097 [US5] Audit mobile/pubspec.yaml, mobile/pubspec.lock, brand sources/runtime derivatives, platform icon/splash outputs, and generated goldens for unexplained dependency drift, non-reproducible assets, oversized files, licenses, and stale variants
- [x] T098 [US5] Audit the complete feature diff for credentials, tokens, private keys, personal information, ticket content, comments, rejection reasons, ratings, and other sensitive data in assets, tests, goldens, logs, and documentation
- [x] T099 [US5] Audit backend/, backend/routes/api.php, mobile models/repositories/services/state, and all visible controls to prove no backend/API/route/authorization/validation/workflow change and no chat, maps, analytics, notifications, exports, offline synchronization, or other new feature
- [x] T100 [US5] Run `git diff --check`, review `git status --short` and the complete diff, trace FR-001–FR-060, VC-001–VC-005, AR-001–AR-005, and SC-001–SC-012 to test/manual evidence, and verify no commit or push occurred

### Manual Visual Acceptance and Device Evidence

- [x] T101 [US5] Execute and record the complete brand, component, accessibility, directionality, theme, text-scale, responsive, state, and workflow manual visual-review checklist from specs/010-design-system-ui-polish/quickstart.md on an available supported non-Android target without representing it as Android evidence
- [x] T102 [US5] Run `flutter devices` and execute the full Android visual smoke matrix with `flutter run -d <android-device-id>` from mobile/ when an Android target, required artifacts, and isolated API are available; otherwise record `DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED` with the concrete reason in specs/010-design-system-ui-polish/quickstart.md
- [x] T103 [US5] Reconcile automated, golden, manual, and device results in specs/010-design-system-ui-polish/quickstart.md, leaving failed or environment-deferred evidence explicit and never equating widget/golden/desktop/web results with Android verification

**Checkpoint**: Feature 010 is ready only when automated checks and required non-device reviews pass, all business regressions are absent, and any unavailable Android verification is documented honestly.

---

## Dependencies

- Phase 1 T001–T018 is foundational and blocks every later phase. Tests T001–T006 precede T007–T017; T018 verifies the foundation.
- Phase 2 T019–T038 depends on Phase 1. Tests T019–T025 precede T026–T035; the test host T036 precedes goldens T037; T038 verifies shared components.
- Phase 3 T039–T047 depends on Phases 1–2 and migrates authentication/profile before role workflows.
- Phase 4 T048–T061 depends on Phases 1–3 and delivers the complete reporter slice.
- Phase 5 T062–T072 depends on Phases 1–3; it may begin after shared components and auth/profile are stable, independently of unfinished reporter screen files.
- Phase 6 T073–T084 depends on Phases 1–3; it may begin after shared components and auth/profile are stable, independently of unfinished reporter/administrator screen files except the shared comments presentation.
- Phase 7 T085–T103 depends on all screen migrations. T102 is environment-dependent; documented deferment is acceptable evidence but is never a live Android pass.
- No task depends on or authorizes a backend change.

## Parallel Opportunities

- T001–T006 cover independent theme, token, semantic, contrast, asset, and golden test files.
- T010–T013 implement independent token families after the asset manifest is stable.
- T019–T025 cover independent shared-component test families.
- T027–T034 implement independent component families after their corresponding tests exist.
- T039–T041 cover authentication/profile behavior versus stable visual baselines.
- T043–T044 migrate separate authentication screens after the shared auth contract is established.
- T048–T053 cover independent reporter list, creation, detail, comments, rating, and golden files.
- T057–T058 migrate independent comment and rating widgets after shared primitives are stable.
- T062–T066 cover independent administrator queue, assignment, reference data, comments, and goldens.
- T069–T070 migrate department and category screens independently.
- T073–T078 cover independent technician list, detail, processing, comments, and golden files.
- T085–T091 cover independent cross-role direction, theme, scale, layout, accessibility, state, and golden-manifest concerns.
- T093–T094 may run in either order only when no formatter or implementation process is changing files.
- T097–T099 are independent dependency/asset, sensitive-data, and scope audits after implementation stabilizes.

## Parallel Example: Phase 2

```text
Task T019: Button variants and state tests
Task T020: Form-control tests
Task T021: Content component tests
Task T022: Status/priority badge tests
Task T023: Dialog/sheet/feedback tests
Task T024: Navigation tests
Task T025: Shared application-state tests

After tests exist:
Task T027: Button implementation
Task T028: Form implementation
Task T029: Surface/list-item implementation
Task T030: Ticket badge implementation
Task T031: Ticket content implementation
Task T032: Dialog/sheet implementation
Task T033: Snackbar/banner implementation
Task T034: Navigation implementation
```

## Parallel Example: Role Migrations

```text
After Phases 1–3 are stable and shared comment files are coordinated:
Task T054–T061: Reporter workflow
Task T067–T072: Administrator workflow
Task T079–T084: Technician workflow
```

## Implementation Strategy

1. Freeze the current dependency, API, role, validation, workflow, and test baseline.
2. Write failing foundation tests, then implement the approved brand, tokens, semantic mappings, and centralized themes.
3. Write failing shared-component tests, then build presentation-only primitives with no repository or business ownership.
4. Migrate authentication/profile first to prove app-shell, direction, keyboard, role-gating, and theme behavior.
5. Migrate reporter, administrator, and technician journeys in separate reviewable slices, running focused behavioral tests after each.
6. Add cross-role directionality, theme, scale, responsive, semantics, state, and deterministic golden matrices.
7. Run the full formatting, analysis, regression, dependency, asset, sensitive-file, scope, and diff audits.
8. Complete manual visual review and separately execute or truthfully defer Android verification.

The suggested MVP is Phase 1 plus Phase 2: an independently tested FixFlow brand/theme/token foundation and reusable component catalog. It creates visible reusable value while leaving all business screens and workflows unchanged until their dedicated migrations.

## Notes

- `[P]` marks tasks that touch distinct files or isolated test concerns and can run concurrently after their stated prerequisite.
- `[US1]` covers cohesive product identity and navigation; `[US2]` reporter UX; `[US3]` administrator UX; `[US4]` technician UX; `[US5]` accessibility, RTL/LTR, and responsive cross-role quality.
- Tests precede corresponding implementation, and a failing baseline must be observed where the behavior does not yet exist.
- Golden tests are limited to deterministic surfaces; every accepted update requires visual inspection.
- Final logo artwork must retain the approved geometric blue-and-orange concept. If the canonical vector cannot be supplied or produced with approval, platform icon/splash finalization is blocked rather than replaced with an invented concept.
- No backend change, API change, route change, authorization change, validation change, workflow change, new product feature, commit, or push is part of this task list.
