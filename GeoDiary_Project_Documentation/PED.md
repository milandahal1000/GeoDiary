# GeoDiary --- Product Engineering Document (PED)

## 1. Product Summary

**GeoDiary** is an offline-first Flutter mobile application for saving
personal memories with photos, GPS coordinates, readable addresses,
dates, and journal notes. Users can browse memories in a chronological
journal and view their locations on an OpenStreetMap-based map.

## 2. Product Vision

Make it easy to remember not only what happened, but where it happened.
GeoDiary should feel calm, personal, lightweight, and dependable,
including when the user has limited connectivity.

## 3. Target Users

-   Travelers who want a private travel journal.
-   People who enjoy recording everyday places and moments.
-   Students or beginner developers who want a practical portfolio
    project demonstrating mobile development, local persistence, device
    permissions, and maps.

## 4. Product Goals

1.  Create a journal entry in a few simple steps.
2.  Attach a photo taken with the camera or selected from the gallery.
3.  Capture latitude and longitude with user permission.
4.  Resolve coordinates to a readable address when a geocoding service
    is available.
5.  Store entries locally so they remain available after restarting the
    app.
6.  Browse entries in a list and on a map.
7.  Provide clear permission, loading, empty, and error states.

## 5. Non-Goals for Version 1

-   User accounts, cloud synchronization, and social sharing.
-   Public profiles or a public feed.
-   AI-generated summaries or recommendations.
-   Live location tracking.
-   Full offline map-tile downloads.
-   A remote backend. A future backend is documented separately in
    `Backend-schema.md`.

## 6. MVP Scope

### Must have

-   Home / Journal screen.
-   Add-memory form.
-   Camera and gallery photo selection.
-   GPS permission and coordinate capture.
-   Title, description, and visit date.
-   Local SQLite persistence.
-   Persistent image files stored inside app-owned storage.
-   Memory detail screen.
-   Edit and delete entries with confirmation.
-   Map screen with saved-memory markers using OpenStreetMap.
-   Empty, loading, permission-denied, and error states.

### Should have

-   Search by title or description.
-   Filter or sort by visit date.
-   Open a location in an external map application.
-   Optional manual location entry if GPS is unavailable.

### Could have later

-   Favorite memories.
-   Tags and trip collections.
-   Export and import backup.
-   Optional encrypted local database.
-   Cloud backup and multi-device synchronization.

## 7. Main User Stories

-   As a user, I can add a photo so that a memory is visually
    recognizable.
-   As a user, I can capture my location so I can remember where a photo
    was taken.
-   As a user, I can write a title and notes to preserve context.
-   As a user, I can reopen the app and see previously saved entries.
-   As a user, I can view saved entries on a map.
-   As a user, I can correct or delete a memory.
-   As a user, I can decline location permission and still use
    non-location features.

## 8. Success Criteria

-   A memory can be created, saved, reopened, edited, and deleted
    without data loss.
-   Entries survive force-closing and relaunching the app.
-   Photos remain available after the original picker temporary file
    expires.
-   Permission denial does not crash the app.
-   The journal remains usable without internet; address lookup and map
    tiles may require internet.
-   Map markers open the correct memory details.
-   The UI remains usable on common Android phone sizes.

## 9. Privacy and Safety

-   Store journal data locally by default.
-   Request camera and location permissions only when needed.
-   Explain why location is requested.
-   Never upload photos or coordinates in Version 1.
-   Handle location permission denial and approximate/limited location.
-   Avoid logging private notes, addresses, or precise coordinates.
-   Provide a clear delete action for individual memories.

## 10. Product Constraints

-   Initial target: Android on Flutter.
-   Local database: SQLite via `sqflite`.
-   Maps: `flutter_map` with OpenStreetMap-compatible tiles.
-   No backend required for the initial release.
-   Public OpenStreetMap tile services have usage policies and are not
    an unlimited production tile-hosting service.
