# GeoDiary --- Implementation Phases

## Working Method

Implement one phase at a time. At the end of each phase: 1. Run
`dart format .`. 2. Run `flutter analyze`. 3. Run relevant tests with
`flutter test`. 4. Run the app on a physical Android device or emulator.
5. Commit the working state to Git before starting the next phase.

Do not build every feature in one large code change. Keep each phase
small enough to diagnose.

## Phase 0 --- Environment and Baseline

**Tasks** - Verify `flutter --version`, `dart --version`,
`flutter doctor -v`, and `flutter devices`. - Create the project with
`flutter create --platforms=android geodiary`. - Confirm the starter app
runs. - Initialize Git and create a baseline commit. - Record Flutter
version and target Android device in README.

**Acceptance criteria** - `flutter run` launches the starter app. -
`flutter analyze` has no unresolved errors introduced by the project. -
Git baseline exists.

## Phase 1 --- App Shell and Design System

**Tasks** - Implement Material 3 theme, color palette, spacing,
typography, and shared widgets. - Build Journal screen with empty state
and Add Memory button. - Add navigation structure for Journal and Map. -
Build responsive layouts for common phone widths.

**Acceptance criteria** - App opens to Journal. - Empty state is
displayed when no memories exist. - Navigation works without placeholder
buttons claiming unimplemented success.

## Phase 2 --- Data Model and Local Database

**Tasks** - Create `Memory` model. - Define SQLite schema and schema
version. - Add database service/repository for create, read, update,
delete. - Add model mapping and basic validation. - Add database tests.

**Acceptance criteria** - CRUD tests pass. - Records persist after app
restart. - Schema version and migration path are documented.

## Phase 3 --- Image Capture and Gallery

**Tasks** - Integrate `image_picker`. - Implement Take Photo and Choose
from Gallery. - Show selected-image preview and replacement/removal. -
Copy chosen images into persistent app-owned storage. - Handle cancelled
selection and file errors.

**Acceptance criteria** - Both camera and gallery paths work on target
device. - Image remains available after app restart. - Cancelling
selection does not clear other form fields.

## Phase 4 --- Location Services

**Tasks** - Add contextual foreground location permission request. -
Check location service availability. - Fetch latitude and longitude with
timeout and error handling. - Attempt reverse geocoding. - Permit saving
without a location.

**Acceptance criteria** - Location is captured when permission and
services allow it. - Denial, timeout, and geocoding failure are handled
without a crash. - No background tracking is used.

## Phase 5 --- Create and View Memories

**Tasks** - Build Add Memory form with title, description, date, image,
and location. - Validate title. - Save image and database record
safely. - Build journal cards and details screen. - Implement edit and
delete with confirmation.

**Acceptance criteria** - A user can create, reopen, edit, and delete a
memory. - Form values remain available after recoverable save errors. -
Missing image files do not crash the screen.

## Phase 6 --- OpenStreetMap

**Tasks** - Integrate `flutter_map` and `latlong2`. - Choose a tile
source and verify its terms. - Show visible attribution. - Plot only
memories with valid coordinates. - Open details from markers and support
an empty map state.

**Acceptance criteria** - Markers match saved coordinates. - Selecting a
marker opens the correct memory. - Map failures do not prevent journal
use.

## Phase 7 --- Search, Polish, and Accessibility

**Tasks** - Add search by title and description. - Add date sorting and
useful empty states. - Add loading indicators, error feedback, and
confirmation dialogs. - Check contrast, text scaling, tap target sizes,
and semantics. - Remove dead code and resolve analyzer warnings where
practical.

**Acceptance criteria** - Search works across persisted records. - Core
workflows are understandable without developer assistance. - No known
high-severity UI or runtime errors remain.

## Phase 8 --- Verification and Release Preparation

**Tasks** - Run unit, widget, and database tests. - Manually test
camera, gallery, location permissions, disabled GPS, no internet, app
restart, and deletion. - Verify Android manifest and app display name. -
Add README instructions and screenshots. - Build a release APK for local
testing.

**Commands**

``` bash
dart format .
flutter analyze
flutter test
flutter build apk --release
```

**Acceptance criteria** - Release build completes. - App passes the
defined critical manual tests. - Known limitations are documented.

## Future Phase --- Backend and Sync

Do not implement this until the local-only app is stable. Review
`Backend-schema.md` before choosing a server stack, authentication
strategy, storage provider, and synchronization behavior.
