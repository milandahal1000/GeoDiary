# GeoDiary --- Future Backend Schema

## 1. Status and Scope

**Future planning only.** Version 1 uses local SQLite and does not
require a backend. This document proposes a possible API and relational
data model for a later release with accounts, cloud backup, and
multi-device synchronization.

The backend stack is intentionally not locked. A future implementation
could use Django REST Framework with PostgreSQL, object storage for
photos, and token-based authentication. Confirm hosting, privacy,
budget, and operational requirements before selecting services.

## 2. Future Capabilities

-   User registration, login, and account recovery.
-   Cloud synchronization of journal metadata.
-   Private photo upload and retrieval.
-   Conflict-aware updates across devices.
-   Backup, restore, and account deletion.
-   Optional sharing only after a separate privacy and authorization
    design.

## 3. Proposed Entities

### User

-   `id`: UUID primary key.
-   `email`: unique, normalized email.
-   `password_hash`: managed by the authentication framework; never
    store plaintext passwords.
-   `display_name`: optional.
-   `created_at`, `updated_at`: timestamps.
-   `is_active`: account status.

### Memory

-   `id`: UUID primary key.
-   `user_id`: foreign key to User, indexed.
-   `title`: required string, bounded length.
-   `description`: optional text.
-   `visited_at`: date/time chosen by the user.
-   `latitude`: nullable decimal/double.
-   `longitude`: nullable decimal/double.
-   `address`: nullable string.
-   `photo_object_key`: nullable private object-storage key, not a
    public filesystem path.
-   `created_at`, `updated_at`: server timestamps.
-   `deleted_at`: nullable timestamp for soft deletion and
    synchronization.
-   `version`: integer for optimistic concurrency, if needed.

### Optional future entities

-   `Device`: user-owned device identifier and last sync time; avoid
    collecting unnecessary device fingerprints.
-   `Tag`: user-owned tag vocabulary.
-   `MemoryTag`: many-to-many relation between memories and tags.
-   `SyncOperation`: only if a durable operation log is justified by the
    synchronization design.

## 4. Example Relational Schema (PostgreSQL Concept)

``` sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    display_name VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE memories (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(160) NOT NULL,
    description TEXT,
    visited_at TIMESTAMPTZ NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address VARCHAR(500),
    photo_object_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    version INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT valid_latitude CHECK (
        latitude IS NULL OR (latitude >= -90 AND latitude <= 90)
    ),
    CONSTRAINT valid_longitude CHECK (
        longitude IS NULL OR (longitude >= -180 AND longitude <= 180)
    ),
    CONSTRAINT location_pair CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
);

CREATE INDEX memories_user_visited_idx
    ON memories(user_id, visited_at DESC);

CREATE INDEX memories_user_updated_idx
    ON memories(user_id, updated_at);
```

This is a conceptual schema, not a migration to run against an existing
production database. A real implementation should use framework-managed
migrations and account for privacy and deletion requirements.

## 5. Proposed REST API

Base path: `/api/v1`

### Authentication

-   `POST /auth/register`
-   `POST /auth/login`
-   `POST /auth/refresh` if refresh tokens are used
-   `POST /auth/logout`
-   `POST /auth/password-reset`

Use a well-maintained authentication library. Apply rate limits and
generic error messages where appropriate. Never create custom password
cryptography.

### Memories

-   `GET /memories?updated_after=<timestamp>&cursor=<cursor>`
-   `POST /memories`
-   `GET /memories/{id}`
-   `PATCH /memories/{id}`
-   `DELETE /memories/{id}`

Every memory query and mutation must be scoped to the authenticated
owner. Never trust a client-supplied `user_id`.

### Photos

-   `POST /memories/{id}/photo` to upload, or obtain a short-lived
    upload URL from the server.
-   `DELETE /memories/{id}/photo`
-   Return authorized, expiring photo URLs or serve through an
    authorization-checked endpoint.

## 6. API Data Example

Request to create a memory (photo upload may be a separate request):

``` json
{
  "title": "Morning walk",
  "description": "Quiet streets and fresh air.",
  "visited_at": "2026-10-14T07:30:00+05:45",
  "latitude": 27.7172,
  "longitude": 85.3240,
  "address": "Example address"
}
```

The coordinates above are illustrative sample data, not a location
assertion. The server should validate title length, timestamp format,
coordinate ranges, and the requirement that latitude and longitude are
either both present or both absent.

## 7. Synchronization Strategy

-   Keep local SQLite as the app's responsive source for browsing and
    editing.
-   Give each memory a stable UUID that can exist on both client and
    server.
-   Track `updated_at`, server version, and deletion tombstones.
-   Upload local changes when connectivity returns.
-   Fetch server changes using a cursor or `updated_after` strategy that
    handles pagination.
-   Define conflict rules before implementing sync. A simple initial
    policy may be last-write-wins based on server timestamps, but it can
    overwrite edits; a conflict UI is safer for meaningful journals.
-   Make sync operations idempotent and retryable.
-   Never treat a failed network request as a successful cloud save.

## 8. Security and Privacy

-   Use HTTPS.
-   Enforce per-user authorization on every record and photo operation.
-   Validate and limit image file type, dimensions, and size.
-   Keep photo buckets private by default.
-   Store secrets in server-side environment/secret management, never in
    the mobile app.
-   Support account deletion and explain how backups and photos are
    removed.
-   Minimize retention of GPS coordinates and avoid logging sensitive
    location data.
-   Consider encryption at rest and local-device protection based on the
    threat model.
-   Define backup retention, abuse prevention, rate limits, and audit
    needs before launch.

## 9. Local-to-Cloud Migration

When adding accounts: 1. Keep the local-only app working. 2. Introduce
stable UUIDs and sync metadata through a SQLite migration. 3. Ask the
user to sign in only when they opt into cloud backup. 4. Offer a preview
or clear explanation before uploading existing memories and photos. 5.
Make retry and conflict states visible. 6. Never delete local entries
merely because upload fails.
