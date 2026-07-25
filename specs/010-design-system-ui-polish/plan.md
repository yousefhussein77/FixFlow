# Implementation Plan: Design System and UI Polish

**Branch**: `010-design-system-ui-polish` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/010-design-system-ui-polish/spec.md`

## Summary

Introduce a centralized, reusable Flutter presentation system for the existing FixFlow application. The work establishes the approved geometric blue-and-orange brand, complete light and dark themes, semantic design tokens, accessible shared components, Arabic-first RTL and English LTR behavior, and phased screen migration across authentication, reporter, administrator, and technician journeys. Existing controllers, repositories, services, models, REST contracts, authorization, validation, retry logic, and ticket workflows remain behaviorally unchanged.

The smallest independently reviewable increment is the theme and token foundation plus shared brand rendering. Subsequent increments migrate shared controls and states, then screens role by role, preserving a green regression suite after every phase.

## Technical Context

**Language/Version**: Dart 3.11.5; Flutter 3.41.9 stable

**Primary Dependencies**: Flutter Material library, existing `http` and `flutter_secure_storage`; no new runtime package is planned. Built-in theme extensions, semantics, directionality, layout, animation, and test APIs are sufficient.

**Storage**: No persistence or database change. Existing secure token storage and backend data remain untouched.

**Testing**: Flutter unit/widget tests, deterministic golden tests where practical, semantic and layout assertions, full existing Flutter regression suite, `flutter analyze`, and `dart format`; manual phone/emulator visual review remains a separate environment-dependent check.

**Target Platform**: Existing supported Flutter mobile targets, with layouts verified from 320 logical pixels through common larger phone widths in portrait and landscape. Android live verification is environment-dependent.

**Project Type**: Monorepo with an unchanged Laravel REST API in `backend/` and the affected Flutter application in `mobile/`.

**Performance Goals**: Local interaction feedback appears within 100 milliseconds; theme or locale changes do not lose screen state; skeleton and state transitions avoid major layout shift; UI polish does not weaken existing network-progress expectations.

**Constraints**: Arabic-first RTL and complete English LTR; WCAG-oriented contrast; 48×48 logical-pixel minimum touch targets; usability at 200% text scale; no color-only meaning; no API, role, validation, route, lifecycle, persistence, or product-scope change.

**Scale/Scope**: One app shell, 16 current screens, four existing ticket widgets, shared state/error presentation, three authenticated roles, light/dark themes, Arabic/English directionality, and representative phone sizes. Tablet/desktop redesign, backend work, new localization workflows, and new product capabilities are excluded.

**Package Justification**: No package addition. Material `ThemeData`, `ColorScheme`, `ThemeExtension`, `TextTheme`, `Semantics`, `MediaQuery`, and Flutter test/golden support meet the approved requirements. A font or icon dependency may be proposed only if implementation proves existing bundled/platform fonts or Material line icons cannot satisfy Arabic/Latin coverage or brand assets; that would require an explicit dependency audit and task-level approval.

## Constitution Check

*GATE: Passed before research and rechecked after design.*

- **Traceability — PASS**: Theme, asset, component, migration, accessibility, and verification decisions trace to User Stories 1–5, FR-001–FR-060, VC-001–VC-005, AR-001–AR-005, and SC-001–SC-012.
- **Independent value — PASS**: Tokens and brand assets form the smallest cross-screen foundation; shared components and each role migration remain independently reviewable.
- **Verification — PASS**: Token/component/widget tests, representative goldens, direction/theme/text-scale checks, full regression tests, analysis, formatting, and a manual review matrix cover normative behavior.
- **Security and operations — PASS**: Presentation code receives existing authorized state only. No sensitive logging, authorization duplication, data persistence, or optimistic business outcome is introduced.
- **Simplicity and packages — PASS**: Built-in Flutter theming and testing are used; no dependency or backend abstraction is planned.
- **Architecture — PASS**: Work stays in `mobile/` and feature documentation. Existing REST contracts and Laravel code remain unchanged.
- **Backend layering — N/A/PASS**: No backend change is planned. If an existing UI contract defect is discovered, planning stops for a separately reviewed compatibility fix.
- **Feature tests — PASS**: Existing backend suites remain regression gates; no new backend behavior exists to test.
- **Mobile states — PASS**: Existing state controllers remain authoritative. Shared state views cover loading, empty, success, validation, unauthorized, offline, conflict, and server error without moving business logic into widgets.
- **V1 scope and increments — PASS**: The work improves usability of the core workflow and excludes all deferred product features.

### Post-Design Recheck

Research and the presentation data model introduce no constitution exception. Brand assets are versioned inputs; token classes and shared components are narrowly scoped; screen phases keep regression checkpoints; manual device verification is clearly separated from automated evidence. No complexity-tracking entry is required.

## Project Structure

### Documentation (this feature)

```text
specs/010-design-system-ui-polish/
|-- spec.md
|-- plan.md               # architecture, inventory, migration phases
|-- research.md           # design and implementation decisions
|-- data-model.md         # presentation contracts and token model
`-- quickstart.md         # automated and manual validation guide
```

