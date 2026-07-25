# Quickstart: Ticket Rating

## Prerequisites

- PHP and Composer dependencies installed under `backend/`
- Flutter dependencies installed under `mobile/`
- Isolated test database configured independently from development data
- Factory support for reporters, technicians, administrators, tickets in every status, and ratings
- Optional Android phone/emulator and reachable isolated API only for the separate live-device check

## Backend validation

```powershell
Set-Location backend
$env:DB_CONNECTION = 'sqlite'
$env:DB_DATABASE = ':memory:'
php artisan migrate:fresh --env=testing --force
php artisan test --filter=TicketRating
php artisan test --testsuite=Feature
vendor\bin\pint --test
composer validate --strict
composer audit
php artisan route:list --path=rating
```

Expected:

- The rating migration applies and rolls back cleanly.
- Focused tests prove integer boundaries, completed-only eligibility, ownership concealment, exactly-one immutability, safe sequential replay, distinct duplicate conflict, locking/uniqueness, rollback, and detail visibility. True cross-connection concurrency is not claimed under SQLite.
- The complete Feature suite remains green.
- Formatting, dependency-manifest, advisory, and route checks pass.
- The route list adds only one reporter `POST` rating operation; authorized detail remains the existing reporter `GET` operation.

## Flutter validation (non-device)

```powershell
Set-Location mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/tickets/ticket_rating_repository_test.dart `
  test/tickets/ticket_rating_controller_test.dart `
  test/tickets/ticket_rating_retry_test.dart `
  test/tickets/reporter_ticket_rating_test.dart
flutter test
```

Expected:

- Formatting is unchanged and analysis has no issues.
- Focused tests prove strict contract parsing, eligible entry, validation, submitting, authoritative success, already-rated detail, concealed/unauthorized clearing, offline/server recovery, retained-token replay, and duplicate-submit prevention.
- The full Flutter suite remains green.

## Automated acceptance scenarios

1. Create an owned completed unrated ticket, submit ratings at boundaries 1 and 5 on separate tickets, and verify one authoritative immutable score and creation time per ticket.
2. Submit representative valid values 2, 3, and 4 and verify authorized reporter details display each value exactly.
3. Attempt missing, 0, 6, negative, fractional, numeric-string, text, Boolean, collection, object, malformed UUID, and unsupported fields; verify `422` and no stored change.
4. Attempt to rate owned `new`, `assigned`, `in_progress`, and `rejected` tickets; verify ineligible conflict and no rating or workflow mutation.
5. Compare an unknown reference and another reporter's completed ticket; verify materially identical concealed `404` responses with no ticket status or rating disclosure.
6. Attempt through missing/revoked/inactive authentication and technician/administrator actors; verify authentication or role denial occurs before target disclosure and creates nothing.
7. Replay an accepted UUID token after an ambiguous outcome; verify `200` returns the exact original rating with no duplicate.
8. Submit a distinct UUID after a rating exists, including a different value; verify already-rated `409` and unchanged original value/time/author.
9. Race distinct and same-token attempts against one unrated completed ticket; verify at most one row, same-token authoritative replay, and distinct loser conflict.
10. Inject persistence failure after authorization and prove complete rollback, unchanged ticket/status/history/comments, sanitized failure, and safe later retry.
11. Exercise Flutter entry, submitting, success, already-rated, validation, concealed, unauthorized, offline, ambiguous retry, server failure, refresh, and restricted-data clearing without optimistic acceptance.
12. Audit routes, models, resources, diagnostics, screens, and controls for zero edit, delete, review text, multiple/anonymous rating, non-completed rating, technician/admin rating, discussion, status, assignment, or unsupported behavior.

See [contracts/openapi.yaml](contracts/openapi.yaml) for exact REST shapes and [data-model.md](data-model.md) for atomicity, uniqueness, retry, and immutability invariants.

## Scope, dependency, secret, and diff audits

```powershell
Set-Location ..
git diff -- backend/composer.json backend/composer.lock mobile/pubspec.yaml mobile/pubspec.lock
rg -n "rating" backend/routes/api.php backend/app mobile/lib/tickets backend/tests mobile/test
rg -n -i "review text|anonymous rating|edit rating|delete rating|rate.*technician|rate.*admin" backend mobile
git diff --check
git status --short
```

Expected: no dependency drift, secret or sensitive payload logging, generated artifacts, unsupported routes/controls, whitespace errors, unrelated application changes, commit, or push.

## Separate live-device verification

This check is independent from automated validation and must never be reported as passed unless it runs on an Android phone/emulator against an isolated reachable API.

```powershell
Set-Location mobile
flutter devices
flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>
```

Sign in as a reporter and verify:

1. Non-completed and already-rated tickets do not offer an actionable new rating path.
2. A completed unrated owned ticket accepts one selected whole-number rating only after explicit submission.
3. Success displays the authoritative score and no edit/delete or second-rating control.
4. Connectivity loss preserves safe intent without false success, and retry reconciles with the same logical submission.
5. Session or ownership failure clears restricted detail and rating data.

Also sign in as technician and administrator and confirm no rating-submission navigation or control exists.

If no Android target, required Android artifacts, or isolated reachable API is available, record **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED** with the concrete reason. Preserve automated Laravel and Flutter evidence separately.

## Validation evidence (revalidated 2026-07-25)

- Clean SQLite test migrations: passed; every migration through `2026_07_25_090000_create_ticket_ratings_table` applied.
- Combined focused Laravel checks for assignment, processing, comments, and rating: passed, 41 tests / 226 assertions; rating coverage includes database and Action value guards, locking, uniqueness, replay/conflict, rollback, ownership, and eligibility.
- Full Laravel Feature suite: passed, 77 tests / 490 assertions.
- Pint: passed. Composer validation: passed. Composer audit: no security vulnerability advisories found.
- Dart formatting: passed, 88 files checked. Flutter analysis: no issues found.
- Combined focused Flutter checks: passed, 44 tests, including rating 401/403/404/409/422/500, offline, malformed payload, distinct conflict codes, detail refresh, stale widget reset, and role absence. Full Flutter suite: passed, 75 tests.
- Route audit: exactly one rating operation, reporter-only `POST /api/reporter/tickets/{reference}/rating`.
- Dependency manifests and lockfiles: no feature-related changes.
- Sensitive-file scan: no credential signatures found. Excluded-scope scan: no excluded rating capability found.
- `git diff --check`: passed; Git reported only working-copy line-ending conversion warnings.
- Android smoke verification: **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED**. `flutter devices` found Windows, Chrome, and Edge only; no Android phone or emulator is available.
