# Data Model: Department and Category Reference Data

## Department

| Field | Rules |
|-------|-------|
| `id` | Stable primary identifier |
| `name` | Trimmed display name, 1–120 characters |
| `normalized_name` | Lowercased comparison value, globally unique |
| `is_active` | Defaults true; controls selectability |
| `version` | Starts at 1; increments on updates/lifecycle changes |
| timestamps | Creation/update evidence |

Relationships: one department owns zero or more categories. Deactivation retains the row and children.

## Category

| Field | Rules |
|-------|-------|
| `id` | Stable primary identifier |
| `department_id` | Required foreign key to exactly one retained department |
| `name` | Trimmed display name, 1–120 characters |
| `normalized_name` | Lowercased comparison value, unique with department ID |
| `is_active` | Defaults true |
| `version` | Starts at 1; increments on changes |
| timestamps | Creation/update evidence |

Category creation/reassignment requires an active department. Effective selectability is `category.is_active && department.is_active`.

## State transitions

```text
absent -> active (create)
active <-> inactive (lifecycle, retained)
version N -> N+1 (successful name, department, or lifecycle change)
version mismatch -> unchanged + conflict
```

## Reference option

Read-only `{id, name}` projection. Department options include active departments. Category options include active children only when the requested parent is active.
