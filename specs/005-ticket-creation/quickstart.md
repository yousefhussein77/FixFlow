# Quickstart: Reporter Ticket Creation and Tracking

## Prerequisites

- PHP/Composer dependencies installed under `backend/`
- Flutter dependencies installed under `mobile/`
- Test environment configured independently from development data
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

Expected: migrations apply; ticket and existing Feature Tests pass; Pint, Composer validation, and
security audit report no failures.

## Flutter validation

```powershell
Set-Location mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter devices
```

If an Android emulator is available, run `flutter run -d <device-id>`, authenticate as a reporter,
and verify Create Ticket, My Tickets, owned details, retry states, and the absence of excluded controls.

## End-to-end scenarios

1. Load active departments, select one, and confirm only its active categories appear.
2. Create a valid ticket without photos, then with five valid JPEG/PNG/WebP photos; confirm a unique
   `TKT-...` reference, `new` status, and reporter ownership.
3. Retry the same submission token and confirm no duplicate ticket or photo records.
4. Submit inactive/mismatched classifications and invalid photo count/type/size; confirm 422 field
   errors and unchanged records/files.
5. Simulate photo storage failure; confirm no ticket, photo row, or durable file remains.
6. Create tickets for two reporters; confirm each list contains only owned results in stable newest
   first pages.
7. Request an owned, another reporter's, and unknown reference; confirm owned success and identical
   concealed 404 responses for the latter two.

See [contracts/openapi.yaml](contracts/openapi.yaml) for request/response details and
[data-model.md](data-model.md) for persistence constraints.

## Validation evidence (2026-07-23)

- Laravel Feature Tests: **PASS**, 32 tests and 232 assertions.
- Ticket Feature Tests: **PASS**, 14 tests and 92 assertions.
- Laravel Pint: **PASS** after formatting; final `--test` clean.
- Composer validation: **PASS** (`composer.json is valid`).
- Migrations: **PASS** for all eight migrations on a clean in-memory SQLite validation database.
- MariaDB migration attempt: **BLOCKED** because the configured service at `127.0.0.1:3306` refused
  the connection; no database changes were made by that failed attempt.
- Composer security audit: **PASS** outside the sandbox; no security vulnerability advisories found.
- Dart formatting: **PASS**, 39 files and no remaining changes.
- Flutter analysis: **PASS**, no issues found.
- Flutter unit/widget tests: **PASS**, 24 tests.
- Flutter emulator verification: **DEFERRED, NOT PASSED**. This machine cannot reach
  `dl.google.com:443`, preventing Gradle from downloading the required Android artifacts. Emulator
  verification must be run on a machine with the required cached artifacts or network access.
- Route audit: **PASS**, exactly five reporter GET/POST routes and no reporter PUT/PATCH/DELETE routes.
- Scope/dependency/secret/storage audit: **PASS**. No dependency manifests changed; no environment,
  key, or credential file is staged; photos use private generated paths and rollback cleanup; no
  excluded feature endpoint or control was added.
