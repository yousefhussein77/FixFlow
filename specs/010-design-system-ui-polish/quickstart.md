# Quickstart: Design System and UI Polish Validation

**Feature**: `010-design-system-ui-polish`
**Purpose**: Validate the implementation without changing or extending approved FixFlow workflows.

This guide is for the implementation phase. Planning completion does not imply that these future implementation checks have passed.

## 1. Preconditions

- Run Flutter and Dart commands from `mobile/`.
- Use the installed supported Flutter SDK; planning inventory recorded Flutter 3.41.9 and Dart 3.11.5.
- Ensure existing feature dependencies are already available.
- Use deterministic local fixtures/fake repositories for widget and golden tests.
- Use an isolated API and non-production test accounts for any live manual journey.
- Do not alter backend routes, request/response contracts, authorization, validation, or persisted workflow data for visual convenience.
- Do not regenerate or accept a golden solely to make a failing comparison green; inspect the visual change first.

## 2. Planned Automated Validation

From `mobile/`:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/design_system
flutter test test/auth test/reference_data test/tickets
flutter test
```

When stable goldens exist, run the focused golden suite without updating baselines:

```powershell
flutter test test/design_system/golden
```

Only after an intentional visual change has been manually inspected may baselines be regenerated:

```powershell
flutter test --update-goldens test/design_system/golden
```

Expected outcome:

- Formatting produces no changes.
- Analysis reports no issues.
- Token, theme, component, accessibility, directionality, responsive, and golden tests pass.
- Every existing Flutter test remains green with the same behavioral outcome.
- No test depends on a live API, clock, network image, uncontrolled font, animation, or random data unless that dependency is explicitly stabilized.

## 3. Theme and Token Verification

Verify automatically and through inspection:

- [ ] Exact brand anchors are available: `#1E4DB7`, `#386CFF`, `#F28A1B`, `#22C55E`, `#F3F4F6`, `#FFFFFF`, and `#111827`.
- [ ] `FixFlowTheme.light()` and `FixFlowTheme.dark()` each produce a complete theme and required extensions.
- [ ] No migrated screen contains an unexplained raw color, spacing, radius, shadow, icon size, or motion duration.
- [ ] Material component themes cover app bar, buttons, inputs, cards, dialogs, bottom sheets, navigation, chips, segmented controls, snackbars, progress, and dividers.
- [ ] Status styles exist for `new`, `assigned`, `in_progress`, `completed`, and `rejected`.
- [ ] Priority styles exist for `low`, `medium`, and `high`.
- [ ] Every status and priority has label plus icon/shape/non-color meaning.
- [ ] Normal text pairs meet 4.5:1; large text and meaningful graphics/control boundaries meet 3:1.
- [ ] Disabled controls remain identifiable without opacity alone.
- [ ] Theme changes preserve active screen/controller state.
- [ ] Reduced-motion configuration removes nonessential transitions.

## 4. Shared Component Verification

### Buttons

- [ ] Primary, secondary, outline, text, destructive, icon, and floating variants are covered.
- [ ] Default, pressed, focused, disabled, and loading states are distinguishable.
- [ ] Loading does not change button dimensions or allow duplicate submission.
- [ ] Interactive hit area is at least 48×48 logical pixels.
- [ ] Icon-only controls expose an accessible name.

### Forms

- [ ] Text, password, search, dropdown, multiline, help/error, and counter treatments are covered.
- [ ] Labels remain identifiable when fields are populated.
- [ ] Password visibility changes do not alter value, focus, or validation.
- [ ] Field error text is associated semantically and is not color-only.
- [ ] Multiline content and long Arabic/English errors wrap without clipping.
- [ ] Character counters and server field errors preserve existing limits and behavior.

### Content and Ticket Semantics

- [ ] Cards and list items use consistent padding, hierarchy, and nested action behavior.
- [ ] Ticket reference, subject, status, priority, and essential metadata are scannable.
- [ ] Avatars have a safe fallback and accessible label where meaningful.
- [ ] History and comments preserve stable chronology and plain-text content.
- [ ] Photos have loading/error semantics and do not distort layout.

### Overlays, Navigation, and Feedback

- [ ] Dialogs/sheets identify purpose and consequence, handle keyboard/safe area, and manage focus.
- [ ] Destructive or terminal actions are visually distinct and retain existing confirmation.
- [ ] Snackbars/banners are announced and are not the sole durable evidence of consequential success.
- [ ] Selected navigation is visible and announced without color alone.
- [ ] Back/up behavior and role-gated destinations are unchanged.
- [ ] Pagination has accessible previous/next state and does not duplicate existing data.

