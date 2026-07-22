# Foundation Verification Evidence

**Feature**: `002-project-foundation`
**Environment check date**: 2026-07-22
**Timezone**: Asia/Aden (UTC+03:00)

This record contains no credentials, application keys, tokens, or connection strings.

## Setup Phase — Fixed Toolchain Check

| Component | Expected | Observed | Result |
|-----------|----------|----------|--------|
| Operating system | Windows 11 | Windows NT build 10.0.26200.0; project environment identified as Windows 11 | Pass |
| PHP | 8.5.0 | PHP 8.5.0 CLI, NTS, x64 | Pass |
| Laravel compatibility | Laravel 13 supports PHP 8.5 | Planning research confirms Laravel 13 supports PHP 8.3–8.5 | Pass |
| Flutter | 3.41.9 stable | Flutter cache metadata reports 3.41.9, stable channel | Pass |
| Dart | 3.11.5 | Flutter cache metadata and Dart SDK version file report 3.11.5 | Pass |
| MariaDB | XAMPP MariaDB 10.4.32 | `C:\xampp\mysql\bin\mysql.exe` reports 10.4.32-MariaDB | Pass |
| Android target | `emulator-5554` in `device` state | Android SDK is present and AVD `Pixel_7` exists, but the device list is empty | Not ready |

### Commands and Safe Diagnostics

| Action | Expected outcome | Result | Diagnostic summary |
|--------|------------------|--------|--------------------|
| `php --version` | PHP 8.5.0 | Pass | Exact CLI version matched |
| Read `C:\src\flutter\bin\cache\flutter.version.json` | Flutter 3.41.9 stable and Dart 3.11.5 | Pass | Installed SDK metadata matched; direct Flutter CLI probe did not return within the bounded check |
| Read `C:\src\flutter\bin\cache\dart-sdk\version` | Dart 3.11.5 | Pass | Exact SDK version matched |
| `C:\xampp\mysql\bin\mysql.exe --version` | MariaDB 10.4.32 | Pass | Exact XAMPP distribution version matched |
| Query Windows version/build | Windows 11 environment | Pass | NT build 26200 observed |
| Android SDK `emulator.exe -list-avds` | Existing Android virtual device | Pass | AVD `Pixel_7` exists |
| Android SDK `adb.exe devices` | `emulator-5554` in `device` state | Not ready | No connected Android device; no alternate target selected |

### Required Follow-up Before Mobile Launch

Start the existing `Pixel_7` AVD and confirm that Android SDK `adb.exe devices` reports `emulator-5554` with state `device`. Do not create another emulator or upgrade Flutter, Dart, or Android tooling as part of this feature.

## User Story 1 — Runnable Project Baseline

**Verification time**: 2026-07-22 16:38–16:58 +03:00

### Backend readiness

| Action | Expected outcome | Actual result | Result |
|--------|------------------|---------------|--------|
| From `backend/`, run `php artisan route:list` | Built-in `GET /up`, API infrastructure, and no application-facing web or business route | Four framework routes listed: `/up`, Sanctum CSRF cookie, and two local-storage routes; `/` and business routes absent | Pass |
| From `backend/`, run `php artisan test` | Health contract and applicable generated tests pass | 2 tests passed with 4 assertions in 0.54 seconds | Pass |
| From `backend/`, start `php artisan serve --host=127.0.0.1 --port=8000`, then request `http://127.0.0.1:8000/up` | HTTP 200 with `text/html` content within five minutes | HTTP 200, `text/html; charset=utf-8`, 1,829-byte response in 1,450 ms | Pass |

The local backend process was stopped after the live request. Diagnostics contain no environment values or credentials.

### Mobile readiness

| Action | Expected outcome | Actual result | Result |
|--------|------------------|---------------|--------|
| From `mobile/`, run `dart format --output=none --set-exit-if-changed lib/main.dart test/widget_test.dart` | No formatting changes required | 2 files checked, 0 changed | Pass |
| From `mobile/`, run `flutter analyze` | No analyzer findings | No issues found in 29.3 seconds | Pass |
| From `mobile/`, run `flutter test` | Minimal starter widget renders without an exception | 1 widget test passed | Pass |
| Query Android SDK `adb.exe -s emulator-5554 get-state` | Fixed target is in `device` state | `device` | Pass |
| From `mobile/`, run `flutter run -d emulator-5554 --no-resident` | Build, install, and display the starter screen within five minutes | APK built and installed in 90.1 seconds; the first app process was reclaimed by Android under low-memory pressure and the Flutter CLI lost its service-protocol connection | Recovered |
| Relaunch the installed `com.example.fixflow/.MainActivity` on `emulator-5554` and observe it | FixFlow starter screen remains foreground without a fatal exception | Activity fully drawn in 6.342 seconds; process remained alive; foreground showed `FixFlow` and `Project foundation is ready.`; no fatal exception was logged | Pass |