No API contract artifact is created because the feature explicitly preserves every existing REST interface.

### Planned Flutter Source Structure

```text
mobile/
|-- assets/
|   `-- brand/
|       |-- fixflow_mark.svg-or-source
|       |-- fixflow_logo_horizontal_light.*
|       |-- fixflow_logo_horizontal_dark.*
|       |-- fixflow_logo_monochrome.*
|       `-- generated/                 # approved platform outputs only
|-- lib/
|   |-- design_system/
|   |   |-- brand/
|   |   |   |-- fixflow_brand.dart
|   |   |   `-- fixflow_logo.dart
|   |   |-- theme/
|   |   |   |-- fixflow_colors.dart
|   |   |   |-- fixflow_theme.dart
|   |   |   |-- fixflow_theme_extensions.dart
|   |   |   `-- fixflow_typography.dart
|   |   |-- tokens/
|   |   |   |-- fixflow_spacing.dart
|   |   |   |-- fixflow_radius.dart
|   |   |   |-- fixflow_elevation.dart
|   |   |   |-- fixflow_borders.dart
|   |   |   |-- fixflow_icons.dart
|   |   |   `-- fixflow_motion.dart
|   |   |-- components/
|   |   |   |-- buttons/
|   |   |   |-- forms/
|   |   |   |-- feedback/
|   |   |   |-- navigation/
|   |   |   `-- tickets/
|   |   `-- layout/
|   |       |-- fixflow_page.dart
|   |       `-- responsive_constraints.dart
|   |-- app.dart                         # consumes centralized themes
|   |-- auth/                            # screen migration only
|   |-- reference_data/                  # screen migration only
|   `-- tickets/                         # screen/widget migration only
`-- test/
    |-- design_system/
    |   |-- theme_test.dart
    |   |-- token_test.dart
    |   |-- component_test.dart
    |   |-- accessibility_test.dart
    |   `-- golden/
    `-- ... existing regression tests
```

Asset filenames are illustrative planned names. The approved geometric logo source must be supplied or created from the documented concept without changing that concept; final file extensions depend on the asset pipeline selected during implementation.

**Structure Decision**: Add a presentation-only `design_system/` boundary. Existing feature UI imports reusable visual primitives, while state controllers, repositories, services, models, routes, and backend code retain their current responsibilities. Screen-specific components remain with their feature when they encode composition rather than reusable visual language.

## Flutter UI Inventory

### Application Shell and Theme

| Current path | Current responsibility | Planned migration |
|---|---|---|
| `mobile/lib/main.dart` | Application entry and dependency composition | Preserve composition; pass existing app configuration only |
| `mobile/lib/app.dart` | `MaterialApp`, routing/session root, seed-based indigo theme | Replace inline seed theme with centralized light/dark `ThemeData`, locale-aware direction, theme mode, and shared app-level component themes |
| `mobile/lib/auth/screens/session_gate.dart` | Restore/loading/authenticated routing/error retry | Apply branded splash/loading/error shell; preserve restoration and retry behavior |

### Authentication and Profile

| Screen | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/auth/screens/sign_in_screen.dart` | Email/password, submit, validation/error, registration navigation | Brand lockup, auth page template, labeled fields, accessible password control, primary action, supportive errors |
| `mobile/lib/auth/screens/register_screen.dart` | Name/email/password/confirmation, validation, submit | Same auth template, counters/help where needed, responsive keyboard-safe form |
| `mobile/lib/auth/screens/profile_screen.dart` | Identity, role-gated navigation, logout, admin/technician/reporter entries | Profile header/avatar, role badge, grouped navigation cards, destructive-safe logout; exact role gating preserved |

### Reference Data

| Screen/widget | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/reference_data/screens/department_screen.dart` | List, create/edit dialogs, activation state, errors | Management list items, empty/loading/error states, form dialog, active/inactive badge, confirmation patterns |
| `mobile/lib/reference_data/screens/category_screen.dart` | Department-scoped categories, create/edit dialogs, activation | Same management patterns with clear parent context and responsive fields |
| `mobile/lib/reference_data/widgets/reference_option_loader.dart` | Loading and option failure/retry | Shared field-loading, empty, validation, offline/server treatment |

