# GeoDiary --- UI/UX Design Specification

## 1. Design Direction

GeoDiary should feel like a quiet, personal travel journal:
photographic, warm, uncluttered, and easy to use with one hand. Use a
light, nature-inspired palette, rounded surfaces, restrained shadows,
and generous spacing. Photos should be the visual focus.

The design references the suggested screens: 1. Journal home with
photo-memory cards. 2. Create Memory form with image preview, title,
description, date, and location. 3. Map view with memory markers. 4.
Memory Details screen with photo, address, date, and notes.

## 2. Visual Principles

-   **Personal:** prioritize photos and the user's own words.
-   **Calm:** avoid crowded dashboards and excessive decoration.
-   **Readable:** clear hierarchy, comfortable line spacing, accessible
    contrast.
-   **Trustworthy:** explain permission use and show location status
    clearly.
-   **Offline-aware:** the journal should still work when map tiles or
    address lookup are unavailable.
-   **Consistent:** use shared spacing, colors, cards, icons, and button
    styles.

## 3. Color Palette

Use these as starting design tokens; verify contrast before release.

  -----------------------------------------------------------------------
  Token                   Hex                     Usage
  ----------------------- ----------------------- -----------------------
  Primary Green           `#287D65`               Primary actions, active
                                                  navigation, location
                                                  accents

  Deep Green              `#205B4C`               Emphasized text or
                                                  pressed states

  Soft Sage               `#E1EEE7`               Welcome panel and soft
                                                  highlights

  Background              `#F7F8F5`               Main app background

  Surface                 `#FFFFFF`               Cards, forms, bottom
                                                  sheets

  Main Text               `#202622`               Headings and body text

  Secondary Text          `#66716A`               Metadata, helper text

  Divider                 `#E2E7E2`               Subtle separators

  Error                   `#B3261E`               Validation and error
                                                  messages
  -----------------------------------------------------------------------

Use Material 3 color schemes and keep the palette centralized rather
than scattering hex values across widgets. Provide a dark theme in a
later polish phase if desired.

## 4. Typography

-   Use the platform's default readable sans-serif font initially.
-   Screen title: 24--28 sp, semibold or bold.
-   Section heading: 19--22 sp, semibold.
-   Card title: 16--18 sp, semibold.
-   Body: 14--16 sp.
-   Metadata: 12--14 sp.
-   Avoid long blocks of uppercase text.
-   Support system font scaling without clipping.

## 5. Spacing, Shape, and Elevation

-   Base spacing unit: 4 dp.
-   Typical page horizontal padding: 20 dp.
-   Space between major sections: 24--28 dp.
-   Card inner padding: 14--20 dp.
-   Rounded cards: 16--24 dp radius.
-   Inputs: comfortable 12--16 dp internal padding.
-   Use subtle borders or low elevation rather than heavy shadows.
-   Primary touch targets should be at least 48 × 48 dp where practical.

## 6. Screen Specifications

### 6.1 Journal Home

**Purpose:** show the user's memories and provide a clear way to add
another.

**Layout** - App bar with GeoDiary title and short subtitle, "Your
memories, mapped." - Optional settings action. - Welcome panel with
landscape icon, headline "Every place has a story.", short supporting
copy, and a gentle green background. - "Your journal" section heading. -
Memory cards in a scrollable list. - Floating extended action button
labeled "Add memory". - Bottom navigation or another clear navigation
control for Journal and Map.

**Memory card** - Photo thumbnail or neutral placeholder. - Title. -
Visit date. - Address or "Location not added". - Optional overflow menu
for edit/delete.

**Empty state** - Photo-library or landscape icon. - Heading: "No
memories yet". - Supporting text: "Your favorite moments will appear
here." - Clear Add Memory action. - Avoid presenting the empty state as
an error.

**Interactions** - Tap card → Memory Details. - Tap Add memory → Create
Memory. - Tap Map navigation → Map View. - Search may be added above the
list in a later phase.

### 6.2 Create Memory

**Purpose:** let the user create or edit a memory without feeling
overwhelmed.