The initial launch interruption was caused by the emulator low-memory manager, not an application exception. The same built APK launched successfully on the required target without rebuilding or selecting an alternate device.

## User Story 2 — Safe Local Environment

**Verification time**: 2026-07-22 +03:00

### Configuration and secret safety

| Action | Expected outcome | Actual result | Result |
|--------|------------------|---------------|--------|
| Run `php artisan test --filter=EnvironmentSafetyTest` from `backend/` | Safe example fields, blank committed secrets, ignored real environment, and no tracked `backend/.env` | 2 tests passed with 16 assertions | Pass |
| Copy `backend/.env.example` to `backend/.env` and run `php artisan key:generate --force --no-ansi` from `backend/` | A local application key exists only in the ignored file | Key presence confirmed without printing its value | Pass |
| Run `git check-ignore backend/.env` from the repository root | Git identifies the real environment file as ignored | Returned `backend/.env` | Pass |
| Run `git ls-files backend/.env` from the repository root | No tracked real environment file | No output | Pass |

The committed example retains blank `APP_KEY` and `DB_PASSWORD` values. The local key, local environment contents, and any credentials were not printed or copied into this evidence.

| Database state | Action | Expected outcome | Actual result | Redaction check | Result |
|----------------|--------|------------------|---------------|-----------------|--------|
| Positive | From `backend/`, run `php tests/database_inspect.php` to bootstrap Laravel and execute a read-only connection metadata query | Laravel identifies the configured MariaDB connection successfully | Connected to `fixflow` using `fixflow_local@127.0.0.1`; server 10.4.32-MariaDB; database charset `utf8mb4`; collation `utf8mb4_unicode_ci` | Output contained no password, application key, token, or connection string | Pass |
| Invalid password | Replace only local `DB_PASSWORD` with a generated temporary invalid value and run the same inspection | Actionable authentication failure and no tracked-file mutation | Exit code 1 with diagnostic class `authentication_failure`; repository status unchanged | Neither the temporary nor valid password appeared in output; no application key appeared | Pass |
| Recovery | Restore the original ignored `.env` content and repeat the inspection | Connection succeeds again without tracked-file mutation | Reconnected to `fixflow` on MariaDB 10.4.32 as `fixflow_local@127.0.0.1`; repository status unchanged | Original local password was restored without being printed or recorded | Pass |

The database was provisioned as `fixflow` with `utf8mb4` and `utf8mb4_unicode_ci`. The account `fixflow_local@127.0.0.1` has database-level privileges only on `fixflow.*` and has no grant option. Laravel's built-in `db:show` was not used for final verification because it also reads `performance_schema.session_status`, which would require privileges outside the explicitly permitted `fixflow.*` boundary.

## User Story 3 — README Walkthrough

**Walkthrough environment**: isolated clean-checkout-equivalent copy with no local `.env`, dependency directory, Flutter tool state, or build output copied from the working project. Git tracking and ignore behavior were initialized in the isolated copy. Composer and Flutter dependencies were restored before timing and their download time was excluded.

**Start**: 2026-07-22 17:42:22 +03:00  
**End**: 2026-07-22 17:51:51 +03:00  
**Elapsed excluding dependencies**: 9 minutes 29 seconds  
**Target**: 20 minutes or less

### README-only results

