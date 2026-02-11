# Changelog

# Changelog

All notable changes to the FreeSPC project will be documented in this file.

## [0.0.1+25] - 2026-02-08 - Unit Number Support

### Added
- **Address Detail**: Added `Unit/Suite` field support for Bingo Halls located in plazas.
    - **Data Model**: Updated `BingoHallModel` with `unitNumber`.
    - **CMS**: Added "Unit/Suite" input field to Hall Profile Editor.
    - **Display**: Hall Profile "About" tab now displays full address including unit number.
    - **Control**: Added explicit "State" field to Hall Profile Editor for manual override.
- **Operating Hours**: Added comprehensive schedule management.
    - **CMS**: Manual entry for each day's Open/Close times.
    - **Logic**: Automatically formats blank close times as "to CLOSE".
    - **Display**: Shown prominently on the "About" tab.
- **CMS Optimization**: Refactored "Edit Hall Profile" screen to use collapsible sections for better organization and reduced scrolling.
- **Program Details**: Added ability to manage multiple bingo programs.
    - **Features**: Name, Multi-line Pricing/Details, and multi-day selection (Samsung-style).
    - **Timeframe**: Added Start/End Time for each program.
    - **Status**: Implemented "Smart Activation". Programs are active based on their schedule.
    - **Override**: Managers can force a program "Active" until a specific time using the checkbox.
    - **Display**: Added "PROGRAMS" tab to Hall Profile screen to showcase these details.
    - **UI Polish**: Improved text contrast on dark backgrounds for "About" and "Programs" tabs.

## [0.0.1+24] - 2026-02-06 - Social Photo Gallery (Phase 26)

### Added
- **Social Gallery**: Complete ecosystem for uploading, viewing, and moderating photos.
    - **Upload Workflow**: Users can upload photos with captions and tags (Halls & Friends).
    - **Tagging**: "Personal" uploads appear instantly. "Hall" tags require approval. Tagging UI includes search delegates and smart chips.
    - **Display**: Instagram-style 3-column grid for Halls, "My Gallery" for users.
    - **Lightbox**: Full-screen photo viewer with pinch-to-zoom.
- **Moderation Tools**: 
    - **Approval Flow**: Hall Managers can Approve/Decline tagged photos.
    - **Safety**: "Report" button for users, auto-hiding content after 5 reports. Strict ToS warning on upload.
    - **Delete**: Owners can delete their own photos.
- **Smart UI**: 
    - **Personal Badge**: Untagged photos get a "PERSONAL" badge on the user profile.
    - **Context Awareness**: "Tag Hall" button hides when uploading directly from a Hall Profile.

### Changed
- **Profile Navigation**: Added "Gallery" pill button to Hall Profile header.
- **User Profile**: Added "My Photos" section with status indicators (Live/Pending/Declined).

## [0.0.1+23] - 2026-02-02 - Smart Recurrence & UI Polish (Phase 21)

### Added
- **Smart Rotation**: recurring specials (Daily, Weekly, Monthly) now technically "rotate" in the feed, projecting their start/end times to the next logical date automatically.
- **Calendar Integration**: "Add to Calendar" button is now fully functional on Android & iOS, with proper permission handling.
- **Smart Dates**: Special Cards now display friendly recurrence text (e.g., "Every Friday at 7 PM") instead of raw timestamps.

### Changed
- **Midnight Rule**: Specials created without an explicit End Time now default to ending at 11:59 PM of the start day, preventing open-ended events.
- **Navigation**: Removed the redundant "Map View" quick action button, consolidating map access to the "Find Hall" button.



### Added
- **Manager Mode**: Secure "Admin Mode" for venue operators, protected by a PIN Gateway (`4836`).
- **Dashboard Hub**: Centralized dashboard for accessing management modules (Profile, Specials, Tournaments, Raffles).
- **Profile CMS**: Operators can now edit their Hall's Name, Bio, Phone, Website, and Logo directly from the app.
- **Specials CMS**: Full CRUD (Create, Read, Update, Delete) interface for managing Special Events with Date/Time pickers.
- **Raffle Utility**: A compliance-focused tool for running manual drawings:
    - **Roll Call**: Generates a 4-digit code for users to join.
    - **Session Logic**: Lists participants, locks entry, distributes tickets, and draws a random winner.
- **Super-Admin Tools**: Added "View As" mode in Profile Settings to toggle between roles (`Super Admin`, `Owner`, `Worker`, `Player`) for testing permissions.

