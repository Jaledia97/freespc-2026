# Changelog

# Changelog

All notable changes to the FreeSPC project will be documented in this file.

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