| Area | First attempt | Final result | Evidence and recovery |
|------|---------------|--------------|-----------------------|
| Fixed prerequisites | Pass | Pass | PHP 8.5.0, Flutter 3.41.9 stable, Dart 3.11.5, XAMPP MariaDB 10.4.32, and `emulator-5554` in `device` state |
| Safe environment | Pass | Pass | Example copied, local password supplied without output, application key generated locally, `backend/.env` ignored and untracked |
| MariaDB | Pass | Pass | Read-only Laravel inspection reached `fixflow` on MariaDB 10.4.32 as `fixflow_local@127.0.0.1` |
| Backend checks | Pass | Pass | Laravel 13.21.1; `/up` present; `/` absent; 4 tests passed |
| Live backend | Pass | Pass | `GET http://127.0.0.1:8000/up` returned HTTP 200 with `text/html` in 191 ms; server stopped afterward |
| Mobile static checks | Pass | Pass | Formatting changed 0 files; analyzer found no issues; widget test passed |
| Mobile launch | Fail | Pass after documented recovery | APK built and installed on `emulator-5554`, but debugger transport disconnected under emulator pressure. Background-memory cleanup and an AVD restart were attempted; opening the installed FixFlow app independently then showed `FixFlow` and `Project foundation is ready.`, remained foreground, and produced no fatal exception |

The complete journey finished within the time target. The mobile startup outcome did not pass on its first debugger-attached attempt, but the failure class and recovery were discoverable in the README and required no alternate device, SDK upgrade, or rebuild of unrelated components.

### Unfamiliar-contributor review

| Review question | Discoverable from root README? | Location/result |
|-----------------|-------------------------------|-----------------|
| Fixed prerequisites and versions | Yes | `Fixed prerequisites` and `Verify the toolchain` |
| Purpose of `backend/`, `mobile/`, and `docs/` | Yes | `Repository layout` |
| Safe local file creation and every required MariaDB field | Yes | `Prepare the safe local environment`; example-copy flow plus explicit DB connection fields |
| XAMPP MariaDB database, charset, collation, account, and privilege scope | Yes | `Prepare XAMPP MariaDB` |
| Dependency setup with working directories | Yes | `Install project dependencies` |
| Backend tests, startup, URL, status, and content-type signal | Yes | `Verify and start the backend` |
| Explicit `emulator-5554` selection, mobile checks, and visible starter text | Yes | `Verify and start the mobile application` |
| Retry actions for missing tools, dependencies, MariaDB, port conflicts, emulator state, SDK cache, and debugger memory pressure | Yes | `Recoverable setup failures` |
| Secret-free evidence expectations | Yes | `Success evidence` |

All 12 PowerShell command blocks name their working directory. No undocumented project-specific knowledge was needed beyond supplying the contributor's own local database password, as explicitly required by the guide.

## Final Audit

**Audit time**: 2026-07-22 +03:00

### Tracked-content secret audit

The audit inspected all 113 paths listed by Git after staging the candidate foundation. It checked for tracked real environment files, private-key markers, nonblank application keys and password/token assignments, credential-bearing URLs, and token-shaped values.

| Check | Expected outcome | Actual result | Result |
|-------|------------------|---------------|--------|
| Tracked real environment files | Zero | Zero; `backend/.env` remained ignored and untracked | Pass |
| Credential or generated-secret findings | Zero | Zero | Pass |
| Secret-bearing verification evidence | Zero | Zero; diagnostics use only classifications and non-sensitive metadata | Pass |

### Scope and dependency audit

The audit covered `backend/app/`, `backend/routes/`, `backend/database/migrations/`, `mobile/lib/`, `backend/composer.json`, and `mobile/pubspec.yaml`. Generated user persistence artifacts and the generated user seeding behavior were identified as outside this feature and removed before the final review. The remaining Sanctum package, configuration, route infrastructure, and token migration are the mandated but unused authentication foundation.

| Check | Actual result | Result |
|-------|---------------|--------|
| Authentication behavior, active tokens, protected routes, users, or roles | None implemented | Pass |
| Tickets, comments, ratings, notifications, maps, QR codes, push, export, analytics, domain persistence, or business rules | None implemented | Pass |
| Mobile HTTP, persistence, repository, service, model, or business state | None implemented | Pass |
| Optional or unjustified packages | None; Laravel generated dependencies plus mandated Sanctum, and Flutter SDK dependencies only | Pass |

### Full quickstart re-run