### Reporter Tickets

| Screen/widget | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/tickets/screens/my_tickets_screen.dart` | Owned list, loading, empty, pagination/retry, create navigation | Reporter list template, ticket cards, status/priority semantics, pagination and empty CTA |
| `mobile/lib/tickets/screens/create_ticket_screen.dart` | Subject/location/description, department/category, priority, photos, validation, submit/retry | Sectioned form, shared inputs/dropdowns/text area/counters, photo tiles, validation summary, sticky-safe submission |
| `mobile/lib/tickets/screens/ticket_details_screen.dart` | Owned detail, photos, comments entry, rating, loading/errors | Detail header, metadata sections, photo presentation, state panels; exact ownership and rating behavior retained |

### Administrator Tickets

| Screen/widget | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/tickets/screens/admin_ticket_list_screen.dart` | All-ticket queue, ticket cards, pagination, assignment action | Dense responsive queue cards, reporter/department/status hierarchy, assignment state, shared pagination and failures |
| `mobile/lib/tickets/widgets/ticket_assignment_sheet.dart` | Technician options, validation, conflict, submission | Accessible dialog/sheet pattern, technician list items/avatars, selected state, confirmation and authoritative refresh |

### Technician Tickets

| Screen/widget | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/tickets/screens/assigned_tickets_screen.dart` | Assigned-only list, pagination, loading/empty/errors | Technician list template with current status/priority and safe retry |
| `mobile/lib/tickets/screens/technician_ticket_details_screen.dart` | Authorized details, history, photos, processing and comments | Technician detail header, metadata/history sections, only approved processing controls |
| `mobile/lib/tickets/widgets/ticket_processing_actions.dart` | Start confirmation, complete, reject reason, transition failures | Shared confirmation/dialog/form patterns, destructive/terminal differentiation, preserved refresh and duplicate blocking |

### Shared Ticket Communication and Rating

| Screen/widget | Existing content/states | Planned design-system coverage |
|---|---|---|
| `mobile/lib/tickets/screens/ticket_comments_screen.dart` | Role-context comments page | Shared page scaffold and comment states across roles |
| `mobile/lib/tickets/widgets/ticket_comments_section.dart` | Chronological comments, composer, validation/retry | Comment list item, author/avatar/time hierarchy, plain-text composer, character counter, submitting/error states |
| `mobile/lib/tickets/widgets/ticket_rating_section.dart` | Eligible selection, submit, conflict refresh, read-only rating | Accessible segmented rating control, validation, success/read-only, distinct conflicts, preserved ticket reset behavior |

### Current Test Inventory

- Authentication: administrator/technician role access, sign-in restore, registration, profile, and logout.
- Reference data: departments, categories, and reference-option loading.
- Reporter: owned list/detail, creation, comments, rating, repositories, retries, and controllers.
- Administrator: ticket list/repository, technician options, assignment, and comments.
- Technician: assigned list/detail/repository, Start Work, completion/rejection, comments, and access.
- Application smoke: signed-out root rendering.

The current 32 test files remain regression gates. New design-system tests supplement rather than replace behavioral assertions.

## Design System Architecture

### Centralized ThemeData

- `FixFlowTheme.light()` and `FixFlowTheme.dark()` are the only application theme constructors.
- Each uses an explicit `ColorScheme`; `ColorScheme.fromSeed` is not the source of semantic production colors.
- Material component themes cover app bars, scaffolds, navigation, buttons, inputs, cards, dialogs, sheets, snackbars, dividers, chips, segmented controls, progress indicators, and focus/selection.
- Theme extensions carry ticket status, priority, semantic feedback, shadows, and any token that is not represented safely by core `ThemeData`.
- Widgets read colors and text styles from context/theme extensions rather than hard-coded screen values.

### Token Reference

| Family | Planned tokens | Rule |
|---|---|---|
| Brand colors | primary `#1E4DB7`, secondary `#386CFF`, accent `#F28A1B`, success `#22C55E` | Immutable anchors; semantic containers/on-colors may use accessible tonal variants |
| Neutral colors | light background `#F3F4F6`, surface `#FFFFFF`, text `#111827`; dark equivalents researched per contrast | Named by role, never by arbitrary shade in screens |
| Typography | display, headline, title, body, label, caption, ticket reference | Arabic/Latin-compatible fallback, explicit size/weight/line height |
| Spacing | `space0`, `spaceHalf=4`, `space1=8`, `space2=16`, `space3=24`, `space4=32`, `space5=40`, `space6=48`, `space8=64` | 8-point grid; 4 only for compact internal alignment |
| Radius | none, small 8, medium 12, large 16, extra-large 24, pill | Component classes map consistently to a radius |
| Border | subtle 1, emphasized 2, focus 2 | Semantic colors and visible focus; border is not sole state cue |
| Elevation/shadow | flat 0, low 1, raised 2, overlay 3 | Soft restrained shadows; dark theme may prefer tonal separation |
| Icons | compact 16, standard 20, action 24, prominent 32, state 48 | Consistent Material line style; 48 target independent of glyph size |
| Motion | immediate 0–50ms, short 150ms, standard 250ms, emphasized 350ms | Reduced motion collapses nonessential transitions |

