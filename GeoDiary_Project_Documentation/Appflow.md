# GeoDiary --- Application Flow

## 1. Primary Navigation

The app has two main destinations: - **Journal:** chronological list of
saved memories. - **Map:** map of memories that have valid latitude and
longitude.

A prominent **Add memory** action is available from the journal and,
where appropriate, the map screen.

## 2. First Launch

1.  App opens to the Journal screen.
2.  If there are no saved memories, show an empty state with a short
    explanation and an Add Memory action.
3.  Do not request camera or location permission on first launch.
4.  Request permissions only when the user selects the related action.

## 3. Create Memory Flow

1.  User taps **Add memory**.
2.  Add Memory form opens.
3.  User may tap **Take photo** or **Choose from gallery**.
4.  If a photo is selected, show a preview and allow replacement/removal
    before saving.
5.  User may tap **Add location**.
6.  App checks location services and requests foreground permission if
    needed.
7.  If granted, fetch coordinates and attempt reverse geocoding.
8.  Display the resolved address when available; retain coordinates if
    address lookup fails.
9.  User enters a required title, optional description, and visit date.
10. User taps **Save memory**.
11. Validate input, copy the image into persistent app storage, and
    insert the database row.
12. Show success feedback and return to the Journal screen.
13. The new memory appears in the list.

The memory should still be saveable if the user skips the photo or
location, unless a later product decision makes either field mandatory.

## 4. Permission and Error Paths

### Camera / gallery

-   User cancels: return to the form without an error.
-   Camera unavailable or file read fails: show a helpful message and
    allow retry.
-   Image copy fails: do not create a database row with a broken path.

### Location

-   Permission denied: explain that location can be added later or
    skipped.
-   Permanently denied: offer a button to open app settings where
    supported.
-   Location services disabled: explain how to enable them and allow
    saving without location.
-   GPS timeout: offer retry; do not freeze the form.
-   Reverse geocoding fails: retain latitude/longitude and allow saving.

### Database

-   Save fails: keep the form values so the user can retry.
-   Delete fails: keep the item visible and show an error.
-   Missing image file: display a placeholder and allow the entry to be
    edited.

## 5. Journal Flow

1.  Load entries from SQLite.
2.  Sort by visit date descending by default.
3.  Show each entry as a card with image thumbnail, title, date, and
    location if present.
4.  Tapping a card opens Memory Details.
5.  Search filters entries by title and description.
6.  If search returns no results, show a distinct "No matching memories"
    state.

## 6. Memory Details Flow

-   Show the photo, title, formatted date, address, coordinates when
    available, and description.
-   Edit opens the form populated with the existing values.
-   Save updates the existing entry instead of creating a duplicate.
-   Delete prompts for confirmation, deletes the record, and returns to
    the journal.
-   If coordinates exist, offer a map action.

## 7. Map Flow

1.  User opens Map.
2.  Load memories with valid coordinates.
3.  Display map tiles and attributed OpenStreetMap data.
4.  Add one marker per geolocated memory.
5.  Tapping a marker shows a preview or opens Memory Details.
6.  Entries without coordinates are excluded from markers but remain in
    the journal.
7.  If no geolocated memories exist, show a helpful empty state.
8.  If map tiles fail to load, keep the rest of the app usable and
    explain that connectivity may be required.

## 8. High-Level Flow Diagram

``` mermaid
flowchart TD
    A[Launch GeoDiary] --> B[Journal]
    B --> C{Saved memories?}
    C -- No --> D[Empty state]
    C -- Yes --> E[Memory list]
    D --> F[Add memory]
    E --> G[Open memory details]
    B --> F
    F --> H[Choose or capture photo]
    H --> I[Optionally add location]
    I --> J[Enter title, notes, and date]
    J --> K[Validate and save to local storage]
    K --> L[Refresh journal]
    G --> M[Edit or delete]
    B --> N[Map]
    N --> O[Markers for geolocated memories]
    O --> G
```