### State Views

- [ ] Loading/progress communicates activity without fabricated content.
- [ ] Skeletons approximate layout, are not announced as real data, and avoid major shifts.
- [ ] Empty state distinguishes no data from failure or restricted access.
- [ ] Success, validation, unauthorized, offline, conflict, and server-error views use supportive language.
- [ ] Only an already approved safe recovery action is offered.
- [ ] Restricted content clears exactly when existing controller behavior requires it.
- [ ] Conflict/offline/server retry and authoritative refresh behavior does not regress.

## 5. Directionality and Localization Matrix

For each representative screen, run Arabic/RTL and English/LTR cases.

| Check | Arabic RTL | English LTR |
|---|---|---|
| Page/title alignment and reading order | [ ] | [ ] |
| Back/navigation direction | [ ] | [ ] |
| Directional chevrons/arrows | [ ] | [ ] |
| Brand mark not mirrored | [ ] | [ ] |
| Ticket references and mixed text readable | [ ] | [ ] |
| Form labels, fields, errors, counters | [ ] | [ ] |
| Dialog action order and focus | [ ] | [ ] |
| Status/priority label and semantics | [ ] | [ ] |
| Comment author/time/content | [ ] | [ ] |
| Rating values and selected state | [ ] | [ ] |

Use long translated labels, Arabic names, English names, mixed Arabic/Latin descriptions, numbers, punctuation, and long ticket references. Do not translate or rewrite user-authored content.

## 6. Responsive and Text-Scale Matrix

Verify representative screens at:

- Widths: 320, 360, 390, and a representative larger supported phone width.
- Orientations: portrait and landscape where supported.
- Text scale: 100% and 200%, plus an intermediate scale if a defect appears.
- Insets: keyboard visible, top/bottom safe areas, and system navigation.

For every case:

- [ ] No Flutter overflow warning.
- [ ] No clipped essential text or controls.
- [ ] No overlapping controls or feedback.
- [ ] No ordinary page-level horizontal scroll.
- [ ] Primary action remains reachable through layout or scrolling.
- [ ] Dialog and bottom-sheet actions remain reachable above the keyboard.
- [ ] Long content wraps or exposes an accessible complete value.
- [ ] Touch targets remain at least 48×48 logical pixels.
- [ ] Information hierarchy remains understandable.

## 7. Screen Migration Acceptance

### Phase 1 — Foundations and Brand

- [ ] Approved geometric blue-and-orange source is present and reviewed.
- [ ] Primary, horizontal light/dark, icon-only light/dark, and monochrome variants are reproducible.
- [ ] Launcher icon uses safe platform padding and no unreadable wordmark.
- [ ] Splash uses an approved background and does not imply authenticated/loading success.
- [ ] Clear-space, minimum-size, background, and prohibited-use rules pass representative review.
- [x] Centralized light/dark themes replace the seed theme (theme/token tests and all role goldens).
- [x] Token, theme, contrast, and brand golden tests pass (design-system tests and deterministic brand goldens).

### Phase 2 — Shared Components

- [x] All component families in `data-model.md` have independently testable variants/states (component catalog and shared-component tests).
- [x] RTL/LTR, light/dark, semantics, targets, 200% scale, and 320-width cases pass (cross-role matrices and component tests).
- [x] Components contain no repository, API, authorization, or workflow logic (scope audit).

### Phase 3 — Authentication and Profile

- [x] Session restore loading/error/retry is unchanged (Phase 3 focused tests).
- [x] Sign-in and registration validation and duplicate protection are unchanged (Phase 3 focused tests).
- [x] Password fields and keyboard/focus behavior pass (authentication widget tests and goldens).
- [x] Profile displays safe identity fields and exact role-gated destinations (profile and role-access tests).
- [x] Logout behavior is unchanged (authentication regression tests).

### Phase 4 — Reporter

- [x] Owned-ticket list loading/empty/pagination/retry behavior is unchanged (reporter regression tests).
- [x] Creation preserves reference relationships, priorities, photo limits, validation, input, idempotency, and retry (ticket-creation regression tests).
- [x] Detail preserves ownership concealment, photos, and approved data (ticket-detail and authorization tests).
- [x] Comments remain immutable plain text with current retry behavior (comment tests and shared comments goldens).
- [x] Rating remains reporter-only, completed-only, exactly once, with distinct conflict states and authoritative refresh (rating tests).
- [x] No edit, delete, assignment, processing, or other excluded reporter action appears (scope audit and role goldens).

### Phase 5 — Administrator