### Changed
- **Permissions**: Updated `ProfileScreen` to show "Switch to Manager Mode" button for `owner`, `manager` `admin`, and `super-admin`.
- **Data Models**: Updated `BingoHallModel` to include `phone`, `websiteUrl`, and `description` fields.
- **Seeding**: Updated `seedMaryEstherEnv` to set the user as `super-admin` for full access to all tools.

### Fixed
- **Null Safety**: Resolved potential crashes in `ManageSpecialsScreen` regarding nullable start times.

## [0.0.1+22] - 2026-01-30 - Recurring Specials & Robust UI (Phase 21)

### Added
- **Recurring Specials**: Added "Recurrence" dropdown to Edit Special screen (`Daily`, `Weekly`, `Monthly`), enabling automated schedule logic.
- **End Time Option**: Admins can now optionally set an End Time for specials via a checkbox toggle.
- **Push Notification Trigger**: "Send Push Notification" checkbox added to the edit/create flow, guarded by a "Notification Fatigue" warning dialog to prevent spam.
- **Image Integration**: Specials creation now supports uploading directly from Gallery/Camera or selecting from the Hall's Asset Library.

### Changed
- **Date Picker UI**: Replaced standard `TextFormField` date inputs with custom `InkWell` + `InputDecorator` buttons to ensure 100% touch responsiveness and prevent keyboard conflicts.
- **Draft Safety**: Confirmed that all Special edits remain in a local "Draft" state until the **Save** button is explicitly pressed.

### Fixed
- **Runtime Crash**: Resolved a "Dependency on Inherited Widget" crash caused by accessing `context` inside `initState` for date formatting.
- **Date Range**: Widened the Date Picker range (2020-2030) to facilitate backdating or editing past specials without assertion errors.

## [0.0.1+21] - 2026-01-29 - Navigation Improvements & Biometrics (Phase 23 & 24)

### Added
- **Biometric Security**: Integrated FaceID and Fingerprint authentication (`local_auth`) for accessing the Hall Manager Dashboard.
- **Biometric Fallback**: Standard PIN (`4836`) remains available as a fallback method.
- **Deep Linking**: Implemented `initialTabIndex` on `HallProfileScreen` to allow direct navigation to specific tabs (e.g., Raffles).

### Changed
- **Wallet Navigation**: Tapping a raffle ticket in the Wallet now navigates directly to the "Active Raffles" tab of the specific Hall Profile.
- **Configuration**: Updated `AndroidManifest.xml` and `Info.plist` to include native biometric permission declarations.

### Fixed
- **Build Errors**: Resolved `local_auth` API version mismatch by using standard parameter signatures.
- **Orientation**: Locked application to Portrait Mode for consistent experience across devices.

## [0.0.1+19] - 2026-01-28 - Wallet System & Bonus Logic (Phase 19)

### Added
- **Wallet System**: Comprehensive wallet UI displaying Hall Membership Cards, Raffle Ticket Stubs, and Active Tournaments.
- **Hall Memberships**: Logic to track balances per hall. Cards are automatically created when "Following" a hall.
- **Follow Bonus**: Halls can now offer a point bonus (e.g., +50 pts) instantly upon following. "Westside Winners" configured with 50pt bonus for testing.
- **QR Integration**: Scanning a worker's QR code now credits points specifically to that hall's membership card (verifying "Following" status first).
- **Mock Data Seeding**: "Seed Wallet Data" and updated "Seed Specials" to test wallet features and bonuses.

### Changed
- **Map Refinement**: Increased zoom limit to support full 100-mile radius. Removed blue radius circle overlay.
- **Image Stability**: Switched from dynamic LoremFlickr to static Unsplash images for consistent UI testing.
- **Search Logic**: Map zoom level and radius slider are now bidirectionally synchronized.
- **Dependencies**: Added `intl` for currency formatting.

### Fixed
- **GlassContainer**: Fixed sizing constraint issues.
- **Data Models**: Resolved `freezed` generation errors by enforcing `abstract class` definitions.

## [2026-01-28] - Map Refinement & Persistent Images (Phase 17.9 & 18.5)

### Map Search & Logic
- **Advanced Filtering**: Implemented "Visible Region" filtering. "Halls Nearby" list now updates dynamically to show strictly what is visible in the map viewport.
- **Bi-Directional Sync**: Radius Slider and Map Zoom are now synchronized. Zooming the map updates the slider, and sliding the radius smooth-zooms the map.
- **Constraints**: Enforced a `minZoom` preference (approx 100mi radius) to prevent massive, unperformant queries.
- **UI Clean Up**: Removed visual radius circle overlay for a cleaner, less obstructed map view.

