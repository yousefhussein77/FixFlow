# In-app notifications

FixFlow stores authenticated, per-user in-app notifications in the `notifications` table. Delivery is pull-based: the Flutter client loads notifications at sign-in, refreshes every minute while open, and refreshes when the application returns to the foreground. Push delivery is intentionally not configured.

## API

All endpoints require a valid Sanctum token and an approved, active account. A user can only list or mutate their own notifications.

- `GET /api/notifications` returns up to 100 notifications ordered by `created_at DESC, id DESC`.
- `GET /api/notifications/unread-count` returns `data.unread_count`.
- `PATCH /api/notifications/{notification}/read` marks one owned notification as read. Replays are idempotent; inaccessible identifiers return the same concealed `404` response.
- `PATCH /api/notifications/read-all` marks all unread notifications belonging to the authenticated user as read and returns `data.updated_count`.

Mutation requests accept no fields. Responses use the canonical FixFlow API envelope.

## Stored data and deduplication

Each notification stores its recipient, type, Arabic title and message, optional related entity metadata, a controlled navigation target and JSON payload, a read timestamp, and creation/update timestamps. `deduplication_key` is unique per recipient so retries of the same domain operation do not create duplicate notifications.

Notification records are created inside the same database transaction as the domain operation. A failed ticket or account operation therefore produces no notification, and a notification persistence failure rolls the domain transaction back.

## Events and destinations

| Domain event | Recipient | Navigation target |
|---|---|---|
| Account request created | Active administrators | `admin.account_requests` |
| Account approved or rejected | Requesting user | `account.status` |
| Ticket created | Active administrators | `admin.tickets` |
| Ticket assigned | Technician, reporter, administrators | Role-specific ticket target |
| Ticket status changed | Reporter, administrators | Reporter ticket/rating or admin tickets |
| Ticket comment created | Reporter or assigned technician, excluding author | Role-specific ticket comments |

The current product does not support reassignment, unassignment, assignment cancellation, or priority mutation. Notifications for those events are deferred until the corresponding business workflows exist.

## Flutter behavior

The notification bell is injected into standard authenticated page headers and explicitly included in the adaptive administrator dashboard header. The center provides Arabic loading, empty, offline, unauthorized, server-error, retry, mark-one-read, and mark-all-read states. The unread badge updates after successful read operations.

Before opening a reporter or technician ticket destination, the application resolves the ticket through the role-specific repository. Missing or unauthorized destinations display a safe Arabic message and do not expose technical details. Notification navigation replaces the notification-center route to avoid duplicate route stacking.

## Verification

Backend coverage includes event creation, recipient ownership, unread count, read operations, deduplication, and transaction rollback. Flutter coverage includes API contract parsing, malformed responses, controller states, the bell and badge, center states, read actions, safe destination failures, lifecycle refresh, administrator integration, RTL, narrow width, and increased text scaling.