- [x] Queue data, pagination, loading/empty/error, and oversight remain unchanged (administrator focused tests).
- [x] Only active eligible technicians appear in assignment (assignment and option tests).
- [x] One-time assignment confirmation/conflict/refresh remains unchanged; no reassignment/unassignment appears (assignment tests and scope audit).
- [x] Reference-data create/update/activate/deactivate behavior and validation remain unchanged (reference-data tests).
- [x] Administrator comments retain approved oversight only (administrator comment tests).
- [x] No technician processing or reporter rating control appears (administrator role-access tests and scope audit).

### Phase 6 — Technician

- [x] Assigned list includes only the authenticated technician's current tickets.
- [x] Detail concealment and restricted-data clearing remain unchanged (technician detail tests).
- [x] Only the four approved technician transitions can appear (processing tests and scope audit).
- [x] Start Work confirmation remains required (processing widget test).
- [x] Rejection reason validation and preservation remain unchanged (rejection tests).
- [x] Conflict/offline/server failures preserve visible error and force authoritative refresh as currently approved (transition controller tests).
- [x] History remains immutable and comments require current assignment (processing persistence and comment authorization tests).
- [x] No reassignment, deletion, rating, or unsupported transition appears (technician scope audit).

### Phase 7 — Cross-Role Acceptance

- [x] Equivalent components/states look and behave consistently across roles (representative role screens, shared components, and cross-role matrices).
- [x] Full Flutter regression suite passes (161 tests).
- [x] Golden diffs are intentionally reviewed (all deterministic role/component goldens).
- [x] Dependency manifests contain no unexplained additions (dependency audit).
- [x] Route/API/scope audit detects no business change (scope audit).
- [x] Sensitive-data audit detects no credentials or restricted content in assets, logs, tests, or goldens (sensitive-file audit).
- [x] Git diff contains only approved presentation, asset, test, and feature-documentation changes for feature 010.

## 8. Golden-Test Matrix

Use goldens only when fonts, dimensions, data, animation, time, and imagery are deterministic.

| Subject | Light LTR | Dark LTR | Light RTL | Dark RTL | 200% text |
|---|---:|---:|---:|---:|---:|
| Brand lockup/app shell | [x] | [x] | N/A | N/A | N/A |
| Button and input catalog | [x] | [x] | [x] | [x] | Widget assertions |
| Ticket card/chips | [x] | [x] | [x] | [x] | Widget assertions |
| Shared state catalog | [x] | [x] | [x] | [x] | Widget assertions |
| Authentication representative | [x] | [x] | [x] | [x] | Widget assertions |
| Reporter list/detail representative | [x] | [x] | [x] | [x] | Widget assertions |
| Administrator queue representative | [x] | [x] | [x] | [x] | Widget assertions |
| Technician detail representative | [x] | [x] | [x] | [x] | Widget assertions |

If a cell is impractical because of nondeterministic platform rendering, document the reason and replace it with widget/semantics/layout assertions plus manual review. Do not mark it passed without evidence.

The unchecked foundation and manual-checklist rows above remain intentionally unclaimed where this review did not produce direct evidence (for example, full brand prohibited-use review, physical-device metrics, or keyboard/landscape execution). Completed rows are mapped to the automated or golden evidence described in the phase records below.

## 9. Manual Visual-Review Checklist

Record target name, OS/API version, resolution, pixel density, app build, locale, theme, text scale, reviewer, and timestamp.

### Brand

- [ ] Logo concept is the approved geometric blue-and-orange FixFlow identity.
- [ ] Correct variant is used for each light/dark/compact context.
- [ ] No stretching, rotation, recoloring, crowding, effect, or busy-background misuse.
- [ ] Clear space and minimum size remain intact.
- [ ] App icon is recognizable at launcher and system-small sizes.
- [ ] Splash is restrained, centered, safe-area correct, and visually continuous with the app.

### Visual System

- [ ] Primary blue drives main actions; orange remains a controlled accent.
- [ ] Typography hierarchy is consistent and Arabic/Latin baselines are comfortable.
- [ ] 8-point rhythm, radii, borders, and shadows are consistent.
- [ ] Line icons are consistent and correctly mirrored only when directional.
- [ ] Dark theme is intentionally designed rather than mechanically inverted.
- [ ] Status/priority/feedback semantics remain understandable without color.

### Usability and Accessibility

