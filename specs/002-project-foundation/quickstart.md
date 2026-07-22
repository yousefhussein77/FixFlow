# Phase 1 Quickstart Validation: FixFlow Project Foundation

This is the design-time validation guide that the implementation must make runnable. It does not claim the applications exist yet. Run commands from the stated directory and record results without secrets.

## Prerequisites

- Windows 11, PowerShell, and Git
- Installed PHP 8.5.0 with Laravel-required extensions, Composer, and a Laravel 13-compatible installer/toolchain
- Installed XAMPP MariaDB 10.4.32 running locally, with an empty `fixflow` database and a least-privilege local account
- Installed Flutter 3.41.9 stable with Dart 3.11.5, Android SDK/toolchain, and Android emulator `emulator-5554`
- Dependencies installed for `backend/` and `mobile/`

Do not upgrade PHP, Flutter, Dart, or MariaDB for this feature. Record the exact versions above in verification evidence and stop if a different toolchain would be used unintentionally.

## 0. Fixed Toolchain Check

**Working directory**: repository root

```powershell
php --version
flutter --version
dart --version
& 'C:\xampp\mysql\bin\mysql.exe' --version
adb devices
```

**Expected**: PHP 8.5.0; Flutter 3.41.9 on the stable channel; Dart 3.11.5; MariaDB 10.4.32; and `emulator-5554` listed with state `device`. Laravel 13 is permitted because its official support range includes PHP 8.5. Stop rather than upgrade if these fixed prerequisites are not available.

## 1. Repository Layout

**Working directory**: repository root

```powershell
@('backend','mobile','docs') | ForEach-Object { if (-not (Test-Path -LiteralPath $_ -PathType Container)) { throw "Missing required directory: $_" } }
```

**Expected**: command completes without output or error; the README identifies the same three areas.

## 2. Safe Local Environment

**Working directory**: repository root

1. Confirm `backend/.env.example` exists and contains the fields in `data-model.md` with an empty `APP_KEY` and no working password.
2. Copy `backend/.env.example` to `backend/.env` and fill only local values.
3. Generate the local application key using the documented backend command.
4. Confirm ignore behavior:

```powershell
git check-ignore backend/.env
git ls-files backend/.env
```

**Expected**: the first command identifies `backend/.env` as ignored; the second prints nothing. Review all tracked example files and evidence for usable credentials before acceptance.

## 3. Backend Static and Automated Checks

**Working directory**: `backend/`

```powershell
php artisan --version
php artisan route:list
php artisan test
```

**Expected**:

- Version reports Laravel 13.x.
- Routes contain the documented `GET /up` readiness behavior and no FixFlow business or application UI route.
- The health Feature Test and generated applicable tests pass.
- No authentication, user, ticket, comment, rating, notification, or other domain endpoint exists.

Contract: [foundation-health.openapi.yaml](contracts/foundation-health.openapi.yaml).

## 4. MariaDB Positive and Negative Readiness

**Working directory**: `backend/`

Start MariaDB through the installed XAMPP environment. With valid local values in the ignored `.env`, run a non-mutating Laravel database inspection command documented by Laravel 13 (for example, the framework's database display command).

**Expected positive result**: the command identifies the configured MariaDB connection and returns successfully without printing the password.

Then temporarily place an intentionally invalid password in the ignored local `.env` and repeat the same check.

**Expected negative result**: the command fails with a recognizable database authentication/connection error, does not print the supplied password, and makes no tracked-file change. Restore the valid local value and repeat the positive check.

Do not run domain migrations: this feature defines no domain schema.

## 5. Live Backend Startup

**Working directory**: `backend/`

Start Laravel using the README's local server command. From another PowerShell session, request:

```powershell
Invoke-WebRequest -Uri 'http://127.0.0.1:8000/up' -UseBasicParsing
```

**Expected**: HTTP 200 within the 5-minute startup window, conforming to the health contract. Stop the local process normally after evidence is recorded.

## 6. Flutter Static and Automated Checks

**Working directory**: `mobile/`

```powershell
flutter --version
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

**Expected**: Flutter reports exactly 3.41.9 stable with Dart 3.11.5; formatting, analysis, and the generated starter widget test pass; dependency review shows no unnecessary third-party package.

## 7. Existing Android Emulator Launch

**Working directory**: `mobile/`

```powershell
flutter devices
flutter run -d emulator-5554
```

**Expected**: `emulator-5554`—not Windows, web, or another device—installs and displays the starter application without a crash within 5 minutes after dependencies are available. Record the device ID and observation, then stop the run normally.

If `emulator-5554` is not listed in state `device`, stop verification, restore/launch that pre-existing emulator, and retry. Creating a new emulator is outside scope.

## 8. Scope and Secret Audit

**Working directory**: repository root

```powershell
git status --short
git ls-files
```

Review tracked files and dependency manifests. Confirm:

- No real `.env`, application key, database password, token, or credential-bearing connection string is tracked or included in evidence.
- Only framework/Sanctum migrations exist; no domain migration or model exists.
- No authentication behavior, users/roles, tickets, comments, ratings, notifications, maps, QR codes, push notifications, export, analytics, or business logic was added.
- No optional backend or Flutter package lacks the purpose and justification recorded in `research.md`.

## 9. Clean-checkout README Walkthrough

On a supported machine with prerequisites available, follow only the root README from a clean checkout. Record start/end times excluding downloads.

**Expected**: both live startup outcomes succeed on the first attempt in 20 minutes or less, all eight specification verification areas have an unambiguous result, and evidence contains no secret.

## Requirement Traceability

| Spec requirement | Validation section |
|------------------|--------------------|
| FR-001 | 1 |
| FR-002, FR-007 | 3, 5 |
| FR-003, FR-008 | 6, 7 |
| FR-004 | 4 |
| FR-005, FR-006 | 2, 8 |
| FR-009 | 9 |
| FR-010 | All sections; evidence record defined in `data-model.md` |
| FR-011, FR-012 | 3, 6, 8 |
