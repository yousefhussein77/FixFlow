# Phase 1 Data Model: FixFlow Project Foundation

## Domain Model

This feature introduces **no domain entities, domain records, relationships, or business state transitions**. Users, roles, tickets, comments, ratings, notifications, authentication tokens in use, and all related persistence are outside scope.

Generated Laravel framework/Sanctum migration files may exist as versioned framework inputs, but this feature does not execute or exercise authentication behavior and does not add a FixFlow business schema.

## Configuration Model

The only data-like structure designed by this feature is local runtime configuration. It is not application data and MUST NOT be persisted in Git.

### Fixed Development Environment

| Component | Required value | Planning rule |
|-----------|----------------|---------------|
| Operating system | Windows 11 | Setup and verification commands use PowerShell |
| PHP | 8.5.0 | Use as installed; Laravel 13 compatibility is confirmed; no upgrade or downgrade |
| Flutter | 3.41.9 stable | Use as installed; no SDK upgrade |
| Dart | 3.11.5 | Use the installed Flutter-paired SDK; no independent upgrade |
| Database | XAMPP MariaDB 10.4.32 | Local development only; no database upgrade or production-support claim |
| Android target | `emulator-5554` | Must be listed in `device` state before launch |

### Backend Environment Configuration

| Field | Required locally | Example value | Validation/handling |
|-------|------------------|---------------|---------------------|
| `APP_NAME` | Yes | `FixFlow` | Non-secret display/logging label |
| `APP_ENV` | Yes | `local` | Example remains non-production |
| `APP_KEY` | Yes after setup | empty | Generated only in local `.env`; never committed or printed in evidence |
| `APP_DEBUG` | Yes | `true` | Local default only; production policy is outside scope |
| `APP_URL` | Yes | `http://127.0.0.1:8000` | Must match documented local health URL |
| `DB_CONNECTION` | Yes | `mysql` | Fixed to Laravel's MariaDB-compatible connection name |
| `DB_HOST` | Yes | `127.0.0.1` | XAMPP local host default, environment-overridable; no embedded credential |
| `DB_PORT` | Yes | `3306` | XAMPP local port default, environment-overridable; numeric port in valid TCP range |
| `DB_DATABASE` | Yes | `fixflow` | Local database name; database provisioning remains external |
| `DB_USERNAME` | Yes | `fixflow_local` | Placeholder/local value, never a production identity |
| `DB_PASSWORD` | Yes | empty | Contributor-supplied locally; example and evidence remain blank/redacted |

### Configuration Lifecycle

```text
committed .env.example
        |
        | contributor copies locally
        v
ignored .env with local values
        |
        | runtime reads without committing
        v
validated startup / database readiness
```

Failure does not mutate configuration automatically. The contributor corrects the local value or unavailable dependency and repeats only the affected verification step.

## Verification Evidence Record

Evidence may be kept in a pull request, review note, or other team-approved record; no new persisted application entity is required.

| Attribute | Rule |
|-----------|------|
| Component | One of repository, backend, database, or mobile |
| Command/action | Exact reproducible action with no inline secret |
| Expected outcome | Observable pass condition from `quickstart.md` |
| Result | Pass or fail |
| Timestamp | Local execution time with timezone |
| Target | Backend URL or fixed emulator ID `emulator-5554` where applicable; no credential-bearing URL |
| Diagnostic summary | Failure class only; passwords, application keys, tokens, and full connection strings prohibited |

## Future Compatibility Boundary

Later feature plans MUST define domain entities and migrations independently. They MUST NOT infer a user, ticket, or authentication data contract from this foundation artifact. The only stable interface created here is the readiness contract in `contracts/foundation-health.openapi.yaml`.