- [ ] Contrast thresholds are visibly credible and backed by automated ratios.
- [ ] Touch targets are comfortable and do not overlap.
- [ ] Screen reader announces page, controls, values, status, priority, validation, and changes meaningfully.
- [ ] Focus order follows reading order; dialogs contain and restore focus.
- [ ] 200% text remains usable.
- [ ] Arabic and English layouts have correct direction and mixed-content behavior.
- [ ] Keyboard, safe areas, landscape, and narrow width cause no overflow or hidden action.
- [ ] Motion is restrained and reduced-motion behavior is comfortable.

### Workflow Preservation

- [ ] Every visible operation already existed before feature 010.
- [ ] All role boundaries and concealed-access outcomes remain intact.
- [ ] Validation wording placement is improved without changing validation rules.
- [ ] Loading, retry, conflict, offline, and server behavior remains authoritative.
- [ ] No screen displays optimistic business success.
- [ ] No excluded feature is present or implied.

## 10. Live Android Verification — Separate Environment-Dependent Check

Prerequisites:

- An Android phone or emulator is available and visible to Flutter.
- Required Android/Gradle artifacts are already available or reachable.
- An isolated reachable FixFlow API and safe test accounts exist for reporter, administrator, and technician.

From `mobile/`:

```powershell
flutter devices
flutter run -d <android-device-id>
```

Run the manual matrix above on that Android target. Record actual device/emulator evidence separately from widget/golden results.

If no Android target, Gradle artifact access, or isolated API is available, record:

> **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED:** [specific unavailable prerequisite]

Do not substitute Windows, Chrome, static screenshots, widget tests, or goldens for an Android pass.

## 11. Backend and Scope Audit

Backend commands are not normally required because this feature changes no backend behavior. Before completion, inspect the diff and confirm:

- No file under `backend/` changed for feature 010.
- No API path, request, response, status code, route, validation rule, authorization rule, or migration changed.
- No product operation, analytics, notification, export, map, chat, or offline-sync capability was added.
- No dependency was added without a documented exception.
- Brand assets and goldens contain no credential, token, personal information, or restricted ticket content.

If a backend file changes to correct an existing contract-preservation defect, stop and obtain separate review; do not treat it as routine UI polish.

## 12. Evidence Record Template

```text
Date:
Flutter/Dart version:
dart format:
flutter analyze:
focused design-system tests:
existing regression tests:
full flutter test:
golden review:
light/dark:
Arabic RTL / English LTR:
320-width / landscape / keyboard:
200% text scale:
contrast / semantics / touch targets:
route/API/scope/dependency/sensitive-file audit:
Android device/emulator:
manual visual reviewer and target:
remaining blocker:
```

## Planning Baseline Evidence (2026-07-25)

- Planning artifact structure, required-topic coverage, placeholders, and whitespace: passed.
- Current Flutter baseline analyzed from `mobile/`: no issues found.
- Current full Flutter regression suite run from `mobile/`: 75 tests passed.
- No feature 010 application code, backend code, dependency, API, route, authorization, validation, or workflow change was made during planning.
- Golden and design-system tests do not exist yet; they are implementation deliverables and are not claimed as passed.
- Android live visual verification was not run during planning and is not claimed as passed.

## Phase 3 Evidence (2026-07-25)

- Scope: authentication session restoration, sign-in, reporter registration, profile identity, exact existing role-gated destinations, refresh, and logout presentation only.
- Focused authentication and profile validation: 29 tests passed, including seven deterministic golden cases.
- Full Flutter regression suite: 117 tests passed.
- `dart format .`: passed with no remaining changes.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed; Git reported line-ending conversion warnings only.
- Light/dark and RTL/LTR authentication goldens were reviewed; fixed reporter, administrator, and technician identity goldens were also reviewed.
- Narrow 320-pixel layouts and 200% text scaling passed for authentication, registration, reporter profile destinations, and logout access.
- Existing controller submission, validation, duplicate protection, restoration retry, local logout authority, and role-gating behavior remained unchanged.
- No Phase 3 changes were made to authentication models, repositories, services, state controllers, backend files, APIs, routes, authorization, or business workflows.
- Android live-device verification was not run and is not claimed as passed.

## Phase 4 Evidence (2026-07-25)

- Scope: reporter ticket list, ticket creation, owned ticket details, comments presentation, rating presentation, and their existing loading, empty, validation, unauthorized, offline, conflict, and server-error states.
- Focused reporter and reference-option tests passed, including responsive 320-pixel and 200% text cases.
- Reporter workflow golden tests: 4 passed for light/dark and RTL/LTR.
- Full Flutter regression suite: 125 tests passed.
- `dart format .`: passed with no remaining changes.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed; existing line-ending conversion warnings only.
- Shared ticket badge goldens were intentionally regenerated after making badge labels wrap safely at large text sizes.
- Existing reporter controllers, repositories, services, models, API paths, authorization, validation, idempotency, retry, ownership concealment, comment immutability, and rating rules remain unchanged.
- No administrator or technician screen migration was performed.
- Android live visual verification was not run and is not claimed as passed.

