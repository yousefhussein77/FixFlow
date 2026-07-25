# Quickstart: Ticket Assignment

## Prerequisites

- PHP/Composer dependencies installed under `backend/`
- Flutter dependencies installed under `mobile/`
- Isolated test database configured independently from development data
- Seeded/factory-capable reporter, administrator, active technician, inactive technician, and
  non-technician accounts
- An Android emulator/device for the optional UI smoke check

## Backend validation

```powershell
Set-Location backend
php artisan migrate --force
php artisan test --testsuite=Feature
vendor\bin\pint --test
composer validate --strict
composer audit
```

Expected after implementation: both assignment migrations apply; all existing and new Feature Tests
pass; formatting, manifest validation, and security audit report no failures. Focused diagnosis may use
`php artisan test --filter=TicketAssignment` once the corresponding tests exist.

## Flutter validation

```powershell
Set-Location mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter devices
```

If an Android device is available, run `flutter run -d <device-id>
--dart-define=FIXFLOW_API_URL=<api-base-url>`, authenticate as an administrator, and validate the queue,
technician choices, assignment states, and absence of excluded controls. Device verification is
optional only when no configured device is available; automated checks remain mandatory.

## End-to-end scenarios

1. Create `new` tickets for two reporters. As an active administrator, load the first page and confirm
   both appear in stable newest-first order with reporter, status, and explicit null assignment.
2. Load active-technician options. Confirm active technicians appear by name/id and reporters,
   administrators, and inactive technicians are absent.
3. Assign one `new` ticket to an active technician. Confirm the response and refreshed row show that
   technician and `assigned`, and confirm exactly one history row contains `new`, `assigned`, acting
   administrator, selected technician, and occurrence time.
4. Attempt assignment separately with an unknown id, inactive technician, and non-technician. Confirm
   field-level `422` outcomes and identical pre/post ticket assignment, status, update time, and history.
5. Attempt assignment on an already assigned or otherwise non-`new` ticket. Confirm `409
   ASSIGNMENT_CONFLICT`, guidance to refresh, and no second history row.
6. Submit two assignment attempts against the same `new` ticket concurrently. Confirm exactly one
   `200`, one `409`, one assigned technician, and one history row.
7. Call all three endpoints without authentication, with an inactive account, as a reporter, and as a
   technician. Confirm defined `401`/`403` envelopes contain no ticket data, counts, or technician list.
8. As an authorized administrator, target an unknown and simulated out-of-oversight ticket reference.
   Confirm materially identical concealed `404 TICKET_NOT_FOUND` results.
9. Simulate a database failure between ticket update and history insertion. Confirm `500 SERVER_ERROR`,
   unchanged ticket/history, sanitized diagnostics, refresh, and safe retry.
10. In Flutter, exercise loading, populated, empty, pagination, validation, unauthorized, concealed
    not-found, conflict, offline, and server states. Confirm duplicate submit is disabled, ambiguous
    outcomes require refresh, and success uses the authoritative returned row.
11. Inspect routes and screens. Confirm there is no reassignment, unassignment, technician processing,
    discussion, rating, deletion, or other status-transition endpoint or control.

See [contracts/openapi.yaml](contracts/openapi.yaml) for exact request, response, and error shapes and
[data-model.md](data-model.md) for persistence constraints and transaction ordering.

## Planning artifact validation (2026-07-23)

- Plan, research, data model, OpenAPI, and quickstart describe the same three operations and scope.
- Endpoint paths, page defaults/limits, fields, nullability, statuses, and stable error codes align.
- No planning placeholder or unresolved clarification remains.

## Implementation validation evidence (revalidated 2026-07-25)

- Combined affected Laravel tests: **PASS**, 41 tests and 226 assertions; assignment coverage includes
  unsupported-field 422 rejection with unchanged ticket/history state.
- Complete Laravel Feature suite: **PASS**, 77 tests and 490 assertions.
- Clean isolated SQLite migration: **PASS**, including all migrations through ticket ratings.
- Laravel Pint: **PASS** after formatting; final `--test` clean.
- Composer manifest validation: **PASS**.
- Composer security audit: **PASS** with approved network access; no vulnerability advisories found.
- Flutter analysis: **PASS**, no issues found.
- Combined affected Flutter tests: **PASS**, 44 tests.
- Complete Flutter suite: **PASS**, 75 tests.
- Route/scope audit: **PASS** for exactly three assignment feature routes: administrator ticket GET,
  technician-option GET, and one-time assignment PATCH. No reassignment, unassignment, technician
  processing, discussion, rating, or ticket deletion route/control was added.
- Android emulator end-to-end verification: **NOT RUN**. `flutter devices` found Windows, Chrome,
  and Edge only; no Android emulator/device was connected. No emulator pass is claimed.
- Live eleven-scenario end-to-end run (T041): **DEFERRED — ENVIRONMENT BLOCKER, NOT PASSED**.
  No Android phone or emulator is available, so no isolated live API/mobile pair can be exercised on
  this machine. Automated backend and Flutter coverage passed, but does not replace this manual check.
