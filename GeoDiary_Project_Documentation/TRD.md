# GeoDiary --- Technical Requirements Document (TRD)

## 1. Technical Overview

GeoDiary is a Flutter/Dart Android application using a local-first
architecture. The first release has no server dependency. SQLite stores
structured journal data, while photos are copied into persistent
app-owned storage and referenced by path.

## 2. Platform and Tooling

-   Flutter stable channel and compatible Dart SDK.
-   Android SDK and Android build tools.
-   Android Studio or VS Code.
-   Git for version control.
-   Android physical device or emulator for testing.
-   Minimum Android version should be chosen based on the Flutter SDK
    and dependencies in use; verify the generated Android configuration
    rather than assuming a fixed API level.

## 3. Main Dependencies

Use current compatible versions selected by `flutter pub add`; commit
`pubspec.lock` for the application. - `image_picker`: camera capture and
gallery selection. - `geolocator`: permission handling and current
coordinates. - `geocoding`: coordinate-to-address lookup where
supported. - `sqflite`: SQLite database. - `path`: safe path
composition. - `path_provider`: persistent app directories. -
`flutter_map`: map rendering. - `latlong2`: geographic coordinate types.

Potential supporting packages: - `intl`: date formatting. -
`url_launcher`: open coordinates in an external map app. - `uuid`:
stable entry IDs if not using SQLite integer IDs.

## 4. Functional Requirements

### FR-01: Create a memory

The user can enter a title, description, visit date, optional photo, and
optional location. Title validation must reject blank input.

### FR-02: Select a photo

The user can take a photo or choose one from the gallery. The app copies
the selected image to persistent app storage before saving its path.
Handle cancellation, unavailable camera, and file errors.

### FR-03: Capture location

The app requests location permission at the moment the user chooses to
capture location. If permission is denied, the user can continue without
coordinates. If GPS/location services are disabled, show an actionable
message.

### FR-04: Resolve address

When coordinates exist, attempt reverse geocoding. Address lookup
failure must not prevent saving coordinates or the memory.

### FR-05: Persist data

SQLite stores memory metadata and image path. All database operations
should be placed behind a service/repository layer rather than embedded
directly in widgets.

### FR-06: Browse memories

Display saved memories newest visit date first by default. Show a
friendly empty state when no entries exist.

### FR-07: View, edit, and delete

A detail screen displays all fields. Editing updates the existing row.
Deletion asks for confirmation and removes the database row; remove the
app-owned image only when it is not referenced by another memory.

### FR-08: Map

Show entries with valid coordinates as markers on an OpenStreetMap-based
map. Selecting a marker opens the corresponding memory. Entries without
coordinates remain visible in the journal but not on the map.

### FR-09: Search and sort

Search title and description. Support chronological sorting; more
advanced filtering can follow the MVP.

## 5. Non-Functional Requirements

-   **Reliability:** no crash on denied permissions, cancelled picker,
    missing photo file, or failed reverse geocoding.
-   **Persistence:** saved entries survive app restarts.
-   **Privacy:** no remote upload in Version 1.
-   **Usability:** forms have labels, validation messages, and clear
    save/cancel actions.
-   **Maintainability:** separate models, screens, services, and
    reusable widgets.
-   **Performance:** load thumbnails efficiently and avoid reading all
    full-resolution image bytes into memory at once.
-   **Accessibility:** readable contrast, scalable text, semantic labels
    for icon-only controls.
-   **Network resilience:** journal CRUD works offline; map tiles and
    address lookup may need connectivity.

## 6. Data and File Handling

-   Persist image files under an application-owned documents or support
    directory.
-   Store a relative or absolute path consistently; if absolute paths
    are stored, plan for migration if the storage location changes.
-   Use ISO-8601 timestamps or a documented integer epoch representation
    consistently.
-   Use parameterized SQLite queries.
-   Add database schema versioning and migrations from the first
    database version.

## 7. Android Permissions

Configure and verify only permissions needed by implemented features: -
Camera permission may be required depending on the camera flow and
Android configuration. - Location permissions should be requested in
context, with foreground location only for the MVP. - Verify
`AndroidManifest.xml` against the current plugin documentation. - Do not
request background location; GeoDiary does not track users
continuously. - Test denied, permanently denied, and
disabled-location-services scenarios.

## 8. OpenStreetMap Requirements

-   Use `flutter_map` and a documented tile URL/provider.
-   Follow the selected tile provider's attribution, caching,
    identification, and usage policies.
-   Display visible attribution on the map.
-   Do not assume the public `tile.openstreetmap.org` service permits
    unlimited or bulk offline usage.
-   Keep map access isolated enough to change providers later if needed.

## 9. Testing Requirements

-   Unit tests for model serialization and validation.
-   Database tests for create/read/update/delete and migrations.
-   Widget tests for empty journal, validation, and basic navigation.
-   Manual device tests for camera, gallery, GPS, denied permissions, no
    internet, and app restart.
-   Map tests should include entries with and without coordinates.

## 10. Definition of Done

A feature is done when code compiles, expected behavior is manually or
automatically tested, failure states are handled, and documentation is
updated.