**Layout order** 1. App bar: "New memory" or "Edit memory". 2. Photo
selection panel with preview. 3. Two actions: "Take photo" and "Choose
from gallery". 4. Title input (required). 5. Description multiline input
(optional). 6. Visit date picker. 7. Location panel with pin icon,
address or coordinates, and "Add location" / "Update location". 8. Clear
Save Memory primary button. 9. Optional Cancel action.

**Behavior** - Keep form values when the user returns from a picker. -
Show inline validation for a blank title. - Show a progress indicator
during location retrieval or saving. - Explain when location is
unavailable and allow saving without it. - Do not imply that an address
was retrieved if reverse geocoding failed. - For edits, prefill all
fields and preserve the existing photo unless replaced.

### 6.3 Map View

**Purpose:** show where saved memories happened.

**Layout** - App bar titled "Memory Map". - OpenStreetMap map taking up
most of the screen. - Clearly visible map attribution. - Markers for
memories with valid coordinates. - Tap marker → a compact preview with
thumbnail, title, and date; tap preview → details. - A clear route back
to Journal and an Add Memory action where appropriate.

**States** - Geolocated entries: display markers. - No geolocated
entries: explain that memories with locations will appear here. - No
network / tile failure: show an unobtrusive warning and preserve other
app functionality. - Entries without coordinates remain available in
Journal.

**Map provider** Use `flutter_map` with a tile provider whose terms
permit the intended use. Respect attribution, caching, and request
policies. Do not assume public OpenStreetMap tiles provide unlimited
production capacity or unrestricted offline downloads.

### 6.4 Memory Details

**Purpose:** let the user revisit one memory.

**Layout** - Large photo area with appropriate cropping. - Title and
formatted visit date. - Location section with readable address and
optional coordinates. - Description with comfortable line spacing. - Map
preview or "View on map" action when coordinates exist. - Edit and
Delete actions in a predictable location.

**Behavior** - If the photo is missing, show a placeholder rather than a
broken image icon. - If address is missing but coordinates exist, show
coordinates and a retry or map action. - Confirm before permanent
deletion.

## 7. Navigation Model

Recommended simple bottom navigation: - **Journal** --- home/list
icon. - **Map** --- map icon.

The Add Memory flow is a prominent action rather than a primary
navigation destination. Memory Details opens from either a journal card
or a map marker. Keep navigation predictable and avoid deep nesting for
the MVP.

## 8. Interaction and Feedback

-   Use snackbars for brief success/error feedback.
-   Use inline field validation for form problems.
-   Use dialogs for destructive confirmation.
-   Use progress indicators for asynchronous operations.
-   Disable repeated Save taps while saving.
-   Make denied permissions recoverable and explain next steps.
-   Use empty states distinct from loading and error states.

## 9. Accessibility

-   Use semantic labels for icon-only buttons.
-   Ensure text and controls remain usable with system text scaling.
-   Check color contrast for text, icons, and buttons.
-   Do not use color alone to convey errors or selected states.
-   Use sufficiently large touch targets.
-   Keep focus order logical for screen readers.

## 10. Responsive Behavior

-   Optimize for portrait Android phones first.
-   Use scrollable forms and lists to avoid keyboard overflow.
-   On larger screens, allow wider cards or a two-pane detail layout as
    an enhancement.
-   Avoid fixed heights for text-heavy content.
-   Test small screens and landscape orientation.

## 11. Asset and Icon Guidance

-   Prefer Material Icons available in Flutter initially.
-   Use user-provided photos as the primary visual content.
-   Avoid shipping large decorative images for the first version.
-   Use consistent image aspect ratios for cards and a larger aspect
    ratio for detail photos.
-   Provide placeholders for missing photos.

## 12. Design Acceptance Checklist

-   [ ] Journal has a clear title, empty state, and Add Memory action.
-   [ ] Memory cards show photo, title, date, and location status.
-   [ ] Create Memory form is grouped logically and scrolls with the
    keyboard open.
-   [ ] Map displays attribution and has an empty/error state.
-   [ ] Details screen supports missing photo/address gracefully.
-   [ ] Loading, validation, success, and failure feedback are
    consistent.
-   [ ] Text scaling and touch targets are checked on a real device.
