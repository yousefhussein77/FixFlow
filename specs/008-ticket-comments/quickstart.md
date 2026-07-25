# Quickstart: Ticket Comments

## Prerequisites

- PHP/Composer dependencies installed under `backend/`
- Flutter dependencies installed under `mobile/`
- Isolated test database configured independently from development data
- Factory support for two reporters, two technicians, an administrator, owned/assigned tickets, and comments
- Optional Android phone/emulator and reachable isolated API only for separate live-device verification

## Backend validation

```powershell
Set-Location backend
php artisan migrate:fresh --env=testing --force
php artisan test --filter=TicketComment
php artisan test --testsuite=Feature
vendor\bin\pint --test
composer validate --strict
composer audit
php artisan route:list --path=comments
```

Expected: the comment migration applies cleanly; focused and full Feature Tests pass; formatting,
manifest, and advisory checks pass; routes expose only role-scoped GET/POST comment operations.

## Flutter validation (non-device)

```powershell
Set-Location mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/tickets/ticket_comment_repository_test.dart test/tickets/ticket_comments_controller_test.dart test/tickets/ticket_comment_retry_test.dart test/tickets/reporter_ticket_comments_test.dart test/tickets/technician_ticket_comments_test.dart test/tickets/admin_ticket_comments_test.dart
flutter test
```

Expected: formatting is clean, analysis has no issues, and focused plus complete unit/widget suites pass.

## Automated acceptance scenarios

1. List an empty owned reporter discussion, then add reporter comments and verify stable oldest-first
   content, author role, identity, and creation time.
2. Compare another reporter's and an unknown ticket for identical concealed list/add responses and no
   disclosed comment count, author, content, or timestamp.
3. List/add as the current technician, change assignment using separately approved behavior, and prove
   the former technician immediately receives concealed outcomes with no write.
4. List/add as an administrator across multiple reporters' tickets and prove comment actions change no
   ticket ownership, assignment, status, or history.
5. Reject missing, blank, over-2,000-character, malformed-token, and unsupported-field submissions;
   prove no comment is created and safe draft text remains available in Flutter.
6. Preserve line breaks and markup-like text as inert plain text; prove original content, author, role,
   and creation time cannot be updated or deleted.
7. Replay one accepted `(ticket, author, submission_token)` and receive the same comment with no
   duplicate; use a distinct token with identical content and receive a distinct comment.
8. Race same-token submissions and prove at most one row; inject persistence failure and prove complete
   rollback plus safe same-token retry.
9. Verify missing/revoked/inactive authentication and wrong route roles disclose no restricted data;
   verify diagnostics omit comment text, tokens, ticket content, and credentials.
10. Exercise reporter, technician, and administrator Flutter loading, populated, empty, submitting,
    validation, concealed/not-found, access-loss, offline, ambiguous-retry, and server states without
    optimistic success or duplicate submission.
11. Audit routes, models, resources, screens, and tests for zero chat, edit, delete, attachment,
    mention, reaction, typing, notification, reassignment, status-processing, rating, or unsupported behavior.

See [contracts/openapi.yaml](contracts/openapi.yaml) for REST shapes and [data-model.md](data-model.md)
for authorization, atomicity, retry, and immutability invariants.

## Separate live-device verification

This check is distinct from automated validation and must never be reported as passed unless it runs
on an Android device/emulator against an isolated reachable API.

```powershell
Set-Location mobile
flutter devices
flutter run -d <android-device-id> --dart-define=FIXFLOW_API_URL=<api-base-url>
```

Sign in independently as reporter, current technician, and administrator. Verify authorized empty/list/add
states, shared chronology, safe retry, assignment-loss concealment, and absence of excluded controls.

If no Android target, required Android artifacts, or isolated reachable API is available, record
**DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED** with the concrete reason. Preserve automated Laravel
and Flutter evidence separately.

## Validation evidence (revalidated 2026-07-25)

- Clean SQLite test migrations: passed; all migrations through `2026_07_25_090000_create_ticket_ratings_table` applied.
- Combined focused Laravel checks for assignment, processing, comments, and rating: passed, 41 tests / 226 assertions, including comment rollback, uniqueness, sequential replay, and assignment-loss authorization. True cross-connection concurrency is not claimed under SQLite.
- Full Laravel Feature suite: passed, 77 tests / 490 assertions.
- Pint: passed. Composer validation: passed. Composer audit: no security vulnerability advisories found.
- Dart formatting: passed, 88 files checked. Flutter analysis: no issues found.
- Combined focused Flutter checks: passed, 44 tests, including comment 401/403/404/422/500, offline, restricted clearing, retry, and all role paths. Full Flutter suite: passed, 75 tests.
- Comment routes: exactly six operations (GET and POST for reporter, technician, and administrator contexts).
- Dependency manifests: no changes in Composer or Flutter dependency manifests or lockfiles.
- Diff whitespace check: passed; Git reported only line-ending conversion warnings for existing Flutter working-copy files.
- Android smoke verification: **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED**. `flutter devices` found only Windows, Chrome, and Edge; no Android phone or emulator is available.