Exact typography metrics, dark/semantic colors, shadow values, and status mappings are recorded in `data-model.md` and must pass contrast tests before implementation acceptance.

### Semantic Status and Priority Styles

- Ticket statuses: `new`, `assigned`, `in_progress`, `completed`, `rejected`.
- Priorities: `low`, `medium`, `high`.
- Every semantic style includes foreground, container, border/icon, text label, and accessible non-color cue.
- Status and priority styles are presentation mappings only; they must not define or infer allowed transitions.

## Brand Asset Strategy

- Preserve the approved geometric FixFlow mark: primary blue structure with orange accent. Do not substitute a different metaphor, mascot, wordmark, or color relationship.
- Maintain one canonical editable vector source, then derive horizontal light/dark, icon-only light/dark, and monochrome variants.
- Store source/runtime brand assets under `mobile/assets/brand/`; platform-generated icon/splash outputs stay in their conventional Android/iOS directories and are reproducible from the canonical source.
- Asset names encode mark/lockup, orientation, background intent, and color mode. Avoid ambiguous names such as `logo2` or `final`.
- The horizontal lockup is used where width permits; icon-only is used for launcher, compact shell, and small surfaces; monochrome is reserved for single-color output.
- App icon uses the geometric mark with platform-safe padding, no small wordmark, and no transparent edge assumptions. Splash uses the mark or approved lockup centered on an approved surface with no workflow/loading claim.
- Clear space and minimum sizes from the specification are captured in an asset usage note and verified in representative screenshots.
- Asset creation is a design deliverable during implementation; no placeholder or newly invented concept may be treated as approved final art.

## Shared Component Plan

1. **Foundations**: page scaffold, constrained content region, section heading, gap utilities used sparingly, semantic icon/text helpers.
2. **Buttons**: primary, secondary, outline, text, destructive, icon, and floating; loading retains size and semantic label; disabled state remains legible.
3. **Forms**: labeled text/password/search fields, dropdown, text area, help/error text, counters, and field-loading states; controllers and validation remain screen-owned.
4. **Content**: surface/card, ticket list item, metadata row, avatar, divider, status chip, priority badge, history item, comment item, and photo tile.
5. **Overlays**: confirmation dialog, form dialog, adaptive bottom sheet, snackbar/banner, and destructive action presentation.
6. **Navigation**: branded app bar, role-gated destination tile, bottom navigation where already appropriate, tabs/segmented controls, back/up affordance, and pagination controls.
7. **States**: progress, skeleton, empty, success, validation summary, unauthorized, concealed/not-found, offline, conflict, server error, and retry action.

Shared components accept content and callbacks; they do not own repositories, issue HTTP calls, infer roles, authorize actions, or mutate workflow state.

## Screen Migration Phases

### Phase 1 — Foundations and Brand

- Add brand assets and usage documentation.
- Add light/dark themes, typography, token families, semantic ticket extensions, and app-shell theme integration.
- Add token/theme/contrast tests and stable brand/component goldens.
- Regression checkpoint: full existing Flutter suite.

### Phase 2 — Shared Components and States

- Build buttons, inputs, surfaces, ticket semantics, dialogs/sheets, navigation primitives, and shared state panels.
- Verify semantics, 48×48 targets, loading stability, 200% text, 320-width layout, RTL/LTR, and light/dark.
- Do not migrate business screens until component contracts are independently green.

### Phase 3 — Authentication and Profile

- Migrate session gate, sign-in, registration, and profile.
- Preserve authentication state, validation, password behavior, role gating, logout, and retry.
- Verify Arabic/English, keyboard insets, focus order, large text, and each role's visible destinations.

### Phase 4 — Reporter Workflow

