# Research: Department and Category Reference Data

## Name uniqueness

- **Decision**: Store display name and a lowercased trimmed `normalized_name`; unique-index department normalized names and category `(department_id, normalized_name)`.
- **Rationale**: Database enforcement handles concurrency while preserving display text.
- **Alternatives considered**: Application-only validation is race-prone; database-collation-only behavior is environment-dependent.

## Optimistic conflicts

- **Decision**: Use an integer `version`, required on update/lifecycle requests, incremented atomically with a matching version predicate.
- **Rationale**: Clear `409` behavior without timestamp precision ambiguity.
- **Alternatives considered**: Last-write-wins violates the spec; timestamp equality varies by storage precision.

## Concealed administration

- **Decision**: Route admin endpoints through authenticated, active, administrator middleware and use scalar IDs so record lookup occurs only inside authorized controllers/actions.
- **Rationale**: Non-admin responses cannot vary with target existence.
- **Alternatives considered**: Implicit binding can resolve before intended authorization and leak `404` differences.

## Retention and options

- **Decision**: Never expose delete; active category options require both category and department active. Department deactivation does not rewrite children.
- **Rationale**: Preserves history and independent category state across parent reactivation.
- **Alternatives considered**: Cascading child deactivation destroys state; soft delete implies a deletion workflow outside scope.

## Flutter design

- **Decision**: Reuse `http`, typed failures, ChangeNotifier-style state, repository boundaries, and auth session token storage. Add one reference controller with operation generation protection.
- **Rationale**: Consistent with the authentication feature without another dependency.
- **Alternatives considered**: New state or client generation packages add unjustified complexity.
