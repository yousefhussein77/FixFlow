# Quickstart: Technician Ticket Processing

## Prerequisites

- PHP/Composer dependencies installed under `backend/`
- Flutter dependencies installed under `mobile/`
- Isolated test database configured independently from development data
- Factory/seed support for reporter, administrator, two active technicians, inactive technician,
  assigned/in-progress/terminal tickets, photos, and status history
- Optional Android phone/emulator plus reachable API only for the separate live-device verification

## Backend validation

```powershell
Set-Location backend
php artisan migrate:fresh --env=testing --force
php artisan test --testsuite=Feature
vendor\bin\pint --test
composer validate --strict
composer audit
```

Expected: all migrations, including the nullable history reason, apply cleanly; processing-focused and
existing Feature Tests pass; Pint, manifest validation, and security audit report no failures.

## Flutter validation (non-device)

```powershell
Set-Location mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected: formatting is clean, analysis has no issues, and the complete unit/widget suite passes.

## Automated acceptance scenarios

1. Assign tickets to two technicians in several statuses; prove each list count/page contains only the
   authenticated technician's current assignments in stable newest-first order.
2. Fetch an owned detail with photos and full assignment/status history, then compare unknown and
   another technician's references for identical concealed 404 envelopes.
3. Verify unauthenticated, inactive, reporter, and administrator actors receive 401/403 without ticket
   data, counts, metadata, history, or existence clues.
4. Accept each exact transition independently: `assigned → in_progress`, `assigned → rejected`,
   `in_progress → completed`, and `in_progress → rejected`.
5. Verify each accepted transition changes one ticket and appends exactly one immutable history row
   with correct actor, statuses, time, assignment, and rejection reason/null.
6. Reject missing, blank, over-limit, or unexpected reasons/status values with field validation and no
   ticket timestamp/history change.
7. Reject `assigned → completed`, duplicates, all changes from `new`, and every change from completed
   or rejected with conflict and authoritative-refresh guidance.
8. Race same and different requests from one starting state; prove at most one accepts that state and
   history contains no duplicate.
9. Inject failure between ticket update and history insertion; prove full rollback, sanitized 500, and
   safe retry after refresh.
10. Exercise Flutter list/detail/transition loading, populated, empty, validation, unauthorized,
    concealed-not-found, conflict, offline, photo-unavailable, and server states; prove no optimistic
    status and duplicate submit prevention.
11. Audit routes and screens for zero discussion, rating, assignment/reassignment/unassignment,
    deletion, reference-management, or unsupported-transition operation/control.

See [contracts/openapi.yaml](contracts/openapi.yaml) for exact REST schemas and [data-model.md](data-model.md)
for transaction, transition, and history invariants.

## Separate live-device verification

This is a distinct final validation task and never substitutes for automated checks.

When an Android phone/emulator, required Android artifacts, and an isolated reachable API are
available:

```powershell
Set-Location mobile
flutter devices
flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>
```

Authenticate as a technician and smoke-test assigned list, owned detail/history, all four permitted
transitions, rejection reason, conflict refresh, assignment loss, and absence of excluded controls.

If the environment has no Android device/emulator, cannot download required Android artifacts, or
cannot reach an isolated API, record **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED** with the concrete
reason. Do not attempt or claim live-device success. Keep automated Laravel and Flutter results as
separate evidence.

## Validation evidence — revalidated 2026-07-25

- Clean migrations: passed using an isolated SQLite database; all migrations through
  `2026_07_25_090000_create_ticket_ratings_table.php` applied.
- Combined focused Laravel checks for assignment, processing, comments, and rating: passed,
  41 tests and 226 assertions. Processing evidence covers transaction locking, sequential stale/conflict
  preservation, rollback, and immutable history; true cross-connection concurrency is not claimed under SQLite.
- Full Laravel Feature suite: passed, 77 tests and 490 assertions.
- Pint: passed. `composer validate --strict`: passed. `composer audit`: no security vulnerability
  advisories found.
- Dart format: passed across 88 files. Flutter analyze: no issues found.
- Combined focused Flutter checks: passed, 44 tests. Full Flutter suite: passed, 75 tests.
- Route audit: exactly `GET /api/technician/tickets`,
  `GET /api/technician/tickets/{reference}`, and
  `PATCH /api/technician/tickets/{reference}/status` exist for technician processing.
- Dependency audit: no changes to `backend/composer.json` or `mobile/pubspec.yaml`.
- Scope and sensitive-data audit: no excluded processing operations, embedded credentials, tokens,
  private keys, rejection-reason diagnostics, or generated dependency changes were found.
- Live Android verification: **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED.** `flutter devices` found
  Windows, Chrome, and Edge only; no Android phone or emulator is available.