### Infrastructure
- **Image Persistence**: Updated `HallRepository` to use static, high-quality Unsplash URLs for seeded Specials, resolving the issue of randomly changing images.
- **Storage**: Integrated Firebase Storage for profile and banner image uploads.
- **Settings**: Relocated "Logout" functionality to a new clean Settings modal in the Profile Screen.

---

## [2026-01-26] - Scalable Geohashing Map, Profile Logic & Auth Updates (Phase 17.5 & 18)

### Scalability & Infrastructure
- **Geohashing**: Migrated Hall Search to use `geoflutterfire_plus` for server-side geohashing, enabling infinite scalability (suppots 10k+ locations without client overload).
- **Optimization**: Implemented "Debounce" logic (100ms throttle) on map interactions to prevent excessive Firestore reads and reduce billing costs.
- **Data Integrity**: Updated Admin Seed tools (`seedSpecials`, `createMockHall`) to automatically generate valid `geoHash` fields for all mock data.

### Map Features
- **Smart Search**: Added a `HallSearchScreen` with Google Maps, Address Geocoding (City/Zip search), and a Radius Slider (1-100mi).
- **Streaming**: "Live Crosshair" logic streams only visible halls in the current viewport/radius using `RxDart`.

### User Profile (Phase 18)
- **Service**: Added `updateUserProfile` to `AuthService` (First/Last Name, Username, Bio).
- **UI Refresh**: Implemented a complete Profile Screen redesign featuring:
    - **Header**: Avatar using Initials + Edit Profile Dialog.
    - **Actions**: "My Tournaments" & "My Raffles" quick access buttons.
    - **Bio Section**: Dedicated "About Me" area with a clean divider.
    - **Menu**: Collapsible "Developer Options" for admin seeding tools.

### Authentication
- **Methods**: Integrated `sign_in_with_apple` and `flutter_facebook_auth` dependencies.
- **Security**: Hardened `AuthWrapper` to handle user profile creation/routing more robustly.

---

## [2026-01-24] - Visual Polish, Smart Cards & Upcoming Games (Phase 10-17)

### UI & UX Redesign
- **Smart Cards**: Introduced a unified `SpecialCard` widget with stateful expansion, embedded action buttons (Call, Navigate, Calendar), and tag display.
- **Interactivity**: Added `url_launcher` for phone calls/navigation and `add_2_calendar` for one-tap event saving.
- **Directory**: "Upcoming Games" screen redesigned with a "Spotify-style" category grid ("Session", "Pulltabs", "Progressives") for easier browsing.
- **Accessibility**: Improved color contrast ratios for category text and action buttons.

### Geo-Fencing
- **Feed Logic**: Home Screen "Specials Feed" now limits results to a **75-mile radius** from the user's location, sorted by "Happening Now".

---

## [2026-01-23] - Security, Scanner & Geolocation (Phase 7-9)

### Security & Roles
- **RBAC**: Implemented Role-Based Access Control (`worker`, `owner`, `admin`) secured by `firestore.rules`.
- **Public Workers**: Separated Verified Worker Identity into a public `public_workers` collection to protect PII during scans.
- **Scanner Audit**: Updated `TransactionService` to record `authorizedByWorkerId` on every point transaction for full auditability.
- **Strict Verification**: `ScanActionDialog` now strictly verifies worker QR tokens against the public registry before processing points.

### Geolocation
- **GPS**: Added `geolocator` dependency and `LocationService`.
- **Proximity**: Updated Home Screen to display real-time distance to halls (e.g., "3.2 mi") sorted by proximity.
- **Battery**: Optimized GPS tracking to use `LocationAccuracy.balanced` (100m filter) to preserve user battery life.

---

## [2026-01-22] - Foundation & Authentication (Phase 1-6)

### Core Infrastructure
- **Setup**: Initialized project structure, dependencies (`riverpod`, `freezed`, `json_serializable`), and Firebase configuration.
- **Database**: Defined core data models: `UserModel`, `BingoHallModel`, `TransactionModel`.
- **Theme**: Implemented `AppTheme` with custom color palette and typography.

### Features
- **Authentication**: Built `AuthService` with Google Sign-In and Email/Password flow.
- **Scan-to-Earn**: Created the core "Game Loop" where users scan a QR code at a kiosk to earn points instantly.
- **Wallet**: Developed `WalletScreen` with real-time point balance updates via Firestore streams.



## Future Roadmap - Beacon Integration Revisit
*Items to revisit once hardware Beacons are deployed:*
- **Raffle System**: Current logic relies on manual "Roll Call" codes. Beacon proximity can automate checking in for raffles without codes.
- **Auto-Checkin**: Move from scanning QR codes to passive point earning upon entry.
