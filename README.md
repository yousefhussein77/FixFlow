# FixFlow

FixFlow is a monorepo foundation for an API-only Laravel backend and an Android Flutter client. This baseline contains no product workflow, business endpoint, authentication behavior, or mobile/backend integration yet.

## Repository layout

| Path | Purpose |
|------|---------|
| `backend/` | Laravel 13 REST API foundation and MariaDB configuration |
| `mobile/` | Flutter Android starter application |
| `docs/` | Project verification evidence |
| `specs/` | Approved feature specifications, plans, contracts, and tasks |

## Fixed prerequisites

Use these installed versions; do not upgrade or substitute them while verifying this foundation:

- Windows 11 and PowerShell
- Git
- PHP 8.5.0 and Composer
- Laravel 13.x dependencies from `backend/composer.lock`
- XAMPP MariaDB 10.4.32 on `127.0.0.1:3306`
- Flutter 3.41.9 stable with Dart 3.11.5
- Android SDK Platform-Tools
- Existing Android emulator `emulator-5554`

### Verify the toolchain

**Working directory:** repository root

```powershell
php --version
flutter --version
dart --version
& 'C:\xampp\mysql\bin\mysql.exe' --version
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
```

Expected: PHP 8.5.0, Flutter 3.41.9 stable, Dart 3.11.5, MariaDB 10.4.32, and `emulator-5554` in `device` state. Stop on a version mismatch rather than upgrading as part of setup.

## Install project dependencies

**Working directory:** `backend/`

```powershell
composer install
```

**Working directory:** `mobile/`

```powershell
flutter pub get
```

Dependency download time is excluded from the 20-minute setup target.

## Prepare the safe local environment

The committed `backend/.env.example` contains no application key or database password. The real `backend/.env` is ignored by Git.

**Working directory:** repository root

```powershell
Copy-Item -LiteralPath backend\.env.example -Destination backend\.env
git check-ignore backend/.env
git ls-files backend/.env
```

Expected: `git check-ignore` prints `backend/.env`; `git ls-files` prints nothing.

Edit only `backend/.env` and keep these local MariaDB coordinates:

```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=fixflow
DB_USERNAME=fixflow_local
DB_PASSWORD=<local password; never commit or paste into logs>
```

Then generate the local application key.

**Working directory:** `backend/`

```powershell
php artisan key:generate --force --no-ansi
```

Never copy the generated key or database password into `.env.example`, documentation, screenshots, commands, or issue reports.

## Prepare XAMPP MariaDB

Start MySQL from the XAMPP Control Panel. The local database must meet these conditions:

- Database: `fixflow`
- Character set: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`
- Account: `fixflow_local@127.0.0.1`
- Privileges restricted to `fixflow.*`

Database/account provisioning is a local machine responsibility. Do not run domain migrations for this foundation; it defines no domain schema.

### Verify the database connection

**Working directory:** `backend/`

```powershell
php tests/database_inspect.php
```

Expected: JSON identifies database `fixflow`, charset `utf8mb4`, collation `utf8mb4_unicode_ci`, MariaDB 10.4.32, and account `fixflow_local@127.0.0.1`. It must not print a password.

## Verify and start the backend

### Static and automated checks

**Working directory:** `backend/`

```powershell
php artisan --version
php artisan route:list
php artisan test
```

Expected: Laravel 13.x, `GET /up`, no `/` application page or FixFlow business route, and all tests passing.

### Live readiness check

Keep this command running in one terminal.

**Working directory:** `backend/` — terminal 1

```powershell
php artisan serve --host=127.0.0.1 --port=8000
```

Request the readiness endpoint from another terminal.

**Working directory:** repository root — terminal 2

```powershell
$response = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/up' -UseBasicParsing
$response.StatusCode
$response.Headers['Content-Type']
```

Expected: status `200` and a `text/html` content type within five minutes. Stop the server with `Ctrl+C` after verification.

## Verify and start the mobile application

Start the existing `Pixel_7` Android virtual device, then verify its fixed device ID.

**Working directory:** repository root

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 get-state
flutter devices
```

Expected: `device` and a Flutter device entry for `emulator-5554`. Do not select Windows, web, or another emulator.

### Static and automated checks

**Working directory:** `mobile/`

```powershell
dart format --output=none --set-exit-if-changed lib\main.dart test\widget_test.dart
flutter analyze
flutter test
```

Expected: no formatting changes, no analyzer findings, and all widget tests passing.

### Explicit emulator launch

**Working directory:** `mobile/`

```powershell
flutter run -d emulator-5554
```

Expected within five minutes: the application installs and shows `FixFlow` with `Project foundation is ready.` without a fatal exception. Press `q` to stop the Flutter run after observing the screen.

## Recoverable setup failures

| Failure | Check | Recovery and retry |
|---------|-------|--------------------|
| A command is not recognized | Run the toolchain commands from the repository root | Add the installed tool to the current PowerShell `PATH`, open a new terminal if needed, and repeat only the failed prerequisite check |
| Composer or pub dependency setup fails | Confirm network access and the relevant lock file | Correct the network/cache issue, then rerun `composer install` from `backend/` or `flutter pub get` from `mobile/` |
| MariaDB connection is refused | Confirm XAMPP MySQL is running and port 3306 is listening | Start MySQL in XAMPP, keep `.env` coordinates local, and rerun `php tests/database_inspect.php` |
| MariaDB reports access denied | Recheck `DB_USERNAME`, `DB_PASSWORD`, and host in ignored `backend/.env` | Correct only the local value; never print it; rerun the database inspection |
| Database inspection lacks metadata privileges | Confirm the account has privileges on `fixflow.*` only | Use `php tests/database_inspect.php`; `php artisan db:show` also reads `performance_schema` and is intentionally not required |
| `emulator-5554` is absent or offline | Run the explicit ADB state command | Start or restart the existing `Pixel_7` AVD, wait for `device`, and repeat the mobile check; do not create another emulator |
| Flutter cannot access its SDK cache | Close stale Flutter/Dart processes and confirm the SDK directory is writable | Retry the same Flutter command from a normal user PowerShell session |
| Flutter loses its debug connection under emulator memory pressure | Check that the APK built and installed and that the emulator remains in `device` state | Close unnecessary emulator apps or restart the existing AVD, then rerun `flutter run -d emulator-5554`; if debugger transport drops again after installation, open the installed FixFlow app from the emulator launcher and confirm the starter screen independently |
| Port 8000 is already in use | Stop the prior local Laravel process | Repeat the documented server command on port 8000 |

## Success evidence

A successful foundation setup has all of these observable results:

- Required versions match the fixed toolchain.
- `backend/.env` is ignored and untracked; committed examples contain no real secret.
- The read-only Laravel database inspection reaches the correctly configured `fixflow` database.
- Laravel tests pass and `GET http://127.0.0.1:8000/up` returns HTTP 200.
- Flutter formatting, analysis, and widget tests pass.
- The starter screen appears on `emulator-5554` without a fatal exception.

Record only pass/fail state, timings, targets, and sanitized failure classes. Never record application keys, passwords, tokens, or credential-bearing URLs.