| Section | Actual result | Result |
|---------|---------------|--------|
| Fixed tools and device | PHP 8.5.0; Flutter 3.41.9 stable; Dart 3.11.5; XAMPP MariaDB 10.4.32; `emulator-5554` in `device` state | Pass |
| Layout and environment safety | All three roots present; `backend/.env` ignored and untracked; committed example secrets blank | Pass |
| Backend framework and routes | Laravel 13.21.1; `/up` present; `/` and business routes absent | Pass |
| Backend tests and formatting | Pint passed; 4 tests and 20 assertions passed | Pass |
| Live backend | `GET /up` returned HTTP 200 and the application-up response; server stopped afterward | Pass |
| MariaDB positive check | `fixflow`, `utf8mb4`, `utf8mb4_unicode_ci`, MariaDB 10.4.32, and `fixflow_local@127.0.0.1` observed without a credential | Pass |
| MariaDB negative and recovery checks | Temporary invalid password produced only `authentication_failure`; restoring ignored `.env` reconnected; Git status unchanged | Pass |
| Flutter format, analysis, and widget test | 2 files unchanged; no analyzer issues; 1 widget test passed | Pass |
| Fixed-device launch | Debug APK built, installed, and launched on `emulator-5554`; the correct package remained foreground; accessibility exposed `FixFlow` and `Project foundation is ready.`; zero fatal log matches | Pass |
| README walkthrough | Completed in 9 minutes 29 seconds excluding downloads; backend passed first attempt; mobile reached the required screen through documented recovery after its first debugger-attached attempt disconnected | Recovered |

### Requirement-to-evidence matrix

| Requirement | Evidence | Result |
|-------------|----------|--------|
| FR-001 | Root layout assertion and README repository layout | Pass |
| FR-002 | Laravel scaffold inspection, route list, empty application routes, and live `/up` | Pass |
| FR-003 | Flutter scaffold, automated checks, and fixed-device launch | Pass |
| FR-004 | Environment-driven `mysql` configuration plus valid/invalid/recovery database probes | Pass |
| FR-005 | `backend/.env.example` field and blank-secret assertions | Pass |
| FR-006 | Layered ignore checks, Git tracking check, and zero-finding secret audit | Pass |
| FR-007 | Feature test and live HTTP 200 readiness response | Pass |
| FR-008 | Documented `emulator-5554` procedure and crash-free foreground starter screen | Pass |
| FR-009 | Root README coverage and unfamiliar-contributor review | Pass |
| FR-010 | Action, expected outcome, actual result, and redacted result tables in this document | Pass |
| FR-011 | Final source, route, migration, behavior, and keyword scope audit | Pass |
| FR-012 | Manifest review against research decisions; no optional package added | Pass |

| Success criterion | Evidence | Result |
|-------------------|----------|--------|
| SC-001 | Clean-checkout-equivalent README walkthrough completed in 9 minutes 29 seconds excluding downloads | Pass |
| SC-002 | `backend/`, `mobile/`, and `docs/` all present and explained in README | Pass |
| SC-003 | Live backend response and crash-free initial mobile screen both observed | Pass |
| SC-004 | Zero tracked real credentials, real environment files, or secrets in evidence | Pass |
| SC-005 | FR-001 through FR-012 map above; all eight quickstart validation groups have explicit results | Pass |
| SC-006 | Final scope review found no out-of-scope capability or domain rule | Pass |
| SC-007 | The clean-checkout-equivalent walkthrough needed the README's documented mobile recovery after the initial debugger transport disconnected; a later full quickstart launch passed on its first attempt | Recovered, not a strict first-attempt pass |

### Final diff and constitution review

The final candidate diff contains 113 staged project files because this repository has no prior tracked baseline. The review covered the complete staged foundation against `spec.md`, `plan.md`, the package decisions, and the constitution gates.

| Gate | Result | Evidence summary |
|------|--------|------------------|
| Traceability and independent value | Pass | Every requirement maps above; each story retains its independent verification |
| Verification | Pass | Backend, database, Flutter, device, README, security, and scope checks have explicit results |
| Security and operations | Pass | Secrets remain environment-only; negative database diagnostics are redacted; recovery is documented |
| Simplicity and packages | Pass | No optional abstraction or service was added |
| Architecture and V1 scope | Pass | Work remains in the approved roots; no client/backend integration or product capability exists |
| Backend layering | Pass, not applicable | No domain controller, request, resource, service/action, policy, factory, or data seeding behavior exists |
| Feature tests | Pass | The only foundation behavior and environment safety are covered |
| Mobile data states | Pass, not applicable | The starter has no data flow, persistence, or state-management layer |

No unexplained architecture or scope drift remains. SC-007 retains the explicitly documented first-attempt exception above; it does not conceal an application crash and the required final mobile outcome passes on the fixed device.