- Migrate owned list, creation, details, photo presentation, comments, and rating.
- Preserve ownership, reference-data loading, photo limits, idempotent/retry behavior, rating conflicts, and authoritative refresh.
- Add representative reporter screen goldens and behavioral regression tests.

### Phase 5 — Administrator Workflow

- Migrate queue, assignment, reference-data management, oversight, and administrator comments.
- Preserve administrator-only navigation, one-time assignment, option eligibility, conflicts, pagination, and reference-data validation.

### Phase 6 — Technician Workflow

- Migrate assigned list, detail, processing actions, rejection, history, and technician comments.
- Preserve current-assignee concealment, exact transition matrix, Start Work confirmation, rejection reason, terminal behavior, and authoritative refresh after ambiguous outcomes.

### Phase 7 — Cross-Role Consistency and Visual Acceptance

- Remove superseded local styling after every consumer is migrated.
- Run all automated checks, representative deterministic goldens, route/dependency/scope audits, and the manual visual matrix.
- Record Android/device verification separately; do not treat desktop/web rendering or automated tests as an Android pass.

## Accessibility and Responsive Plan

- Programmatically verify representative foreground/background pairs against 4.5:1, 3:1 large-text, and 3:1 graphical/control thresholds.
- Use semantic labels and merged/excluded semantics deliberately for cards, chips, ratings, history, loading, and icon-only controls.
- Provide visible focus and logical traversal for keyboard-capable targets; modal focus remains contained and restores after dismissal.
- Test `TextScaler` through 200%, long Arabic/English strings, mixed-direction content, and long user/reference names.
- Use constraints, wrapping, flexible layout, scroll views, and safe areas; avoid fixed heights for textual controls and state panels.
- Test 320, 360, 390, and representative larger phone widths plus landscape and keyboard insets.
- Mirror directional navigation icons only. Ticket references, universal icons, rating order, brand marks, and user content retain their intended semantics.
- Pair every color with text/icon/shape and expose status/priority in semantics.

## Testing Strategy

### Automated Layers

- **Token/theme tests**: exact brand anchors, complete light/dark schemes, no missing extension, typography/token invariants, semantic mappings, and contrast calculations.
- **Component widget tests**: variants and states, semantics, targets, disabled/loading stability, focus, validation, directionality, text scaling, and narrow widths.
- **Screen widget tests**: representative state matrices for each role while reusing existing fake repositories/controllers and preserving behavioral assertions.
- **Golden tests**: stable logo treatment, buttons/forms, ticket card/chips, state panel, auth screen, reporter list/detail, administrator queue, and technician detail in selected light/dark and RTL/LTR combinations. Fonts, surface size, locale, time, and image inputs must be deterministic.
- **Regression tests**: all existing Flutter tests remain required; no golden update is accepted without visual review of the rendered difference.
- **Static checks**: `dart format .` and `flutter analyze` from `mobile/`.

### Manual Review

The complete executable matrix lives in `quickstart.md` and covers:

- Light and dark themes.
- Arabic RTL and English LTR.
- 320/360/390/larger phone widths, portrait and landscape.
- Normal and 200% text scaling.
- Authentication/profile, reporter, administrator, and technician journeys.
- Loading, skeleton, empty, success, validation, unauthorized, offline, conflict, and server-error states.
- Brand clear space/size, system bars, keyboard, safe areas, touch targets, focus, semantics, and non-color meaning.

## Risk Controls

| Risk | Control | Evidence |
|---|---|---|
| UI refactor changes business behavior | Keep controllers/repositories/services unchanged; migrate one screen family at a time | Existing behavioral tests remain green at every phase |
| Semantic colors fail contrast in a theme | Define foreground/container pairs and test ratios | Theme contrast tests plus manual review |
| RTL changes alter rating/order/reference semantics | Explicit mirror policy and mixed-content tests | RTL widget/golden matrix |
| Large text causes hidden actions | Flexible layouts, no textual fixed heights, scroll/safe area patterns | 200% and narrow-width tests |
| Goldens become brittle | Limit to deterministic stable surfaces; use semantic/layout assertions elsewhere | Reviewed golden policy and controlled fixtures |
| Brand files drift or are replaced | Canonical source and documented generated variants | Asset inventory and visual approval |
| New package expands dependency surface | Default to Flutter SDK capabilities | Manifest audit; explicit approval if exception arises |
| Device unavailable | Keep live Android review separate and mark deferred honestly | Quickstart evidence section |

## Complexity Tracking

No constitution violations or exceptions are planned.
