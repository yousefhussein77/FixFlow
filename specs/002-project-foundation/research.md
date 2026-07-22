# Phase 0 Research: FixFlow Project Foundation

**Date**: 2026-07-22

## Backend Runtime Baseline

**Decision**: Use the installed PHP 8.5.0 with Laravel 13.x and a Composer constraint of `^13.0` on Windows 11.

**Rationale**: Laravel 13's official support matrix includes PHP 8.3 through 8.5, so it is compatible with the installed PHP 8.5.0. It receives security fixes through March 17, 2028 and recommends a caret major constraint. Keeping the installed runtime avoids unnecessary foundation work and satisfies the instruction not to require a PHP upgrade.

**Alternatives considered**:

- Laravel 12 with PHP 8.5.0: compatible, but its bug-fix support ends shortly after this plan date and it creates an earlier framework upgrade.
- Downgrade PHP: rejected because Laravel 13 supports installed PHP 8.5.0 and changing the installed toolchain adds no foundation value.

**Source**: [Laravel 13 release and support policy](https://laravel.com/docs/13.x/releases)

## API-only Laravel Initialization

**Decision**: Generate a standard Laravel 13 application, use Laravel's official API installation path to register `routes/api.php` and Sanctum, retain the built-in `/up` health route, and add no starter kit, web UI, domain route, or authentication flow.

**Rationale**: The official API setup path supplies Laravel's intended API routing and the constitution-mandated future authentication package. Merely installing Sanctum does not implement authentication. The built-in readiness response gives this foundation a stable non-business startup contract.

**Alternatives considered**:

- Manually create API routing without Sanctum: smaller immediate dependency surface, but diverges from the constitution's selected authentication foundation and duplicates official setup behavior.
- Install an authentication starter kit: rejected because it introduces authentication and UI behavior explicitly outside this feature.
- Create a custom health controller/envelope: rejected because the built-in readiness route satisfies startup verification without speculative application layers.

**Sources**: [Laravel 13 routing (`install:api`)](https://laravel.com/docs/13.x/routing), [Laravel 13 testing](https://laravel.com/docs/13.x/testing)

## Mobile Runtime Baseline

**Decision**: Use the already-installed Flutter 3.41.9 stable SDK with Dart 3.11.5, target Android only, and run on the existing emulator `emulator-5554`.

**Rationale**: Flutter 3.41.9 and Dart 3.11.5 are the paired stable toolchain already installed and available to this project. The foundation needs a reproducible starter launch, not adoption of the newest SDK. Pinning the installed pair and explicit emulator removes upgrade work and device-selection ambiguity.

**Alternatives considered**:

- Upgrade to a newer Flutter/Dart stable pair: rejected because the installed stable pair satisfies the foundation and upgrades are explicitly outside scope.
- Flutter 3.47 pre-release or any later line: rejected because this feature must not require an SDK upgrade and needs reliable existing-emulator verification.
- Generate every Flutter platform: rejected because only Android is in scope and extra host projects add unverified surface.

**Source of installed baseline**: User-provided development environment inventory for this feature. Exact version checks are required by `quickstart.md` before scaffolding.

## MariaDB Baseline and Driver

**Decision**: Use the installed XAMPP MariaDB 10.4.32 through Laravel's built-in `mysql` connection/PDO driver on default local host `127.0.0.1`, port `3306`, and `utf8mb4`. All connection coordinates and credentials remain environment-provided.

**Rationale**: MariaDB 10.4.32 is already supplied by the machine's XAMPP installation and is the required local development database for this bounded foundation. Laravel's MySQL-compatible PDO driver avoids another database package. Environment variables keep XAMPP paths and credentials outside application code and allow a later deployment baseline to be specified independently.

**Alternatives considered**:

- MariaDB 11.x LTS: newer and maintained, but rejected for this feature because it would require changing the installed database environment.
- MariaDB rolling 12.x: rejected because it would replace the installed database and adds no foundation value.
- Containerized MariaDB: rejected because database provisioning is explicitly outside the feature and would add orchestration files and operational choices.

**Risk note**: MariaDB 10.4 is outside current community maintenance. This plan accepts it only as the existing local XAMPP development constraint; it makes no production-support claim. Production database selection, hardening, and upgrade planning remain outside this foundation feature.

## Environment and Secret Hygiene

**Decision**: Commit only `.env.example` templates with inert values, ignore real `.env` variants while explicitly allowing examples, never place `APP_KEY` or a working password in examples, and validate both ignore behavior and tracked content before completion.

**Rationale**: Layered root and generated application ignore rules protect local secrets even if contributors invoke Git from different directories. Explicit allow-rules prevent a broad `.env*` exclusion from accidentally dropping the safe template. A Git-status check alone cannot detect a secret already tracked, so a tracked-content scan is also required.

**Alternatives considered**:

- Commit development credentials: rejected as unsafe and constitutionally prohibited.
- Add a dotenv package for Flutter: rejected because the starter mobile app has no environment-dependent behavior.
- Depend only on generated `.gitignore` files: rejected because the monorepo requires a root-level policy and future project areas must inherit safe defaults.

## Verification Design

**Decision**: Combine automated static/test checks with live process verification. Backend success is a Feature Test plus an HTTP request to `/up`; database readiness uses a framework database inspection command; mobile success is analyze/test plus an explicit-device emulator launch and visual observation.

**Rationale**: Tests make the baseline repeatable, while live checks prove that XAMPP MariaDB and emulator `emulator-5554` actually work. Explicit device selection avoids accidentally launching another target. Negative database verification proves errors remain useful and secret-safe.

**Alternatives considered**:

- Automated tests only: cannot prove the local emulator or MariaDB service is usable.
- Manual verification only: weak regression evidence and ambiguous repeatability.
- Add end-to-end automation packages: excessive for one starter screen and one built-in readiness endpoint.

## Resolved Clarifications

All Technical Context choices are resolved. No planning questions remain open.