### Manual Visual-Review Evidence Record

- Date: 2026-07-25. Exact local timestamp was not captured.
- Available target: Windows desktop host used for Flutter widget/golden execution; no Android target was connected.
- Build context: Flutter 3.41.9 and Dart 3.11.5, deterministic widget/golden test host.
- Locale and direction: English documentation context; both RTL and LTR test directions were exercised.
- Themes and text scale: light and dark themes; 100% and 200% text-scale widget coverage.
- Review method: deterministic golden inspection plus automated semantics, touch-target, directionality, responsive-width, and overflow checks. This is not live-device evidence.
- Android OS/API version: not available because no Android device or emulator was connected.
- Android physical resolution and pixel density: not available because no Android device or emulator was connected.
- Reviewer: Codex automated review; no separate human visual reviewer was available.

## Phase 7 Evidence (2026-07-25)

- Scope: cross-role consistency across representative authentication, reporter, administrator, and technician surfaces, shared components, semantic states, themes, directions, scaling, responsive widths, accessibility, and golden coverage.
- Cross-role design-system matrix: 70 tests passed, including RTL/LTR, light/dark, shared state, accessibility, touch-target, text-scale, and responsive checks.
- Stable golden coverage: all approved authentication, reporter, administrator, technician, brand, component, and overlay baselines passed.
- Complete Flutter regression suite: 161 tests passed.
- `dart format .`: passed with no remaining changes.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed; Git reported existing line-ending conversion warnings only.
- Dependency audit: Flutter/Dart dependency graph inspected; no Phase 7 dependency changes or unexplained additions found.
- Sensitive-file audit: no credentials, tokens, private keys, personal data, ticket content, comments, rejection reasons, or ratings found in Phase 7 tests, assets, goldens, or documentation. Password strings are intentional form-fixture coverage.
- Scope audit: Phase 7 changed only Flutter presentation/tests and feature documentation. No backend, API, route, authorization, validation, state-machine, or business-workflow change was introduced by feature 010.
- Manual visual review: representative light/dark and RTL/LTR goldens were inspected for hierarchy, contrast, status/priority distinction, spacing, clipping, and overflow; automated narrow-width and 200% text checks passed.
- Android device check: `flutter devices` found Windows, Chrome, and Edge only. Android verification is **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED** because no Android device or emulator is available.

## Phase 6 Evidence (2026-07-25)

- Scope: technician assigned-ticket list, ticket details, immutable status history, exact processing controls, rejection presentation, and technician comments presentation.
- Focused technician list/detail/processing/rejection/comments/access tests passed, including 320-pixel and 200% text cases, Start Work confirmation, rejection reason entry, conflict/offline/server refresh preservation, and concealed detail access.
- Technician workflow golden tests: 4 passed for light/dark and RTL/LTR variants.
- Full Flutter regression suite: 139 tests passed.
- `dart format .`: passed with no remaining changes.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed; Git reported line-ending conversion warnings only.
- Existing technician-only filtering, role gating, exact four-transition state machine, rejection validation, immutable history ordering, comment authorization, retry behavior, and restricted-access clearing were preserved.
- No reassignment, unassignment, deletion, rating, unsupported transition, API, route, backend, or authorization change was added.
- Android live visual verification was not run and is not claimed as passed.

## Phase 5 Evidence (2026-07-25)

- Scope: administrator ticket queue, ticket oversight details, one-time assignment presentation, reference-data management presentation, and administrator comments using the shared comments surface.
- Focused administrator, assignment, and reference-data validation: 11 tests passed.
- Administrator workflow golden tests: 4 passed for light/dark and RTL/LTR variants.
- Responsive administrator queue and department management tests passed at 320-pixel width with 200% text scaling.
- Full Flutter regression suite: 132 tests passed.
- `dart format .`: passed with no remaining changes.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed; Git reported line-ending conversion warnings only.
- Existing administrator authorization, queue pagination, unassigned-ticket presentation, one-time assignment/conflict refresh behavior, reference-data validation and activation, and administrator comment context were preserved.
- No reassignment, unassignment, status processing, rating, deletion, or new oversight operation was added. No backend, API, route, validation, or authorization change was made for Phase 5.
- Android live visual verification was not run and is not claimed as passed.
